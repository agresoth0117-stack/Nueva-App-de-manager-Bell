plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.manager_bell"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.manager_bell"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // 👇 Kotlin DSL correcto para desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {

        release {
            signingConfig = signingConfigs.getByName("debug")  // ❗ si tienes keystore luego lo cambiamos

            // 🔥 Aquí agregué exactamente lo que pediste:
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        debug {
            isDebuggable = true
        }
    }
}

dependencies {
    // 👇 Desugaring correcto para Kotlin DSL
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    implementation("androidx.multidex:multidex:2.0.1")

    // TODAS tus demás dependencias se siguen manejando desde pubspec.yaml
}

flutter {
    source = "../.."
}
