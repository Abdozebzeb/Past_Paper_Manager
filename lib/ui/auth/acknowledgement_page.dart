import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../logic/app_state.dart';
import '../main_screen.dart';

class AcknowledgementPage extends StatelessWidget {
  const AcknowledgementPage({super.key});

  final String content = """
# CIE Past Paper Manager

**Terms of Service, Privacy Policy & Acknowledgements**

**Last Updated:** July 12, 2026

---

## Welcome

Welcome to **CIE Past Paper Manager**.

CIE Past Paper Manager is a closed-source educational application developed as a hobby project by **Abdullah Zeb**. By downloading, installing, or using this application, you agree to the Terms of Service and Privacy Policy described below.

---

# Terms of Service

## 1. Eligibility

- You must be at least 13 years old to use your own Google account with CIE Past Paper Manager.
- Users under the age of 13 may only use the application with permission from a parent or legal guardian.

---

## 2. Account Requirements

- Google Sign-In is required to use the application.
- You are responsible for maintaining the security of your Google account.
- You may revoke this application's access from your Google Account at any time.

---

## 3. Acceptable Use

You agree not to:

- Reverse engineer, decompile, disassemble, or modify the application.
- Attempt to extract or reproduce the application's source code.
- Redistribute, resell, sublicense, or commercially distribute the application.
- Create modified or cracked versions of the application.
- Remove or alter copyright notices.
- Bypass authentication or security mechanisms.
- Use bots, automated scripts, or other automated tools to abuse the application.
- Excessively download examination materials in a manner that negatively affects the service.
- Use downloaded content to build another competing application or service.
- Use the application or its services for commercial purposes without written permission.
- Scrape or abuse any application APIs or backend services.
- Attempt to exploit software bugs, vulnerabilities, or unintended behavior.
- Tamper with analytics, usage statistics, or telemetry collected by the application.
- Impersonate another user or falsely represent your identity.
- Interfere with the operation, security, or availability of the application.

Violation of these terms may result in your access being restricted or permanently revoked.

---

## 4. Updates

- The application may receive updates that add, modify, remove, or disable features.
- Remote Configuration may be used to modify application behavior without requiring a software update.
- Certain versions of the application may become unsupported and may require updating before continued use.

---

## 5. Examination Materials

- CIE Past Paper Manager does not modify examination materials.
- PDF files are downloaded exactly as provided by their original source.
- The application currently downloads examination materials from **PapaCambridge**.
- Future versions may use different content sources.
- If requested by Cambridge Assessment International Education or the respective content provider, support for downloading examination materials may be modified or removed.

---

## 6. Intellectual Property

Unless otherwise stated:

- All software, source code, application design, user interface, branding, graphics, and original content within CIE Past Paper Manager are the intellectual property of **Abdullah Zeb**.
- This application is provided for personal educational use only.
- No rights are granted to copy, redistribute, or reuse any part of the application except where permitted by law.

---

## 7. Disclaimer of Warranty

This software is provided **"AS IS"**, without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, and non-infringement.

While reasonable efforts are made to ensure reliability and accuracy, no guarantee is made that the application will always operate without interruption, errors, or inaccuracies.

---

## 8. Changes to These Terms

These Terms of Service may be updated from time to time.

The latest version will always be available within the application or accompanying documentation. Continued use of the application constitutes acceptance of any updated terms.

---

## 9. Governing Law

These Terms of Service shall be governed by and interpreted in accordance with the laws of the **Islamic Republic of Pakistan**.

---

# Privacy Policy

## 1. Information We Collect

To provide application functionality, the following information is collected:

- Google account full name
- Google email address
- Application usage statistics
- Daily active user information
- Application launch events
- Download activity
- Button interaction events
- Account creation date
- Last active date

---

## 2. Information We Do Not Collect

The application does **not** collect:

- Phone numbers
- GPS or precise location
- IP addresses
- Contacts
- Photos
- Files outside the application's storage
- Crash logs
- Google profile pictures
- Google User IDs

---

## 3. Local Storage

The application stores the following data on your device:

- Downloaded examination papers
- Application settings
- Theme preference
- Login session information

---

## 4. Data Storage

User information is securely stored using **Firebase** services.

The developer does not operate independent servers for storing user account information.

---

## 5. Analytics

Anonymous usage analytics are collected solely to improve the application.

These analytics help measure:

- Daily active users
- Application launches
- Feature usage
- Download statistics
- General application activity

Analytics are not used for advertising or sold to third parties.

---

## 6. Authentication

Google Sign-In is mandatory for using the application.

Only the following account information is stored:

- Full Name
- Email Address

No passwords are stored by CIE Past Paper Manager.

---

## 7. Data Removal

Users may revoke Google Sign-In access through their Google Account settings.

Requests regarding stored account information may also be submitted via the contact information provided below.

---

# Copyright & Legal Notice

All Cambridge International examination materials remain the intellectual property of their respective copyright holders.

CIE Past Paper Manager is an independent educational application and is **not affiliated with, endorsed by, sponsored by, or approved by Cambridge Assessment International Education, Cambridge University Press & Assessment, or PapaCambridge**.

The application currently retrieves publicly available examination materials from PapaCambridge for educational convenience. No examination content is modified before being presented to users.

Should Cambridge Assessment International Education or the relevant content provider request the removal of supported examination materials or download functionality, reasonable efforts will be made to comply.

---

# Acknowledgements

The development of CIE Past Paper Manager would not have been possible without the resources and support provided by the following organizations and individuals.

## Developer

Developed, designed, tested, and maintained by:

**Abdullah Zeb**

This project was created as an independent hobby project with the goal of making Cambridge International past papers more organized and accessible for students.

---

## Cambridge Assessment International Education

Acknowledgement is given to Cambridge Assessment International Education for producing the examination materials used by students around the world.

All examination papers, mark schemes, examiner reports, grade thresholds, trademarks, and related materials remain the property of Cambridge Assessment International Education.

---

## PapaCambridge

Special thanks to **PapaCambridge** for making examination resources publicly accessible, which enables students to prepare more effectively for their examinations.

---

## Student Feedback

Thank you to the students who provided valuable feedback, suggestions, and ideas that helped improve the application's usability and overall experience.

---

## Beta Testing

Thank you to everyone who participated in testing pre-release versions of the application and reported issues that contributed to improving stability and reliability.

---

# Contact

For support, privacy requests, bug reports, or legal enquiries, please contact:

**Abdullah Zeb**

**Email:** AbdullahZeb1919@gmail.com

---

# Acceptance

By downloading, installing, or using CIE Past Paper Manager, you acknowledge that you have read, understood, and agreed to this Terms of Service, Privacy Policy, and Legal Notice.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:  Theme.of(context).cardColor, 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1))
                ),
                child: Markdown(
                  data: content, 
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(color: Colors.white70, fontSize: 14),
                    h1: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  )
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, 
              height: 55, 
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  await AppState.setNotFirstRun();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (_) => const MainScreen())
                    );
                  }
                },
                child: const Text("I Agree & Continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

extension on Theme {
  Color? get scaffoldBackgroundColor => null;
  
  Color? get cardColor => null;
}