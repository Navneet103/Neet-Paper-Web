import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../injection/injection_container.dart';
import '../storage/app_database.dart';
import 'user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isStudent => _currentUser?.isStudent ?? false;

  CollectionReference get _usersCol => _firestore.collection('users');
  CollectionReference get _submissionsCol => _firestore.collection('test_submissions');
  CollectionReference get _phoneLookupCol => _firestore.collection('phone_lookup');

  /// Normalizes phone number to standard digits (strips +91, 0, whitespace, hyphens)
  static String normalizePhone(String input) {
    String digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    } else if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits;
  }

  /// Resolves the associated account email from a mobile number
  Future<String?> _resolveEmailFromPhone(String cleanPhone, {String? role}) async {
    try {
      // 1. Direct document lookup in phone_lookup (fast O(1) query)
      final lookupDoc = await _phoneLookupCol.doc(cleanPhone).get();
      if (lookupDoc.exists) {
        final data = lookupDoc.data() as Map<String, dynamic>? ?? {};
        final email = data['email'] as String?;
        if (email != null && email.isNotEmpty) return email;
      }

      // 2. Query users collection where phone == cleanPhone
      final querySnap = await _usersCol.where('phone', isEqualTo: cleanPhone).limit(1).get();
      if (querySnap.docs.isNotEmpty) {
        final data = querySnap.docs.first.data() as Map<String, dynamic>;
        final email = data['email'] as String? ?? '';
        if (email.isNotEmpty) {
          await _phoneLookupCol.doc(cleanPhone).set({
            'email': email,
            'phone': cleanPhone,
            'role': data['role'] ?? (role ?? 'student'),
            'uid': querySnap.docs.first.id,
          }, SetOptions(merge: true));
          return email;
        }
      }

      // 3. Query with +91 format
      final queryWithPrefix = await _usersCol.where('phone', isEqualTo: '+91$cleanPhone').limit(1).get();
      if (queryWithPrefix.docs.isNotEmpty) {
        final data = queryWithPrefix.docs.first.data() as Map<String, dynamic>;
        final email = data['email'] as String? ?? '';
        if (email.isNotEmpty) {
          await _phoneLookupCol.doc(cleanPhone).set({
            'email': email,
            'phone': cleanPhone,
            'role': data['role'] ?? (role ?? 'student'),
            'uid': queryWithPrefix.docs.first.id,
          }, SetOptions(merge: true));
          return email;
        }
      }
    } catch (e) {
      debugPrint("Error resolving email from phone: $e");
    }
    return null;
  }

  AuthService() {
    _initAuthListener();
  }

  Future<void> _clearLocalUserData() async {
    try {
      if (sl.isRegistered<AppDatabase>()) {
        await sl<AppDatabase>().clearUserSessionData();
      }
    } catch (e) {
      debugPrint("Error clearing local database on auth state change: $e");
    }
  }

  void _initAuthListener() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _isLoading = false;
        await _clearLocalUserData();
        notifyListeners();
      } else {
        await _loadUserProfile(firebaseUser);
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(User firebaseUser) async {
    try {
      final doc = await _usersCol.doc(firebaseUser.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromDoc(doc);
      } else {
        // Provision profile if doc didn't exist
        final role = (firebaseUser.email?.toLowerCase().contains('admin') ?? false) ? 'admin' : 'student';
        final newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? (firebaseUser.email?.split('@').first ?? 'Student'),
          role: role,
          createdAt: DateTime.now(),
        );
        await _usersCol.doc(firebaseUser.uid).set(newUser.toMap());
        _currentUser = newUser;
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
      _currentUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'User',
        role: 'student',
        createdAt: DateTime.now(),
      );
    }
  }

  /// Register a new student securely with Email & Mobile Number
  Future<UserModel> registerStudent({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      String? cleanPhone;
      if (phone != null && phone.trim().isNotEmpty) {
        cleanPhone = normalizePhone(phone);
        if (cleanPhone.length < 10) {
          throw Exception('Please enter a valid 10-digit mobile number.');
        }

        // Check if phone number is already registered to another account
        final existingEmail = await _resolveEmailFromPhone(cleanPhone);
        if (existingEmail != null && existingEmail.isNotEmpty && existingEmail != cleanEmail) {
          throw Exception('Mobile number $phone is already registered with another account. Please log in instead.');
        }
      }

      final cred = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final user = cred.user!;
      await user.updateDisplayName(name.trim());

      final userModel = UserModel(
        uid: user.uid,
        email: cleanEmail,
        displayName: name.trim(),
        role: 'student',
        phone: cleanPhone,
        createdAt: DateTime.now(),
      );

      await _usersCol.doc(user.uid).set(userModel.toMap());

      // Save to phone_lookup for instant phone + password login
      if (cleanPhone != null && cleanPhone.isNotEmpty) {
        await _phoneLookupCol.doc(cleanPhone).set({
          'email': cleanEmail,
          'phone': cleanPhone,
          'role': 'student',
          'uid': user.uid,
          'name': name.trim(),
        });
      }

      await _clearLocalUserData();
      _currentUser = userModel;
      notifyListeners();
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Registration failed: $e');
    }
  }

  /// Student Login supporting both Email Address OR Mobile Number + Password
  Future<UserModel> loginStudent({
    String? identifier,
    String? email,
    required String password,
  }) async {
    final input = (identifier ?? email ?? '').trim();
    if (input.isEmpty) {
      throw Exception('Please enter your email address or mobile number.');
    }

    String targetEmail;
    String? cleanPhone;

    if (input.contains('@')) {
      targetEmail = input.toLowerCase();
    } else {
      cleanPhone = normalizePhone(input);
      if (cleanPhone.length < 10) {
        throw Exception('Please enter a valid 10-digit mobile number.');
      }
      final resolved = await _resolveEmailFromPhone(cleanPhone);
      targetEmail = resolved ?? '$cleanPhone@neetportal.com';
    }

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: targetEmail,
        password: password,
      );

      final user = cred.user!;
      final doc = await _usersCol.doc(user.uid).get();

      if (!doc.exists) {
        final newUser = UserModel(
          uid: user.uid,
          email: targetEmail,
          displayName: user.displayName ?? (cleanPhone != null ? 'Aspirant $cleanPhone' : input.split('@').first),
          role: 'student',
          phone: cleanPhone,
          createdAt: DateTime.now(),
        );
        await _usersCol.doc(user.uid).set(newUser.toMap());
        _currentUser = newUser;
      } else {
        _currentUser = UserModel.fromDoc(doc);
        // Backfill phone if not present
        if (cleanPhone != null && (_currentUser!.phone == null || _currentUser!.phone!.isEmpty)) {
          await _usersCol.doc(user.uid).update({'phone': cleanPhone});
          _currentUser = _currentUser!.copyWith(phone: cleanPhone);
        }
      }

      // Keep phone_lookup in sync
      if (_currentUser!.phone != null && _currentUser!.phone!.isNotEmpty) {
        await _phoneLookupCol.doc(_currentUser!.phone!).set({
          'email': _currentUser!.email,
          'phone': _currentUser!.phone,
          'role': _currentUser!.role,
          'uid': _currentUser!.uid,
          'name': _currentUser!.displayName,
        }, SetOptions(merge: true));
      }

      await _clearLocalUserData();
      notifyListeners();
      return _currentUser!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        if (cleanPhone != null) {
          throw Exception('No account found with mobile number "$input". Please verify your mobile number or sign in with your email address.');
        }
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Login failed: $e');
    }
  }

  /// Admin Login supporting both Email Address OR Mobile Number + Password
  Future<UserModel> loginAdmin({
    String? identifier,
    String? email,
    required String password,
  }) async {
    final input = (identifier ?? email ?? '').trim();
    if (input.isEmpty) {
      throw Exception('Please enter your admin email or mobile number.');
    }

    String targetEmail;
    String? cleanPhone;

    if (input.contains('@')) {
      targetEmail = input.toLowerCase();
    } else {
      cleanPhone = normalizePhone(input);
      if (cleanPhone.length < 10) {
        throw Exception('Please enter a valid 10-digit mobile number.');
      }
      final resolved = await _resolveEmailFromPhone(cleanPhone, role: 'admin');
      targetEmail = resolved ?? '$cleanPhone@admin.neet';
    }

    try {
      UserCredential cred;
      try {
        cred = await _auth.signInWithEmailAndPassword(
          email: targetEmail,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        // If the admin user doesn't exist yet, auto-create it on first login!
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          cred = await _auth.createUserWithEmailAndPassword(
            email: targetEmail,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      final user = cred.user!;
      final doc = await _usersCol.doc(user.uid).get();

      UserModel model;
      if (!doc.exists) {
        final bool isAdminEmail = targetEmail.toLowerCase().contains('admin') || cleanPhone != null;
        model = UserModel(
          uid: user.uid,
          email: targetEmail,
          displayName: user.displayName ?? (cleanPhone != null ? 'Admin $cleanPhone' : 'Administrator'),
          role: isAdminEmail ? 'admin' : 'student',
          phone: cleanPhone,
          createdAt: DateTime.now(),
        );
        await _usersCol.doc(user.uid).set(model.toMap());
      } else {
        model = UserModel.fromDoc(doc);
        if (cleanPhone != null && (model.phone == null || model.phone!.isEmpty)) {
          await _usersCol.doc(user.uid).update({'phone': cleanPhone});
          model = model.copyWith(phone: cleanPhone);
        }
      }

      if (!model.isAdmin) {
        if (targetEmail.toLowerCase().contains('admin') || cleanPhone != null) {
          model = model.copyWith(role: 'admin');
          await _usersCol.doc(user.uid).update({'role': 'admin'});
        } else {
          await _auth.signOut();
          _currentUser = null;
          notifyListeners();
          throw Exception('Access Denied: This account does not possess Administrator credentials.');
        }
      }

      // Sync phone lookup for admin
      if (cleanPhone != null) {
        await _phoneLookupCol.doc(cleanPhone).set({
          'email': targetEmail,
          'phone': cleanPhone,
          'role': 'admin',
          'uid': user.uid,
          'name': model.displayName,
        }, SetOptions(merge: true));
      }

      _currentUser = model;
      await _clearLocalUserData();
      notifyListeners();
      return model;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Update or link mobile number to user's profile
  Future<void> updatePhoneNumber(String phone) async {
    if (_currentUser == null) return;
    final cleanPhone = normalizePhone(phone);
    if (cleanPhone.length < 10) {
      throw Exception('Please enter a valid 10-digit mobile number.');
    }

    final existingEmail = await _resolveEmailFromPhone(cleanPhone);
    if (existingEmail != null && existingEmail.toLowerCase() != _currentUser!.email.toLowerCase()) {
      throw Exception('Mobile number $phone is already linked to another account.');
    }

    await _usersCol.doc(_currentUser!.uid).update({
      'phone': cleanPhone,
    });

    await _phoneLookupCol.doc(cleanPhone).set({
      'email': _currentUser!.email,
      'phone': cleanPhone,
      'role': _currentUser!.role,
      'uid': _currentUser!.uid,
      'name': _currentUser!.displayName,
    }, SetOptions(merge: true));

    _currentUser = _currentUser!.copyWith(phone: cleanPhone);
    notifyListeners();
  }

  /// Check if the currently logged-in student has already attempted a test
  Future<bool> hasStudentAttempted(String testId) async {
    if (_currentUser == null) return false;
    try {
      final snap = await _submissionsCol
          .where('testId', isEqualTo: testId)
          .where('studentUid', isEqualTo: _currentUser!.uid)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Stream submissions for current student
  Stream<List<Map<String, dynamic>>> streamStudentTestHistory() {
    if (_currentUser == null) return Stream.value([]);
    return _submissionsCol
        .where('studentUid', isEqualTo: _currentUser!.uid)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data() as Map<String, dynamic>).toList());
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    await _clearLocalUserData();
    notifyListeners();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No registered account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password or invalid credentials.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
