FROM ubuntu:18.04
MAINTAINER DIALLO Abdoul Gadirou <diallo.abdoulgadirou@gmail.com>
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nginx git
RUN rm -Rf /var/www/html/*
RUN git clone https://gitlab.com/Gadirou/static-website-example.git /var/www/html/
WORKDIR  /
EXPOSE 80
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]