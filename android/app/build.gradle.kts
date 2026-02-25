import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.athr.tayser"
    compileSdk = 36  // ← غيرها لـ 35 (أكثر استقراراً)

    defaultConfig {
        applicationId = "com.athr.tayser"
        minSdk = 24
        targetSdk = 35
        versionCode = 3
        versionName = "1.0"
        multiDexEnabled = true  // ← أضف هذا
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
        // ← أضف هذه السطور لتجاهل التحذيرات
        freeCompilerArgs = listOf(
            "-Xjvm-default=all",
            "-Xopt-in=kotlin.RequiresOptIn",
            "-Xsuppress-version-warnings"
        )
    }

    // ← أضف هذا القسم
    lint {
        disable += "InvalidPackage"
        checkReleaseBuilds = false
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")  // ← أضف هذا
}

flutter {
    source = "../.."
}
