// AGP kept at 8.10.1 (not the 8.11.1 the Flutter tool puts in .android) so it
// syncs in Android Studio releases that cap at AGP 8.10.x. The example is its
// own Gradle project and the consumed AAR is version-agnostic, so this
// downgrade is safe and doesn't affect the module. Bump when AS catches up.
plugins {
    id("com.android.application") version "8.10.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}
