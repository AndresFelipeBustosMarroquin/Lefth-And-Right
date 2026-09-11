import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // Desktop
            if (width >= 1000) {
              return _buildDesktopLayout(width);
            }

            // Tablet / ventanas medianas
            if (width >= 700) {
              return _buildTabletLayout(width);
            }

            // Móvil / ventana pequeña
            return _buildMobileLayout(width);
          },
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout(double width) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1450),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
          child: Row(
            children: [
              // BRANDING
              Expanded(flex: 5, child: _buildBranding()),

              const SizedBox(width: 70),

              // LOGIN
              Expanded(flex: 7, child: _buildLoginCard()),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TABLET
  // ============================================================

  Widget _buildTabletLayout(double width) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            child: Column(
              children: [
                _buildBranding(compact: true),

                const SizedBox(height: 45),

                _buildLoginCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout(double width) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          children: [
            _buildBranding(compact: true, mobile: true),

            const SizedBox(height: 30),

            _buildLoginCard(mobile: true),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BRANDING
  // ============================================================

  Widget _buildBranding({bool compact = false, bool mobile = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // BALANZA
        Icon(
          Icons.balance,
          size: mobile
              ? 65
              : compact
              ? 70
              : 100,
          color: const Color(0xFF142B42),
        ),

        SizedBox(height: mobile ? 12 : 18),

        // LEFT AND RIGHT
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'LEFT AND RIGHT',
            style: TextStyle(
              color: const Color(0xFF142B42),
              fontSize: mobile
                  ? 27
                  : compact
                  ? 32
                  : 44,
              fontWeight: FontWeight.w700,
              letterSpacing: mobile ? 1.5 : 2.5,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // SUBTÍTULO
        Text(
          'ANÁLISIS POLÍTICO',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF65758B),
            fontSize: mobile ? 12 : 15,
            fontWeight: FontWeight.w500,
            letterSpacing: mobile ? 3 : 4,
          ),
        ),

        SizedBox(height: mobile ? 25 : 45),

        // LÍNEA
        Container(
          width: mobile ? 55 : 90,
          height: 2,
          color: const Color(0xFFD9DEE5),
        ),

        SizedBox(height: mobile ? 22 : 35),

        // DESCRIPCIÓN
        Padding(
          padding: EdgeInsets.symmetric(horizontal: mobile ? 15 : 20),
          child: Text(
            'Datos, análisis y perspectivas\npara un mejor debate.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF607086),
              fontSize: mobile ? 15 : 19,
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGIN CARD
  // ============================================================

  Widget _buildLoginCard({bool mobile = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 24 : 48,
        vertical: mobile ? 30 : 48,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(mobile ? 18 : 12),
        border: Border.all(color: const Color(0xFFE5E8EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITULO
          Center(
            child: Text(
              'Iniciar sesión',
              style: TextStyle(
                color: const Color(0xFF142B42),
                fontSize: mobile ? 28 : 40,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // DESCRIPCIÓN
          Center(
            child: Text(
              'Accede para continuar con tu análisis político\ny ver tu progreso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF718096),
                fontSize: mobile ? 14 : 17,
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: mobile ? 30 : 45),

          // EMAIL
          _buildLabel('Correo electrónico'),

          const SizedBox(height: 10),

          _buildTextField(
            controller: _emailController,
            hintText: 'Ingresa tu correo electrónico',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),

          SizedBox(height: mobile ? 22 : 30),

          // PASSWORD
          _buildLabel('Contraseña'),

          const SizedBox(height: 10),

          _buildTextField(
            controller: _passwordController,
            hintText: 'Ingresa tu contraseña',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF718096),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // TERMS
          _buildTermsCheckbox(),

          const SizedBox(height: 25),

          // LOGIN BUTTON
          _buildLoginButton(),

          const SizedBox(height: 30),

          // DIVIDER
          Container(height: 1, color: const Color(0xFFE5E8EC)),

          const SizedBox(height: 25),

          // CREATE ACCOUNT
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  '¿No tienes una cuenta? ',
                  style: TextStyle(color: Color(0xFF718096), fontSize: 14),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Ir a crear cuenta
                    },
                    child: const Text(
                      'Crear cuenta',
                      style: TextStyle(
                        color: Color(0xFF1769D1),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF24364B),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF24364B), fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9AA6B5), fontSize: 15),
        prefixIcon: Icon(icon, color: const Color(0xFF7A8797), size: 21),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1769D1), width: 1.5),
        ),
      ),
    );
  }

  // ============================================================
  // TERMS CHECKBOX
  // ============================================================

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (value) {
              setState(() {
                _acceptedTerms = value ?? false;
              });
            },
            activeColor: const Color(0xFF142B42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: Color(0xFF9AA6B5)),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 13,
                height: 1.4,
              ),
              children: [
                TextSpan(text: 'Acepto los '),
                TextSpan(
                  text: 'Términos y Condiciones',
                  style: TextStyle(
                    color: Color(0xFF1769D1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: ' y la '),
                TextSpan(
                  text: 'Política de Privacidad',
                  style: TextStyle(
                    color: Color(0xFF1769D1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _acceptedTerms
            ? () {
                // TODO: Login
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF142B42),
          disabledBackgroundColor: const Color(0xFFD9DEE5),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF8B96A4),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: const Text(
          'Iniciar sesión',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
