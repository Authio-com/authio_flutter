/// Domain types for the Authio Flutter SDK.
///
/// These shapes mirror the Swift, Kotlin, and React Native SDKs so docs
/// and examples can be 1:1 across platforms. The auth-core REST API uses
/// snake_case on the wire; we re-key to camelCase in `lib/src/wire.dart`
/// so the public surface speaks Dart-idiomatic.
library;

import 'errors.dart';

/// Membership lifecycle on a (user, organization) pair.
enum MembershipStatus {
  /// Created via invitation, not yet accepted.
  invited,

  /// Live member of the org.
  active,

  /// Temporarily blocked from accessing the org.
  suspended,

  /// Permanently removed; row kept for audit.
  deactivated;

  /// Decode a wire string into the enum, defaulting to [active] for unknown
  /// values so callers don't crash on new server-side states.
  static MembershipStatus fromWire(String? raw) {
    switch (raw) {
      case 'invited':
        return MembershipStatus.invited;
      case 'active':
        return MembershipStatus.active;
      case 'suspended':
        return MembershipStatus.suspended;
      case 'deactivated':
        return MembershipStatus.deactivated;
      default:
        return MembershipStatus.active;
    }
  }
}

/// Per-membership preferred login method. An org admin can pin a member
/// to a specific factor (e.g. force SSO for one org while passkey for another).
enum PreferredLoginMethod {
  /// User prefers passkey for this org.
  passkey,

  /// User prefers magic link for this org.
  magicLink,

  /// User prefers OAuth (Google, Microsoft, etc.) for this org.
  oauth,

  /// Org mandates SAML/OIDC SSO.
  sso;

  /// Decode the wire string; returns null when no preference is set.
  static PreferredLoginMethod? fromWire(String? raw) {
    switch (raw) {
      case 'passkey':
        return PreferredLoginMethod.passkey;
      case 'magic_link':
        return PreferredLoginMethod.magicLink;
      case 'oauth':
        return PreferredLoginMethod.oauth;
      case 'sso':
        return PreferredLoginMethod.sso;
      default:
        return null;
    }
  }
}

/// Identity object. Project-scoped, not org-scoped — the *whole point* of
/// Authio is that one [User] can belong to many [Organization]s.
class User {
  /// Construct a User.
  const User({
    required this.id,
    required this.email,
    required this.emailVerified,
    this.projectId,
    this.name,
    this.avatarUrl,
    this.defaultOrganizationId,
    this.createdAt,
    this.updatedAt,
  });

  /// Stable identifier, e.g. `user_01HX…`.
  final String id;

  /// Project this user lives under.
  final String? projectId;

  /// Canonical email. Project-unique with the user id.
  final String email;

  /// True once any of the user's auth methods has proven mailbox control.
  final bool emailVerified;

  /// Display name, when provided.
  final String? name;

  /// HTTPS URL to a public avatar image.
  final String? avatarUrl;

  /// The org the user last picked. Used by hosted-UI for multi-org auto-route.
  final String? defaultOrganizationId;

  /// First-seen timestamp (ISO-8601 from the server).
  final DateTime? createdAt;

  /// Last-updated timestamp (ISO-8601 from the server).
  final DateTime? updatedAt;

  /// JSON-serialisable snapshot. Round-trips with [User.fromJson].
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'project_id': projectId,
        'email': email,
        'email_verified': emailVerified,
        'name': name,
        'avatar_url': avatarUrl,
        'default_organization_id': defaultOrganizationId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  /// Decode a User from its JSON snapshot.
  factory User.fromJson(Map<String, Object?> json) => User(
        id: _requireString(json, 'id'),
        projectId: _optString(json, 'project_id'),
        email: _requireString(json, 'email'),
        emailVerified: _optBool(json, 'email_verified') ?? false,
        name: _optString(json, 'name'),
        avatarUrl: _optString(json, 'avatar_url'),
        defaultOrganizationId: _optString(json, 'default_organization_id'),
        createdAt: _optDateTime(json, 'created_at'),
        updatedAt: _optDateTime(json, 'updated_at'),
      );
}

/// B2B account in your product. End-users belong to N of these via [Membership].
class Organization {
  /// Construct an Organization.
  const Organization({
    required this.id,
    required this.projectId,
    required this.name,
    required this.slug,
    this.createdAt,
  });

  /// Stable identifier, e.g. `org_01HX…`.
  final String id;

  /// Owning project id.
  final String projectId;

  /// Display name.
  final String name;

  /// URL-safe slug, unique within the project.
  final String slug;

  /// First-seen timestamp.
  final DateTime? createdAt;

  /// JSON-serialisable snapshot.
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'project_id': projectId,
        'name': name,
        'slug': slug,
        'created_at': createdAt?.toIso8601String(),
      };

  /// Decode an Organization from JSON.
  factory Organization.fromJson(Map<String, Object?> json) => Organization(
        id: _requireString(json, 'id'),
        projectId: _requireString(json, 'project_id'),
        name: _requireString(json, 'name'),
        slug: _requireString(json, 'slug'),
        createdAt: _optDateTime(json, 'created_at'),
      );
}

/// The join object between [User] and [Organization]. One user, many memberships.
class Membership {
  /// Construct a Membership.
  const Membership({
    required this.id,
    required this.organizationId,
    required this.role,
    required this.status,
    this.projectId,
    this.userId,
    this.joinedAt,
    this.lastActiveAt,
    this.preferredLoginMethod,
    this.invitedBy,
  });

  /// Stable identifier, e.g. `mem_01HX…`.
  final String id;

  /// Owning project id.
  final String? projectId;

  /// Owning user id.
  final String? userId;

  /// Org this membership grants access to.
  final String organizationId;

  /// Free-form role string (`admin`, `member`, `viewer`, custom).
  final String role;

  /// Lifecycle state.
  final MembershipStatus status;

  /// First-seen timestamp.
  final DateTime? joinedAt;

  /// Most recent activity timestamp.
  final DateTime? lastActiveAt;

  /// Pinned login method (org-level enforcement).
  final PreferredLoginMethod? preferredLoginMethod;

  /// User id of the admin who issued the invite, when applicable.
  final String? invitedBy;

  /// JSON-serialisable snapshot.
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'project_id': projectId,
        'user_id': userId,
        'organization_id': organizationId,
        'role': role,
        'status': status.name,
        'joined_at': joinedAt?.toIso8601String(),
        'last_active_at': lastActiveAt?.toIso8601String(),
        'preferred_login_method': preferredLoginMethod?.name == 'magicLink'
            ? 'magic_link'
            : preferredLoginMethod?.name,
        'invited_by': invitedBy,
      };
}

/// What `GET /v1/me/organizations` returns — membership row with the
/// embedded org. Render this as the org switcher in your UI.
class MembershipWithOrg {
  /// Construct a MembershipWithOrg.
  const MembershipWithOrg({
    required this.membership,
    required this.organization,
  });

  /// The membership row.
  final Membership membership;

  /// The embedded organization.
  final Organization organization;
}

/// What the SDK persists. `accessToken` is short-lived (~15 min); call
/// [AuthioClient.verify] on app launch and re-authenticate when it
/// returns false.
///
/// `orgId` is null when the user has authenticated but not yet selected
/// an organization — common on first login for multi-org users. Render
/// the org picker before allowing org-scoped requests.
class AuthioSession {
  /// Construct a session.
  const AuthioSession({
    required this.sessionId,
    required this.userId,
    required this.accessToken,
    required this.expiresAt,
    this.orgId,
    this.role,
    this.refreshToken,
  });

  /// Server-side session id, opaque.
  final String sessionId;

  /// Logged-in user id.
  final String userId;

  /// Currently-selected org id, or null when the user hasn't picked one.
  final String? orgId;

  /// Role string in the active org, or null when no org is selected.
  final String? role;

  /// JWT — pass on `Authorization: Bearer …` for API calls.
  final String accessToken;

  /// Long-lived refresh token; null when not issued.
  final String? refreshToken;

  /// Expiry of [accessToken].
  final DateTime expiresAt;

  /// True iff [accessToken] has already expired locally.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// JSON-serialisable snapshot (used by secure storage).
  Map<String, Object?> toJson() => <String, Object?>{
        'session_id': sessionId,
        'user_id': userId,
        'org_id': orgId,
        'role': role,
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt.toIso8601String(),
      };

  /// Decode a session from JSON.
  factory AuthioSession.fromJson(Map<String, Object?> json) => AuthioSession(
        sessionId: _requireString(json, 'session_id'),
        userId: _requireString(json, 'user_id'),
        orgId: _optString(json, 'org_id'),
        role: _optString(json, 'role'),
        accessToken: _requireString(json, 'access_token'),
        refreshToken: _optString(json, 'refresh_token'),
        expiresAt: _requireDateTime(json, 'expires_at'),
      );

  /// Return a copy with selected fields swapped.
  AuthioSession copyWith({
    String? sessionId,
    String? userId,
    String? orgId,
    String? role,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) =>
      AuthioSession(
        sessionId: sessionId ?? this.sessionId,
        userId: userId ?? this.userId,
        orgId: orgId ?? this.orgId,
        role: role ?? this.role,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        expiresAt: expiresAt ?? this.expiresAt,
      );
}

/// Supported OAuth providers. Auth-core may light up more over time; pass
/// `OAuthProvider.custom('discord')` for any provider name not in this enum.
class OAuthProvider {
  /// Canonical Google provider.
  static const OAuthProvider google = OAuthProvider._('google');

  /// Canonical Microsoft / Entra ID provider.
  static const OAuthProvider microsoft = OAuthProvider._('microsoft');

  /// Sign in with Apple.
  static const OAuthProvider apple = OAuthProvider._('apple');

  /// GitHub OAuth.
  static const OAuthProvider github = OAuthProvider._('github');

  /// Slack OAuth.
  static const OAuthProvider slack = OAuthProvider._('slack');

  /// LinkedIn OIDC.
  static const OAuthProvider linkedin = OAuthProvider._('linkedin');

  /// GitLab OIDC.
  static const OAuthProvider gitlab = OAuthProvider._('gitlab');

  /// Escape hatch for any other provider name auth-core knows about.
  factory OAuthProvider.custom(String name) {
    if (name.isEmpty) {
      throw const AuthioError(
        code: AuthioErrorCode.invalidArgument,
        message: 'OAuthProvider.custom: name is required',
      );
    }
    return OAuthProvider._(name);
  }

  const OAuthProvider._(this.name);

  /// Wire name as expected by auth-core.
  final String name;

  @override
  bool operator ==(Object other) => other is OAuthProvider && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'OAuthProvider($name)';
}

/* ---------------- internal JSON helpers ---------------- */

String _requireString(Map<String, Object?> json, String key) {
  final raw = json[key];
  if (raw is String && raw.isNotEmpty) return raw;
  throw AuthioError(
    code: AuthioErrorCode.decodeFailed,
    message: 'Missing required string field: $key',
  );
}

String? _optString(Map<String, Object?> json, String key) {
  final raw = json[key];
  if (raw is String && raw.isNotEmpty) return raw;
  return null;
}

bool? _optBool(Map<String, Object?> json, String key) {
  final raw = json[key];
  if (raw is bool) return raw;
  return null;
}

DateTime? _optDateTime(Map<String, Object?> json, String key) {
  final raw = json[key];
  if (raw is String && raw.isNotEmpty) {
    return DateTime.tryParse(raw)?.toUtc();
  }
  return null;
}

DateTime _requireDateTime(Map<String, Object?> json, String key) {
  final parsed = _optDateTime(json, key);
  if (parsed != null) return parsed;
  throw AuthioError(
    code: AuthioErrorCode.decodeFailed,
    message: 'Missing required ISO-8601 field: $key',
  );
}
