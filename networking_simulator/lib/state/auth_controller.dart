import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/env.dart';
import '../services/firestore_service.dart' show currentUidProvider;

/// Lightweight user profile surfaced to the UI. We don't expose
/// `fba.User` directly so the rest of the app stays decoupled from
/// FirebaseAuth's types.
class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
}

abstract class AuthController {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<void> signInWithGoogle();
  Future<void> signOut();
}

/// Auto-signed-in fake user. Used when `USE_MOCKS=true` or when Firebase
/// hasn't been configured yet (HUMAN_TODO step 5 not done).
class MockAuthController implements AuthController {
  MockAuthController(this._ref) {
    _ref.read(currentUidProvider.notifier).set(_user.uid);
    _ctrl.add(_user);
  }

  final Ref _ref;
  final _ctrl = StreamController<AppUser?>.broadcast();
  final AppUser _user = const AppUser(
    uid: 'demo-local',
    displayName: 'Demo User',
    email: 'demo@connectai.dev',
    photoUrl: null,
  );

  @override
  Stream<AppUser?> get authStateChanges => _ctrl.stream;

  @override
  AppUser? get currentUser => _user;

  @override
  Future<void> signInWithGoogle() async {
    _ctrl.add(_user);
  }

  @override
  Future<void> signOut() async {
    _ctrl.add(null);
    _ref.read(currentUidProvider.notifier).set(null);
  }
}

/// Real Firebase Auth wrapper. Web Google sign-in uses
/// `signInWithPopup(GoogleAuthProvider())` — no separate `google_sign_in`
/// initialization needed on the web platform.
class RealAuthController implements AuthController {
  RealAuthController(this._ref) {
    _sub = _auth.authStateChanges().listen((u) {
      final mapped = u == null
          ? null
          : AppUser(
              uid: u.uid,
              displayName: u.displayName ?? 'Friend',
              email: u.email ?? '',
              photoUrl: u.photoURL,
            );
      _ctrl.add(mapped);
      _ref.read(currentUidProvider.notifier).set(mapped?.uid);
    });
  }

  final Ref _ref;
  final fba.FirebaseAuth _auth = fba.FirebaseAuth.instance;
  final _ctrl = StreamController<AppUser?>.broadcast();
  late final StreamSubscription _sub;

  @override
  Stream<AppUser?> get authStateChanges => _ctrl.stream;

  @override
  AppUser? get currentUser {
    final u = _auth.currentUser;
    if (u == null) return null;
    return AppUser(
      uid: u.uid,
      displayName: u.displayName ?? 'Friend',
      email: u.email ?? '',
      photoUrl: u.photoURL,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    final provider = fba.GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');
    await _auth.signInWithPopup(provider);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  void dispose() => _sub.cancel();
}

final authControllerProvider = Provider<AuthController>((ref) {
  if (useMocks || Firebase.apps.isEmpty) return MockAuthController(ref);
  return RealAuthController(ref);
});

/// Streams the current user. Frontend reads this to gate the auth screen.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authControllerProvider).authStateChanges;
});
