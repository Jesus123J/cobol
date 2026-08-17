# mvs-mainframe — Mainframe IBM emulado en Docker

Un mainframe **MVS 3.8j (TK4-)** corriendo sobre el emulador **Hercules**, todo en
contenedores. Es el mismo estilo de entorno (TSO, JCL, pantalla verde 3270) que se
usa en los bancos, en versión libre de los años 80.

## Arrancar

```bash
docker compose up -d mvs
```

El arranque (IPL) tarda 1–3 minutos. Consola web de Hercules: http://localhost:8038

## Conectarse (pantalla verde)

```bash
./terminal.sh
```

Eso abre una terminal 3270 (`c3270`) en un contenedor conectado al mainframe.

**Login TSO:** en la pantalla del logo escribe `LOGON HERC02` y Enter.
Contraseña: `CUL8TR`. Usuarios disponibles:

| Usuario | Clave  | Perfil |
|---------|--------|--------|
| HERC01  | CUL8TR | administrador |
| HERC02  | CUL8TR | usuario normal (recomendado) |
| HERC03/04 | PASS4U | usuarios básicos |

**Teclas en c3270:** Enter = Intro · `Ctrl+C` NO cierra: usa `Ctrl+]` y luego
escribe `quit` para salir · PF3 = salir de un menú (tecla F3) · `Ctrl+a` seguido
de `c` limpia la pantalla (Clear).

## Practicar COBOL

1. Tras el logon, en `READY` escribe `RFE` (editor tipo ISPF) → opción `2` (Edit).
2. Crea un miembro en tu dataset, p. ej.: dataset `HERC02.TEST.CNTL`, member `HOLA`.
3. Escribe un job JCL+COBOL como el de `jobs/HOLA.jcl` de esta carpeta
   (el COBOL va en columnas: área A empieza en la columna 8).
4. Guarda (PF3) y envíalo con `SUBMIT` desde el editor o `SUB 'HERC02.TEST.CNTL(HOLA)'` en TSO.
5. Mira el resultado en la cola de salida: en RFE opción `3.8` (Outlist),
   o desde READY: `ST` para ver el estado de tus jobs.

El job de ejemplo usa el procedimiento `COBUCLG` (Compile → Link → Go) con el
compilador ANS COBOL de MVS. El `DISPLAY` del programa sale en el SYSOUT del job.

## Editar dentro de la pantalla verde (RFE)

Existe la biblioteca `HERC02.BANCO.CNTL` con el member `INFORME` ya cargado.
Tras el logon: `RFE` → `2` (Edit) → Project `HERC02`, Group `BANCO`,
Type `CNTL`, Member `INFORME` → Enter.

Dentro del editor: se escribe encima del texto directamente; comandos de linea
sobre los numeros de la izquierda (`i` inserta, `d` borra, `r` repite);
en la linea `===>`: `FIND texto`, `CHANGE viejo nuevo ALL`, `SAVE`, `SUBMIT`,
`CANCEL`. F3 = guardar y salir, F7/F8 = subir/bajar pagina.
Si el teclado se bloquea (X en la barra de abajo): Ctrl+R (reset).

## Enviar jobs COBOL desde el Mac (lectora de tarjetas)

Como alternativa a escribir dentro de TSO, puedes editar el JCL en tu Mac y
"meterlo por la lectora de tarjetas" del mainframe:

```bash
./submit.sh jobs/GRAFICO.jcl   # envia el job a JES2
./salida.sh                    # muestra el listado de la impresora
./salida.sh 300                # ... las ultimas 300 lineas
```

Jobs incluidos:
- `jobs/HOLA.jcl` — hola mundo COBOL con un bucle.
- `jobs/GRAFICO.jcl` — estadisticas del PIB 2014-2024 con grafico de barras
  (media, min, max, desviacion estandar con raiz por Newton-Raphson, porque
  este COBOL del 74 no tiene SQRT).
- `jobs/CARGA.jcl` — crea el dataset `HERC02.BANCO.CUENTAS` (8 cuentas de
  prueba). Ejecutalo una vez antes que INFORME.
- `jobs/INFORME.jcl` — "programa de produccion" que lee ese dataset e imprime
  el informe diario de cuentas con totales. **El ticket de practica**: anadir
  la columna INTERES (tipo A = 2%, tipo C = 0.5%) y el total de intereses.

Importante: los jobs que crean o catalogan datasets necesitan credenciales en
la tarjeta JOB (`USER=HERC02,PASSWORD=CUL8TR`) — sin ellas el sistema de
seguridad (RAKF) hace fallar la asignacion con `IEF197I`.

Reglas de oro del COBOL antiguo (MVS 3.8j): formato fijo (area A en col. 8,
area B en col. 12), los niveles 77 van ANTES que los 01 en WORKING-STORAGE,
no hay `FUNCTION`, ni `END-IF`, ni referencias `(1:n)`.

## Si el logon dice "USERID HERC02 IN USE" (IKJ56425I)

Quedo una sesion anterior colgada (cerraste la terminal sin hacer `LOGOFF`).
Solucion: abre la consola del operador en http://localhost:8038 y en el campo
`Command` ejecuta `/C U=HERC02`. Luego reintenta el logon.
Costumbre sana: salir siempre con `LOGOFF` desde READY.

## Si la pantalla se queda en el logo del gato (teclado bloqueado)

La pantalla con el gato ASCII es solo la bienvenida del emulador. La pantalla
buena es la que dice `Logon ===>` abajo. Si tras ~1 minuto no aparece, es que
MVS activó las terminales sin nadie conectado. Solución:

```bash
docker compose restart mvs
./terminal.sh        # conéctate durante el primer minuto del arranque
```

y espera en la terminal: cuando el IPL termina aparece la pantalla `Logon ===>` sola.

## Parar / borrar todo

```bash
docker compose down            # parar (conserva la imagen)
docker compose down --rmi all  # borrar también las imágenes (~todo fuera)
```

No se montan volúmenes: al recrear el contenedor el mainframe vuelve a su estado
original (ideal para trastear sin miedo).

## Nota Apple Silicon

La imagen del mainframe es x86 y corre bajo emulación (Rosetta): el IPL es algo
lento, pero para practicar va sobrado.
