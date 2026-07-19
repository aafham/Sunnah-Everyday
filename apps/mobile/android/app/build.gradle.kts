import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.aafha.sunnaheveryday"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.aafha.sunnaheveryday"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Release signing and release automation are owned by REL-03.
            // Keeping this unset prevents debug credentials from being reused.
        }
    }
}

// Fail closed until the owner provisions a verified upload-key process and
// REL-03 replaces this guard with an audited release-signing configuration.
// A debug APK remains available for local development only.
tasks.configureEach {
    if (name.contains("Release", ignoreCase = true)) {
        doFirst {
            throw GradleException(
                "Release builds are disabled until REL-03 signing readiness is complete.",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
