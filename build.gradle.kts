plugins {
	java
	id("org.springframework.boot") version "3.5.6"
	id("io.spring.dependency-management") version "1.1.7"
	jacoco
	id("com.diffplug.spotless") version "6.25.0"
	checkstyle
}

group = "ingsis"
version = "0.0.1-SNAPSHOT"
description = "ingsis project for Spring Boot"

java {
	toolchain { languageVersion = JavaLanguageVersion.of(17) }
}

repositories { mavenCentral() }

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-web")        // Web clásico
	implementation("org.springframework.boot:spring-boot-starter-data-jpa")
	implementation("org.springframework.boot:spring-boot-starter-validation")

	compileOnly("org.projectlombok:lombok")
	annotationProcessor("org.projectlombok:lombok")

	runtimeOnly("org.postgresql:postgresql")

	testImplementation("org.springframework.boot:spring-boot-starter-test")
	testImplementation("org.testcontainers:junit-jupiter:1.20.1")
	testImplementation("org.testcontainers:postgresql:1.20.1")
	testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.withType<Test> { useJUnitPlatform() }

/* -------- Coverage (JaCoCo) -------- */
jacoco { toolVersion = "0.8.12" }
tasks.jacocoTestReport {
	dependsOn(tasks.test)
	reports { xml.required.set(true); html.required.set(true) }
}

/* -------- Formatter (Spotless) -------- */
spotless {
	java {
		googleJavaFormat()
		target("src/**/*.java")
	}
}

/* -------- Linter (Checkstyle) -------- */
checkstyle {
	toolVersion = "10.18.1"
	// Usá 'config' (no configFile) para evitar deprecations en Gradle modernos
	config = resources.text.fromFile("config/checkstyle/checkstyle.xml")
}