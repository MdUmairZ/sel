# Step 1: Use an official Maven image with JDK 17 to build and bundle the app
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn dependency:go-offline -B
RUN mvn test-compile

# Step 2: Use a slim runtime image containing Java 17 and Chrome
FROM eclipse-temurin:17-jre
WORKDIR /app

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    curl \
    unzip \
    libglib2.0-0 \
    libnss3 \
    libfontconfig1 \
    chromium \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app /app
ENV CHROME_BIN=/usr/bin/chromium

CMD ["mvn", "test"]
# Step 2: Use a slim runtime image containing Java 17 and Chrome for execution headless environment
FROM eclipse-temurin:17-jre
WORKDIR /app

# Install stable Chrome dependencies required for headless Selenium runs
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    curl \
    unzip \
    libglib2.0-0 \
    libnss3 \
    libfontconfig1 \
    chromium \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled classes and dependencies from the build stage
COPY --from=build /app /app

# Set environment variable to target the internal Chromium binary if needed
ENV CHROME_BIN=/usr/bin/chromium

# Default command to run the TestNG tests inside the container
CMD ["mvn", "test"]
