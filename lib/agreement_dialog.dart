import 'package:flutter/material.dart';

class AgreementDialog extends StatelessWidget {
  final VoidCallback onAgree;

  const AgreementDialog({Key? key, required this.onAgree}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Important Agreement'),
      content: const Text(
        'By using this software, you agree not to trust its advice regarding whether potentially toxic substances, animals, plants, and fungi are dangerous or edible. The information provided by this software should not be relied upon for determining the safety or edibility of any substance or organism.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onAgree();
          },
          child: const Text('I Agree'),
        ),
      ],
    );
  }
}