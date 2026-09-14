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
        // Android AAR packaging of the sherpa-onnx Kotlin API and JNI runtime.
        maven { url = uri("https://xdcobra.github.io/maven/") }
    }
}

rootProject.name = "LinguaLive"
include(":app")
