import 'package:flutter/material.dart';
import 'package:left_and_right/features/result.dart';
import 'package:left_and_right/models/question.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int currentQuestion = 0;
  int? selectedAnswer;

  final List<int> scores = [];
  final List<int> _answers = [];

  final List<Question> questions = [
    Question(
      category: 'Economía',
      text: '¿Qué papel debería tener el Estado en la economía?',
      weight: 2,
      options: [
        'Debería intervenir mucho para reducir las desigualdades.',
        'Debería intervenir en áreas importantes.',
        'Debería buscar un equilibrio entre Estado y mercado.',
        'Debería intervenir poco y dejar más espacio al mercado.',
        'Debería intervenir lo mínimo posible.',
      ],
    ),
    Question(
      category: 'Economía',
      text: '¿Cómo debería funcionar el sistema de impuestos?',
      weight: 2,
      options: [
        'Quienes tienen mayores ingresos deberían pagar mucho más.',
        'Debería existir una diferencia importante según los ingresos.',
        'Debería buscarse un equilibrio entre impuestos y capacidad de pago.',
        'Los impuestos deberían ser relativamente bajos.',
        'Los impuestos deberían ser lo más bajos posible.',
      ],
    ),
    Question(
      category: 'Economía',
      text: '¿Qué papel deberían tener las empresas privadas?',
      options: [
        'El Estado debería tener una participación importante en sectores estratégicos.',
        'El Estado debería regular fuertemente a las empresas.',
        'Debería existir equilibrio entre regulación y libertad empresarial.',
        'Las empresas deberían tener bastante libertad para operar.',
        'El Estado debería intervenir lo mínimo posible en las empresas.',
      ],
    ),
    Question(
      category: 'Estado y gobierno',
      text: '¿Cómo debería enfrentar el Estado la delincuencia?',
      weight: 2,
      options: [
        'Debería priorizar principalmente la prevención y las causas sociales.',
        'Debería combinar prevención con una respuesta policial moderada.',
        'Debería equilibrar prevención, justicia y seguridad.',
        'Debería fortalecer las medidas policiales y judiciales.',
        'Debería priorizar medidas de seguridad y control más estrictas.',
      ],
    ),
    Question(
      category: 'Sociedad',
      text: '¿Qué debería hacer el Estado frente a las desigualdades sociales?',
      weight: 2,
      options: [
        'Reducirlas activamente mediante políticas públicas.',
        'Reducirlas mediante programas sociales importantes.',
        'Buscar un equilibrio entre igualdad y responsabilidad individual.',
        'Priorizar principalmente la igualdad de oportunidades.',
        'Dejar que las diferencias dependan principalmente de las decisiones individuales.',
      ],
    ),
    Question(
      category: 'Sociedad',
      text: '¿Qué importancia debería tener la responsabilidad individual?',
      options: [
        'Las condiciones sociales influyen mucho en las oportunidades de cada persona.',
        'La sociedad tiene una responsabilidad importante sobre las oportunidades.',
        'La responsabilidad debería compartirse entre individuo y sociedad.',
        'La responsabilidad individual debería tener bastante peso.',
        'Cada persona debería ser principalmente responsable de sus resultados.',
      ],
    ),
    Question(
      category: 'Sociedad',
      text: '¿Cómo debería garantizarse el acceso a la educación?',
      weight: 2,
      options: [
        'El Estado debería garantizar ampliamente el acceso gratuito.',
        'El Estado debería financiar una parte importante de la educación.',
        'Deberían combinarse recursos públicos y privados.',
        'Debería existir mayor participación privada.',
        'La educación debería depender principalmente de opciones privadas.',
      ],
    ),
    Question(
      category: 'Valores y cultura',
      text:
          '¿Qué papel debería tener la religión en las decisiones del Estado?',
      options: [
        'Debería existir una separación estricta entre religión y Estado.',
        'Debería tener poca influencia en las decisiones públicas.',
        'El Estado debería ser neutral y respetar todas las creencias.',
        'Las tradiciones religiosas podrían tener cierta influencia.',
        'Las tradiciones religiosas deberían tener una influencia importante.',
      ],
    ),
    Question(
      category: 'Valores y cultura',
      text: '¿Cómo debería responder la sociedad ante los cambios culturales?',
      weight: 2,
      options: [
        'Debería promover activamente los cambios sociales.',
        'Debería facilitar los cambios y respetar la diversidad.',
        'Debería equilibrar cambio y tradición.',
        'Debería proteger algunas tradiciones frente a cambios rápidos.',
        'Debería priorizar la conservación de las tradiciones.',
      ],
    ),
    Question(
      category: 'Valores y cultura',
      text: '¿Cómo debería abordar el Estado los debates sobre valores personales?',
      options: [
        'Debería proteger ampliamente la libertad individual.',
        'Debería intervenir muy poco en las decisiones personales.',
        'Debería equilibrar libertad individual y otros intereses sociales.',
        'Debería establecer algunos límites basados en normas sociales.',
        'Debería dar mayor importancia a los valores tradicionales.',
      ],
    ),
    Question(
      category: 'Contexto colombiano',
      text: '¿Qué estrategia debería priorizarse para avanzar frente al conflicto armado en Colombia?',
      options: [
        'Priorizar el diálogo, la negociación y la implementación de acuerdos.',
        'Combinar negociación con garantías firmes de seguridad y justicia.',
        'Equilibrar diálogo, protección de la población y acción institucional.',
        'Dar mayor prioridad a operaciones de seguridad y control territorial.',
        'Priorizar una respuesta militar y de seguridad más intensiva.',
      ],
    ),
    Question(
      category: 'Contexto colombiano',
      text: '¿Qué debería hacerse cuando circula información política dudosa en redes sociales?',
      weight: 2,
      options: [
        'Priorizar la verificación independiente y la educación mediática, evitando restricciones estatales.',
        'Promover verificaciones transparentes y corregir contenidos engañosos con medidas limitadas.',
        'Combinar transparencia, alfabetización digital y reglas claras con garantías de expresión.',
        'Exigir a las plataformas una moderación más activa bajo supervisión pública.',
        'Permitir una intervención estatal amplia para retirar contenido político considerado falso.',
      ],
    ),
    Question(
      category: 'Estado y gobierno',
      text: '¿Qué mecanismo debería tener mayor peso para controlar las decisiones del Gobierno?',
      options: [
        'Controles institucionales estrictos y supervisión independiente.',
        'Controles legislativos y judiciales sólidos, junto con rendición de cuentas.',
        'Un equilibrio entre capacidad de gobierno y contrapesos institucionales.',
        'Mayor margen de acción para el Gobierno, con controles posteriores.',
        'Amplias facultades para el Ejecutivo y menos restricciones institucionales.',
      ],
    ),
    Question(
      category: 'Derechos y libertades',
      text: '¿Qué tan amplia debería ser la libertad de expresión?',
      options: [
        'Debería protegerse de manera muy amplia.',
        'Debería tener pocas restricciones.',
        'Debería equilibrarse con otros derechos.',
        'Debería tener restricciones más amplias en algunos casos.',
        'Debería limitarse ampliamente cuando pueda afectar el orden social.',
      ],
    ),
    Question(
      category: 'Derechos y libertades',
      text: '¿Qué debería priorizar el Estado frente a la privacidad?',
      options: [
        'La privacidad debería tener una protección muy amplia.',
        'El Estado debería necesitar fuertes razones para intervenir.',
        'Debería existir equilibrio entre privacidad y seguridad.',
        'La seguridad podría justificar algunas intervenciones.',
        'La seguridad debería tener prioridad en muchos casos.',
      ],
    ),
    Question(
      category: 'Derechos y libertades',
      text: '¿Cómo debería actuar el Estado frente a las libertades individuales?',
      weight: 2,
      options: [
        'Debería protegerlas ampliamente.',
        'Debería limitarse únicamente en casos necesarios.',
        'Debería buscar un equilibrio entre libertad y orden.',
        'Debería establecer más límites cuando exista un riesgo social.',
        'Debería priorizar el orden incluso si implica mayores restricciones.',
      ],
    ),
    Question(
      category: 'Valores y cultura',
      text: '¿Qué papel debería tener el Estado frente a la igualdad de género y el reconocimiento de la identidad de género?',
      options: [
        'Desarrollar políticas activas y amplias para garantizar igualdad y reconocimiento.',
        'Proteger estos derechos con medidas públicas y atención a la no discriminación.',
        'Equilibrar la protección de derechos, la libertad personal y el pluralismo.',
        'Limitar las políticas estatales y dar más espacio a decisiones familiares y comunitarias.',
        'Reducir la intervención estatal y priorizar las normas y tradiciones sociales existentes.',
      ],
    ),
    Question(
      category: 'Valores y cultura',
      text: '¿Cómo debería regularse el aborto?',
      options: [
        'Debe ser legal, segura y accesible a solicitud de la mujer.',
        'Debe ser legal durante un plazo amplio, con información y atención sanitaria.',
        'Debe permitirse bajo causales definidas, con garantías de salud y debido proceso.',
        'Debe limitarse a circunstancias excepcionales, como riesgo grave para la salud.',
        'Debe prohibirse salvo cuando sea indispensable para proteger la vida de la mujer.',
      ],
    ),
    Question(
      category: 'Valores y cultura',
      text:
          '¿A partir de qué edad deberían poder acceder jóvenes trans a tratamientos médicos de afirmación de género, con evaluación especializada y consentimiento informado?',
      options: [
        'Desde antes de los 16 años, con evaluación individual y salvaguardas clínicas.',
        'A partir de los 16 años, con evaluación especializada y consentimiento informado.',
        'A partir de los 18 años, con evaluación especializada y consentimiento informado.',
        'A partir de los 21 años, tras valoración especializada.',
        'No deberían permitirse estos tratamientos médicos a ninguna edad.',
      ],
    ),
    Question(
      category: 'Valores y cultura',
      text:
          '¿Qué papel deberían tener las medidas de acción afirmativa, como los cupos, para reducir brechas de género?',
      options: [
        'Aplicarlas ampliamente mientras persistan desigualdades medibles.',
        'Usarlas de forma temporal en ámbitos donde exista subrepresentación.',
        'Combinar medidas temporales con políticas universales de igualdad de oportunidades.',
        'Priorizar políticas universales y evitar cupos por género.',
        'No establecer medidas diferenciadas por género; aplicar criterios individuales.',
      ],
    ),
    Question(
      category: 'Valores y cultura',
      text:
          '¿Qué enfoque debería orientar las políticas públicas inspiradas por el feminismo?',
      options: [
        'Transformar de manera amplia las estructuras que reproducen desigualdades de género.',
        'Priorizar reformas y servicios públicos para corregir desigualdades estructurales.',
        'Combinar igualdad ante la ley con medidas focalizadas donde se detecten brechas.',
        'Centrarse en igualdad jurídica y evitar políticas basadas en grupos.',
        'Limitar la intervención pública y dejar estos cambios principalmente a decisiones individuales y sociales.',
      ],
    ),
    Question(
      category: 'Valores y cultura',
      text: '¿Qué reconocimiento jurídico deberían tener las parejas del mismo sexo?',
      options: [
        'Los mismos derechos y la misma figura legal del matrimonio civil.',
        'Igualdad de derechos mediante matrimonio civil o una figura equivalente.',
        'Una unión civil con protecciones legales amplias, aunque diferenciada del matrimonio.',
        'Una figura legal limitada, sin equiparación plena de derechos.',
        'No crear una figura legal equivalente al matrimonio para estas parejas.',
      ],
    ),
    Question(
      category: 'Estado y gobierno',
      text: '¿Qué diseño institucional considera más adecuado para formar el Gobierno nacional?',
      options: [
        'Un sistema parlamentario donde el Gobierno dependa de la confianza del Congreso.',
        'Un sistema parlamentario con acuerdos entre partidos y controles legislativos.',
        'Un sistema presidencial con separación de poderes y controles equilibrados.',
        'Un sistema presidencial con mayor capacidad de decisión para el Ejecutivo.',
        'Un Ejecutivo con amplias facultades para decidir y pocos controles durante su mandato.',
      ],
    ),
    Question(
      category: 'Organización política',
      text: '¿Qué modelo territorial de Estado considera más adecuado para Colombia?',
      options: [
        'Un Estado federal con amplia autonomía y competencias para sus territorios.',
        'Un Estado federal con coordinación nacional en asuntos comunes.',
        'Un Estado unitario descentralizado que combine coordinación y autonomía territorial.',
        'Un Estado unitario con más decisiones y recursos en el Gobierno nacional.',
        'Un Estado unitario centralizado con competencias principalmente nacionales.',
      ],
    ),
    Question(
      category: 'Participación ciudadana',
      text: '¿Qué forma de participación debería tener mayor peso en las decisiones públicas?',
      options: [
        'Mecanismos frecuentes de decisión directa por parte de la ciudadanía.',
        'Asambleas ciudadanas y consultas vinculantes en temas relevantes.',
        'Combinar representación electa con mecanismos participativos.',
        'Priorizar las decisiones de representantes electos con consultas ocasionales.',
        'Dejar la mayoría de las decisiones en manos de representantes e instituciones especializadas.',
      ],
    ),
  ];

  late final List<List<int>> _optionOrders = questions.map((question) {
    final order = List<int>.generate(question.options.length, (index) => index);
    order.shuffle();
    return order;
  }).toList();

  void nextQuestion() {
    if (selectedAnswer == null) {
      return;
    }

    final originalAnswerIndex = _optionOrders[currentQuestion][selectedAnswer!];
    final weightedScore =
        (originalAnswerIndex - 2) * questions[currentQuestion].weight;

    if (currentQuestion < scores.length) {
      scores[currentQuestion] = weightedScore;
      _answers[currentQuestion] = originalAnswerIndex;
    } else {
      scores.add(weightedScore);
      _answers.add(originalAnswerIndex);
    }

    if (currentQuestion == questions.length - 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultScreen(questions: questions, scores: scores),
        ),
      );

      return;
    }

    setState(() {
      currentQuestion++;
      selectedAnswer = currentQuestion < _answers.length
          ? _optionOrders[currentQuestion].indexOf(_answers[currentQuestion])
          : null;
    });
  }

  void _goBack() {
    if (currentQuestion == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      currentQuestion--;
      selectedAnswer = _optionOrders[currentQuestion].indexOf(
        _answers[currentQuestion],
      );
    });
  }

  void showHowItWorks() {
    showDialog(
      context: context,
      builder: (context) {
        final screenHeight = MediaQuery.sizeOf(context).height;

        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 380,
              maxHeight: screenHeight * 0.9,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF142B42),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          '¿Cómo funciona?',
                          style: TextStyle(
                            color: Color(0xFF172033),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Descubre dónde te ubicas en el espectro político '
                    'a través de tus opiniones.',
                    style: TextStyle(
                      color: Color(0xFF526071),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _howItWorksStep(
                    number: 1,
                    title: 'Responde las preguntas',
                    description:
                        'Te mostraremos preguntas sobre diferentes temas '
                        'políticos y sociales.',
                  ),
                  const Divider(height: 18, color: Color(0xFFE8ECF1)),
                  _howItWorksStep(
                    number: 2,
                    title: 'Elige según tu opinión',
                    description:
                        'No existen respuestas correctas o incorrectas. '
                        'Responde según lo que realmente piensas.',
                  ),
                  const Divider(height: 18, color: Color(0xFFE8ECF1)),
                  _howItWorksStep(
                    number: 3,
                    title: 'Descubre tu ubicación',
                    description:
                        'A medida que respondas, analizaremos tus respuestas '
                        'para estimar tu posición en el espectro.',
                  ),
                  const SizedBox(height: 12),
                  _buildPoliticalSpectrum(),
                  const Divider(height: 22, color: Color(0xFFE8ECF1)),
                  _howItWorksStep(
                    number: 4,
                    title: 'Conoce tu resultado',
                    description:
                        'Al finalizar podrás consultar tu ubicación general '
                        'y cómo se distribuyen tus respuestas en diferentes '
                        'dimensiones.',
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F5F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF142B42),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tus respuestas son anónimas',
                                style: TextStyle(
                                  color: Color(0xFF172033),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'No buscamos juzgar tus opiniones. El objetivo '
                                'es ayudarte a conocer mejor tu propia '
                                'posición política.',
                                style: TextStyle(
                                  color: Color(0xFF526071),
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF142B42),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Entendido',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _howItWorksStep({
    required int number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF142B42),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF172033),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF526071),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPoliticalSpectrum() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2463B5),
                    Color(0xFF5B9BE8),
                    Color(0xFFD1D8E2),
                    Color(0xFFE78B77),
                    Color(0xFFB83D32),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF172033),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Izquierda',
              style: TextStyle(color: Color(0xFF526071), fontSize: 10),
            ),
            Text(
              'Centro',
              style: TextStyle(color: Color(0xFF526071), fontSize: 10),
            ),
            Text(
              'Derecha',
              style: TextStyle(color: Color(0xFF526071), fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

    final progress = (currentQuestion + 1) / questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Text(
                    'Análisis político',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: showHowItWorks,
                    icon: const Icon(Icons.info_outline_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pregunta ${currentQuestion + 1} de ${questions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE2E7EF),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF142B42)),
                ),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EEF3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  question.category,
                  style: const TextStyle(
                    color: Color(0xFF142B42),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                question.text,
                style: const TextStyle(
                  fontSize: 25,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 22),

              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final selected = selectedAnswer == index;
                    final optionIndex = _optionOrders[currentQuestion][index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAnswer = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFE9EEF3)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF142B42)
                                : const Color(0xFFE0E5EC),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? const Color(0xFF142B42)
                                    : const Color(0xFFF0F2F6),
                              ),
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF687386),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.options[optionIndex],
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: selectedAnswer == null ? null : nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF142B42),
                    disabledBackgroundColor: const Color(0xFFD7DCE5),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF8A919D),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    currentQuestion == questions.length - 1
                        ? 'Ver resultado'
                        : 'Continuar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
