#!/bin/sh
# Abre una terminal 3270 (pantalla verde) conectada al mainframe emulado.
# Requiere que el mainframe esté corriendo:  docker compose up -d mvs
cd "$(dirname "$0")"
exec docker compose run --rm terminal
