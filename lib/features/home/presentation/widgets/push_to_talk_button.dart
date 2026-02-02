import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PushToTalkButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isListening;

  const PushToTalkButton({
    super.key,
    required this.onPressed,
    required this.isListening,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: isListening ? AppTheme.errorColor : AppTheme.secondaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isListening ? AppTheme.errorColor : AppTheme.secondaryColor).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          isListening ? Icons.stop : Icons.mic,
          color: isListening ? Colors.white : AppTheme.primaryColor,
          size: 32,
        ),
      ),
    );
  }
}
