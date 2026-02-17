# BUILD
FROM growerp/flutter-sdk-image:3.35.6 as build_env

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

RUN flutter analyze
RUN flutter test

ARG RELEASE_MODE=release
ENV MODE=$RELEASE_MODE


RUN flutter build web --${MODE}

# SERVE stage
FROM nginx:alpine

COPY --from=build_env /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
