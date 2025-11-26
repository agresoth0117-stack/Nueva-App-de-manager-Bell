allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ❗ No mover carpetas build — Codemagic falla con rutas personalizadas
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
