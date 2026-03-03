ARG FLUTTER_VERSION=3.38.7
# Stage 1 - Install dependencies and build the app
# This matches the flutter version on our CI/CD pipeline on Github
FROM --platform=amd64 ghcr.io/instrumentisto/flutter:${FLUTTER_VERSION}@sha256:73f65f634fc55dd44dd7981f2f5a548eb8dca99c7fdd654398e2a882f3d112f6 AS build-env

# Set directory to Copy App
WORKDIR /app

COPY . .

# Precompile tmail flutter
RUN ./scripts/prebuild.sh
# Build flutter for web
RUN flutter build web --release

# Stage 2 - Create the run-time image
FROM nginx:alpine
RUN apk add gzip
COPY --from=build-env /app/server/nginx.conf /etc/nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Record the exposed port
EXPOSE 80

# Before stating NGinx, re-zip all the content to ensure customizations are propagated
CMD gzip -k -r -f /usr/share/nginx/html/ && nginx -g 'daemon off;'
