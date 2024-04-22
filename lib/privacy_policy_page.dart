import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '''
1. Introduction
   - Explain the purpose of the privacy policy and the company's commitment to protecting user privacy.

2. Information Collection
   - Describe the types of personal information collected by the app (e.g., name, email, location data, usage data).
   - Explain how the information is collected (e.g., user input, automatic collection, third-party sources).

3. Use of Information
   - Describe how the collected information is used by the company (e.g., to provide and improve services, personalize user experience, communicate with users).
   - Specify if the information is used for marketing or advertising purposes.

4. Information Sharing
   - Explain if and how the collected information is shared with third parties (e.g., service providers, affiliates, partners).
   - Describe the circumstances under which information may be disclosed (e.g., legal requirements, merger or acquisition).

5. Data Security
   - Describe the measures taken to protect user information from unauthorized access, alteration, or disclosure.
   - Explain if data is encrypted and how it is stored securely.

6. User Rights
   - Inform users about their rights regarding their personal information (e.g., access, correction, deletion).
   - Provide instructions on how users can exercise their rights.

7. Data Retention
   - Explain how long the collected information is retained by the company.
   - Describe the criteria used to determine the retention period.

8. Children's Privacy
   - Specify if the app is intended for use by children under a certain age (e.g., 13 years old).
   - Explain if parental consent is required and how it is obtained.

9. Changes to the Privacy Policy
   - Inform users that the privacy policy may be updated from time to time.
   - Describe how users will be notified of any changes.

10. Contact Information
    - Provide contact details for users to reach out with any questions or concerns regarding the privacy policy.
    - Include a mailing address, email address, or contact form.

By using this app, you consent to the collection, use, and sharing of your personal information as described in this privacy policy.
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