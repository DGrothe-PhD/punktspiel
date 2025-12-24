import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:punktspiel/generated/l10n.dart';

class PointsEntryRow extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final void Function(String) onChanged;
  final S locale = S();

  PointsEntryRow({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Minus button
        IconButton(
          icon: const Icon(Icons.remove),
          tooltip: 'Minus',
          onPressed: enabled
              ? () {
                  final text = controller.text;
                  if ((int.tryParse(text)?? 0) > 0) {
                    final newText = '-$text';
                    controller.text = newText;
                    controller.selection = TextSelection.collapsed(offset: newText.length);
                    onChanged(newText);
                  }
                }
              : null,
        ),
        // Number input field
        Expanded(
          child: TextField(
            enabled: enabled,
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: locale.pointsLabel,
              isDense: true,
            ),
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))
            ],
          ),
        ),
      ],
    );
  }
}