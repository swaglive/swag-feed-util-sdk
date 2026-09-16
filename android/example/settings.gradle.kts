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
        // Maven repository bundled with this release.
        maven(url = file("../aar-repo"))
        // Flutter engine artifacts referenced by the AAR poms.
        maven(url = "https://storage.googleapis.com/download.flutter.io")
    }
}

rootProject.name = "FeedUtilExample"

include(":app")
