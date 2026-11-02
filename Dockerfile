# Step 1: Use an official Maven image with JDK 17 to build and compile the app
FROM maven:3.8.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy the build configuration and source code
COPY pom.xml .
COPY src ./src

# Pre-fetch dependencies and compile test classes
RUN mvn dependency:go-offline -B
RUN mvn test-compile

# Step 2: Runtime image equipped with Java, Maven, Chrome, and ChromeDriver
FROM maven:3.8.6-eclipse-temurin-17
WORKDIR /app

# Install stable Chrome and ChromeDriver dependencies required for headless Selenium runs
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    unzip \
    libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    chromium \
    chromium-chromedriver \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled classes and source code from the builder stage
COPY --from=builder /app /app

# Set environment variables for Chromium binaries
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver

# Default command to run the TestNG tests inside the container
CMD ["mvn", "test"]
