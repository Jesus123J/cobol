# Sesión 15/08/2026 — COBOL, Mainframe emulado y MySQL

Documentación de todo lo montado hoy: qué es cada proyecto, qué herramientas
usa, cómo se arranca, qué aprendimos y qué quedó pendiente.

---

## Resumen de lo que se hizo

1. **`cobol-estadistica/`** — Proyecto COBOL moderno (GnuCOBOL) en Docker:
   analiza datos económicos (PIB e inflación) y dibuja gráficos de barras
   en la terminal. Funciona y está probado.
2. **`mvs-mainframe/`** — Un mainframe IBM completo emulado en Docker
   (MVS 3.8j sobre Hercules), con terminal de pantalla verde, TSO, editor,
   compilador COBOL de 1974, y flujo batch por lectora de tarjetas.
   Funciona y está probado de punta a punta.
3. **`mysql-db/`** — MySQL 8.4 en Docker para bases de datos de proyectos
   privados, con datos persistentes.
4. Limpieza: 6 contenedores huérfanos de terminal eliminados; el mainframe
   quedó **parado** (no borrado).

---

## Proyecto 1: `cobol-estadistica/` — COBOL moderno

**Qué es:** un programa COBOL (formato libre, GnuCOBOL) que lee
`data/economia.csv`, calcula media, mínimo, máximo, desviación estándar y
crecimiento del período, y dibuja gráficos de barras con caracteres `█`.

**Herramientas:** GnuCOBOL 4 (compilador libre), Docker (Ubuntu 24.04).

**Uso:**
```bash
cd ~/Desktop/me/cobol/cobol-estadistica
docker run --rm cobol-estadistica                          # ejecutar
docker run --rm -v "$PWD/data:/app/data" cobol-estadistica # con tus datos
docker build -t cobol-estadistica .                        # tras cambiar código
```

---

## Proyecto 2: `mvs-mainframe/` — El mainframe como el del banco

**Qué es:** la experiencia real de mainframe bancario. Un IBM System/370
emulado con **Hercules**, corriendo **MVS 3.8j** (el antecesor de z/OS, de
1981, versión libre "TK4-"), con:

| Pieza | Qué hace | Equivalente en el banco |
|---|---|---|
| Hercules | Emula el hardware IBM | El mainframe físico |
| MVS 3.8j | Sistema operativo | z/OS |
| TSO | Sesión interactiva de usuario | TSO/ISPF |
| RPF | Editor de pantalla completa | ISPF |
| JES2 | Cola y ejecución de jobs | JES2 (¡el mismo!) |
| JCL | Lenguaje para lanzar trabajos | JCL (igual hoy) |
| VTAM | Red de terminales 3270 | VTAM/red SNA |
| RAKF | Seguridad (usuarios/claves) | RACF |
| c3270 | Terminal pantalla verde | El emulador 3270 del PC |

**Concepto clave:** todo vive DENTRO del mainframe (archivos = *datasets*,
editor, compilador). El Mac es solo una ventana.

### Arrancar y entrar

```bash
cd ~/Desktop/me/cobol/mvs-mainframe
docker compose up -d mvs      # arrancar (IPL: espera 1-3 min)
./terminal.sh                 # abrir pantalla verde
```
- En `Logon ===>`: `logon herc02` → clave `CUL8TR`
- Salir SIEMPRE con `LOGOFF` desde READY; cerrar c3270: `Ctrl+]` y `quit`
- Consola del operador (web): http://localhost:8038
- Parar todo: `docker compose stop` · Borrar todo: `docker compose down --rmi all`

**Estado actual: el mainframe quedó PARADO.** Para volver a practicar:
`docker compose up -d mvs` y esperar 1-3 minutos.

### Los dos flujos de trabajo

**A) Desde el Mac (lectora de tarjetas):**
```bash
./submit.sh jobs/GRAFICO.jcl   # envía el job a JES2 (puerto 3505)
./salida.sh                    # muestra el listado de la impresora
```

**B) Dentro de la pantalla verde (como los compañeros):**
`RFE` → `2` (Edit) → DSNAME `HERC02.BANCO.CNTL` (nombre completo), MEMBER
`INFORME`, VOLUME vacío → tipo `1` (EDIT OS) → editar → `SUBMIT` en el
`CMD =>` → resultado en opción 3.8 (Outlist).

### Chuleta del editor RPF

- Se escribe ENCIMA del texto (máquina de escribir); Enter confirma
- Sobre los NÚMEROS de línea: `I` inserta (`I3` = 3 líneas, salen en rojo),
  `D` borra (`D3` = 3), `DD`...`DD` borra bloque, `RESET` en CMD cancela
  un comando a medias (estado PENDING)
- En `CMD =>`: `FIND texto` · `CHANGE viejo nuevo ALL` · `SAVE` · `SUBMIT`
  · `CANCEL` (salir sin guardar)
- Teclas PF: F3 = guardar y salir · F7/F8 = página arriba/abajo
- **Mac:** usar `fn`+tecla F, o activar "Usar F1, F2... como teclas de
  función estándar" en Ajustes → Teclado
- Teclado bloqueado (`X` abajo): `Ctrl+R`
- **COBOL siempre en MAYÚSCULAS**; área A en col. 8, instrucciones col. 12,
  nada pasa de col. 72

### Jobs incluidos (carpeta `jobs/`)

- `HOLA.jcl` — hola mundo COBOL (probado, RC=0000)
- `GRAFICO.jcl` — estadísticas del PIB 2014-2024 con gráfico de barras `*`
  impreso por la impresora del sistema (probado; mismos resultados que el
  proyecto GnuCOBOL: desviación 152.80, crecimiento +47.56%)
- `CARGA.jcl` — crea el dataset `HERC02.BANCO.CUENTAS` con 8 cuentas
  de prueba (probado)
- `INFORME.jcl` — "programa de producción" que lee las cuentas e imprime
  el informe diario con totales (probado). También está cargado DENTRO del
  mainframe como member `INFORME` de `HERC02.BANCO.CNTL`

### 🎫 TICKET PENDIENTE (el ejercicio en curso)

> **BANCO-042:** añadir al informe diario la columna INTERES ANUAL
> (tipo A = 2% del saldo, tipo C = 0,5%) y el TOTAL DE INTERESES al pie.

Pasos ya explicados: 3 variables nuevas (`WS-INTERES`, `WS-TOTINT`,
`ED-INTERES` — insertar tras `ED-NUM`), el `IF R-TIPO = 'A'` con los dos
`COMPUTE` en el párrafo `PROCESA`, ampliar el `DISPLAY`, y el total al
final. Verificación: el total de intereses debe rondar los **800**.

### Averías y lecciones aprendidas (troubleshooting)

| Problema | Causa | Solución |
|---|---|---|
| `IKJ56425I USERID HERC02 IN USE` | Sesión anterior sin LOGOFF | En http://localhost:8038, comando `/C U=HERC02` |
| Pantalla se queda en el logo del gato, teclado bloqueado | Terminales VTAM activadas sin cliente conectado | `docker compose restart mvs` y conectarse durante el 1er minuto |
| Job falla `IEF197I SYSTEM ERROR DURING ALLOCATION` | Falta identificarse ante la seguridad RAKF | Añadir `USER=HERC02,PASSWORD=CUL8TR` a la tarjeta JOB |
| `ALLOC FAILED RC=0004` en RPF | RPF no antepone el prefijo de usuario | Poner el nombre completo: `HERC02.BANCO.CNTL` |
| Compilador escupe errores IKF2030I-C | Los niveles 77 iban después de los 01 | En este COBOL del 74, los 77 van ANTES que los 01 |

### Rarezas del COBOL de 1974 vs el moderno

Sin `FUNCTION` (ni SQRT — la desviación estándar se calcula con
Newton-Raphson a mano), sin `END-IF` (el punto cierra el IF), sin
referencias `(1:n)`, sin `NUMVAL`. Formato fijo estricto.

### Credenciales del sistema

| Usuario | Clave | Rol |
|---|---|---|
| HERC01 | CUL8TR | administrador |
| HERC02 | CUL8TR | usuario normal (el tuyo) |
| HERC03/04 | PASS4U | usuarios básicos |

---

## Proyecto 3: `mysql-db/` — Base de datos para proyectos privados

**Qué es:** MySQL 8.4 (LTS) en Docker, con los datos guardados en un
volumen (sobreviven a reinicios y a borrar el contenedor).

```bash
cd ~/Desktop/me/mysql-db
docker compose up -d            # arrancar
docker compose stop             # parar
```

**Conexión** (desde cualquier cliente: DBeaver, TablePlus, tu app, etc.):
- Host `127.0.0.1` · Puerto `3306` · Usuario `root` · Clave `123456`
- Base de datos inicial creada: `proyectos`

**Cliente de línea de comandos sin instalar nada:**
```bash
docker exec -it mysql-proyectos mysql -uroot -p123456
```
y dentro: `CREATE DATABASE mi_proyecto;`, `SHOW DATABASES;`, etc.

⚠️ La clave `123456` está en `mysql-db/docker-compose.yml` — cámbiala
si quieres otra (antes del primer arranque es trivial; después, cámbiala
con `ALTER USER` dentro de MySQL).

**Borrar TODO incluido los datos:** `docker compose down -v`

---

## Mapa de carpetas

```
~/Desktop/me/
├── cobol/                     # TODO lo de COBOL, junto
│   ├── cobol-estadistica/     # COBOL moderno con gráficos (GnuCOBOL + Docker)
│   └── mvs-mainframe/         # Mainframe MVS 3.8j emulado (+ su propio README)
├── mysql-db/                  # MySQL 8.4 para proyectos privados
└── documentacion/             # este documento
```
