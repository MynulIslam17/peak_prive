import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/utils/app_toast.dart';
import 'package:harry_service_app/app/core/widgets/app_form_field.dart';
import 'package:harry_service_app/app/modules/auth/controllers/user_singup_controller.dart';
import 'package:harry_service_app/app/modules/auth/models/signup_request_model.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text-style.dart';
import '../../../routes/app_routes.dart';
import '../widgets/auth_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String phoneNumber = '';

  bool _isAgree = false;

  final nameTEController = TextEditingController();
  final emailTEController = TextEditingController();
  final passwordTEController = TextEditingController();
  final confirmTEController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  /// Customer accounts use the API role `User`. Providers pick a service.
  bool _asProvider = false;
  String? _selectedService;

  /// Shown once a submit was tried, for the checks outside the form fields.
  bool _showErrors = false;

  static const _services = [
    ('Ski Pass', Icons.confirmation_number_outlined),
    ('Ski Hire', Icons.downhill_skiing_rounded),
    ('Transport', Icons.airport_shuttle_outlined),
    ('Restaurant Booking', Icons.restaurant_rounded),
    ('Massage', Icons.spa_outlined),
  ];

  final signUpController = Get.find<UserSignupController>();

  @override
  void dispose() {
    nameTEController.dispose();
    emailTEController.dispose();
    passwordTEController.dispose();
    confirmTEController.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color, [double width = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: AppTextStyle.p_medium_12(color: AppColors.textSecondary)),
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthScaffold(
        title: 'Create your account',
        subtitle: 'Book ski passes, rentals, transfers, tables and massages in one place.',
        footer: AuthSwitchLine(question: 'Already have an account?', action: 'Sign in', onTap: () => Get.back()),
        children: [
          _label('I am a'),
          _RoleSelector(provider: _asProvider, onChanged: (provider) => setState(() => _asProvider = provider)),
          // Providers choose their service right under the tabs.
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _asProvider ? _servicePicker() : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 18),
          AppFormField(
            label: 'Full name',
            hint: 'Your name',
            controller: nameTEController,
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: (value) => (value == null || value.trim().isEmpty) ? "Name can't be empty" : null,
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'Email',
            hint: 'you@example.com',
            controller: emailTEController,
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return "Email can't be empty";
              if (!EmailValidator.validate(v)) return 'Not a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _label('Phone number'),
          IntlPhoneField(
            initialCountryCode: 'CA',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: AppTextStyle.sub_h3_regular_14(color: AppColors.textPrimary),
            dropdownTextStyle: AppTextStyle.sub_h3_regular_14(color: AppColors.textPrimary),
            flagsButtonPadding: const EdgeInsets.only(left: 10),
            decoration: InputDecoration(
              hintText: 'Phone number',
              hintStyle: AppTextStyle.sub_h3_regular_14(color: AppColors.textDisabled),
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: _border(AppColors.border),
              enabledBorder: _border(AppColors.border),
              focusedBorder: _border(AppColors.primary_1, 1.4),
              errorBorder: _border(AppColors.error),
              focusedErrorBorder: _border(AppColors.error, 1.4),
            ),
            onChanged: (phone) => phoneNumber = phone.completeNumber,
            validator: (phone) {
              if (phone == null || phone.number.isEmpty) return 'Phone number required';
              if (!phone.isValidNumber()) return 'Invalid phone number';
              return null;
            },
          ),
          const SizedBox(height: 4),
          AppFormField(
            label: 'Password',
            hint: 'At least 6 characters',
            controller: passwordTEController,
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) return "Password can't be empty";
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'Confirm password',
            hint: 'Type it again',
            controller: confirmTEController,
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) return "Confirm Password can't be empty";
              if (value != passwordTEController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 10),
          _TermsRow(value: _isAgree, error: _showErrors && !_isAgree, onChanged: (v) => setState(() => _isAgree = v)),
          const SizedBox(height: 16),
          GetBuilder<UserSignupController>(
            builder: (c) => AppPrimaryButton(label: 'Create account', loading: c.signupProgress, onPressed: _submit),
          ),
        ],
      ),
    );
  }

  /// The provider's service, as tappable chips (one choice).
  Widget _servicePicker() {
    final missing = _showErrors && _selectedService == null;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Service type'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (label, icon) in _services)
                ChoiceChip(
                  avatar: Icon(
                    icon,
                    size: 18,
                    color: _selectedService == label ? Colors.white : AppColors.textSecondary,
                  ),
                  label: Text(label),
                  selected: _selectedService == label,
                  showCheckmark: false,
                  labelStyle: AppTextStyle.p_medium_12(
                    color: _selectedService == label ? Colors.white : AppColors.textPrimary,
                  ),
                  selectedColor: AppColors.primary_1,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: _selectedService == label
                        ? AppColors.primary_1
                        : (missing ? AppColors.error : AppColors.border),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedService = label);
                  },
                ),
            ],
          ),
          if (missing)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text('Select the service you provide', style: AppTextStyle.p_regular_12(color: AppColors.error)),
            ),
        ],
      ),
    );
  }

  void _submit() async {
    if (signUpController.signupProgress) return; // a request is already running
    FocusScope.of(context).unfocus();
    setState(() => _showErrors = true);

    if (!_formKey.currentState!.validate()) return;

    if (phoneNumber.isEmpty) {
      showAppToast(type: ToastType.warning, title: 'Phone Required', message: 'Please enter a valid phone number');
      return;
    }
    if (_asProvider && (_selectedService == null || _selectedService!.isEmpty)) {
      showAppToast(type: ToastType.warning, title: 'Service required', message: 'Select the service you provide');
      return;
    }
    if (!_isAgree) {
      showAppToast(type: ToastType.warning, title: 'Terms Required', message: 'Please agree to terms and conditions');
      return;
    }

    final email = emailTEController.text.trim();
    final model = SignupRequestModel(
      fullName: nameTEController.text.trim(),
      email: email,
      phoneNumber: phoneNumber,
      password: passwordTEController.text.trim(),
      confirmPassword: confirmTEController.text.trim(),
      role: _asProvider ? 'Provider' : 'User',
      providerType: _asProvider ? providerTypeFor(_selectedService!) : null,
    );

    final isSuccess = await signUpController.signup(model);
    if (!mounted) return;
    if (isSuccess) {
      Get.toNamed(Routes.otpVerify, arguments: {'isFromSignUp': true, 'email': email});
    } else {
      showAppToast(type: ToastType.error, title: 'Error', message: signUpController.errorMessage ?? 'Sign up failed');
    }
  }
}

/// API value for the service chosen on the provider signup tab.
String providerTypeFor(String label) {
  switch (label) {
    case 'Ski Hire':
      return 'Ski_Hire';
    case 'Ski Pass':
      return 'Ski_Pass';
    default:
      return label;
  }
}

/// Customer / Provider segmented control. The gold thumb slides to the
/// chosen side; each half has its own ripple, clipped to its rounded shape,
/// so the ripple shows on the tab that was tapped.
class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.provider, required this.onChanged});

  final bool provider;
  final ValueChanged<bool> onChanged;

  static const _height = 48.0;
  static const _radius = 10.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height + 8,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(_radius + 4),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: provider ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary_1,
                  borderRadius: BorderRadius.circular(_radius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary_1.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _tab('Customer', Icons.person_outline_rounded, !provider, () => onChanged(false)),
              _tab('Provider', Icons.storefront_outlined, provider, () => onChanged(true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, IconData icon, bool selected, VoidCallback onTap) {
    final color = selected ? Colors.white : AppColors.textSecondary;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              if (!selected) HapticFeedback.selectionClick();
              onTap();
            },
            borderRadius: BorderRadius.circular(_radius),
            // A light ripple on the gold tab, a gold one on the grey tab.
            splashColor: selected ? Colors.white.withValues(alpha: 0.25) : AppColors.primary_1.withValues(alpha: 0.18),
            highlightColor: selected
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.primary_1.withValues(alpha: 0.08),
            child: SizedBox(
              height: _height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Shrinks instead of overflowing with very large text.
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: AppTextStyle.sub_h3_semibold_14(color: color),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 18, color: color),
                              const SizedBox(width: 6),
                              Text(label),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.value, required this.onChanged, this.error = false});

  final bool value;
  final bool error;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                value: value,
                activeColor: AppColors.primary_1,
                side: BorderSide(color: error ? AppColors.error : AppColors.textTertiary, width: 1.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                onChanged: (v) => onChanged(v ?? false),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'I agree to the terms and conditions',
                style: AppTextStyle.sub_h3_regular_14(color: error ? AppColors.error : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
