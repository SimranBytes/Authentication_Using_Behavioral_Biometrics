import 'package:flutter/material.dart';

/// A dialog shown when the user fails authentication after retries.
class ForcedLogoutDialog extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onCancel;

  const ForcedLogoutDialog({
    Key? key,
    required this.onLoginPressed,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('You Were Logged Out!', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(
        'We couldn\'t verify your identity after multiple attempts. Please log in again to continue.',
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onLoginPressed,
          child: Text('Log In'),
        ),
      ],
    );
  }
}
