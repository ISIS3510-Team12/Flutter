# Juggle Flutter App

![Logo](./assets/appbanner.svg)

## Introduction
Juggle is a smart task coordination platform for university students, especially those working on group projects. It helps organize tasks, assign responsibilities, track progress, and manage deadlines in one place, reducing the need to use multiple communication platforms.

## Setup

1. Setup Flutter dependencies by running the following command in the terminal:


```bash
flutter pub get
```

2. Generate the Freezed files by running the following command in the terminal:

```bash
dart run build_runner build
```

3. Create a `.env` file in the root directory of the project and add the following environment variables with the Firebase project credentials:

```
APIKEY=
APPID=
MESSAGINGSENDERID=
PROJECTID=
STORAGEBUCKET=
API_URL=http://10.0.2.2:8000
```

4. In `android/local.properties`, add the following line with the Google Maps API key:

```
MAPS_API_KEY=GOOGLE_MAPS_API_KEY
```


## Firebase Auth emulator

Enable it to use Firebase Auth Emulator to avoid using real Firebase Auth during development.

### Backend

1. Start the Firebase Auth emulator by running the following command in the terminal from the backend root directory

```bash
firebase emulators:start --only auth
```

The emulator UI is available at http://localhost:4000

2. Add the following variable to the backend environment file and start the backend

```
FIREBASE_AUTH_EMULATOR_HOST=host.docker.internal:9099
```

### Flutter

To use the Firebase Auth emulator and the local backend, set `useDevConfig` to `true` in `lib/ui/core/app/service_locator.dart`:

```dart
const bool useDevConfig = true;
```
