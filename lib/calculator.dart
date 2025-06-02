import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({Key? key}) : super(key: key);

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  String _expression = '';

  static const Color _displayColor = Color(0xFFFFF1D5);
  static const Color _digitButtonColor = Color(0xFFA67C52);
  static const Color _operatorButtonColor = Color(0xFF5C3A21);
  static const Color _textColorDark = Color(0xFF3A2A1C);
  static const Color _textColorLight = Color(0xFFF5E8D0);

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
      } else if (value == '=') {
        _calculateResult();
      } else {
        _expression += value;
      }
    });
  }

  void _calculateResult() {
    if (_expression.isEmpty) return;

    String parsedExp = _expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');

    try {
      Parser p = Parser();
      Expression exp = p.parse(parsedExp);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      String resultStr = eval.toStringAsFixed(
        eval.truncateToDouble() == eval ? 0 : 6,
      );
      _expression = resultStr;
    } catch (e) {
      _expression = 'Error';
    }
  }

  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: _displayColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _expression.isEmpty ? '0' : _expression,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: _textColorDark,
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: Material(
            color: bgColor,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              highlightColor: textColor.withOpacity(0.2),
              splashColor: Colors.transparent,
              onTap: onTap,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          children: [
            _buildButton(
              label: '7',
              bgColor: _digitButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('7'),
            ),
            _buildButton(
              label: '8',
              bgColor: _digitButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('8'),
            ),
            _buildButton(
              label: '9',
              bgColor: _digitButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('9'),
            ),
            _buildButton(
              label: '÷',
              bgColor: _operatorButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('÷'),
            ),
          ],
        ),
        Row(
          children: [
            _buildButton(
              label: '4',
              bgColor: _digitButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('4'),
            ),
            _buildButton(
              label: '5',
              bgColor: _digitButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('5'),
            ),
            _buildButton(
              label: '6',
              bgColor: _digitButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('6'),
            ),
            _buildButton(
              label: '×',
              bgColor: _operatorButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('×'),
            ),
          ],
        ),
        Row(
          children: [
            _buildButton(
              label: '1',
              bgColor: _digitButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('1'),
            ),
            _buildButton(
              label: '2',
              bgColor: _digitButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('2'),
            ),
            _buildButton(
              label: '3',
              bgColor: _digitButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('3'),
            ),
            _buildButton(
              label: '−',
              bgColor: _operatorButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('−'),
            ),
          ],
        ),
        Row(
          children: [
            _buildButton(
              label: '0',
              bgColor: _digitButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('0'),
            ),
            _buildButton(
              label: 'C',
              bgColor: _digitButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('C'),
            ),
            _buildButton(
              label: '=',
              bgColor: _digitButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('='),
            ),
            _buildButton(
              label: '+',
              bgColor: _operatorButtonColor,
              textColor: _textColorLight,
              onTap: () => _onButtonPressed('+'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Calculator',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            _buildDisplay(),
            const SizedBox(height: 24),
            Expanded(child: _buildKeypad()),
          ],
        ),
      ),
    );
  }
}
