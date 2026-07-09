# First
My current application Lib Folder and pubspec yaml is pasted in this very chat

What i want to do:
    Create a new screen called settings screen, Similar to CIE Datesheet App (Its code is also pasted above)
    Move About and Import export to settings screen
    Have the Same about format as CIE Datesheet App
    have the same switch theme from light to dark as CIE Datesheet App
    do not use hardcoded colours througout the app

    for the downloads section i want an option to download multpule listtings serially so the person can step away while the stuff is being downloaded, currently the user can only download one subject per download button click but i want a + and a - icon somehwere on the download page so similar download setup cards can be appeared
    Right now the hardcoded path is "https://pastpapers.papacambridge.com/directories/CAIE/CAIE-pastpapers/upload/", i want this to be non hardcoded and when the app is opened for the first time the path from firebase is downloaded and upon every app open check for data version similar to SNS Student Portal (its code is also pasted)
    i want a google login > Acknowledgment screen > welcome screen > Homepage
    i want the pdfs to be opened inside the app somehow in a new window which has a specefic pourpouse of just viewing the pdf
    MSIX vs inno problem
    I want this app to work on macos too from now on, before this app was only ment to work on windows but now i am moving towards macos too so if neccasry rewrite the entire logic or parts of logic to support macos too, the main concern for me is the downloaded pastpapers folder either use a plugin which supports bot windows or macos or do something else beacuse currently with msix i dont think i can download past papers i can open them if i copy paste inside the folder but i cant download them maybe due to persmissions, and as far as ik permissons are much harder on macos, currently i will be testing on windows but i will test on macos later


Detils of what i want:
1. New Screen "Settings Screen"
- Accessed Via a settings icon on the left navbar
- Same Settings List view format as the CIE Datesheet App
- have the same switch theme from light to dark as CIE Datesheet App
    Which means no more usage of HardCoded Colours througout the App
2. Redisigned Downloads Page
- Currently Only one subject can be downloaded per Job I want added + and - buttons so more subjects can be downloaded serilly per download job
- Right now the hardcoded path is "https://pastpapers.papacambridge.com/directories/CAIE/CAIE-pastpapers/upload/", i want this to be non hardcoded and when the app is opened for the first time the path from firebase is downloaded and upon every app open check for data version similar to SNS Student Portal (its code is also pasted)
- There may be 1+ paths if the file has failed to download from the first path move to the second if failed from second then to thrid and so on until the last valid path
    This is the example i copied from firbase Settings/Config
    {
    "DataUpdateDate": "1 July 2026 at 19:00:02 UTC+5",
    "DataVersion": 1,
    "DownloadPath": [
        "https://pastpapers.papacambridge.com/directories/CAIE/CAIE-pastpapers/upload/",
        "https://example.com/files/"
    ]
    }


3. New Login Feature
- I want this app to have google account login like the CIE Datesheet App
    login > Acknowledgment screen > welcome screen > Homepage
- For the user the following ADDITIONAL items will be saved
* Email
* Name
* DOB

4. PDF's being opened In app
- When the Open Button is clicked make a new icon appear in the nav bar "Reader" icon and open the icon so ther person can open pdf in app and open mutipule pdfs, when the person steps away from the pdf display screen the pdfs will remail open if the person opens another pdf while the previous pdf is open, the new pdf will be opened in a new tab insdie the reader screen

NOTE:
This app was initlly only designed to be used on windows but now i am thinking of moving it to MacOS, For the timebeing i will be testing this on windows only
ReDesign the neccasry logic for this app to support macos too
i use dartmsixcreate for flutter windows but i  get a grey screen for the open Papers page the rest of the app is fine i get the expected screens, although it works well on debug and release but as soon as it converts to msix and is installed via msix i get the grey screen
I am not a prgrammer and this entire app has been created by AI, for any blocks of code which need to be repalced specefy the file name etc, tell me explictly which files to create, replace or delete
I have pasted the code for three apps above
- CIE PastPaper Manager
- CIE Datesheet App
- SNS Student Portal
i may want specefic logic from these apps



# Second
I used AI entirley for this project and i do not know how to code, i have done a massive overhaul currently the logic is fine but most of my inital gui has been lost, the prompt below is what i gave gemini to create the current project:

Detils of what i want:
1. New Screen "Settings Screen"
- Accessed Via a settings icon on the left navbar
- Same Settings List view format as the CIE Datesheet App
- have the same switch theme from light to dark as CIE Datesheet App
    Which means no more usage of HardCoded Colours througout the App
2. Redisigned Downloads Page
- Currently Only one subject can be downloaded per Job I want added + and - buttons so more subjects can be downloaded serilly per download job
- Right now the hardcoded path is "https://pastpapers.papacambridge.com/directories/CAIE/CAIE-pastpapers/upload/", i want this to be non hardcoded and when the app is opened for the first time the path from firebase is downloaded and upon every app open check for data version similar to SNS Student Portal (its code is also pasted)
- There may be 1+ paths if the file has failed to download from the first path move to the second if failed from second then to thrid and so on until the last valid path
    This is the example i copied from firbase Settings/Config
    {
    "DataUpdateDate": "1 July 2026 at 19:00:02 UTC+5",
    "DataVersion": 1,
    "DownloadPath": [
        "https://pastpapers.papacambridge.com/directories/CAIE/CAIE-pastpapers/upload/",
        "https://example.com/files/"
    ]
    }


3. New Login Feature
- I want this app to have google account login like the CIE Datesheet App
    login > Acknowledgment screen > welcome screen > Homepage
- For the user the following ADDITIONAL items will be saved
* Email
* Name
* DOB

4. PDF's being opened In app
- When the Open Button is clicked make a new icon appear in the nav bar "Reader" icon and open the icon so ther person can open pdf in app and open mutipule pdfs, when the person steps away from the pdf display screen the pdfs will remail open if the person opens another pdf while the previous pdf is open, the new pdf will be opened in a new tab insdie the reader screen

NOTE:
This app was initlly only designed to be used on windows but now i am thinking of moving it to MacOS, For the timebeing i will be testing this on windows only
ReDesign the neccasry logic for this app to support macos too
i use dartmsixcreate for flutter windows but i  get a grey screen for the open Papers page the rest of the app is fine i get the expected screens, although it works well on debug and release but as soon as it converts to msix and is installed via msix i get the grey screen
I am not a prgrammer and this entire app has been created by AI, for any blocks of code which need to be repalced specefy the file name etc, tell me explictly which files to create, replace or delete
I have pasted the code for three apps above
- CIE PastPaper Manager
- CIE Datesheet App
- SNS Student Portal
i may want specefic logic from these apps


Currently the view papers page has massive loss of GUI, i think there are no logging currently to firebase either
the download page (Download Job) card is all messed up
    For instance there are no checkboxes and the desgin is not good
    there should be only a fancy + button without any text
The reader should only appear when a pdf(s) are open, else the icon is not visible
the reader should not load the pdf everytime it is opened, rather it should keep them loaded until they are closed by clicking "X" button on the tab(s)
the light theme is a bit messed up the left navbar, Download Job, and the View papers page drop downs are hardcoded dark
My main concern right now is the view papers page, and download page correct them and the other files give me the whole replacement files without losing any current logic and the inital GUI
The reader tab should not be rigid cornery rather it should be rounded something like chrome tabs
the settings and reader icons should be at the bottom of the nav bar

the recent overhaul had a massibe 1485 deletions according to git and there was a decrease in massive amount of lines in the files which makes me lead to belive there might be massive loss of inital working unrelated logic too
 