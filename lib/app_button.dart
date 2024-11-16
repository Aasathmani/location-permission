import 'dart:ffi';

import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Widget? child;
  final String? label;
  final TextStyle? labelStyle;
  final EdgeInsets? labelPadding;
  final VoidCallback onTap;
  final Color? color;
  final Color? disabledColor;
  final Color? labelColor;
  final Color? disabledLabelColor;
  final double elevation;
  final double height;
  final BorderRadius? borderRadius;
  final BorderSide borderSide;
  final FocusNode? focusNode;

  final bool enabled;

  const AppButton({
    super.key,
    this.child,
    this.label,
    this.labelStyle,
    required this.onTap,
    this.color,
    this.disabledColor,
    this.labelColor,
    this.disabledLabelColor,
    this.elevation = 0,
    this.height = 44,
    this.labelPadding,
    this.borderRadius,
    this.focusNode,
    this.enabled = true,
    this.borderSide = BorderSide.none,
  }) : assert(child != null || label != null);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !enabled,
      child: SizedBox(
        height: height,
        child: Material(
          color: enabled
              ? color ?? Theme.of(context).colorScheme.secondary
              : disabledColor ?? Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            side: borderSide,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          child: InkWell(
            focusNode: focusNode,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              onTap();
            },
            child: _getContentLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _getContentLayout(BuildContext context) {
    return child ??
        Padding(
          padding: labelPadding ??
              const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
            child: Center(
            child: Text(
              label ?? '',
              style: labelStyle ??
                  TextStyle(
                      color: enabled
                          ? labelColor ?? Colors.black
                          : disabledColor ?? Colors.white,fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        );
  }
}
