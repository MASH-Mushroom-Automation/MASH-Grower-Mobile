import 'package:flutter/material.dart';

class RegistrationStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepLabels;

  const RegistrationStepIndicator({
    super.key,
    required this.currentStep,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(
          stepLabels.length,
          (index) => Expanded(
            child: _buildStep(context, index),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, int index) {
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final primaryColor = const Color(0xFF2D5F4C); // Dark green from design
    final completedColor = primaryColor;
    final currentColor = primaryColor;
    final inactiveColor = Colors.grey.shade300;

    return Row(
      children: [
        // Circle with number or checkmark
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? completedColor
                : isCurrent
                    ? currentColor
                    : inactiveColor,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        
        // Line connecting to next step (except for last step)
        if (index < stepLabels.length - 1)
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: index < currentStep ? completedColor : inactiveColor,
            ),
          ),
      ],
    );
  }
}

class RegistrationStepIndicatorWithLabels extends StatelessWidget {
  final int currentStep;
  final List<String> stepLabels;

  const RegistrationStepIndicatorWithLabels({
    super.key,
    required this.currentStep,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step circles with connecting lines
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: List.generate(
              stepLabels.length * 2 - 1,
              (index) {
                if (index.isEven) {
                  // Circle
                  final stepIndex = index ~/ 2;
                  final isCompleted = stepIndex < currentStep;
                  final isCurrent = stepIndex == currentStep;
                  final primaryColor = const Color(0xFF2D5F4C);
                  final inactiveColor = Colors.grey.shade300;
                  
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isCurrent ? primaryColor : inactiveColor,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(
                              '${stepIndex + 1}',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  );
                } else {
                  // Line
                  final stepIndex = index ~/ 2;
                  final isCompleted = stepIndex < currentStep;
                  final primaryColor = const Color(0xFF2D5F4C);
                  final inactiveColor = Colors.grey.shade300;
                  
                  return Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: isCompleted ? primaryColor : inactiveColor,
                    ),
                  );
                }
              },
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              stepLabels.length,
              (index) => SizedBox(
                width: 36,
                child: Text(
                  stepLabels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: index == currentStep ? FontWeight.bold : FontWeight.normal,
                    color: index <= currentStep
                        ? const Color(0xFF2D5F4C)
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
