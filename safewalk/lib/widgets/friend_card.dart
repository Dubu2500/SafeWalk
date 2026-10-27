import 'package:flutter/material.dart';

class CompanionCard extends StatelessWidget {
  const CompanionCard({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(child: Text(name[0])),
        title: Text('$name está acompañándote'),
        subtitle: const Text('Recibirá una alerta si detectamos algo inusual.'),
        trailing: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(value: 0.75, color: Colors.green),
        ),
      ),
    );
  }
}
