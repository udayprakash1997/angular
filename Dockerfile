#FROM node:18.12.0-alpine as builder
FROM node:19-bullseye as builder

#LABEL image.title="H&S Shell app" \
 #   image.description="Docker image for Shell app"

WORKDIR /src

# Install dependencies from packages.json
COPY package.json ./
COPY package-lock.json ./

# Install all node packages
#COPY /prod/.npmrc .
RUN npm install -g pnpm
RUN pnpm install --force
RUN npx kendo-ui-license activate



# Copy everything over to Docker environment
COPY . ./

# The test command will force Jest to run in CI-mode, and tests will only run once instead of launching the watcher
ENV CI=true

RUN pnpm build

# STAGE 2: production environment
#######################################
# Pull the official nginx base image
FROM nginx:stable-alpine

# copy the nginx custom configuration file
COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /usr/share/nginx/html

# Remove default nginx static resources
RUN rm -rf ./*

# Copy static resources from builder stage
COPY --from=builder /src/dist/. .

CMD ["nginx", "-g", "daemon off;"]
