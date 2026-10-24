# LocalJobs Mobile

Flutter frontend for LocalJobs.

## Configure the backend URL

The API base URL is supplied with the API_BASE_URL Dart define. The default is http://localhost:5000.

    flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5000

For an Android emulator, use the host bridge address instead:

    flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000

For a physical device, set API_BASE_URL to the development machine's reachable LAN address. Chrome development also requires the backend to allow the Flutter web origin through CORS.
