import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text-style.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/widgets/booking_details_parts.dart';
import '../../../core/widgets/collapsible_details_layout.dart';
import '../../../data/api/peak_api.dart';
import '../../../routes/app_routes.dart';
import '../booking_text.dart';
import '../controllers/booking_detail_controller.dart';
import '../widgets/action_dialogs.dart';
import '../widgets/review_dialog.dart';

/// One booking, any service, customer or provider (`Routes.bookingDetails`).
///
/// Arguments: `{'bookingId': id}` (legacy `{'id': id}` or a bare id string
/// also work), optionally `'booking': Booking` to draw at once.
class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({super.key});

  /// Reads the booking id from route arguments in any of the old shapes.
  static String bookingIdFrom(dynamic args) {
    if (args is String) return args.trim();
    if (args is Map) {
      final v = args['bookingId'] ?? args['id'] ?? args['_id'];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
      final b = args['booking'];
      if (b is Booking) return b.id;
    }
    if (args is Booking) return args.id;
    return '';
  }

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late final String _tag;
  late final BookingDetailController c;
  AppLifecycleListener? _lifecycle;

  /// Opened from "Leave a review": show the review once the booking loads.
  bool _openReview = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _openReview = args is Map && args['openReview'] == true;
    final id = BookingDetailsScreen.bookingIdFrom(args);
    final initial = args is Map && args['booking'] is Booking ? args['booking'] as Booking : null;
    final isProvider = Get.isRegistered<AuthController>() &&
        (Get.find<AuthController>().role ?? '').toLowerCase() == 'provider';
    // The same booking can be opened twice (notification → details → …).
    _tag = 'booking-$id-${identityHashCode(this)}';
    c = Get.put(
      BookingDetailController(bookingId: id, initial: initial, viewerIsProviderHint: isProvider),
      tag: _tag,
    );
    _lifecycle = AppLifecycleListener(onResume: c.refreshQuietly);
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    Get.delete<BookingDetailController>(tag: _tag);
    super.dispose();
  }

  // ───────────────────────────── actions ─────────────────────────────

  void _show(ActionOutcome o) {
    if (o.silent || o.message.isEmpty || !mounted) return;
    showAppToast(
      type: o.ok ? ToastType.success : ToastType.error,
      title: o.ok ? 'Done' : "Couldn't do that",
      message: o.message,
    );
  }

  String _noun(Booking b) => b.kind == ServiceKind.transport ? 'vehicle' : 'equipment';

  Future<void> _onAction(BookingAction a) async {
    final b = c.booking;
    if (b == null || c.isBusy) return;
    switch (a) {
      case BookingAction.approve:
        final ok = await confirmBookingAction(context,
            title: 'Accept this booking?',
            message: 'The guest is notified that the booking is confirmed.',
            confirmLabel: 'Accept',
            icon: Icons.check_circle_outline_rounded);
        if (ok != null) _show(await c.run(a));
      case BookingAction.reject:
        // After accepting, "reject" means cancelling the booking.
        final accepted = b.status != BookingStatus.pending;
        final ok = await confirmBookingAction(context,
            title: accepted ? 'Cancel this booking?' : 'Reject this booking?',
            message: 'The guest gets a full refund (${euro(b.total)}) to their card. This can’t be undone.',
            confirmLabel: accepted ? 'Cancel booking' : 'Reject',
            cancelLabel: 'Keep it',
            icon: Icons.event_busy_rounded,
            destructive: true,
            askReason: true,
            reasonHint: 'Reason for the guest (optional)');
        if (ok != null) _show(await c.run(a, reason: ok.reason));
      case BookingAction.handOver:
        final ok = await confirmBookingAction(context,
            title: 'Hand over the ${_noun(b)}?',
            message: 'Confirm the guest has collected the ${_noun(b)}. '
                'Return is due ${bookingDateTime(b.schedule.endAt)}.',
            confirmLabel: 'Hand over',
            icon: Icons.handshake_outlined);
        if (ok != null) _show(await c.run(a));
      case BookingAction.markReturned:
        final fee = b.isOverdue ? b.timer!.lateFee : 0;
        final ok = await confirmBookingAction(context,
            title: 'Mark as returned?',
            message: 'Returns more than 15 minutes late are charged for every started hour at the '
                'listing’s late rate, up to the booking price.'
                '${fee > 0 ? '\n\nLate fee so far: ${euro(fee)}.' : ''}',
            confirmLabel: 'Mark returned',
            icon: Icons.assignment_return_outlined);
        if (ok != null) _show(await c.run(a));
      case BookingAction.complete:
        final ok = await confirmBookingAction(context,
            title: 'Mark as done?',
            message: 'Confirms the service took place. Your earnings are released.',
            confirmLabel: 'Mark done',
            icon: Icons.task_alt_rounded);
        if (ok != null) _show(await c.run(a));
      case BookingAction.cancel:
        final p = cancelRefundPreview(b, now: c.now());
        final rule = p.percent == 100
            ? (b.status == BookingStatus.pending
                ? 'The provider hasn’t accepted yet, so you get a full refund.'
                : 'It’s more than 24 hours before the start, so you get a full refund.')
            : 'It’s less than 24 hours before the start, so 90% is refunded and the provider keeps 10%.';
        final ok = await confirmBookingAction(context,
            title: 'Cancel this booking?',
            message: '$rule\n\nRefund to your card: about ${euro(p.amount)} (${p.percent}%).',
            confirmLabel: 'Cancel booking',
            cancelLabel: 'Keep it',
            icon: Icons.event_busy_rounded,
            destructive: true,
            askReason: true);
        if (ok != null) _show(await c.run(a, reason: ok.reason));
      case BookingAction.payLateFee:
        _show(await c.payLateFee());
      case BookingAction.review:
        final r = await ReviewDialog.show(context, title: b.listing.title, onSubmit: (rating, comment) async {
          final o = await c.submitReview(rating, comment);
          return (ok: o.ok, message: o.message);
        });
        if (r != null && mounted) {
          showAppToast(
            type: r.ok ? ToastType.success : ToastType.info,
            title: r.ok ? 'Thank you' : 'Already reviewed',
            message: r.message,
          );
        }
    }
  }

  // ───────────────────────────── build ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailController>(
      tag: _tag,
      builder: (c) {
        final b = c.booking;
        if (_openReview && b != null && !c.isLoading) {
          _openReview = false;
          if (c.shows(BookingAction.review)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _onAction(BookingAction.review);
            });
          }
        }
        if (b == null) {
          return c.errorMessage != null
              ? BookingDetailsState.error(title: 'Booking', message: c.errorMessage!, onRetry: c.load)
              : const BookingDetailsState.loading(title: 'Booking');
        }
        final primary = c.primaryActions;
        final main = primary.isEmpty ? null : primary.first;
        return CollapsibleDetailsLayout(
          imageUrl: b.listing.thumbnail ?? '',
          title: b.listing.title,
          onBack: Get.back,
          bottomBar: BookingTotalBar(
            total: euro(b.total),
            label: c.isProviderView ? 'Booking total' : 'Total paid',
            actionLabel: main == null ? null : _label(main, b),
            actionIcon: main == null ? null : _icon(main),
            loading: main != null && c.busyAction == main,
            loadingLabel: 'Please wait…',
            onAction: main == null || c.isBusy ? null : () => _onAction(main),
          ),
          children: [
            BookingDetailsHeader(
              title: b.listing.title,
              status: b.status,
              overdue: b.isOverdue,
              forProvider: c.isProviderView,
              subtitle: [b.kind.label, if (b.listing.serviceArea != null) b.listing.serviceArea!].join(' · '),
            ),
            ..._notices(b, c),
            for (final a in primary.skip(1)) _InlineAction(label: _label(a, b), icon: _icon(a), busy: c.busyAction == a, enabled: !c.isBusy, onTap: () => _onAction(a)),
            ..._party(b, c),
            ..._schedule(b),
            ..._items(b),
            ..._contact(b, c),
            ..._payment(b, c),
            ..._timeline(b),
            if (c.isProviderView && b.dispute != null) ...[
              const BookingSectionTitle('Dispute'),
              BookingInfoCard(rows: [
                BookingInfoRow(Icons.gavel_rounded, 'Status', b.dispute!.status),
                BookingInfoRow(Icons.payments_outlined, 'Amount', b.dispute!.amount == null ? null : euro(b.dispute!.amount)),
                BookingInfoRow(Icons.notes_rounded, 'Reason', b.dispute!.reason),
              ]),
            ],
            for (final a in c.secondaryActions)
              _DangerAction(label: _label(a, b), busy: c.busyAction == a, enabled: !c.isBusy, onTap: () => _onAction(a)),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  String _label(BookingAction a, Booking b) => switch (a) {
        BookingAction.approve => 'Accept',
        BookingAction.reject => b.status == BookingStatus.pending ? 'Reject booking' : 'Cancel booking',
        BookingAction.handOver => 'Hand over',
        BookingAction.markReturned => 'Mark as returned',
        BookingAction.complete => 'Mark as done',
        BookingAction.cancel => 'Cancel booking',
        BookingAction.payLateFee => b.lateFee != null ? 'Pay late fee ${euro(b.lateFee!.amount)}' : 'Pay late fee',
        BookingAction.review => 'Write a review',
      };

  IconData _icon(BookingAction a) => switch (a) {
        BookingAction.approve => Icons.check_rounded,
        BookingAction.reject || BookingAction.cancel => Icons.close_rounded,
        BookingAction.handOver => Icons.handshake_outlined,
        BookingAction.markReturned => Icons.assignment_return_outlined,
        BookingAction.complete => Icons.task_alt_rounded,
        BookingAction.payLateFee => Icons.credit_card_rounded,
        BookingAction.review => Icons.star_rounded,
      };

  // ───────────────────────────── sections ─────────────────────────────

  List<Widget> _notices(Booking b, BookingDetailController c) {
    final provider = c.isProviderView;
    final out = <Widget>[];
    final t = b.status.isOpen ? timerText(b.timer, now: c.now(), forProvider: provider) : null;
    if (t != null) {
      out.add(BookingNotice(
        icon: b.isOverdue ? Icons.timer_off_outlined : Icons.timer_outlined,
        text: t,
        color: b.isOverdue ? AppColors.error : AppColors.primary_1,
      ));
    }
    if (b.status == BookingStatus.pending) {
      final by = b.approvalDeadline == null ? null : bookingDateTime(b.approvalDeadline, kind: b.kind);
      out.add(BookingNotice(
        icon: Icons.hourglass_top_rounded,
        text: provider
            ? 'Accept or reject this request${by == null ? '' : ' by $by'}. Unanswered requests are cancelled and refunded automatically.'
            : 'Waiting for the provider to accept${by == null ? '' : '. They must answer by $by'}; otherwise you’re refunded in full.',
      ));
    }
    if (b.lateFee?.isDue == true) {
      out.add(BookingNotice(
        icon: Icons.more_time_rounded,
        color: AppColors.error,
        text: provider
            ? 'The guest owes a late fee of ${euro(b.lateFee!.amount)}.'
            : 'You returned late. Late fee due: ${euro(b.lateFee!.amount)}. New bookings are blocked until it is paid.',
      ));
    }
    if (b.noShow) {
      out.add(BookingNotice(
        icon: Icons.person_off_outlined,
        text: provider
            ? 'The guest never picked this up. The booking was closed as a no-show.'
            : 'This rental was never picked up, so it was closed as a no-show (not refunded).',
      ));
    }
    final cx = b.cancellation;
    if (b.status == BookingStatus.cancelled) {
      final parts = <String>[
        cx?.describe(viewerIsProvider: provider) ?? 'This booking was cancelled.',
        if (cx?.reason != null) 'Reason: ${cx!.reason}',
        if ((cx?.refundAmount ?? 0) > 0)
          provider ? 'Refunded to the guest: ${euro(cx!.refundAmount)}' : 'Refunded to your card: ${euro(cx!.refundAmount)}',
      ];
      out.add(BookingNotice(icon: Icons.event_busy_rounded, color: AppColors.error, text: parts.join('\n')));
    }
    return out;
  }

  List<Widget> _party(Booking b, BookingDetailController c) {
    final p = c.isProviderView ? b.customer : b.provider;
    if (p == null) return const [];
    return [
      BookingSectionTitle(c.isProviderView ? 'Guest' : 'Your provider'),
      _PartyCard(person: p, caption: c.isProviderView ? 'Booked by' : 'Hosted by'),
    ];
  }

  List<Widget> _schedule(Booking b) {
    final s = b.schedule;
    final rows = <BookingInfoRow>[];
    switch (b.kind) {
      case ServiceKind.skiHire:
      case ServiceKind.transport:
        // Same words as checkout: a trip starts and ends, a rental is picked up and returned.
        final trip = b.kind == ServiceKind.transport;
        rows
          ..add(BookingInfoRow(Icons.login_rounded, trip ? 'Start' : 'Pick-up', bookingDateTime(s.startAt)))
          ..add(BookingInfoRow(Icons.logout_rounded, trip ? 'End' : 'Return', bookingDateTime(s.endAt)));
        if (b.kind == ServiceKind.transport && b.people != null) {
          rows.add(BookingInfoRow(Icons.people_outline_rounded, 'Passengers', '${b.people}'));
        }
      case ServiceKind.massage:
        rows
          ..add(BookingInfoRow(Icons.calendar_today_rounded, 'Date', bookingDay(s.date)))
          ..add(BookingInfoRow(Icons.schedule_rounded, 'Time', s.time))
          ..add(BookingInfoRow(Icons.hourglass_bottom_rounded, 'Duration', s.duration));
        if (b.people != null) rows.add(BookingInfoRow(Icons.people_outline_rounded, 'Persons', '${b.people}'));
      case ServiceKind.restaurant:
        rows
          ..add(BookingInfoRow(Icons.calendar_today_rounded, 'Date', bookingDay(s.date)))
          ..add(BookingInfoRow(Icons.schedule_rounded, 'Time slot', s.slot?.label));
        if (b.itemCount > 0) rows.add(BookingInfoRow(Icons.event_seat_outlined, 'Seats', '${b.itemCount}'));
      case ServiceKind.skiPass:
        rows
          ..add(BookingInfoRow(Icons.calendar_today_rounded, 'Valid on', bookingDay(s.date)))
          ..add(BookingInfoRow(Icons.people_outline_rounded, 'Persons', '${b.people ?? 1}'));
        if (b.ticketNumber != null) {
          rows.add(BookingInfoRow(Icons.confirmation_number_outlined, 'Ticket', b.ticketNumber, emphasize: true));
        }
    }
    rows.add(BookingInfoRow(Icons.tag_rounded, 'Booking ref', bookingRef(b.id)));
    return [
      BookingSectionTitle(switch (b.kind) {
        ServiceKind.transport => 'Trip',
        ServiceKind.skiHire => 'Rental period',
        _ => 'When',
      }),
      BookingInfoCard(rows: rows),
      if (b.kind == ServiceKind.skiPass && b.ticketNumber != null && b.status != BookingStatus.cancelled)
        _InlineAction(
          label: 'View ticket',
          icon: Icons.confirmation_number_outlined,
          enabled: true,
          onTap: () => Get.toNamed(Routes.ticket, arguments: {'booking': b, 'bookingId': b.id, 'fromBooking': true}),
        ),
    ];
  }

  List<Widget> _items(Booking b) {
    if (b.items.isEmpty) return const [];
    final restaurant = b.kind == ServiceKind.restaurant;
    return [
      BookingSectionTitle(restaurant ? 'Seats (${b.itemCount})' : 'Equipment (${b.itemCount})'),
      for (final i in b.items) ...[
        BookingItemTile(
          title: restaurant ? '${i.name} seat' : i.name,
          imageUrl: i.photo,
          subtitle: '${euro(i.price)} each',
          quantity: i.quantity,
          fallbackIcon: restaurant ? Icons.event_seat_outlined : Icons.downhill_skiing_rounded,
        ),
        const SizedBox(height: 8),
      ],
    ];
  }

  List<Widget> _contact(Booking b, BookingDetailController c) {
    final x = b.contact;
    if (x == null || x.isEmpty) return const [];
    return [
      BookingSectionTitle(c.isProviderView ? 'Guest contact' : 'Your contact details'),
      BookingInfoCard(rows: [
        if (x.phoneNumber != null) BookingInfoRow(Icons.phone_outlined, 'Phone', x.phoneNumber),
        if (x.address != null)
          BookingInfoRow(Icons.home_outlined, b.kind == ServiceKind.transport ? 'Pick-up address' : 'Address', x.address),
        if (x.destination != null) BookingInfoRow(Icons.flag_outlined, 'Destination', x.destination),
      ]),
    ];
  }

  List<Widget> _payment(Booking b, BookingDetailController c) {
    final fee = b.lateFee;
    final e = b.earning;
    return [
      const BookingSectionTitle('Payment'),
      BookingInfoCard(rows: [
        BookingInfoRow(Icons.payments_outlined, c.isProviderView ? 'Guest paid' : 'Total paid', euro(b.total), emphasize: true),
        if (b.refundedAmount > 0)
          BookingInfoRow(Icons.undo_rounded, 'Refunded', euro(b.refundedAmount), valueColor: AppColors.success),
        if (fee != null && fee.amount > 0)
          BookingInfoRow(
            Icons.more_time_rounded,
            'Late fee (${_hours(fee.hours)})',
            '${euro(fee.amount)} · ${fee.status == LateFeeStatus.paid ? 'Paid' : 'Due'}',
            valueColor: fee.status == LateFeeStatus.paid ? AppColors.success : AppColors.error,
          ),
        if (e != null) ...[
          // After a partial refund the backend still sends the full price as
          // `gross`; show what the provider kept so the rows add up.
          if (b.refundedAmount > 0)
            BookingInfoRow(
              Icons.receipt_long_outlined,
              'Kept after refund',
              euro(e.platformFee != null && e.net != null ? e.platformFee! + e.net! : e.gross - b.refundedAmount),
            )
          else
            BookingInfoRow(Icons.receipt_long_outlined, 'Gross', euro(e.gross)),
          // A restaurant's service fee goes to the platform in full; the
          // commission is taken from the rest.
          if (e.splitsServiceFee) ...[
            BookingInfoRow(Icons.room_service_outlined, 'Service fee (platform)', euro(e.serviceFee)),
            BookingInfoRow(Icons.percent_rounded, 'Commission', e.commission == null ? 'At completion' : euro(e.commission)),
          ] else
            BookingInfoRow(Icons.percent_rounded, 'Platform fee', e.platformFee == null ? 'At completion' : euro(e.platformFee)),
          BookingInfoRow(Icons.account_balance_wallet_outlined, 'Your earning', e.net == null ? 'At completion' : euro(e.net), emphasize: true),
          if (e.lateFee?.net != null)
            BookingInfoRow(
              Icons.more_time_rounded,
              'Late fee earning',
              '${euro(e.lateFee!.net)}${e.lateFee!.status == EarningStatus.paid ? '' : ' · when paid'}',
              valueColor: e.lateFee!.status == EarningStatus.paid ? AppColors.success : null,
            ),
          BookingInfoRow(Icons.info_outline_rounded, 'Payout', switch (e.status) {
            EarningStatus.pending => 'Pending (paid when completed)',
            EarningStatus.paid => 'Paid to your wallet',
            EarningStatus.none => 'None',
            EarningStatus.unknown => null,
          }),
        ],
        BookingInfoRow(Icons.event_note_outlined, 'Booked on', bookingDateTime(b.timeline?.bookedAt ?? b.createdAt, kind: b.kind)),
      ]),
    ];
  }

  String _hours(num h) => h == 1 ? '1 h' : '${NumberFormat('0.#').format(h)} h';

  List<Widget> _timeline(Booking b) {
    final t = b.timeline;
    if (t == null) return const [];
    final rows = <BookingInfoRow>[
      // Ski passes are confirmed instantly; nobody "accepts" them.
      if (t.approvedAt != null)
        BookingInfoRow(Icons.check_circle_outline_rounded, b.kind == ServiceKind.skiPass ? 'Confirmed' : 'Accepted',bookingDateTime(t.approvedAt, kind: b.kind)),
      if (t.handedOverAt != null) BookingInfoRow(Icons.handshake_outlined, 'Handed over', bookingDateTime(t.handedOverAt, kind: b.kind)),
      if (t.returnedAt != null) BookingInfoRow(Icons.assignment_return_outlined, 'Returned', bookingDateTime(t.returnedAt, kind: b.kind)),
      if (t.completedAt != null) BookingInfoRow(Icons.task_alt_rounded, 'Completed', bookingDateTime(t.completedAt, kind: b.kind)),
      if (t.cancelledAt != null) BookingInfoRow(Icons.event_busy_rounded, 'Cancelled', bookingDateTime(t.cancelledAt, kind: b.kind)),
    ];
    if (rows.isEmpty) return const [];
    return [const BookingSectionTitle('Timeline'), BookingInfoCard(rows: rows)];
  }
}

// ───────────────────────────── small widgets ─────────────────────────────

class _PartyCard extends StatelessWidget {
  const _PartyCard({required this.person, required this.caption});

  final PersonRef person;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final photo = person.photo;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.shimmerBase,
            backgroundImage: photo != null
                ? CachedNetworkImageProvider(photo)
                : const AssetImage('assets/images/profile_img.png') as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(caption, style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
                const SizedBox(height: 2),
                Text(person.name ?? (caption == 'Booked by' ? 'Guest' : 'Provider'), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyle.sub_h2_medium_16()),
                if (person.email != null)
                  Text(person.email!, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyle.p_regular_12(color: AppColors.textTertiary)),
              ],
            ),
          ),
          if (person.id.isNotEmpty)
            _CircleButton(
              icon: Icons.chat_bubble_outline_rounded,
              tooltip: 'Message',
              onTap: () => Get.toNamed(Routes.messagingScreen, arguments: {
                'otherUserId': person.id,
                'chatId': '',
                'otherUserName': person.name ?? (caption == 'Booked by' ? 'Guest' : 'Provider'),
                'otherUserProfileUrl': person.photo ?? '',
                'isOnline': false,
              }),
            ),
          if (person.phone != null) ...[
            const SizedBox(width: 8),
            _CircleButton(icon: Icons.call_outlined, tooltip: 'Call', filled: true, onTap: () => makePhoneCall(person.phone)),
          ],
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.tooltip, required this.onTap, this.filled = false});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? AppColors.primary_1 : Colors.white,
        shape: CircleBorder(side: filled ? BorderSide.none : const BorderSide(color: AppColors.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: filled ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Secondary positive action inside the sheet.
class _InlineAction extends StatelessWidget {
  const _InlineAction({required this.label, required this.icon, required this.onTap, required this.enabled, this.busy = false});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: enabled ? onTap : null,
          icon: busy
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary_1))
              : Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF9A7A12),
            side: const BorderSide(color: AppColors.primary_1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

/// Reject / cancel: red outlined button at the end of the sheet.
class _DangerAction extends StatelessWidget {
  const _DangerAction({required this.label, required this.onTap, required this.enabled, this.busy = false});

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: enabled ? onTap : null,
          icon: busy
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error))
              : const Icon(Icons.close_rounded, size: 18),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
