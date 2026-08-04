# CIE Past Paper Manager

A clean, fast, and actually usable desktop application for browsing, downloading, and managing Cambridge past papers. Built to save students from wasting hours digging through cluttered websites just to find a single marking scheme.

---

## Download

* **Microsoft Store:** [Get from Microsoft Store](https://apps.microsoft.com/store/detail/9NGKC89464X7?cid=DevShareMCLPCB)
* **Winget Command:**
  ```cmd
  winget install 9NGKC89464X7 --source msstore
## About

CIE Past Paper Manager was built to save students time by eliminating the need to download past papers manually from websites filled with annoying ads and pop ups. The app features a built in downloader that can download all the required past papers with just a few clicks.

Searching for question papers or marking schemes through File Explorer or Finder was also a headache. This app solves that problem by letting you browse and open papers instantly without manually searching through filenames or scrolling endlessly.

---

## Features

### Browsing Past Papers

* Dropdown options to select:

  * Subject Code
  * Series (May/June, Oct/Nov, March)
  * Year
  * Type (Grade Threshold, Marking Scheme, Question Paper)
  * Paper

### Downloading Past Papers

* Fill in the required fields to automatically download past papers:

  * Subject Code
  * Start Year
  * End Year
  * Papers
  * Variants
  * Types (MS, QP, GT)

### PDF Reader

* Open multiple PDFs in a tabbed layout like chrome or Adobe Acrobat Reader
* Easily switch between different tabs
* Open the related Marking Scheme, Question Paper, or Grade Threshold directly from the selected tab

#### Reader Side Panel (for question papers only)

##### Info Tab

Automatically displays:

* Paper Name
* Paper Code
* Standard Duration
* Total Marks
* Grade Threshold for the selected component

##### Grading Tab

* Log the completed paper by entering your score
* Automatically assigns a grade based on the related grade threshold
* Automatically records the paper duration using the built-in stopwatch or timer (if used)

##### Stopwatch / Timer

* Automatically detects the standard duration of the opened question paper and sets the timer accordingly
* Built in stopwatch
* Adjustable timer

### Past Paper Attempt Logs

* Manually log completed papers to keep track of your progress
* Filterable table headers
* Information displayed for each record:

  * Date Completed
  * Syllabus (9709/11)
  * Paper Code (9709_s24_qp_11)
  * Duration
  * Score
  * Grade

### Authentication and Backup

* User data is securely stored in Cloud Firestore and auto synced the next time you sign in.

---

## Future Plans

* Add support for macOS (THIS WILL BE A PAIN!!!!!! Apple just loves making life miserable for developers)
* Add a friends system so users can view each other's progress
* Add graphs to visualize user progress
* Add an in app update button on the home page whenever an update is available
* Integrate AI (preferably Gemini) so users can ask questions about the contents of the currently opened paper directly from the reader
* Add a Notes and Topicals marketplace
* Add support for iPad and Android tablets so students can solve papers using a stylus and save their work

---

## Screenshots

| Home Page              | Download Page              | Reader Page / Info Tab              | Reader Page / Grading Tab              |
| ---------------------- | -------------------------- | ----------------------------------- | -------------------------------------- |
| ![Home Page](https://github.com/user-attachments/assets/641bdbf6-aaa7-47aa-be16-992f2dbdfe86) | ![Download Page](https://github.com/user-attachments/assets/fa5e9c81-c7f4-40a5-8be5-7c4d3f8bee56) | ![Reader Page / Info Tab](https://github.com/user-attachments/assets/62fcb5bf-76e3-45b2-a115-df92ba789766) | ![Reader Page / Grading Tab](https://github.com/user-attachments/assets/cd0293db-68c1-4399-b56f-1d3d7fee2496) |

| Logs Page              | Manual Logging Dialog              | Settings Page              | About Dialog              |
| ---------------------- | ---------------------------------- | -------------------------- | ------------------------- |
| ![Logs Page](https://github.com/user-attachments/assets/c332f70e-33ae-4c96-941a-0cd266731a70) | ![Manual Logging Dialog](https://github.com/user-attachments/assets/eff61add-bcb1-45f1-b2a7-101e50e2d961) | ![Settings Page](https://github.com/user-attachments/assets/c3a90b06-0750-40cc-929a-dfd52a2766fe) | ![About Dialog](https://github.com/user-attachments/assets/14a553a2-f162-4962-942a-595c9ef2aa25) |

---

## Credits

Created by **Abdullah Zeb**

---

## Feedback

If something breaks, feels slow or simply annoys you:

Open an issue or fix it yourself.

You can also DM me on **[Instagram](https://www.instagram.com/abdullahhzeb/)** to report bugs or share suggestions.

Either works.

---

## Setup Instructions For Local Development

### Installation Guide (Windows)

Follow these steps to set up the development environment for the Past Paper Manager.


#### 1. Install Core Tools
*   **[VS Code](https://code.visualstudio.com/):** My preferred code editor.
*   **[Git for Windows](https://git-scm.com/download/win):** Required for version control.
*   **[Node.js (includes npm)](https://nodejs.org/):** Required to install the Firebase CLI.

#### 2. Visual Studio
1.  Download the **[Visual Studio Installer](https://visualstudio.microsoft.com/downloads/)**.
2.  Run the installer and select **"Desktop development with C++"**.
3.  Ensure the default components are checked and click **Install**.

#### 3. Flutter SDK
1.  Download the **[Flutter SDK](https://docs.flutter.dev/get-started/install/windows)**.
2.  Extract the zip file to a folder (e.g., `C:\src\flutter`).
3.  **Edit your System Environment Variables**: Add the path to `flutter\bin` to your "Path" variable.
4.  Open a terminal and run:
    ```bash
    flutter doctor
    ```
    *Ensure "Windows Version" show green checkmarks.*

#### 4. VS Code Setup
1.  Open VS Code.
2.  Go to the **Extensions**.
3.  Search for and install: **Flutter**

#### 5. Firebase & FlutterFire Configuration
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

#### 6. Run the Project
1.  Open the project folder in VS Code.
2.  Get dependencies:
    ```bash
    flutter pub get
    ```
3.  Launch the app:
    *   Press **F5** or type `flutter run -d windows` in the terminal.

**Note:** Ensure you rename `lib/app_config_sample.dart` to `lib/app_config.dart` and fill in your specific API keys before running
