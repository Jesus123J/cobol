#!/bin/sh
# Muestra la salida de la impresora del sistema (ultimas N lineas).
# Uso: ./salida.sh [lineas]
LINEAS=${1:-120}
docker exec mvs-tk4 tail -n "$LINEAS" prt/prt00e.txt
