Release Commad: shorebird release windows --flutter-version=3.41.6
MSIX Commad: dart run msix:create --build-windows false
Remove Important Secrets: python -m git_filter_repo --invert-paths --path firebase.json --path shorebird.yaml --path lib/firebase_options.dart --force


