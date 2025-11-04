# ---------- BUILD STAGE ----------
FROM node:14.17.0 AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci

# Addinf build arg for backend URL
ARG REACT_APP_SERVER_URL
ENV REACT_APP_SERVER_URL=$REACT_APP_SERVER_URL

COPY . .
RUN npm run build

# ---------- PRODUCTION STAGE ----------
FROM nginx:stable
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
