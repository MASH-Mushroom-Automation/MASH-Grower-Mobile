import 'package:flutter/material.dart';

class ValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;

  const ValidatedTextField({
    required this.controller,
    required this.label,
    required this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    super.key,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  String? _errorText;
  bool _hasBeenEdited = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_hasBeenEdited) {
      setState(() {
        _errorText = widget.validator(widget.controller.text);
      });
    }

    widget.onChanged?.call(widget.controller.text);
  }

  void _onFocusLost() {
    setState(() {
      _hasBeenEdited = true;
      _errorText = widget.validator(widget.controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          _onFocusLost();
        }
      },
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 2.0,
            ),
          ),
          errorText: _errorText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        ),
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        enabled: widget.enabled,
        textCapitalization: widget.textCapitalization,
        validator: widget.validator,
        autovalidateMode: AutovalidateMode.disabled, // We handle validation manually
      ),
    );
  }
}