Unable to connect Flutter app to Firebase Cloud Functions emulator, for callable functions. It just returns a null object without any errors.

The logs are not registering a HTTP request from the app either. It's showing a GET request if I directly paste the function URL into the normal browser. But it's not getting anything from the app. 

firebase.json
```
{
  "firestore": {
    "database": "(default)",
    "location": "nam5",
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "functions": [
    {
      "source": "functions",
      "codebase": "default",
      "ignore": [
        "venv",
        ".git",
        "firebase-debug.log",
        "firebase-debug.*.log",
        "*.local"
      ],
      "runtime": "python313"
    }
  ],
  "emulators": {
    "functions": {
      "port": 5001
    },
    "firestore": {
      "port": 8083
    },
    "ui": {
      "enabled": true
    },
    "singleProjectMode": true
  }
}
```

Function definition
```py
# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import https_fn, options
from firebase_admin import initialize_app, firestore
import requests
import uuid
# from datetime import datetime, timedelta # TODO: add to requirements.txt if used for @cache

initialize_app()

options.set_global_options(region=options.SupportedRegion.ASIA_SOUTH1) 

@https_fn.on_call()
def validate_volunteer(req: https_fn.CallableRequest):
    """
    Validates if the current user is a registered volunteer.
    """
    volunteer_uid = req.auth.uid if req.auth else None
    if not volunteer_uid:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="Authentication required."
        )

    db = firestore.client()
    volunteer_ref = db.collection('volunteers').document(volunteer_uid)
    volunteer_doc = volunteer_ref.get()

    return volunteer_doc.exists
```

Flutter test command
```
flutter run -t .\test\cloud_functions_test.dart
```

Flutter code
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:volunteers_app/firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  // await FirebaseAuth.instance.signInWithEmailAndPassword(
  //   email: '---',
  //   password: '---',
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: FirebaseFunctions.instance
            .httpsCallable('validate_volunteer')
            .call({}),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            print('Snapshot data: ${snapshot.data}');
            return Text('Result: ${snapshot.data as bool}');
          }
        },
      ),
    );
  }
}
```

Flutter Error
```
══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY ╞═══════════════════════════════════════════════════════════
The following _TypeError was thrown building FutureBuilder<HttpsCallableResult<dynamic>>(dirty,
state: _FutureBuilderState<HttpsCallableResult<dynamic>>#86a79):
TypeError: null: type 'Null' is not a subtype of type 'bool'

The relevant error-causing widget was:
  FutureBuilder<HttpsCallableResult<dynamic>>
  FutureBuilder:org-dartlang-app:/cloud_functions_test.dart:24:13

When the exception was thrown, this was the stack:
dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 307:3     throw_
dart-sdk/lib/_internal/js_dev_runtime/private/profile.dart 117:39               _failedAsCheck
dart-sdk/lib/_internal/js_shared/lib/rti.dart 1554:3                            _generalAsCheckImplementation
cloud_functions_test.dart 33:50                                                 <fn>
packages/flutter/src/widgets/async.dart 627:48                                  build
packages/flutter/src/widgets/framework.dart 5841:27                             build
packages/flutter/src/widgets/framework.dart 5733:15                             performRebuild
packages/flutter/src/widgets/framework.dart 5892:11                             performRebuild
packages/flutter/src/widgets/framework.dart 5445:7                              rebuild
packages/flutter/src/widgets/framework.dart 2704:14                             [_tryRebuild]
packages/flutter/src/widgets/framework.dart 2762:11                             [_flushDirtyElements]
packages/flutter/src/widgets/framework.dart 3066:17                             buildScope
packages/flutter/src/widgets/binding.dart 1229:9                                drawFrame
packages/flutter/src/rendering/binding.dart 482:5                               [_handlePersistentFrameCallback]
packages/flutter/src/scheduler/binding.dart 1442:7                              [_invokeFrameCallback]
packages/flutter/src/scheduler/binding.dart 1355:9                              handleDrawFrame
packages/flutter/src/scheduler/binding.dart 1208:5                              [_handleDrawFrame]
lib/_engine/engine/platform_dispatcher.dart 1347:5                              invoke
lib/_engine/engine/platform_dispatcher.dart 301:5                               invokeOnDrawFrame
lib/_engine/engine/initialization.dart 190:36                                   <fn>
dart-sdk/lib/_internal/js_dev_runtime/patch/js_allow_interop_patch.dart 224:27  _callDartFunctionFast1

════════════════════════════════════════════════════════════════════════════════════════════════════
```

Firebase Emulator Debug Logs
```
[debug] [2025-06-18T02:05:43.917Z] ----------------------------------------------------------------------
[debug] [2025-06-18T02:05:43.920Z] Command:       C:\Program Files\nodejs\node.exe C:\Users\2004b\AppData\Roaming\npm\node_modules\firebase-tools\lib\bin\firebase.js emulators:start
[debug] [2025-06-18T02:05:43.920Z] CLI Version:   14.6.0
[debug] [2025-06-18T02:05:43.920Z] Platform:      win32
[debug] [2025-06-18T02:05:43.920Z] Node Version:  v22.16.0
[debug] [2025-06-18T02:05:43.921Z] Time:          Wed Jun 18 2025 07:35:43 GMT+0530 (India Standard Time)
[debug] [2025-06-18T02:05:43.921Z] ----------------------------------------------------------------------
[debug] 
[debug] [2025-06-18T02:05:44.158Z] > command requires scopes: ["email","openid","https://www.googleapis.com/auth/cloudplatformprojects.readonly","https://www.googleapis.com/auth/firebase","https://www.googleapis.com/auth/cloud-platform"]
[debug] [2025-06-18T02:05:44.159Z] > authorizing via signed-in user (balu.somenumbers@gmail.com)
[debug] [2025-06-18T02:05:44.252Z] java version "21.0.1" 2023-10-17 LTS
Java(TM) SE Runtime Environment (build 21.0.1+12-LTS-29)
Java HotSpot(TM) 64-Bit Server VM (build 21.0.1+12-LTS-29, mixed mode, sharing)

[debug] [2025-06-18T02:05:44.299Z] Parsed Java major version: 21
[info] i  emulators: Starting emulators: functions, firestore, extensions {"metadata":{"emulator":{"name":"hub"},"message":"Starting emulators: functions, firestore, extensions"}}
[debug] [2025-06-18T02:05:44.301Z] Checked if tokens are valid: true, expires at: 1750215260469
[debug] [2025-06-18T02:05:44.301Z] Checked if tokens are valid: true, expires at: 1750215260469
[debug] [2025-06-18T02:05:44.302Z] >>> [apiv2][query] GET https://serviceusage.googleapis.com/v1/projects/padur-library-58b3a/services/cloudresourcemanager.googleapis.com [none]
[debug] [2025-06-18T02:05:44.302Z] >>> [apiv2][(partial)header] GET https://serviceusage.googleapis.com/v1/projects/padur-library-58b3a/services/cloudresourcemanager.googleapis.com x-goog-quota-user=projects/padur-library-58b3a
[debug] [2025-06-18T02:05:45.851Z] <<< [apiv2][status] GET https://serviceusage.googleapis.com/v1/projects/padur-library-58b3a/services/cloudresourcemanager.googleapis.com 200
[debug] [2025-06-18T02:05:45.851Z] <<< [apiv2][body] GET https://serviceusage.googleapis.com/v1/projects/padur-library-58b3a/services/cloudresourcemanager.googleapis.com [omitted]
[debug] [2025-06-18T02:05:45.851Z] Checked if tokens are valid: true, expires at: 1750215260469
[debug] [2025-06-18T02:05:45.851Z] Checked if tokens are valid: true, expires at: 1750215260469
[debug] [2025-06-18T02:05:45.851Z] >>> [apiv2][query] GET https://cloudresourcemanager.googleapis.com/v1/projects/padur-library-58b3a [none]
[debug] [2025-06-18T02:05:47.113Z] <<< [apiv2][status] GET https://cloudresourcemanager.googleapis.com/v1/projects/padur-library-58b3a 200
[debug] [2025-06-18T02:05:47.114Z] <<< [apiv2][body] GET https://cloudresourcemanager.googleapis.com/v1/projects/padur-library-58b3a {"projectNumber":"465520690779","projectId":"padur-library-58b3a","lifecycleState":"ACTIVE","name":"padur-library","labels":{"firebase":"enabled","firebase-core":"disabled"},"createTime":"2025-06-12T18:57:22.511079Z"}
[debug] [2025-06-18T02:05:47.127Z] [logging] Logging Emulator only supports listening on one address (127.0.0.1). Not listening on ::1
[debug] [2025-06-18T02:05:47.127Z] [firestore] Firestore Emulator only supports listening on one address (127.0.0.1). Not listening on ::1
[debug] [2025-06-18T02:05:47.128Z] [firestore.websocket] websocket server for firestore only supports listening on one address (127.0.0.1). Not listening on ::1
[debug] [2025-06-18T02:05:47.128Z] assigned listening specs for emulators {"user":{"hub":[{"address":"127.0.0.1","family":"IPv4","port":4400},{"address":"::1","family":"IPv6","port":4400}],"ui":[{"address":"127.0.0.1","family":"IPv4","port":4000},{"address":"::1","family":"IPv6","port":4000}],"logging":[{"address":"127.0.0.1","family":"IPv4","port":4500}],"firestore":[{"address":"127.0.0.1","family":"IPv4","port":8083}],"firestore.websocket":[{"address":"127.0.0.1","family":"IPv4","port":9151}]},"metadata":{"message":"assigned listening specs for emulators"}}
[debug] [2025-06-18T02:05:47.134Z] [hub] writing locator at C:\Users\2004b\AppData\Local\Temp\hub-padur-library-58b3a.json
[debug] [2025-06-18T02:05:47.143Z] [Extensions] Started Extensions emulator, this is a noop.
[debug] [2025-06-18T02:05:47.148Z] [functions] Functions Emulator only supports listening on one address (127.0.0.1). Not listening on ::1
[debug] [2025-06-18T02:05:47.148Z] [eventarc] Eventarc Emulator only supports listening on one address (127.0.0.1). Not listening on ::1
[debug] [2025-06-18T02:05:47.148Z] [tasks] Cloud Tasks Emulator only supports listening on one address (127.0.0.1). Not listening on ::1
[debug] [2025-06-18T02:05:47.148Z] late-assigned ports for functions and eventarc emulators {"user":{"hub":[{"address":"127.0.0.1","family":"IPv4","port":4400},{"address":"::1","family":"IPv6","port":4400}],"ui":[{"address":"127.0.0.1","family":"IPv4","port":4000},{"address":"::1","family":"IPv6","port":4000}],"logging":[{"address":"127.0.0.1","family":"IPv4","port":4500}],"firestore":[{"address":"127.0.0.1","family":"IPv4","port":8083}],"firestore.websocket":[{"address":"127.0.0.1","family":"IPv4","port":9151}],"functions":[{"address":"127.0.0.1","family":"IPv4","port":5001}],"eventarc":[{"address":"127.0.0.1","family":"IPv4","port":9299}],"tasks":[{"address":"127.0.0.1","family":"IPv4","port":9499}]},"metadata":{"message":"late-assigned ports for functions and eventarc emulators"}}
[warn] !  functions: The following emulators are not running, calls to these services from the Functions emulator will affect production: apphosting, auth, database, hosting, pubsub, storage, dataconnect {"metadata":{"emulator":{"name":"functions"},"message":"The following emulators are not running, calls to these services from the Functions emulator will affect production: \u001b[1mapphosting, auth, database, hosting, pubsub, storage, dataconnect\u001b[22m"}}
[debug] [2025-06-18T02:05:47.185Z] defaultcredentials: writing to file C:\Users\2004b\AppData\Roaming\firebase\balu_somenumbers_gmail.com_application_default_credentials.json
[debug] [2025-06-18T02:05:47.186Z] Setting GAC to C:\Users\2004b\AppData\Roaming\firebase\balu_somenumbers_gmail.com_application_default_credentials.json {"metadata":{"emulator":{"name":"functions"},"message":"Setting GAC to C:\\Users\\2004b\\AppData\\Roaming\\firebase\\balu_somenumbers_gmail.com_application_default_credentials.json"}}
[debug] [2025-06-18T02:05:47.187Z] Checked if tokens are valid: true, expires at: 1750215260469
[debug] [2025-06-18T02:05:47.187Z] Checked if tokens are valid: true, expires at: 1750215260469
[debug] [2025-06-18T02:05:47.187Z] >>> [apiv2][query] GET https://firebase.googleapis.com/v1beta1/projects/padur-library-58b3a/adminSdkConfig [none]
[debug] [2025-06-18T02:05:47.605Z] <<< [apiv2][status] GET https://firebase.googleapis.com/v1beta1/projects/padur-library-58b3a/adminSdkConfig 200
[debug] [2025-06-18T02:05:47.605Z] <<< [apiv2][body] GET https://firebase.googleapis.com/v1beta1/projects/padur-library-58b3a/adminSdkConfig {"projectId":"padur-library-58b3a","storageBucket":"padur-library-58b3a.firebasestorage.app"}
[debug] [2025-06-18T02:05:47.624Z] Ignoring unsupported arg: auto_download {"metadata":{"emulator":{"name":"firestore"},"message":"Ignoring unsupported arg: auto_download"}}
[debug] [2025-06-18T02:05:47.624Z] Ignoring unsupported arg: single_project_mode_error {"metadata":{"emulator":{"name":"firestore"},"message":"Ignoring unsupported arg: single_project_mode_error"}}
[debug] [2025-06-18T02:05:47.624Z] Starting Firestore Emulator with command {"binary":"java","args":["-Dgoogle.cloud_firestore.debug_log_level=FINE","-Duser.language=en","-jar","C:\\Users\\2004b\\.cache\\firebase\\emulators\\cloud-firestore-emulator-v1.19.8.jar","--host","127.0.0.1","--port",8083,"--websocket_port",9151,"--project_id","padur-library-58b3a","--rules","D:\\Balu\\Projects\\TeamBooks_FlutterFrames\\teambooks_flutterframes\\firestore.rules","--single_project_mode",true,"--functions_emulator","127.0.0.1:5001"],"optionalArgs":["port","webchannel_port","host","rules","websocket_port","functions_emulator","seed_from_export","project_id","single_project_mode"],"joinArgs":false,"shell":false,"port":8083} {"metadata":{"emulator":{"name":"firestore"},"message":"Starting Firestore Emulator with command {\"binary\":\"java\",\"args\":[\"-Dgoogle.cloud_firestore.debug_log_level=FINE\",\"-Duser.language=en\",\"-jar\",\"C:\\\\Users\\\\2004b\\\\.cache\\\\firebase\\\\emulators\\\\cloud-firestore-emulator-v1.19.8.jar\",\"--host\",\"127.0.0.1\",\"--port\",8083,\"--websocket_port\",9151,\"--project_id\",\"padur-library-58b3a\",\"--rules\",\"D:\\\\Balu\\\\Projects\\\\TeamBooks_FlutterFrames\\\\teambooks_flutterframes\\\\firestore.rules\",\"--single_project_mode\",true,\"--functions_emulator\",\"127.0.0.1:5001\"],\"optionalArgs\":[\"port\",\"webchannel_port\",\"host\",\"rules\",\"websocket_port\",\"functions_emulator\",\"seed_from_export\",\"project_id\",\"single_project_mode\"],\"joinArgs\":false,\"shell\":false,\"port\":8083}"}}
[info] i  firestore: Firestore Emulator logging to firestore-debug.log {"metadata":{"emulator":{"name":"firestore"},"message":"Firestore Emulator logging to \u001b[1mfirestore-debug.log\u001b[22m"}}
[info] +  firestore: Firestore Emulator UI websocket is running on 9151. {"metadata":{"emulator":{"name":"firestore"},"message":"Firestore Emulator UI websocket is running on 9151."}}
[debug] [2025-06-18T02:05:49.906Z] [Extensions] Connecting Extensions emulator, this is a noop.
[info] i  functions: Watching "D:\Balu\Projects\TeamBooks_FlutterFrames\teambooks_flutterframes\functions" for Cloud Functions... {"metadata":{"emulator":{"name":"functions"},"message":"Watching \"D:\\Balu\\Projects\\TeamBooks_FlutterFrames\\teambooks_flutterframes\\functions\" for Cloud Functions..."}}
[debug] [2025-06-18T02:05:49.914Z] Customer code is not Node
[debug] [2025-06-18T02:05:49.915Z] Validating python source
[debug] [2025-06-18T02:05:49.915Z] Building python source
[debug] [2025-06-18T02:05:49.917Z] Could not find functions.yaml. Must use http discovery
[debug] [2025-06-18T02:05:49.930Z] Running command with virtualenv: command="D:\Balu\Projects\TeamBooks_FlutterFrames\teambooks_flutterframes\functions\venv\Scripts\activate.bat", args=["","&&","python.exe","-c","\"import firebase_functions; import os; print(os.path.dirname(firebase_functions.__file__))\""]
[debug] [2025-06-18T02:05:50.061Z] stdout: D:\Balu\Projects\TeamBooks_FlutterFrames\teambooks_flutterframes\functions\venv\Lib\site-packages\firebase_functions

[debug] [2025-06-18T02:05:50.069Z] Running admin server with args: ["python.exe","\"D:\\Balu\\Projects\\TeamBooks_FlutterFrames\\teambooks_flutterframes\\functions\\venv\\Lib\\site-packages\\firebase_functions\\private\\serving.py\""] and env: {"GCLOUD_PROJECT":"padur-library-58b3a","K_REVISION":"1","PORT":"80","GOOGLE_CLOUD_QUOTA_PROJECT":"padur-library-58b3a","FUNCTIONS_EMULATOR":"true","TZ":"UTC","FIREBASE_DEBUG_MODE":"true","FIREBASE_DEBUG_FEATURES":"{\"skipTokenVerification\":true,\"enableCors\":true}","FIREBASE_EMULATOR_HUB":"127.0.0.1:4400","FIRESTORE_EMULATOR_HOST":"127.0.0.1:8083","FIREBASE_FIRESTORE_EMULATOR_ADDRESS":"127.0.0.1:8083","CLOUD_EVENTARC_EMULATOR_HOST":"http://127.0.0.1:9299","CLOUD_TASKS_EMULATOR_HOST":"127.0.0.1:9499","FIREBASE_CONFIG":"{\"storageBucket\":\"padur-library-58b3a.firebasestorage.app\",\"projectId\":\"padur-library-58b3a\"}","GOOGLE_APPLICATION_CREDENTIALS":"C:\\Users\\2004b\\AppData\\Roaming\\firebase\\balu_somenumbers_gmail.com_application_default_credentials.json","ADMIN_PORT":"8081"} in D:\Balu\Projects\TeamBooks_FlutterFrames\teambooks_flutterframes\functions
[debug] [2025-06-18T02:05:50.069Z] Running command with virtualenv: command="D:\Balu\Projects\TeamBooks_FlutterFrames\teambooks_flutterframes\functions\venv\Scripts\activate.bat", args=["","&&","python.exe","\"D:\\Balu\\Projects\\TeamBooks_FlutterFrames\\teambooks_flutterframes\\functions\\venv\\Lib\\site-packages\\firebase_functions\\private\\serving.py\""]
[info]  * Serving Flask app 'serving'
 * Debug mode: off

[error] WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://127.0.0.1:8081

[error] Press CTRL+C to quit

[error] 127.0.0.1 - - [18/Jun/2025 02:05:51] "GET /__/functions.yaml HTTP/1.1" 200 -

[debug] [2025-06-18T02:05:51.611Z] Got response from /__/functions.yaml endpoints:
  add_book_to_catalog:
    availableMemoryMb: null
    callableTrigger: {}
    concurrency: null
    cpu: gcf_gen1
    entryPoint: add_book_to_catalog
    ingressSettings: null
    labels:
      deployment-callable: 'true'
    maxInstances: null
    minInstances: null
    platform: gcfv2
    region:
    - asia-south1
    secretEnvironmentVariables: []
    serviceAccountEmail: null
    timeoutSeconds: null
  check_phone_number_exists:
    availableMemoryMb: null
    callableTrigger: {}
    concurrency: null
    cpu: gcf_gen1
    entryPoint: check_phone_number_exists
    ingressSettings: null
    labels:
      deployment-callable: 'true'
    maxInstances: null
    minInstances: null
    platform: gcfv2
    region:
    - asia-south1
    secretEnvironmentVariables: []
    serviceAccountEmail: null
    timeoutSeconds: null
  get_book_details:
    availableMemoryMb: null
    callableTrigger: {}
    concurrency: null
    cpu: gcf_gen1
    entryPoint: get_book_details
    ingressSettings: null
    labels:
      deployment-callable: 'true'
    maxInstances: null
    minInstances: null
    platform: gcfv2
    region:
    - asia-south1
    secretEnvironmentVariables: []
    serviceAccountEmail: null
    timeoutSeconds: null
  validate_volunteer:
    availableMemoryMb: null
    callableTrigger: {}
    concurrency: null
    cpu: gcf_gen1
    entryPoint: validate_volunteer
    ingressSettings: null
    labels:
      deployment-callable: 'true'
    maxInstances: null
    minInstances: null
    platform: gcfv2
    region:
    - asia-south1
    secretEnvironmentVariables: []
    serviceAccountEmail: null
    timeoutSeconds: null
params: []
requiredAPIs: []
specVersion: v1alpha1

[error] 127.0.0.1 - - [18/Jun/2025 02:05:51] "GET /__/quitquitquit HTTP/1.1" 200 -

[info] +  functions: Loaded functions definitions from source: add_book_to_catalog, check_phone_number_exists, get_book_details, validate_volunteer. {"metadata":{"emulator":{"name":"functions"},"message":"Loaded functions definitions from source: add_book_to_catalog, check_phone_number_exists, get_book_details, validate_volunteer."}}
[info] +  functions[asia-south1-add_book_to_catalog]: http function initialized (http://127.0.0.1:5001/padur-library-58b3a/asia-south1/add_book_to_catalog). {"metadata":{"emulator":{"name":"functions"},"message":"\u001b[1mhttp\u001b[22m function initialized (http://127.0.0.1:5001/padur-library-58b3a/asia-south1/add_book_to_catalog)."}}
[info] +  functions[asia-south1-check_phone_number_exists]: http function initialized (http://127.0.0.1:5001/padur-library-58b3a/asia-south1/check_phone_number_exists). {"metadata":{"emulator":{"name":"functions"},"message":"\u001b[1mhttp\u001b[22m function initialized (http://127.0.0.1:5001/padur-library-58b3a/asia-south1/check_phone_number_exists)."}}
[info] +  functions[asia-south1-get_book_details]: http function initialized (http://127.0.0.1:5001/padur-library-58b3a/asia-south1/get_book_details). {"metadata":{"emulator":{"name":"functions"},"message":"\u001b[1mhttp\u001b[22m function initialized (http://127.0.0.1:5001/padur-library-58b3a/asia-south1/get_book_details)."}}
[info] +  functions[asia-south1-validate_volunteer]: http function initialized (http://127.0.0.1:5001/padur-library-58b3a/asia-south1/validate_volunteer). {"metadata":{"emulator":{"name":"functions"},"message":"\u001b[1mhttp\u001b[22m function initialized (http://127.0.0.1:5001/padur-library-58b3a/asia-south1/validate_volunteer)."}}
[debug] [2025-06-18T02:05:51.650Z] Could not find VSCode notification endpoint: FetchError: request to http://localhost:40001/vscode/notify failed, reason: . If you are not running the Firebase Data Connect VSCode extension, this is expected and not an issue.
[info] 
┌─────────────────────────────────────────────────────────────┐
│ ✔  All emulators ready! It is now safe to connect your app. │
│ i  View Emulator UI at http://127.0.0.1:4000/               │
└─────────────────────────────────────────────────────────────┘

┌────────────┬────────────────┬──────────────────────────────────┐
│ Emulator   │ Host:Port      │ View in Emulator UI              │
├────────────┼────────────────┼──────────────────────────────────┤
│ Functions  │ 127.0.0.1:5001 │ http://127.0.0.1:4000/functions  │
├────────────┼────────────────┼──────────────────────────────────┤
│ Firestore  │ 127.0.0.1:8083 │ http://127.0.0.1:4000/firestore  │
├────────────┼────────────────┼──────────────────────────────────┤
│ Extensions │ 127.0.0.1:5001 │ http://127.0.0.1:4000/extensions │
└────────────┴────────────────┴──────────────────────────────────┘
  Emulator Hub host: 127.0.0.1 port: 4400
  Other reserved ports: 4500, 9151
┌─────────────────────────┬───────────────┬─────────────────────┐
│ Extension Instance Name │ Extension Ref │ View in Emulator UI │
└─────────────────────────┴───────────────┴─────────────────────┘
Issues? Report them at https://github.com/firebase/firebase-tools/issues and attach the *-debug.log files.
 
[debug] [2025-06-18T02:06:04.669Z] [work-queue] {"queuedWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:06:04.669Z"],"queueLength":1,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:06:04.669Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:06:04.669Z"],"workRunningCount":1}
[debug] [2025-06-18T02:06:04.671Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:06:45.807Z] [work-queue] {"queuedWork":["/padur-library-58b3a/asia-south1/validate_volunteer-2025-06-18T02:06:45.807Z"],"queueLength":1,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:06:45.808Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":["/padur-library-58b3a/asia-south1/validate_volunteer-2025-06-18T02:06:45.807Z"],"workRunningCount":1}
[debug] [2025-06-18T02:06:45.808Z] Accepted request GET /padur-library-58b3a/asia-south1/validate_volunteer --> asia-south1-validate_volunteer
[debug] [2025-06-18T02:06:45.810Z] [functions] Runtime ready! Sending request! {"metadata":{"emulator":{"name":"functions"},"message":"[functions] Runtime ready! Sending request!"}}
[debug] [2025-06-18T02:06:45.811Z] [functions] Got req.url=/padur-library-58b3a/asia-south1/validate_volunteer, mapping to path=/ {"metadata":{"emulator":{"name":"functions"},"message":"[functions] Got req.url=/padur-library-58b3a/asia-south1/validate_volunteer, mapping to path=/"}}
[debug] [2025-06-18T02:06:45.826Z] Running command with virtualenv: command="D:\Balu\Projects\TeamBooks_FlutterFrames\teambooks_flutterframes\functions\venv\Scripts\activate.bat", args=["","&&","functions-framework"]
[debug] [2025-06-18T02:06:45.838Z] [worker-pool] addWorker(asia-south1-validate_volunteer) {"metadata":{"emulator":{"name":"functions"},"message":"[worker-pool] addWorker(asia-south1-validate_volunteer)"}}
[debug] [2025-06-18T02:06:45.839Z] [worker-pool] Adding worker with key asia-south1-validate_volunteer, total=1 {"metadata":{"emulator":{"name":"functions"},"message":"[worker-pool] Adding worker with key asia-south1-validate_volunteer, total=1"}}
[info] >   * Serving Flask app 'validate_volunteer'
 {"user":" * Serving Flask app 'validate_volunteer'\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m  * Serving Flask app 'validate_volunteer'\r"}}
[info] >   * Debug mode: on
 {"user":" * Debug mode: on\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m  * Debug mode: on\r"}}
[info] >  WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 {"user":"WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.\r"}}
[info] >   * Running on http://127.0.0.1:8823
 {"user":" * Running on http://127.0.0.1:8823\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m  * Running on http://127.0.0.1:8823\r"}}
[info] >  Press CTRL+C to quit
 {"user":"Press CTRL+C to quit\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m Press CTRL+C to quit\r"}}
[info] >   * Restarting with watchdog (windowsapi)
 {"user":" * Restarting with watchdog (windowsapi)\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m  * Restarting with watchdog (windowsapi)\r"}}
[info] >   * Debugger is active!
 {"user":" * Debugger is active!\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m  * Debugger is active!\r"}}
[info] >   * Debugger PIN: 923-795-662
 {"user":" * Debugger PIN: 923-795-662\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m  * Debugger PIN: 923-795-662\r"}}
[info] >  WARNING:root:Request has invalid method. GET
 {"user":"WARNING:root:Request has invalid method. GET\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m WARNING:root:Request has invalid method. GET\r"}}
[debug] [2025-06-18T02:06:47.992Z] [worker-asia-south1-validate_volunteer-00d6369a-befb-4f40-a20a-93528191a2ff]: IDLE {"metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"[worker-asia-south1-validate_volunteer-00d6369a-befb-4f40-a20a-93528191a2ff]: IDLE"}}
[debug] [2025-06-18T02:06:47.993Z] [worker-pool] submitRequest(triggerId=asia-south1-validate_volunteer) {"metadata":{"emulator":{"name":"functions"},"message":"[worker-pool] submitRequest(triggerId=asia-south1-validate_volunteer)"}}
[info] i  functions: Beginning execution of "asia-south1-validate_volunteer" {"metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"Beginning execution of \"asia-south1-validate_volunteer\""}}
[debug] [2025-06-18T02:06:47.994Z] [worker-asia-south1-validate_volunteer-00d6369a-befb-4f40-a20a-93528191a2ff]: BUSY {"metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"[worker-asia-south1-validate_volunteer-00d6369a-befb-4f40-a20a-93528191a2ff]: BUSY"}}
[info] >  ERROR:root:Invalid request, unable to process.
 {"user":"ERROR:root:Invalid request, unable to process.\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m ERROR:root:Invalid request, unable to process.\r"}}
[info] >  127.0.0.1 - - [18/Jun/2025 02:06:47] "GET /__/health HTTP/1.1" 400 -
 {"user":"127.0.0.1 - - [18/Jun/2025 02:06:47] \"GET /__/health HTTP/1.1\" 400 -\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m 127.0.0.1 - - [18/Jun/2025 02:06:47] \"GET /__/health HTTP/1.1\" 400 -\r"}}
[info] >  INFO:werkzeug:127.0.0.1 - - [18/Jun/2025 02:06:47] "GET /__/health HTTP/1.1" 400 -
 {"user":"INFO:werkzeug:127.0.0.1 - - [18/Jun/2025 02:06:47] \"\u001b[31m\u001b[1mGET /__/health HTTP/1.1\u001b[0m\" 400 -\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m INFO:werkzeug:127.0.0.1 - - [18/Jun/2025 02:06:47] \"\u001b[31m\u001b[1mGET /__/health HTTP/1.1\u001b[0m\" 400 -\r"}}
[info] >  WARNING:root:Request has invalid method. GET
 {"user":"WARNING:root:Request has invalid method. GET\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m WARNING:root:Request has invalid method. GET\r"}}
[debug] [2025-06-18T02:06:48.000Z] Finishing up request with event=pause {"metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"Finishing up request with event=pause"}}
[info] i  functions: Finished "asia-south1-validate_volunteer" in 6.871ms {"metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"Finished \"asia-south1-validate_volunteer\" in 6.871ms"}}
[debug] [2025-06-18T02:06:48.001Z] [worker-asia-south1-validate_volunteer-00d6369a-befb-4f40-a20a-93528191a2ff]: IDLE {"metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"[worker-asia-south1-validate_volunteer-00d6369a-befb-4f40-a20a-93528191a2ff]: IDLE"}}
[debug] [2025-06-18T02:06:48.001Z] Finishing up request with event=finish {"metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"Finishing up request with event=finish"}}
[debug] [2025-06-18T02:06:48.001Z] Finishing up request with event=close {"metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"Finishing up request with event=close"}}
[debug] [2025-06-18T02:06:48.002Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":[],"workRunningCount":0}
[info] >  ERROR:root:Invalid request, unable to process.
 {"user":"ERROR:root:Invalid request, unable to process.\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m ERROR:root:Invalid request, unable to process.\r"}}
[info] >  127.0.0.1 - - [18/Jun/2025 02:06:47] "GET / HTTP/1.1" 400 -
 {"user":"127.0.0.1 - - [18/Jun/2025 02:06:47] \"GET / HTTP/1.1\" 400 -\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m 127.0.0.1 - - [18/Jun/2025 02:06:47] \"GET / HTTP/1.1\" 400 -\r"}}
[info] >  INFO:werkzeug:127.0.0.1 - - [18/Jun/2025 02:06:47] "GET / HTTP/1.1" 400 -
 {"user":"INFO:werkzeug:127.0.0.1 - - [18/Jun/2025 02:06:47] \"\u001b[31m\u001b[1mGET / HTTP/1.1\u001b[0m\" 400 -\r","metadata":{"emulator":{"name":"functions"},"function":{"name":"asia-south1-validate_volunteer"},"extension":{},"message":"\u001b[90m> \u001b[39m INFO:werkzeug:127.0.0.1 - - [18/Jun/2025 02:06:47] \"\u001b[31m\u001b[1mGET / HTTP/1.1\u001b[0m\" 400 -\r"}}
[debug] [2025-06-18T02:06:48.468Z] Functions emulator received unknown request at path /favicon.ico
[debug] [2025-06-18T02:07:12.373Z] [work-queue] {"queuedWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:07:12.373Z"],"queueLength":1,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:07:12.373Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:07:12.373Z"],"workRunningCount":1}
[debug] [2025-06-18T02:07:12.373Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:15:56.462Z] [work-queue] {"queuedWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:15:56.462Z"],"queueLength":1,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:15:56.462Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:15:56.462Z"],"workRunningCount":1}
[debug] [2025-06-18T02:15:56.463Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:16:02.455Z] [work-queue] {"queuedWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:16:02.455Z"],"queueLength":1,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:16:02.455Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:16:02.455Z"],"workRunningCount":1}
[debug] [2025-06-18T02:16:02.456Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:16:12.093Z] Functions emulator received unknown request at path /
[debug] [2025-06-18T02:17:35.268Z] [work-queue] {"queuedWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:17:35.268Z"],"queueLength":1,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:17:35.268Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:17:35.268Z"],"workRunningCount":1}
[debug] [2025-06-18T02:17:35.268Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:17:40.057Z] [work-queue] {"queuedWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:17:40.057Z"],"queueLength":1,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:17:40.058Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:17:40.057Z"],"workRunningCount":1}
[debug] [2025-06-18T02:17:40.058Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:18:21.643Z] [work-queue] {"queuedWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:18:21.643Z"],"queueLength":1,"runningWork":[],"workRunningCount":0}
[debug] [2025-06-18T02:18:21.643Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":["/padur-library-58b3a/us-central1/validate_volunteer-2025-06-18T02:18:21.643Z"],"workRunningCount":1}
[debug] [2025-06-18T02:18:21.643Z] [work-queue] {"queuedWork":[],"queueLength":0,"runningWork":[],"workRunningCount":0}
```