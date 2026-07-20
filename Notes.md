Release CommadL shorebird release windows --flutter-version=3.41.6
MSIX Commad: dart run msix:create --build-windows false

General UI Clean-up (Removing Hardcoded Colors)
To make this work everywhere, you should now perform a Find and Replace (Ctrl+Shift+F):
Search for: Colors.blueAccent
Replace with: Theme.of(context).primaryColor
Search for: Color(0xFF0A0F1C) (Your old dark background)
Replace with: Theme.of(context).scaffoldBackgroundColor
Search for: Color(0xFF161D2D) (Your old dark surface)
Replace with: Theme.of(context).cardColor
For instances like Colors.blueAccent.withOpacity(0.1), use:
Theme.of(context).primaryColor.withAlpha(25)
Crucial Note for ReaderSidePanel:
In the _thresholdRow and _buildClockCard, change Colors.blueAccent references to Theme.of(context).primaryColor. The palette you selected in Settings will now reflect instantly in every tab of the reader.


