pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
<<<<<<< HEAD
    // google services gradle plugin for firebase
    id("com.google.gms.google-services") version "4.4.2" apply false
=======
    id("com.google.gms.google-services") version "4.4.2" apply false
    
>>>>>>> 37de08c9af9cd4f226d12c5b2b68b9ca7800a507
}

include(":app")
