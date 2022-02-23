#stage 1
#specify node version to be used for building
FROM node:14-alpine as build-stage

#set working directory
WORKDIR /app

#copy package json files
COPY package*.json /app/

# show only errors during build
RUN npm install --quiet

#copy all the folder contents from local to container
COPY . .

#create a react production build
RUN npm run build

#stage 2
#define server
FROM ubuntu/nginx:latest

#copy the output from first stage that is our react build
#into nginx html directory where it will serve our index file
COPY --from=build-stage /app/build/ /var/www/html

#delete the default configuration file
RUN rm -rf /etc/nginx/sites-enabled/*

#copy react configuration file to sites-available
COPY --from=build-stage /app/nginx.conf /etc/nginx/sites-available/react

#create symbolik link to sites-enabled as default
RUN ln -s /etc/nginx/sites-available/react /etc/nginx/sites-enabled/default
