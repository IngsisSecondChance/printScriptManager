# ========== Build stage ==========
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Copiamos Gradle wrapper y archivos de construcción primero para cachear dependencias
COPY gradlew gradlew
COPY gradle gradle
COPY settings.gradle.kts settings.gradle.kts
COPY build.gradle.kts build.gradle.kts

# Descargamos dependencias (sin código todavía para aprovechar cache)
RUN ./gradlew --no-daemon dependencies || true

# Ahora sí copiamos el código fuente
COPY src src

# Construimos el JAR sin correr tests (tests ya corren en CI)
RUN ./gradlew --no-daemon clean bootJar -x test

# ========== Runtime stage ==========
FROM eclipse-temurin:17-jre AS runtime
WORKDIR /app

# (opcional) usuario no-root
RUN useradd -r -s /bin/false appuser

# Copiamos el jar generado desde la stage build
COPY --from=build /app/build/libs/*.jar app.jar

# Exponemos el puerto interno de Spring (afuera lo mapea compose)
EXPOSE 8080

# Variables por defecto (se pueden overridear en compose)
ENV SPRING_PROFILES_ACTIVE=docker

USER appuser
ENTRYPOINT ["java","-jar","/app/app.jar"]
