Install Flutter: https://docs.flutter.dev/get-started/install (target platform: web)

### Terminal 0
```
npm install -g firebase-tools
```

### Terminal 1
```
firebase emulators:start
```
if "running scripts is disabled on this system": https://stackoverflow.com/a/4038991/14139068

### Terminal 2
```
cd .\apps\volunteers_app\
```
For testing Firebase Cloud Functions Emulator,
```
flutter run -t .\test\cloud_functions_test.dart
```
