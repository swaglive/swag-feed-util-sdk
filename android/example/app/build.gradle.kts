import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "live.swag.feedutil.example"
    compileSdk = 36

    buildFeatures { buildConfig = true }

    defaultConfig {
        applicationId = "com.example.feedutil.demo"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"

        // The shipped AAR bakes no tracker token, so the host supplies it at
        // runtime. Put `feedUtilTrackerAuthToken=<token from Swag>` in
        // local.properties (gitignored); empty means unauthenticated, which
        // the tracker rejects with domain_tracker_server_not_found.
        val trackerProps = Properties()
        val localProps = rootProject.file("local.properties")
        if (localProps.exists()) {
            localProps.inputStream().use { trackerProps.load(it) }
        }
        buildConfigField(
            "String",
            "TRACKER_AUTH_TOKEN",
            "\"${trackerProps.getProperty("feedUtilTrackerAuthToken", "")}\"",
        )
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

// Names the built artifact: FeedUtilExample-<buildType>.apk (default was
// app-<buildType>.apk). The "-<buildType>" suffix is still appended by AGP.
base {
    archivesName = "FeedUtilExample"
}

dependencies {
    // AARs from `flutter build aar` — see settings.gradle.kts repositories.
    implementation("live.swag.feedutil:feed-util:1.0")

    // Pull-to-refresh for the demo feed (AndroidX; android.useAndroidX=true).
    implementation("androidx.swiperefreshlayout:swiperefreshlayout:1.1.0")
}
