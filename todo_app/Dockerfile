# BUILD
FROM growerp/flutter-sdk-image:3.35.6 AS build_env

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Fix permissions for Flutter
RUN mkdir -p /app/.flutter-plugins-dependencies || true
RUN chmod -R 777 /app/.flutter-plugins-dependencies || true
RUN chmod -R 777 /app/.dart_tool || true

ARG RELEASE_MODE=release
ENV MODE=$RELEASE_MODE

# Set Flutter environment
ENV FLUTTER_ROOT=/home/mobiledevops/.flutter-sdk
ENV GIT_DIR=/dev/null

RUN flutter analyze --no-pub
RUN flutter test --no-pub

RUN flutter build web --${MODE}

# SERVE stage
FROM nginx:1.25-alpine

COPY --from=build_env /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
