allprojects {
    repositories {
        google()
        mavenCentral()
    }

    configurations.configureEach {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.datastore") {
                useVersion("1.2.1")
                because("Use the current stable DataStore native libraries for 16 KB page-size compatibility.")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    if (name == "isar_flutter_libs") {
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                namespace = "dev.isar.isar_flutter_libs"
            }
        }

        afterEvaluate {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                compileSdk = 34
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
