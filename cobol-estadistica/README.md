# cobol-estadistica

Analizador estadístico económico escrito en COBOL (GnuCOBOL), empaquetado en Docker.

Lee `data/economia.csv` (año, PIB, inflación), calcula media, mínimo, máximo,
desviación estándar y crecimiento del período, y dibuja gráficos de barras
en la terminal.

## Estructura

```
cobol-estadistica/
├── Dockerfile
├── data/economia.csv      # datos de ejemplo (edítalos y vuelve a construir)
└── src/estadistica.cbl    # programa COBOL (formato libre)
```

## Uso

```bash
docker build -t cobol-estadistica .
docker run --rm cobol-estadistica
```

Para probar con tus propios datos sin reconstruir la imagen:

```bash
docker run --rm -v "$PWD/data:/app/data" cobol-estadistica
```

## Sin Docker (si tienes GnuCOBOL instalado)

```bash
cobc -x -free src/estadistica.cbl -o estadistica
./estadistica   # ejecutar desde la raíz del proyecto
```
