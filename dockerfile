# Start with the official Bun image
FROM oven/bun:debian

# Install make and build essentials
RUN apt-get update && apt-get install -y python3 python-is-python3 build-essential qtbase5-dev git cmake libfmt-dev libboost-all-dev freeglut3-dev

RUN ln -s /usr/lib/x86_64-linux-gnu/libglut.so /usr/lib/x86_64-linux-gnu/libglut.so.3

# Set the working directory inside the container
WORKDIR /app

# Install ARGoS

COPY deb/ deb/

RUN apt-get install -y sudo

RUN apt-get install -y ./deb/argos3_simulator-3.0.0-x86_64-beta59.deb

# Verify make is installed
RUN make --version

# Copy package.json
COPY package.json bun.lock ./

COPY smart/package.json smart/bun.lock ./smart/
COPY smart-service/package.json smart-service/bun.lock ./smart-service/
COPY smart-visualiser/package.json smart-visualiser/bun.lock ./smart-visualiser/

# Install dependencies
RUN bun install

# Copy all files
COPY . .

WORKDIR /app/smart

RUN sh build.sh

# ──────────────────────────────────────────────────────────────────────────────

ENV PORT=80

EXPOSE 80

WORKDIR /app/smart-service

# Define the command to start your app
CMD ["bun", "start"]
