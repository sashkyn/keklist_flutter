import 'package:flutter/material.dart';

final class MyChipWidget extends StatelessWidget {
  final bool isSelected;
  final Widget child;
  final Function(bool) onSelect;
  final Color selectedColor;

  const MyChipWidget({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onSelect,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return RawChip(
      showCheckmark: false,
      label: child,
      backgroundColor: isSelected ? selectedColor : null,
      shape: StadiumBorder(
        side: BorderSide(
          color: selectedColor,
          width: 2.0,
        ),
      ),
      selectedColor: selectedColor,
      selected: isSelected,
      onPressed: () {
        onSelect(isSelected);
      },
    );
  }
}
