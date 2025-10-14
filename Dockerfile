# ========== Build stage ==========
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Copiamos wrapper + config primero (cache de dependencias)
COPY gradlew gradlew
COPY gradle gradle
COPY settings.gradle.kts settings.gradle.kts
COPY build.gradle.kts build.gradle.kts

# Permisos para el wrapper
RUN chmod +x gradlew

# Pre-descarga de dependencias (sin código aún para cachear)
RUN ./gradlew --no-daemon dependencies || true

# Ahora sí el código
COPY src src

# Construcción del JAR (sin tests si ya corren en CI)
RUN ./gradlew --no-daemon clean bootJar -x test

# ========== Runtime stage ==========
FROM eclipse-temurin:17-jre AS runtime
WORKDIR /app

# Usuario no-root (opcional)
RUN useradd -r -s /bin/false appuser

# Copiamos el jar generado
COPY --from=build /app/build/libs/*.jar app.jar

# Puerto interno (ajustá si tu app escucha en otro)
EXPOSE 8081

# Perfil por defecto (si usás perfiles)
ENV SPRING_PROFILES_ACTIVE=docker

USER appuser
ENTRYPOINT ["java","-jar","/app/app.jar"]