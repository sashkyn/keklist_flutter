import 'package:flutter/material.dart';
import 'package:rememoji/screens/mind_day_collection/widgets/messaged_list/mind_message_widget.dart';
import 'package:rememoji/services/entities/mind.dart';

class MindMonologListWidget extends StatelessWidget {
  final List<Mind> minds;
  final Function(Mind) onTap;

  const MindMonologListWidget({
    super.key,
    required this.minds,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: minds.map((mind) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () => onTap(mind),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 10.0,
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      child: MindMessageWidget(mind: mind),
                    ),
                  ),
                ),
              ],
            );
          }).toList() +
          [
            Column(children: const [SizedBox(height: 160.0)]),
          ],
    );
  }
}
