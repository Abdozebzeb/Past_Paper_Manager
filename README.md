# CIE Past Paper Manager

A clean, fast, and actually usable desktop application for browsing, downloading, and managing Cambridge past papers. Built to save students from wasting hours digging through cluttered websites just to find a single marking scheme.

---

## About

CIE Past Paper Manager was built to save students time by eliminating the need to download past papers manually from websites filled with annoying ads and pop-ups. The app features a built-in downloader that can download all the required past papers with just a few clicks.

Searching for question papers or marking schemes through File Explorer was also a headache. This app solves that problem by letting you browse and open papers instantly without manually searching through filenames.

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

* Open multiple PDFs in a tabbed layout
* Easily switch between tabs
* Open the corresponding Marking Scheme, Question Paper, or Grade Threshold directly from the selected tab

#### Reader Side Panel (Question Papers Only)

##### Info Tab

Automatically displays:

* Paper Name
* Paper Code
* Standard Duration
* Total Marks
* Grade Threshold for the selected component

##### Grading Tab

* Log a completed paper by entering your score
* Automatically assigns a grade based on the corresponding grade threshold
* Automatically records the paper duration using the built-in stopwatch or timer (if used)

##### Stopwatch / Timer

* Automatically detects the standard duration of the opened question paper and configures the timer accordingly
* Built-in stopwatch
* Option to manually adjust the timer

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

* User data is securely stored in Cloud Firestore and automatically synchronized the next time you sign in.

---

## Future Plans

* Add support for macOS
* Add a friends system so users can view each other's progress
* Add graphs to visualize progress
* Add an in-app update button on the home page whenever an update is available
* Integrate AI so users can ask questions about the contents of the currently opened paper directly from the reader
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

If something breaks, feels slow, or simply annoys you:

Open an issue or fix it yourself.

You can also DM me on **[Instagram](https://www.instagram.com/abdullahhzeb/)** to report bugs or share suggestions.

Either works.
