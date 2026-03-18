# WeatherApp (Secure Cross-Platform Weather Application)

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Vercel](https://img.shields.io/badge/vercel-%23000000.svg?style=for-the-badge&logo=vercel&logoColor=white)

A modern cross-platform application for checking weather conditions. Optimized for both web browsers and mobile devices.

## Project Links
* [Open Web Version (Firebase Hosting)](https://weatherfreeapp.web.app/)
* [Watch Video Demo](https://github.com/user-attachments/assets/968f297d-8e01-41fc-a16f-784a61672b7a)
* [Download Android APK](https://github.com/MyhelShik/WeatherAppSimple/releases/tag/app)

## Key Features
* **City Search:** Instant location search worldwide.
* **Current Weather:** Accurate real-time data on temperature, wind speed, and humidity based on OpenWeatherMap.
* **Forecast:** Detailed weather forecast for upcoming hours and days.
* **Responsive Design:** The interface smoothly adapts to desktop browser and smartphone screens.
* **Pretty design:** The interface is interesting, smooth, fluid and clean. Providing beautiful changing of gradient colors when switching from day to night or back and forth. 

## Architecture and Security (Serverless Proxy)

The standout feature of this project is its **API key protection**. 

Instead of exposing sensitive API keys within the client-side code, this project secures them through a dedicated serverless proxy architecture:

1. **Frontend (Flutter Web):** Deployed on ultra-fast **Firebase Hosting**. The client application contains absolutely no secret data or API keys.
2. **Backend (Vercel Serverless Functions):** Written in Node.js. Acts as a secure middleware bridge.
3. **Provider (OpenWeather API):** Vercel receives requests from the frontend, securely injects the hidden environment API key, and fetches the weather data from OpenWeatherMap.

*Result: Complete protection against API key compromise and unauthorized billing usage.*

## Stack
* **Frontend:** Dart, Flutter
* **Backend:** JavaScript, Node.js, Vercel Serverless (located in the /api folder)
* **Hosting:** Firebase Hosting (Web)
* **API:** OpenWeatherMap (Geocoding API, Current Weather API, Forecast API)

## How to Run Locally?

*(assuming that the user has pre-installed flutter on local machine already)*

1. Clone the repository:
   ```bash
   git clone [https://github.com/MyhelShik/WeatherAppSimple.git](https://github.com/MyhelShik/WeatherAppSimple.git)
   ```
   
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
   
3. Run the project:
   ```bash
   flutter run -d chrome
   ```
   
