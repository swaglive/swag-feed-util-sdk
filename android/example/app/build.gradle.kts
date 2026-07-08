import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "live.swag.feedutil.example"
    compileSdk = 36

    defaultConfig {
        applicationId = "live.swag.feedutil.example"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            // Debug signing so the example runs without a release keystore.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    // AARs from `flutter build aar` — see settings.gradle.kts repositories.
    implementation("live.swag.feedutil:feed-util:1.0")

    // Pull-to-refresh for the demo feed (AndroidX; android.useAndroidX=true).
    implementation("androidx.swiperefreshlayout:swiperefreshlayout:1.1.0")
}
