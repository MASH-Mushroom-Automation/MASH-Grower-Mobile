import 'package:flutter/material.dart';
import '../../../core/utils/password_strength_validator.dart';

/// Visual password strength indicator widget
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showDetails;

  const PasswordStrengthIndicator({
    Key? key,
    required this.password,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final result = PasswordStrengthValidator.validate(password);
    final color = _getStrengthColor(result.strength);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children:  [
        // Strength bar
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: result.score,
                  minHeight: 8,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              result.message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        if (showDetails && result.suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSuggestions(context, result),
        ],
        
        if (showDetails) ...[
          const SizedBox(height: 12),
          _buildRequirements(context, result),
        ],
      ],
    );
  }

  Widget _buildSuggestions(BuildContext context, PasswordStrengthResult result) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                'Suggestions:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...result.suggestions.map((suggestion) => Padding(
                padding: const EdgeInsets.only(left: 22, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRequirements(BuildContext context, PasswordStrengthResult result) {
    final theme = Theme.of(context);
    
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildRequirementChip(
          context,
          'Min ${PasswordStrengthValidator.minLength} chars',
          result.requirements['minLength']!,
        ),
        _buildRequirementChip(
          context,
          'Uppercase',
          result.requirements['hasUppercase']!,
        ),
        _buildRequirementChip(
          context,
          'Lowercase',
          result.requirements['hasLowercase']!,
        ),
        _buildRequirementChip(
          context,
          'Number',
          result.requirements['hasNumber']!,
        ),
        _buildRequirementChip(
          context,
          'Special char',
          result.requirements['hasSpecialChar']!,
        ),
      ],
    );
  }

  Widget _buildRequirementChip(BuildContext context, String label, bool met) {
    final theme = Theme.of(context);
    final color = met ? Colors.green : Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: met ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.amber;
      case PasswordStrength.strong:
        return Colors.lightGreen;
      case PasswordStrength.veryStrong:
        return Colors.green;
    }
  }
}

/// Compact password strength indicator (just the bar)
class CompactPasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const CompactPasswordStrengthIndicator({
    Key? key,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final result = PasswordStrengthValidator.validate(password);
    final color = _getStrengthColor(result.strength);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: result.score,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          result.message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: 11,
              ),
        ),
      ],
    );
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.amber;
      case PasswordStrength.strong:
        return Colors.lightGreen;
      case PasswordStrength.veryStrong:
        return Colors.green;
    }
  }
}
