# authio (Flutter)

> Part of **[Authio Lobby](https://authio.com/products/lobby)** —
> Authio's drop-in passwordless authentication. Learn more at
> https://authio.com/products/lobby.

Authio Flutter SDK — passwordless, multi-org authentication for iOS,
Android, and beyond. Native passkeys via `package:passkeys`
(iOS `ASAuthorization` + Android Credential Manager), OAuth via the
system browser, magic links, and secure session storage backed by
`flutter_secure_storage`.

The public surface mirrors the Authio
[Swift](https://github.com/authio-com/authio_swift),
[Kotlin](https://github.com/authio-com/authio_kotlin), and
[React Native](https://github.com/authio-com/authio_react-native)
SDKs, so docs and patterns are 1:1 across mobile platforms.

## Install

Add to your `pubspec.yaml`:

```yaml
dependencies:
  authio: ^0.1.0
```

Then `flutter pub get`.

## Quick start

```dart
import 'package:authio/authio.dart';

final authio = Authio(
  projectId: 'proj_...',
  hostedUiUrl: 'https://auth.authio.com',
);

// Magic link sign-in
await authio.signInWithMagicLink(email: 'user@example.com');

// Passkey sign-in
final session = await authio.signInWithPasskey();
```

## Documentation

- Lobby hub: https://docs.authio.com/lobby
- Methods: https://docs.authio.com/lobby/methods
- Sessions: https://docs.authio.com/lobby/sessions
- API reference: https://docs.authio.com/api

## License

MIT.
