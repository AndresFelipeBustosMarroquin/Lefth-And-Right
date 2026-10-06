import 'package:flutter/material.dart';
import 'package:left_and_right/features/email_verification.dart';
import 'package:left_and_right/features/login.dart';
import 'package:left_and_right/services/auth_api.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _passwordRequirements =
      'Mínimo 6 caracteres, con mayúscula, minúscula, número y símbolo.';

  static const _obsceneWords = {
    'puta',
    'putas',
    'puto',
    'putos',
    'mierda',
    'mierdas',
    'joder',
    'jodido',
    'jodida',
    'cabron',
    'cabrona',
    'cabrones',
    'pendejo',
    'pendeja',
    'pendejos',
    'pendejas',
    'hijueputa',
    'gonorrea',
    'malparido',
    'malparida',
    'verga',
  };

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _showValidationErrors = false;
  bool _isSubmitting = false;

  bool _isValidEmail(String email) {
    return email.contains('@');
  }

  bool _containsObsceneWord(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll('ñ', 'n');
    final words = normalized.split(RegExp(r'[^a-z0-9]+'));

    return words.any(_obsceneWords.contains) ||
        words.join(' ').contains('hijo de puta');
  }

  bool _isValidPassword(String password) {
    return password.length >= 6 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(password);
  }

  bool _passwordsMatch() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  bool get _isRegisterFormValid {
    return _fullNameController.text.trim().isNotEmpty &&
        !_containsObsceneWord(_fullNameController.text) &&
        _isValidEmail(_emailController.text.trim()) &&
        _isValidPassword(_passwordController.text) &&
        _passwordsMatch() &&
        _acceptedTerms;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _showValidationErrors = true;
    });

    if (!_isRegisterFormValid) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    final email = _emailController.text.trim();

    try {
      await AuthApi.register(
        name: _fullNameController.text.trim(),
        email: email,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationScreen(email: email),
        ),
      );
    } on AuthApiException catch (error) {
      if (!mounted) return;
      if (error.code == 'EMAIL_PENDING') {
        var notice = 'Esta cuenta ya existe y aún no está confirmada.';
        try {
          await AuthApi.resendVerification(email);
          notice = 'La cuenta existe y aún no está confirmada. '
              'Enviamos un nuevo código a tu correo.';
        } on AuthApiException catch (resendError) {
          notice = resendError.message;
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: email,
              initialNotice: notice,
            ),
          ),
        );
      } else if (error.code == 'EMAIL_SEND_FAILED' ||
          error.code == 'EMAIL_NOT_CONFIGURED') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: email,
              initialNotice: error.message,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showTermsDialog() {
    showInfoDialog(
      context,
      title: 'Términos y tratamiento de datos',
      content: const LegalDocumentsContent(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? onVisibilityPressed,
    TextInputType? keyboardType,
    String? helperText,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Color(0xFF24364B), fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9AA6B5), fontSize: 15),
        prefixIcon: Icon(icon, color: const Color(0xFF7A8797), size: 21),
        suffixIcon: onVisibilityPressed == null
            ? null
            : IconButton(
                onPressed: onVisibilityPressed,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        helperText: helperText,
        errorText: errorText,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF24364B),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLegalCard({required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        border: Border.all(color: const Color(0xFFE5E8EC)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: const Color(0xFF718096)),
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildBranding({bool compact = false, bool mobile = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
        Container(
          width: mobile ? 55 : 90,
          height: 2,
          color: const Color(0xFFD9DEE5),
        ),
        SizedBox(height: mobile ? 22 : 35),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            if (width >= 1000) {
              return _buildDesktopLayout();
            }
            if (width >= 700) {
              return _buildTabletLayout();
            }
            return _buildMobileLayout();
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1450),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: _buildBranding()),
                const SizedBox(width: 70),
                Expanded(flex: 7, child: _buildRegisterCard()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
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
                _buildRegisterCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          children: [
            _buildBranding(compact: true, mobile: true),
            const SizedBox(height: 30),
            _buildRegisterCard(mobile: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterCard({bool mobile = false}) {
    final fullName = _fullNameController.text.trim();
    final fullNameError = _containsObsceneWord(fullName)
        ? 'El nombre no puede contener palabras obscenas.'
        : _showValidationErrors && fullName.isEmpty
        ? 'Ingresa tu nombre completo.'
        : null;
    final emailError =
        _showValidationErrors &&
            _emailController.text.trim().isNotEmpty &&
            !_isValidEmail(_emailController.text.trim())
        ? 'Ingresa un correo válido.'
        : null;
    final passwordError =
        _showValidationErrors && !_isValidPassword(_passwordController.text)
        ? _passwordRequirements
        : null;
    final confirmPasswordError =
        _showValidationErrors &&
            _confirmPasswordController.text.isNotEmpty &&
            !_passwordsMatch()
        ? 'Las contraseñas no coinciden.'
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 24 : 48,
        vertical: mobile ? 30 : 40,
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
          Center(
            child: Text(
              'Crear cuenta',
              style: TextStyle(
                color: const Color(0xFF142B42),
                fontSize: mobile ? 28 : 40,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: mobile ? 30 : 36),
          _buildFieldLabel('Nombre completo'),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _fullNameController,
            hintText: 'Ingresa tu nombre completo',
            icon: Icons.person_outline,
            errorText: fullNameError,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: mobile ? 22 : 26),
          _buildFieldLabel('Correo electrónico'),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _emailController,
            hintText: 'Ingresa tu correo electrónico',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            errorText: emailError,
            onChanged: (_) {
              if (_showValidationErrors) {
                setState(() {});
              }
            },
          ),
          SizedBox(height: mobile ? 22 : 26),
          _buildFieldLabel('Contraseña'),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _passwordController,
            hintText: 'Crea una contraseña',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            onVisibilityPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            helperText: _passwordRequirements,
            errorText: passwordError,
            onChanged: (_) {
              if (_showValidationErrors) {
                setState(() {});
              }
            },
          ),
          SizedBox(height: mobile ? 22 : 26),
          _buildFieldLabel('Confirmar contraseña'),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirma tu contraseña',
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            onVisibilityPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            errorText: confirmPasswordError,
            onChanged: (_) {
              if (_showValidationErrors) {
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 16),
          _buildLegalCard(
            icon: Icons.description_outlined,
            child: Row(
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
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF526071),
                        fontSize: 13,
                        height: 1.45,
                      ),
                      children: [
                        const TextSpan(text: 'He leído y acepto los '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: _showTermsDialog,
                            child: const Text(
                              'Términos, Condiciones y Política de Tratamiento de Datos',
                              style: TextStyle(
                                color: Color(0xFF142B42),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showValidationErrors && !_acceptedTerms)
            const Padding(
              padding: EdgeInsets.only(left: 48, top: 5),
              child: Text(
                'Debes aceptar los términos y la política de tratamiento de datos.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          SizedBox(height: mobile ? 25 : 30),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF142B42),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Crear cuenta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 30),
          Container(height: 1, color: const Color(0xFFE5E8EC)),
          const SizedBox(height: 25),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  '¿Ya tienes una cuenta? ',
                  style: TextStyle(color: Color(0xFF718096), fontSize: 14),
                ),
                GestureDetector(
                  onTap: _goToLogin,
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      color: Color(0xFF1769D1),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
}
