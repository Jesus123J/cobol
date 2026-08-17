#!/bin/sh
# Envia un archivo JCL a la lectora de tarjetas del mainframe (puerto 3505).
# Uso: ./submit.sh jobs/GRAFICO.jcl
if [ -z "$1" ] || [ ! -f "$1" ]; then
  echo "Uso: $0 <archivo.jcl>"; exit 1
fi
docker exec -i mvs-tk4 bash -c 'cat > /dev/tcp/127.0.0.1/3505' < "$1" \
  && echo "Job enviado a la lectora. Mira la salida con ./salida.sh"
