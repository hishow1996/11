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
        // Official sherpa-onnx publishes Android artifacts through JitPack.
        // This keeps the JNI/Kotlin runtime out of the source tree while
        // allowing the Android build to resolve it reproducibly.
        maven { url = uri("https://jitpack.io") }
    }
}

rootProject.name = "LinguaLive"
include(":app")
