import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_components.dart';
import '../../../../injection/injection_container.dart';

class LoginPage extends StatefulWidget {
  final String? initialTab; // 'student', 'register', or 'admin'

  const LoginPage({super.key, this.initialTab});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _auth = sl<AuthService>();

  // Student Login Controllers (supports Email OR Mobile Number)
  final _studentIdentifierController = TextEditingController();
  final _studentPasswordController = TextEditingController();
  final _studentLoginFormKey = GlobalKey<FormState>();

  // Student Register Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _studentRegFormKey = GlobalKey<FormState>();

  // Admin Login Controllers (supports Email OR Mobile Number)
  final _adminIdentifierController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _adminLoginFormKey = GlobalKey<FormState>();

  bool _obscureStudentLogin = true;
  bool _obscureStudentReg = true;
  bool _obscureAdmin = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.initialTab == 'register') initialIndex = 1;
    if (widget.initialTab == 'admin') initialIndex = 2;
    _tabController = TabController(length: 3, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentIdentifierController.dispose();
    _studentPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regPhoneController.dispose();
    _adminIdentifierController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleStudentLogin() async {
    if (!_studentLoginFormKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.loginStudent(
        identifier: _studentIdentifierController.text,
        password: _studentPasswordController.text,
      );
      if (!mounted) return;
      if (_auth.currentUser?.isAdmin == true) {
        context.go('/admin');
      } else {
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _handleStudentRegister() async {
    if (!_studentRegFormKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.registerStudent(
        name: _regNameController.text,
        email: _regEmailController.text,
        password: _regPasswordController.text,
        phone: _regPhoneController.text.trim(),
      );
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _handleAdminLogin() async {
    if (!_adminLoginFormKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.loginAdmin(
        identifier: _adminIdentifierController.text,
        password: _adminPasswordController.text,
      );
      if (!mounted) return;
      context.go('/admin');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Modern sleek slate
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF312E81), Color(0xFF4338CA), Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        const AppLogo(size: 72, isCircle: true, hasGlow: true),
                        const SizedBox(height: 14),
                        const Text(
                          'NEET Master Portal',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NTA Standard Online Examination Platform',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Container(
                    color: AppColors.surfaceSubtle,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textMuted,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Student Login'),
                        Tab(text: 'Register'),
                        Tab(text: 'Admin Portal'),
                      ],
                    ),
                  ),

                  // Error Banner
                  if (_errorMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.errorBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Tab Views
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: SizedBox(
                      height: 450,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildStudentLoginForm(),
                          _buildStudentRegisterForm(),
                          _buildAdminLoginForm(),
                        ],
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

  Widget _buildStudentLoginForm() {
    return Form(
      key: _studentLoginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aspirant Login',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sign in using your Email or 10-digit Mobile Number.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _studentIdentifierController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address or Mobile Number',
              hintText: 'e.g. student@neet.com or 9876543210',
              prefixIcon: Icon(Icons.account_circle_outlined, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email or 10-digit mobile number';
              final trimmed = v.trim();
              if (trimmed.contains('@')) {
                if (!trimmed.contains('.') || trimmed.length < 5) return 'Enter a valid email address';
              } else {
                final digits = trimmed.replaceAll(RegExp(r'\D'), '');
                if (digits.length < 10) return 'Enter a valid 10-digit mobile number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _studentPasswordController,
            obscureText: _obscureStudentLogin,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscureStudentLogin ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: () => setState(() => _obscureStudentLogin = !_obscureStudentLogin),
              ),
            ),
            validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleStudentLogin,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('LOG IN AS STUDENT', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          const Spacer(),
          Center(
            child: TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('Don\'t have an account? Register Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRegisterForm() {
    return Form(
      key: _studentRegFormKey,
      child: ListView(
        children: [
          const Text(
            'Create Student Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Register once with your Email & Mobile Number to access tests.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _regNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'e.g. aspirant@neet.com',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              hintText: '10-digit mobile number (e.g. 9876543210)',
              prefixIcon: Icon(Icons.phone_android_rounded, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your mobile number';
              final digits = v.replaceAll(RegExp(r'\D'), '');
              if (digits.length < 10) return 'Enter a valid 10-digit mobile number';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _regPasswordController,
            obscureText: _obscureStudentReg,
            decoration: InputDecoration(
              labelText: 'Create Password',
              hintText: 'Minimum 6 characters',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscureStudentReg ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: () => setState(() => _obscureStudentReg = !_obscureStudentReg),
              ),
            ),
            validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can log in anytime using either your Email or Mobile Number with this single password.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleStudentRegister,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('COMPLETE REGISTRATION', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminLoginForm() {
    return Form(
      key: _adminLoginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Admin Secure Portal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Restricted', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Sign in with your Administrator Email or Mobile Number.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _adminIdentifierController,
            decoration: const InputDecoration(
              labelText: 'Administrator Email or Username',
              hintText: 'e.g. navneet@1232 or admin@neet.com',
              prefixIcon: Icon(Icons.admin_panel_settings_outlined, size: 20),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your admin email or username' : null,
          ),
          const SizedBox(height: 10),
          // Quick credential helper for admin
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Admin ID:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              ActionChip(
                avatar: const Icon(Icons.key_rounded, size: 14, color: AppColors.primary),
                label: const Text('navneet@1232', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.4),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                onPressed: () {
                  setState(() {
                    _adminIdentifierController.text = 'navneet@1232';
                    _adminPasswordController.text = '123456';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _adminPasswordController,
            obscureText: _obscureAdmin,
            decoration: InputDecoration(
              labelText: 'Admin Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscureAdmin ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: () => setState(() => _obscureAdmin = !_obscureAdmin),
              ),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Please enter password' : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleAdminLogin,
              icon: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.security_rounded, size: 18),
              label: const Text('ADMINISTRATOR SIGN IN', style: TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1B4B),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
