// App-level build.gradle.kts (android/app/build.gradle.kts)
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // ✅ Flutter Plugin
    id("com.google.gms.google-services")   // ✅ Google Services Plugin (Required for Firebase)
}

android {
    namespace = "com.example.os_project"
    compileSdk = 35 // ✅ Updated to match plugin requirements
    ndkVersion = "27.0.12077973" // ✅ Use the highest required NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        isCoreLibraryDesugaringEnabled = true // ✅ Enable desugaring for Java 8+ features
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.os_project"
        minSdk = 23  // ✅ Set minimum SDK manually
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    signingConfigs {
        create("release") {
            keyAlias = "your-key-alias"
            keyPassword = "your-key-password"
            storeFile = file("your-keystore-file.jks")
            storePassword = "your-store-password"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release") // ✅ Correct Kotlin DSL reference
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.1.0")) // ✅ Firebase BOM
    implementation("com.google.firebase:firebase-auth-ktx") // ✅ Firebase Auth
    implementation("com.google.firebase:firebase-firestore-ktx") // ✅ Firestore (if used)

    // ✅ Required for desugaring (fixes flutter_local_notifications issue)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
