pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        // Local Maven repo produced by `flutter build aar` (run it from
        // apps/feed_util first).
        maven(url = file("../aar-repo"))
        // Flutter engine artifacts referenced by the AAR poms.
        maven(url = "https://storage.googleapis.com/download.flutter.io")
    }
}

rootProject.name = "FeedUtilExample"

include(":app")
