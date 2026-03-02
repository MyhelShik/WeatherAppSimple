plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    
    // --- ДОБАВЛЕНО: Плагин Google Services для работы Firebase ---
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.weatherfreeapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Уникальный ID приложения, который ты зарегистрировал в Firebase
        applicationId = "com.example.weatherfreeapp"
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Используем дебаг-ключи для сборки, пока не создан боевой ключ
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// --- ДОБАВЛЕНО: Зависимости Firebase ---
dependencies {
    // Импорт Firebase BoM (Bill of Materials) для управления версиями
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))

    // Подключаем нужные модули Firebase
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}