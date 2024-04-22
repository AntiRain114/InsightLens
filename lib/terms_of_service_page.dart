import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms of Service"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Terms of Service",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '''
1. Acceptance of Terms
   - Explain that by using the app, users agree to be bound by the terms of service.
   - Mention that continued use of the app constitutes acceptance of the terms.

2. Description of Service
   - Provide a brief description of the app and its purpose.
   - Explain the main features and functionalities of the app.

3. User Responsibilities
   - Outline the responsibilities of users while using the app (e.g., providing accurate information, not misusing the service).
   - Specify any prohibited activities or behaviors.

4. Intellectual Property
   - State that the app and its content are protected by intellectual property rights.
   - Explain that users are granted a limited, non-exclusive license to use the app for personal, non-commercial purposes.

5. Disclaimer of Warranties
   - Disclaim any warranties, express or implied, regarding the app's performance, accuracy, or reliability.
   - Mention that the app is provided "as is" and "as available" without warranties of any kind.

6. Limitation of Liability
   - Limit the company's liability for any damages, losses, or claims arising from the use of the app.
   - Exclude liability for indirect, incidental, consequential, or punitive damages.

7. Termination
   - Explain that the company reserves the right to terminate or suspend user access to the app at any time, with or without cause.
   - Describe the circumstances under which termination may occur (e.g., violation of terms, discontinuation of the app).

8. Governing Law and Jurisdiction
   - Specify the governing law and jurisdiction that apply to the terms of service.
   - Mention where any legal disputes or claims will be resolved.

9. Changes to the Terms of Service
   - Inform users that the terms of service may be updated from time to time.
   - Describe how users will be notified of any changes and how continued use of the app constitutes acceptance of the updated terms.

10. Contact Information
    - Provide contact details for users to reach out with any questions or concerns regarding the terms of service.
    - Include a mailing address, email address, or contact form.

By using this app, you acknowledge that you have read, understood, and agree to be bound by these terms of service.
              ''',
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Back to Settings"),
            ),
          ],
        ),
      ),
    );
  }
}