# Step 1: Use an official Maven image with JDK 17 to build and compile the app
FROM maven:3.8.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy the build configuration and source code
COPY pom.xml .
COPY src ./src

# Pre-fetch dependencies and compile test classes
RUN mvn dependency:go-offline -B
RUN mvn test-compile

# Step 2: Runtime image equipped with Java, Maven, and Google Chrome
FROM maven:3.8.6-eclipse-temurin-17
WORKDIR /app

# Install dependencies and Google Chrome Stable
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    unzip \
    libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled classes and source code from the builder stage
COPY --from=builder /app /app

# Set environment variables for Chrome binaries
ENV CHROME_BIN=/usr/bin/google-chrome-stable

# Default command to run the TestNG tests inside the container
CMD ["mvn", "test"]
