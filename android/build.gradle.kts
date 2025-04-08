// Root-level build.gradle.kts (android/build.gradle.kts)

buildscript {
    repositories {
        google()
        mavenCentral() // ✅ Removed deprecated jcenter()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.1") // ✅ Latest Gradle plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0") // ✅ Kotlin plugin
        classpath("com.google.gms:google-services:4.4.2") // ✅ Fixed classpath format
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Configure shared build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ✅ Ensure subprojects depend on ":app"
subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
