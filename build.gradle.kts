plugins {
	java
	id("org.springframework.boot") version "4.0.2"
	id("io.spring.dependency-management") version "1.1.7"
	id("io.freefair.lombok") version "9.1.0"
	id("com.diffplug.spotless") version "8.1.0"
}

group = "com.apiece"
version = "0.0.1-SNAPSHOT"
description = "Demo project for Spring Boot"

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(25)
	}
}

tasks.withType<JavaCompile> {
	options.compilerArgs.add("-parameters")
}

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.springframework.boot:spring-boot-h2console")
	implementation("org.springframework.boot:spring-boot-starter-data-jpa")
	implementation("org.springframework.boot:spring-boot-starter-webmvc")
	implementation("org.springframework.boot:spring-boot-starter-validation")
	implementation("org.springframework.security:spring-security-crypto")
	runtimeOnly("com.h2database:h2")
	runtimeOnly("org.postgresql:postgresql")
	testImplementation("org.springframework.boot:spring-boot-starter-data-jpa-test")
	testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")
	testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.withType<Test> {
	useJUnitPlatform()
}

spotless {
	java {
		target("src/**/*.java")
		removeUnusedImports()
		trimTrailingWhitespace()
		endWithNewline()
	}

	kotlinGradle {
		target("*.gradle.kts")
		ktlint()
		trimTrailingWhitespace()
		endWithNewline()
	}

	json {
		target("src/**/*.json", ".claude/**/*.json")
		gson()
			.indentWithSpaces(2)
			.sortByKeys()
		trimTrailingWhitespace()
		endWithNewline()
	}

	yaml {
		target("src/**/*.yaml", "src/**/*.yml")
		jackson()
			.yamlFeature("WRITE_DOC_START_MARKER", false)
			.yamlFeature("MINIMIZE_QUOTES", true)
		trimTrailingWhitespace()
		endWithNewline()
	}

	format("markdown") {
		target("*.md", ".claude/**/*.md")
		trimTrailingWhitespace()
		endWithNewline()
	}

	format("misc") {
		target("src/**/*.properties", "src/**/*.xml", "src/**/*.sql", "src/**/*.sh")
		trimTrailingWhitespace()
		endWithNewline()
	}
}