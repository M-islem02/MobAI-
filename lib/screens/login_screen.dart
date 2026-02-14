import 'package:flutter/material.dart';
import '../models/admin_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController(text: 'admin');
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final identifier = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username/email and password')),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final user = MockAuthService.authenticate(identifier, password);

    if (!mounted) return;

    if (user == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
      return;
    }

    if (user.role != 'admin') {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admin can access this web interface')),
      );
      return;
    }

    if (!user.canAuthenticate) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account is disabled or locked')),
      );
      return;
    }

    user.lastLogin = DateTime.now();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1000;
    final isPhone = size.width < 600;

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [

            // ── Main content ──
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 20 : 40,
                    vertical: isPhone ? 24 : 40,
                  ),
                  child: isDesktop
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(isPhone),
                ),
              ),
            ),

            // ── BMS Sponsor badge – bottom-right ──
            Positioned(
              right: isPhone ? 16 : 32,
              bottom: isPhone ? 12 : 24,
              child: _buildBmsSponsorBadge(isPhone),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════ DESKTOP (large-scale) ═══════════════════

  Widget _buildDesktopLayout() {
    return Container(
      width: 1100,
      constraints: const BoxConstraints(maxHeight: 760),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Left: Mascot hero panel ──
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF006D84), Color(0xFF0E93AF)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  bottomLeft: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ant mascot – BIG 400px
                  Image.asset(
                    'assets/images/ant_logo.png',
                    width: 400,
                    height: 400,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.warehouse_rounded,
                      size: 160,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Namla',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'WAREHOUSE MANAGEMENT SYSTEM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'MobAI Hackathon 2026',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Right: Login form ──
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
              child: _buildForm(isDesktop: true),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════ MOBILE / TABLET ═══════════════════

  Widget _buildMobileLayout(bool isPhone) {
    final logoSize = isPhone ? 120.0 : 200.0;
    final cardPadding = isPhone ? 24.0 : 40.0;

    return Container(
      width: isPhone ? double.infinity : 520,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 50,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/ant_logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.warehouse_rounded,
              size: isPhone ? 60 : 80,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: isPhone ? 12 : 20),
          Text(
            'Namla WMS',
            style: TextStyle(
              fontSize: isPhone ? 28 : 36,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: isPhone ? 20 : 32),
          _buildForm(isDesktop: false, isPhone: isPhone),
        ],
      ),
    );
  }

  // ═══════════════════ FORM ═══════════════════

  Widget _buildForm({bool isDesktop = false, bool isPhone = false}) {
    final titleSize = isDesktop ? 36.0 : (isPhone ? 24.0 : 30.0);
    final subtitleSize = isDesktop ? 18.0 : (isPhone ? 14.0 : 16.0);
    final badgeTextSize = isDesktop ? 16.0 : (isPhone ? 12.0 : 14.0);
    final inputHeight = isDesktop ? 72.0 : (isPhone ? 52.0 : 60.0);
    final inputFontSize = isDesktop ? 20.0 : (isPhone ? 16.0 : 18.0);
    final iconSize = isDesktop ? 24.0 : (isPhone ? 18.0 : 20.0);
    final btnHeight = isDesktop ? 64.0 : (isPhone ? 52.0 : 56.0);
    final btnFontSize = isDesktop ? 22.0 : (isPhone ? 16.0 : 18.0);
    final gap = isDesktop ? 24.0 : (isPhone ? 14.0 : 18.0);
    final bigGap = isDesktop ? 40.0 : (isPhone ? 20.0 : 28.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sign In',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: isDesktop ? 8 : 4),
        Text(
          'Web interface is restricted to ADMIN access',
          style: TextStyle(fontSize: subtitleSize, color: AppColors.textLight),
        ),
        SizedBox(height: bigGap),

        // ── Admin-only access badge ──
        Container(
          padding: EdgeInsets.all(isDesktop ? 16 : 10),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.primaryDark.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_rounded,
                  size: iconSize, color: AppColors.primaryDark),
              SizedBox(width: isDesktop ? 12 : 8),
              Expanded(
                child: Text(
                  'Admin access only · Full control panel',
                  style: TextStyle(
                    fontSize: badgeTextSize,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: gap),

        // ── Username / Email ──
        _buildTextField(
          controller: _emailCtrl,
          hint: 'Username or Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          height: inputHeight,
          fontSize: inputFontSize,
          iconSize: iconSize,
        ),
        SizedBox(height: gap * 0.7),

        // ── Password ──
        _buildTextField(
          controller: _passwordCtrl,
          hint: 'Password',
          icon: Icons.lock_outline,
          obscure: _obscurePassword,
          height: inputHeight,
          fontSize: inputFontSize,
          iconSize: iconSize,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: iconSize,
              color: AppColors.textLight,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        SizedBox(height: isDesktop ? 10 : 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(
              'Forgot password?',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 13,
                color: AppColors.textLight,
              ),
            ),
          ),
        ),
        SizedBox(height: gap),

        // ── Sign In button ──
        SizedBox(
          width: double.infinity,
          height: btnHeight,
          child: FilledButton(
            onPressed: _loading ? null : _signIn,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 18 : 14)),
              elevation: 0,
            ),
            child: _loading
                ? SizedBox(
                    width: isDesktop ? 28 : 22,
                    height: isDesktop ? 28 : 22,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.admin_panel_settings_rounded,
                          size: iconSize, color: Colors.white),
                      SizedBox(width: isDesktop ? 12 : 8),
                      Text(
                        'Sign In as ADMIN',
                        style: TextStyle(
                          fontSize: btnFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════ TEXT FIELD ═══════════════════

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required double height,
    required double fontSize,
    required double iconSize,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: AppColors.textLight, fontSize: fontSize * 0.9),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(icon, size: iconSize, color: AppColors.textLight),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: iconSize + 28),
          suffixIcon: suffix,
          filled: true,
          fillColor: AppColors.bg,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: (height - fontSize - 8) / 2,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2)),
        ),
      ),
    );
  }

  // ═══════════════════ BMS SPONSOR ═══════════════════

  Widget _buildBmsSponsorBadge(bool isPhone) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPhone ? 10 : 16,
        vertical: isPhone ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo_bms_small.png',
            width: isPhone ? 24 : 36,
            height: isPhone ? 24 : 36,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          SizedBox(width: isPhone ? 6 : 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sponsored by',
                style: TextStyle(
                    fontSize: isPhone ? 9 : 12,
                    color: Colors.white54,
                    letterSpacing: 0.5),
              ),
              Text(
                'BMS Electric',
                style: TextStyle(
                    fontSize: isPhone ? 13 : 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════ BACKGROUND PATTERN ═══════════════════

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
