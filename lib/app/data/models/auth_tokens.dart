/// Access and refresh tokens from a login or refresh response.
class AuthTokens {
  const AuthTokens({this.accessToken, this.refreshToken});

  final String? accessToken;
  final String? refreshToken;

  bool get hasAccess => accessToken != null && accessToken!.isNotEmpty;

  /// Accepts `{data: {tokens: {accessToken, refreshToken}}}`,
  /// `{data: {accessToken, refreshToken}}`, or the same keys at the top level.
  factory AuthTokens.fromBody(Map<String, dynamic>? body) {
    final data = body?['data'];
    final maps = <Map>[
      if (data is Map && data['tokens'] is Map) data['tokens'] as Map,
      if (data is Map) data,
      if (body != null) body,
    ];
    String? pick(String key) {
      for (final map in maps) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
      return null;
    }

    return AuthTokens(
      accessToken: pick('accessToken'),
      refreshToken: pick('refreshToken'),
    );
  }
}
