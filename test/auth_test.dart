import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("Should not be initialized to begin with", () {
      expect(provider._isInitialized, false);
    });
    test("Can't log out if not initialized", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test("Should be able to be initialized", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    test("User should be null after initialization", () {
      expect(provider.currentUser, null);
    });
    test(
      "Should be able to initialize in less than 2 secs",
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test("Create user should delegate to logIn function", () async {
      final badEmailUser =
          provider.createUser(email: "foobar@gmail.com", password: "anything");
      expect(badEmailUser,
          throwsA(const TypeMatcher<InvalidCredentialAuthException>()));

      final badPasswordUser =
          provider.createUser(email: "anything@bmail.com", password: "foobar");
      expect(badPasswordUser,
          throwsA(const TypeMatcher<InvalidCredentialAuthException>()));

      final user = await provider.createUser(email: "foo", password: "bar");
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test("Logged in user should be able to get verified ", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test("Should be able to log out and log in again", () async {
      await provider.logOut();
      await provider.logIn(
        email: "email",
        password: "pass",
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider extends AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == "foobar@gmail.com" || password == "foobar") {
      throw InvalidCredentialAuthException();
    }
    const user = AuthUser(
      isEmailVerified: false,
      email: 'foobar@gmail.com',
      id: 'my_id',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw InvalidCredentialAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw InvalidCredentialAuthException();
    const newUser = AuthUser(
      isEmailVerified: true,
      email: 'foobar@gmail.com',
      id: 'my_id',
    );
    _user = newUser;
  }
}
