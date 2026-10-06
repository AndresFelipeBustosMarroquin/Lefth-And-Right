import 'package:flutter/material.dart';
import 'package:left_and_right/features/email_verification.dart';
import 'package:left_and_right/features/forgot_password.dart';
import 'package:left_and_right/features/options.dart';
import 'package:left_and_right/features/register.dart';
import 'package:left_and_right/services/auth_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptedLegalDocuments = false;
  bool _showValidationErrors = false;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return email.contains('@');
  }

  bool get _isLoginFormValid {
    return _isValidEmail(_emailController.text.trim()) &&
        _passwordController.text.isNotEmpty &&
        _acceptedLegalDocuments;
  }

  void _goToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _enterAsGuest() {
    AuthSession.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OptionsScreen(email: 'Invitado'),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _showValidationErrors = true;
    });
    if (!_isLoginFormValid) return;

    setState(() {
      _isLoggingIn = true;
    });
    AuthSession.clear();
    final email = _emailController.text.trim();

    try {
      await AuthApi.login(email: email, password: _passwordController.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OptionsScreen(email: email)),
      );
    } on AuthApiException catch (error) {
      if (!mounted) return;
      AuthSession.clear();
      if (error.code == 'EMAIL_NOT_VERIFIED') {
        var notice = error.message;
        try {
          await AuthApi.resendVerification(email);
          notice =
              'Tu cuenta aún no está confirmada. '
              'Enviamos un nuevo código a tu correo.';
        } on AuthApiException catch (resendError) {
          notice = resendError.message;
        }
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmailVerificationScreen(email: email, initialNotice: notice),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
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
              return _buildDesktopLayout(width);
            }

            if (width >= 700) {
              return _buildTabletLayout(width);
            }

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: _buildBranding()),
              const SizedBox(width: 70),
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
          SizedBox(height: mobile ? 30 : 40),

          // ======================================================
          // CORREO
          // ======================================================
          _buildLabel('Correo electrónico'),

          const SizedBox(height: 10),

          _buildTextField(
            controller: _emailController,
            hintText: 'Ingresa tu correo electrónico',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            errorText:
                _showValidationErrors &&
                    !_isValidEmail(_emailController.text.trim())
                ? 'Ingresa un correo electrónico válido.'
                : null,
          ),

          SizedBox(height: mobile ? 22 : 30),

          // ======================================================
          // CONTRASEÑA
          // ======================================================
          _buildLabel('Contraseña'),

          const SizedBox(height: 10),

          _buildTextField(
            controller: _passwordController,
            hintText: 'Ingresa tu contraseña',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            errorText: _showValidationErrors && _passwordController.text.isEmpty
                ? 'Ingresa tu contraseña.'
                : null,
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

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForgotPasswordScreen(
                    initialEmail: _emailController.text.trim(),
                  ),
                ),
              ),
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: Color(0xFF1769D1),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: mobile ? 25 : 30),

          _buildLegalConsent(),

          const SizedBox(height: 25),

          // ======================================================
          // BOTÓN LOGIN
          // ======================================================
          _buildLoginButton(),

          const SizedBox(height: 10),

          Center(
            child: TextButton(
              onPressed: _enterAsGuest,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF142B42),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Entrar como invitado',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                  '¿No tienes una cuenta? ',
                  style: TextStyle(color: Color(0xFF718096), fontSize: 14),
                ),
                GestureDetector(
                  onTap: _goToRegister,
                  child: const Text(
                    'Crear cuenta',
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
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: (_) {
        if (_showValidationErrors) {
          setState(() {});
        }
      },
      style: const TextStyle(color: Color(0xFF24364B), fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
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

  Widget _buildLegalConsent() {
    return _buildLegalChoiceCard(
      icon: Icons.verified_user_outlined,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _acceptedLegalDocuments,
              onChanged: (value) {
                setState(() {
                  _acceptedLegalDocuments = value ?? false;
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
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF142B42),
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
    );
  }

  Widget _buildLegalChoiceCard({
    required IconData icon,
    required Widget child,
  }) {
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

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoggingIn ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF142B42),
          disabledBackgroundColor: const Color(0xFFD9DEE5),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF8B96A4),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: _isLoggingIn
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Iniciar sesión',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }

  // ============================================================
  // TÉRMINOS
  // ============================================================

  void _showTermsDialog() {
    _showInfoDialog(
      title: 'Términos y tratamiento de datos',
      content: const LegalDocumentsContent(),
    );
  }

  // ============================================================
  // DIÁLOGO
  // ============================================================

  void _showInfoDialog({required String title, required Widget content}) {
    showInfoDialog(context, title: title, content: content);
  }
}

void showInfoDialog(
  BuildContext context, {
  required String title,
  required Widget content,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 650),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF142B42),
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close, color: Color(0xFF718096)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E8EC)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: content,
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E8EC)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF142B42),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: const Text('Cerrar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ================================================================
// TÉRMINOS Y CONDICIONES
// ================================================================

class TermsContent extends StatelessWidget {
  const TermsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalDocument(
      content: '''
TÉRMINOS Y CONDICIONES DE USO – LEFT AND RIGHT

Última actualización: 25 de septiembre de 2026


1. IDENTIFICACIÓN DE LA APLICACIÓN

LEFT AND RIGHT es una aplicación web desarrollada en el contexto académico de la Corporación Tecnológica Industrial Colombiana – TEINCO.

Su propósito es permitir al usuario responder un conjunto de preguntas relacionadas con opiniones, valores y posiciones políticas, con el fin de generar una representación informativa de sus respuestas dentro de un modelo de clasificación ideológica.

La aplicación tiene fines académicos, informativos y de investigación.


2. ACEPTACIÓN DE LOS TÉRMINOS

Al acceder y utilizar LEFT AND RIGHT, el usuario declara que ha leído y comprendido estos Términos y Condiciones y que acepta las condiciones establecidas en ellos.

Si el usuario no está de acuerdo con alguna de estas condiciones, deberá abstenerse de utilizar la aplicación.


3. FINALIDAD DE LA APLICACIÓN

LEFT AND RIGHT permite al usuario explorar sus propias respuestas y obtener una representación estructurada de las mismas dentro del modelo ideológico utilizado por el proyecto.

Los resultados generados:

• No constituyen una verdad absoluta sobre la ideología del usuario.
• No representan una opinión oficial de TEINCO.
• No constituyen asesoramiento político.
• No deben utilizarse como fundamento exclusivo para tomar decisiones políticas, electorales, económicas o personales.
• No determinan las preferencias electorales futuras del usuario.
• No pretenden diagnosticar, evaluar o determinar la personalidad del usuario.

La aplicación presenta resultados derivados de las respuestas proporcionadas durante el cuestionario.


4. NATURALEZA DE LOS RESULTADOS

Las clasificaciones generadas corresponden a un modelo computacional y académico construido a partir de criterios previamente definidos por los desarrolladores.

Los resultados pueden no representar completamente la complejidad de las opiniones políticas de una persona.

La clasificación obtenida debe entenderse como una aproximación informativa y no como una determinación definitiva de la identidad política del usuario.


5. DATOS PERSONALES

Para el funcionamiento de la aplicación podrán recopilarse determinados datos proporcionados directamente por el usuario.

El tratamiento de datos personales se realizará de conformidad con la legislación colombiana aplicable en materia de protección de datos personales.


6. INFORMACIÓN RELACIONADA CON POSICIONES POLÍTICAS

Determinadas respuestas proporcionadas dentro del cuestionario pueden revelar información relacionada con la orientación o posición política del usuario.

Cuando dicha información tenga la naturaleza de dato sensible conforme a la legislación aplicable, LEFT AND RIGHT solicitará la autorización correspondiente y comunicará previamente al usuario la finalidad del tratamiento.


7. USO VOLUNTARIO

La participación del usuario en el cuestionario es voluntaria.

El usuario podrá decidir si desea proporcionar la información solicitada.

Cuando se trate de información sensible, su suministro estará sujeto a la autorización correspondiente y a las condiciones establecidas por la legislación aplicable.


8. USO DE LA INFORMACIÓN

La información recopilada podrá utilizarse para:

1. Procesar las respuestas proporcionadas por el usuario.
2. Generar los resultados correspondientes al modelo implementado.
3. Evaluar el funcionamiento de la aplicación.
4. Realizar análisis académicos o estadísticos cuando formen parte de la finalidad informada.
5. Mejorar el funcionamiento del sistema.

Cualquier finalidad adicional será informada al usuario cuando resulte necesario.


9. CONFIDENCIALIDAD Y SEGURIDAD

LEFT AND RIGHT implementará medidas razonables de seguridad destinadas a proteger la información contra pérdida, alteración, consulta, utilización o acceso no autorizado.

La información personal será tratada de acuerdo con los principios y obligaciones establecidos por la legislación aplicable.


10. DERECHOS DEL USUARIO

El usuario, como titular de sus datos personales, podrá ejercer los derechos reconocidos por la legislación colombiana, entre ellos:

• Conocer los datos objeto de tratamiento.
• Solicitar la actualización de la información.
• Solicitar la rectificación de datos incorrectos o incompletos.
• Solicitar la supresión de los datos cuando corresponda.
• Revocar la autorización cuando sea procedente.
• Presentar consultas o reclamos relacionados con el tratamiento de sus datos.

Para ejercer estos derechos, el usuario podrá comunicarse a:

bustosbustospipe123@gmail.com


11. USO RESPONSABLE

El usuario se compromete a utilizar LEFT AND RIGHT de manera responsable y lícita.

No deberá utilizar la aplicación para:

• Suplantar la identidad de otra persona.
• Introducir información deliberadamente falsa con el propósito de alterar el funcionamiento del sistema.
• Intentar acceder sin autorización a información de otros usuarios.
• Interferir con el funcionamiento de la aplicación.
• Utilizar los resultados para discriminar, acosar, perseguir o estigmatizar a otras personas.


12. NEUTRALIDAD DE LA APLICACIÓN

LEFT AND RIGHT se presenta como una herramienta de carácter académico e informativo.

La aplicación no representa a ningún partido político, candidato, movimiento político, campaña electoral o grupo ideológico.

La existencia de categorías o clasificaciones dentro del sistema no debe interpretarse como respaldo o rechazo hacia una determinada posición política.


13. LIMITACIONES DEL SISTEMA

Los resultados dependen de:

• Las respuestas proporcionadas.
• Las categorías definidas por el proyecto.
• Los criterios utilizados para procesar la información.
• El modelo conceptual empleado.
• Las limitaciones propias de cualquier sistema automatizado de clasificación.

LEFT AND RIGHT no garantiza que el resultado represente de manera completa todas las posiciones políticas, valores o convicciones del usuario.


14. PROPIEDAD INTELECTUAL

El software, diseño, estructura, textos, elementos gráficos y demás componentes originales de LEFT AND RIGHT estarán protegidos por las normas colombianas aplicables en materia de propiedad intelectual.

Salvo autorización expresa o cuando la legislación disponga lo contrario, el usuario no podrá reproducir, modificar, distribuir, comercializar o realizar ingeniería inversa sobre los componentes protegidos de la aplicación.


15. MODIFICACIONES

Los desarrolladores podrán actualizar estos Términos y Condiciones cuando resulte necesario debido a cambios en:

• La aplicación.
• Las funcionalidades ofrecidas.
• La legislación aplicable.
• Las políticas de tratamiento de datos.
• Las condiciones académicas del proyecto.

Cuando corresponda, se informará al usuario sobre modificaciones relevantes.


16. LEGISLACIÓN APLICABLE

Estos Términos y Condiciones se regirán por la legislación aplicable de la República de Colombia.

En materia de datos personales serán aplicables las normas colombianas correspondientes.

En materia de propiedad intelectual serán aplicables las normas colombianas correspondientes.


FIN DE LOS TÉRMINOS Y CONDICIONES
''',
    );
  }
}

class LegalDocumentsContent extends StatelessWidget {
  const LegalDocumentsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TermsContent(),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Divider(color: Color(0xFFE5E8EC)),
        ),
        _PrivacyContent(),
      ],
    );
  }
}

// ================================================================
// POLÍTICA DE PRIVACIDAD
// ================================================================

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return _LegalDocument(
      content: '''
AUTORIZACIÓN PARA EL TRATAMIENTO DE DATOS PERSONALES

LEFT AND RIGHT podrá tratar los datos personales proporcionados por el usuario con el propósito de permitir el funcionamiento de la aplicación y desarrollar las funcionalidades informadas.


FINALIDADES

La información podrá ser utilizada para:

• Gestionar la cuenta del usuario.
• Procesar las respuestas proporcionadas en el cuestionario.
• Generar los resultados del modelo implementado.
• Mantener el funcionamiento de la aplicación.
• Realizar análisis académicos o estadísticos cuando correspondan a la finalidad informada.
• Mejorar las funcionalidades de LEFT AND RIGHT.


INFORMACIÓN RELACIONADA CON POSICIONES POLÍTICAS

Algunas respuestas del cuestionario pueden revelar información relacionada con la orientación o posición política del usuario.

Cuando dicha información tenga la naturaleza de dato sensible, su tratamiento estará sujeto a la autorización correspondiente.

La participación en el cuestionario es voluntaria.


DERECHOS DEL TITULAR

El usuario podrá ejercer los derechos reconocidos por la legislación colombiana aplicable, incluyendo conocer, actualizar, rectificar y solicitar la supresión de sus datos cuando corresponda, así como revocar la autorización cuando legalmente proceda.

Para ejercer estos derechos:

bustosbustospipe123@gmail.com


DECLARACIÓN

Al seleccionar la casilla de autorización, el usuario manifiesta que ha sido informado sobre las finalidades del tratamiento y que autoriza el tratamiento de la información en los términos descritos anteriormente, cuando dicho tratamiento sea legalmente procedente.


FIN DE LA AUTORIZACIÓN
''',
    );
  }
}

class _LegalDocument extends StatelessWidget {
  const _LegalDocument({required this.content});

  final String content;

  bool _isSectionHeading(String line) {
    return RegExp(r'^\d+\.\s+[A-ZÁÉÍÓÚÜÑ]').hasMatch(line) ||
        (line.length > 3 && line == line.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final lines = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < lines.length; index++)
          if (index == 0)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E8EC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.article_outlined,
                    color: Color(0xFF142B42),
                    size: 22,
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      lines[index],
                      style: const TextStyle(
                        color: Color(0xFF142B42),
                        fontSize: 16,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (lines[index].startsWith('•'))
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lines[index].substring(1).trim(),
                      style: const TextStyle(
                        color: Color(0xFF35465A),
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_isSectionHeading(lines[index]))
            Container(
              margin: const EdgeInsets.only(top: 18, bottom: 9),
              padding: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(0xFF142B42), width: 3),
                ),
              ),
              child: Text(
                lines[index],
                style: const TextStyle(
                  color: Color(0xFF142B42),
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.25,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Text(
                lines[index],
                style: const TextStyle(
                  color: Color(0xFF35465A),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
      ],
    );
  }
}
