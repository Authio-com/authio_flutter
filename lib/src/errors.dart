/// Stable error codes the SDK emits. Branch on these in your app — the
/// `message` field is human-friendly and subject to change.
enum AuthioErrorCode {
  /// Constructor called without a `publishableKey`.
  missingPublishableKey,

  /// Required argument missing on an SDK call.
  invalidArgument,

  /// `package:passkeys` is not available on this device / platform.
  passkeyUnsupported,

  /// The user dismissed the system passkey UI.
  passkeyCancelled,

  /// The OAuth system browser closed without returning a callback.
  oauthCancelled,

  /// Deep-link callback URL was malformed / missing required params.
  oauthInvalidCallback,

  /// The magic-link callback URL had no `token` query param.
  magicLinkInvalidCallback,

  /// Network failure between the device and api.authio.com.
  networkError,

  /// auth-core returned a 4xx with a structured error body.
  badRequest,

  /// auth-core returned 401 / 403.
  unauthorized,

  /// auth-core returned 5xx.
  serverError,

  /// auth-core returned an unexpected response shape.
  decodeFailed,

  /// `flutter_secure_storage` could not read/write.
  storageFailure,
}

/// Thrown by every public SDK call when something goes wrong. `code` is
/// stable; `status` and `requestId` are populated when the failure
/// originated server-side.
class AuthioError implements Exception {
  /// Construct a typed Authio error.
  const AuthioError({
    required this.code,
    required this.message,
    this.status = 0,
    this.requestId,
    this.details,
    this.cause,
  });

  /// Stable enum identifier. Switch on this in your app.
  final AuthioErrorCode code;

  /// Human-readable message. Don't display verbatim — wrap it.
  final String message;

  /// HTTP status when the failure came from auth-core; 0 otherwise.
  final int status;

  /// Server-side trace id when available. Surface in your bug reports.
  final String? requestId;

  /// Provider-specific extra info (OAuth error_description, etc.).
  final Map<String, Object?>? details;

  /// Underlying exception when this error wraps a lower-level failure.
  final Object? cause;

  /// True when the failure is a network-level issue (vs. a 4xx/5xx from auth-core).
  bool get isNetwork => code == AuthioErrorCode.networkError;

  /// True for codes that represent the user cancelling a system-UI flow.
  bool get isCancellation =>
      code == AuthioErrorCode.passkeyCancelled ||
      code == AuthioErrorCode.oauthCancelled;

  @override
  String toString() {
    final parts = <String>[
      'AuthioError(${code.name})',
      if (status != 0) 'status=$status',
      if (requestId != null) 'request_id=$requestId',
      '"$message"',
    ];
    return parts.join(' ');
  }
}
