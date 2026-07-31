# Installation Guide (Windows)

Follow these steps to set up the development environment for the Past Paper Manager.

---

### 1. Install Core Tools
*   **[VS Code](https://code.visualstudio.com/):** My preferred code editor.
*   **[Git for Windows](https://git-scm.com/download/win):** Required for version control.
*   **[Node.js (includes npm)](https://nodejs.org/):** Required to install the Firebase CLI.

### 2. Visual Studio
1.  Download the **[Visual Studio Installer](https://visualstudio.microsoft.com/downloads/)**.
2.  Run the installer and select **"Desktop development with C++"**.
3.  Ensure the default components are checked and click **Install**.

### 3. Flutter SDK
1.  Download the **[Flutter SDK](https://docs.flutter.dev/get-started/install/windows)**.
2.  Extract the zip file to a folder (e.g., `C:\src\flutter`).
3.  **Edit your System Environment Variables**: Add the path to `flutter\bin` to your "Path" variable.
4.  Open a terminal and run:
    ```bash
    flutter doctor
    ```
    *Ensure "Windows Version" show green checkmarks.*

### 4. VS Code Setup
1.  Open VS Code.
2.  Go to the **Extensions**.
3.  Search for and install: **Flutter**

### 5. Firebase & FlutterFire Configuration
Since this project uses Firebase for Auth and Analytics, you must configure the CLI:

1.  **Install Firebase CLI**:
    ```bash
    npm install -g firebase-tools
    ```
2.  **Login to Firebase**:
    ```bash
    firebase login
    ```
3.  **Install FlutterFire CLI**:
    ```bash
    dart pub global activate flutterfire_cli
    ```
4.  **Configure the project**:
    Navigate to the project root folder in your terminal and run:
    ```bash
    flutterfire configure
    ```
    *Follow the on-screen prompts to select/create your Firebase project and platforms (Windows).*

### 6. Run the Project
1.  Open the project folder in VS Code.
2.  Get dependencies:
    ```bash
    flutter pub get
    ```
3.  Launch the app:
    *   Press **F5** or type `flutter run -d windows` in the terminal.

---
**Note:** Ensure you rename `lib/app_config_sample.dart` to `lib/app_config.dart` and fill in your specific API keys before running if you are using a custom backend.