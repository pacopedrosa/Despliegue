#!/bin/sh
set -e
# Verifica si el certificado ya existe
if [ ! -f /etc/nginx/certs/selfsigned.crt ]; then
 echo "Generando certificado autofirmado..."
 openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
 -subj "/C=ES/ST=Granada/L=Granada/O=IES HLanz/OU=DAW/CN=localhost/emailAddress=pacopedrosa@gmail.com" \
 -keyout /etc/nginx/certs/selfsigned.key \
 -out /etc/nginx/certs/selfsigned.crt
fi
# Ejecuta Nginx en primer plano
exec nginx -g "daemon off;"
