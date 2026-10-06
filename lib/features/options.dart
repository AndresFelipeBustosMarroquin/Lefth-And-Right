import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:left_and_right/features/test.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({required this.email, super.key});

  final String email;

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _FactText extends StatefulWidget {
  const _FactText({super.key, required this.text});

  final String text;

  @override
  State<_FactText> createState() => _FactTextState();
}

class _FactTextState extends State<_FactText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant _FactText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characters = widget.text.split('');

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = Curves.easeInOut.transform(_controller.value);
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              for (var i = 0; i < characters.length; i++)
                TextSpan(
                  text: characters[i] == ' ' ? '\u00A0' : characters[i],
                  style: TextStyle(
                    color: const Color(0xFF142B42).withValues(
                      alpha: (progress * 1.2 - (i / characters.length) * 0.5)
                          .clamp(0.0, 1.0)
                          .toDouble(),
                    ),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _OptionsScreenState extends State<OptionsScreen> {
  static const List<String> _politicalFacts = [
    'La Constitución Política de Colombia vigente fue promulgada en 1991.',
    'Colombia tiene tres ramas principales del poder público: ejecutiva, legislativa y judicial.',
    'La Rama Legislativa está representada principalmente por el Congreso de la República.',
    'El Congreso colombiano está compuesto por el Senado y la Cámara de Representantes.',
    'Una de las funciones del Congreso es elaborar leyes.',
    'El Congreso también ejerce control político sobre el Gobierno.',
    'El Congreso puede reformar la Constitución mediante actos legislativos.',
    'La Rama Ejecutiva está encabezada por el Presidente de la República.',
    'El Presidente es jefe de Estado, jefe de Gobierno y suprema autoridad administrativa.',
    'Los ministros forman parte del Gobierno Nacional.',
    'Los departamentos administrativos también forman parte del Gobierno Nacional.',
    'El Presidente dirige las relaciones internacionales de Colombia.',
    'El Presidente es comandante supremo de las Fuerzas Armadas.',
    'El Presidente tiene responsabilidades constitucionales relacionadas con el orden público.',
    'Colombia utiliza elecciones para escoger diferentes autoridades públicas.',
    'Las elecciones del Congreso de 2026 se realizaron el 8 de marzo.',
    'Las elecciones presidenciales de 2026 están contempladas para el 31 de mayo.',
    'La Registraduría publica información sobre los procesos electorales nacionales.',
    'El preconteo electoral tiene carácter informativo y no constituye el resultado jurídico definitivo.',
    'Los escrutinios verifican y consolidan oficialmente los resultados electorales.',
    'Los ciudadanos pueden participar en elecciones mediante el voto.',
    'El Senado y la Cámara representan diferentes circunscripciones electorales.',
    'El Congreso ejerce una función constituyente además de su función legislativa.',
    'El Congreso tiene determinadas funciones judiciales frente a altos funcionarios en circunstancias establecidas por la Constitución.',
    'El Congreso también cumple determinadas funciones electorales.',
    'Las funciones de las instituciones públicas están delimitadas por la Constitución y la ley.',
    'Ninguna autoridad pública puede ejercer funciones diferentes de aquellas que le atribuyen la Constitución y la ley.',
    'Las ramas del poder tienen funciones separadas, pero deben colaborar para cumplir los fines del Estado.',
    'Colombia cuenta con órganos autónomos e independientes dentro de su estructura estatal.',
    'La organización electoral forma parte de la estructura institucional del Estado colombiano.',
    'Colombia cuenta con organismos de control dentro de su estructura estatal.',
    'Los partidos que no participan en el Gobierno pueden ejercer oposición política bajo las reglas establecidas por la ley.',
    'La Constitución reconoce derechos para los partidos y movimientos minoritarios.',
    'El Estatuto de la Oposición está relacionado con los derechos de las organizaciones políticas que se declaran en oposición.',
    'Los ciudadanos eligen representantes para ejercer funciones públicas en su nombre.',
    'El Congreso puede citar a ministros y otras autoridades para ejercer control político.',
    'La moción de censura es uno de los mecanismos relacionados con el control político del Congreso.',
    'El Senado tiene atribuciones específicas establecidas por la Constitución y la ley.',
    'La Cámara de Representantes también tiene atribuciones específicas establecidas por la Constitución y la ley.',
    'Las elecciones cuentan con jurados de votación encargados de funciones durante la jornada electoral.',
    'La Registraduría publica actas electorales como parte del proceso de resultados.',
    'Colombia tiene elecciones territoriales para escoger autoridades de departamentos y municipios.',
    'Entre las autoridades territoriales elegidas mediante voto se encuentran gobernadores y alcaldes.',
    'También existen asambleas departamentales y concejos municipales y distritales.',
    'El Presidente de Colombia ejerce un período constitucional de cuatro años.',
    'Gustavo Petro fue elegido Presidente de Colombia en 2022.',
    'Francia Márquez fue elegida Vicepresidenta junto con Gustavo Petro en 2022.',
    'Gustavo Petro fue anteriormente alcalde mayor de Bogotá entre 2012 y 2015.',
    'Antes de llegar a la Presidencia, Gustavo Petro fue senador de la República.',
    'La política colombiana involucra instituciones nacionales, territoriales, partidos, movimientos políticos y mecanismos de participación ciudadana.',
  ];

  final Random _random = Random();
  late Timer _timer;
  int _currentFactIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentFactIndex = _random.nextInt(_politicalFacts.length);
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      setState(() {
        int nextIndex = _random.nextInt(_politicalFacts.length);
        while (nextIndex == _currentFactIndex && _politicalFacts.length > 1) {
          nextIndex = _random.nextInt(_politicalFacts.length);
        }
        _currentFactIndex = nextIndex;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Volver al inicio de sesión',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: const Color(0xFF142B42),
                    ),
                  ),
                  const Icon(Icons.balance, size: 64, color: Color(0xFF142B42)),
                  const SizedBox(height: 20),
                  const Text(
                    'LEFT AND RIGHT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF142B42),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF142B42),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '¿Sabías que…?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDEE5EE)),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 700),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: _FactText(
                        key: ValueKey<String>(_politicalFacts[_currentFactIndex]),
                        text: _politicalFacts[_currentFactIndex],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TestScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Iniciar test'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF142B42),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
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
}
