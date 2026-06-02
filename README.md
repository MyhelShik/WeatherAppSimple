# WeatherApp Simple

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Vercel](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)
![OpenWeather](https://img.shields.io/badge/OpenWeather-EB6E4B?style=for-the-badge&logoColor=white)
![Lottie](https://img.shields.io/badge/Lottie-00DDB3?style=for-the-badge&logoColor=white)

WeatherApp Simple is a cross-platform Flutter weather app with city search, current conditions, forecast data, animated weather states, saved favorite cities, Google authentication, and daily request limits.

The app does not call OpenWeather directly from the client. Instead, it uses a small Vercel API proxy so the OpenWeather key stays on the server.

Web version: [weatherfreeapp.web.app](https://weatherfreeapp.web.app/)  
Video demo: [GitHub user attachment](https://github.com/user-attachments/assets/968f297d-8e01-41fc-a16f-784a61672b7a)  
APK release: [GitHub Releases](https://github.com/MyhelShik/WeatherAppSimple/releases)

## What It Does

- Searches cities through a server-side OpenWeather geocoding proxy.
- Shows current weather with temperature, condition, humidity, wind, and related details.
- Loads forecast data from a Vercel API endpoint.
- Uses Lottie animations to make weather states feel more alive.
- Lets users save favorite cities locally.
- Supports Google sign-in with Firebase Auth.
- Applies daily search limits for guests and signed-in users.
- Stores authenticated-user usage counters in Firestore.
- Stores guest counters and favorites with `shared_preferences`.

## How It Works

```text
Flutter app
   |
   v
Vercel API proxy
   |
   v
OpenWeather API

Firebase Auth + Firestore
   |
   +-- Google sign-in
   +-- Authenticated-user daily limits

SharedPreferences
   |
   +-- Guest daily limits
   +-- Favorite cities
```

## Tech Stack

- **Flutter** and **Dart** for the mobile/web client.
- **Firebase Auth** for Google authentication.
- **Cloud Firestore** for signed-in user request counters.
- **Vercel serverless functions** for OpenWeather proxy endpoints.
- **OpenWeather API** for weather, forecast, and city search data.
- **SharedPreferences** for local guest state and favorites.
- **Lottie** for animated weather visuals.
- **HTTP** package for API calls.

## API Proxy

The Flutter client calls:

```text
https://weather-app-simple-sable.vercel.app/api
```

The proxy exposes three main endpoints:

```text
/api/search?query=city
/api/weather?city=city
/api/forecast?city=city
```

The OpenWeather key is stored as a Vercel environment variable:

```env
OPENWEATHER_API_KEY=your_openweather_key
```

This keeps the API key out of the Flutter app and makes the deployed client safer to share.

## Running Locally

Clone the repository:

```bash
git clone https://github.com/MyhelShik/WeatherAppSimple.git
cd WeatherAppSimple
```

Install Flutter dependencies:

```bash
flutter pub get
```

Configure Firebase for the platforms you want to run. The project uses `firebase_options.dart`, so Firebase should be configured with FlutterFire.

For native Google sign-in, provide the Google client ID expected by the app:

```env
CLIENT_ID_GOOGLE=your_google_client_id
```

Run the app:

```bash
flutter run
```

## Notes

This project focuses on a small but complete product flow: searching weather data, protecting API keys, handling authenticated and guest users differently, saving local preferences, and presenting the result with a clean animated Flutter interface.
