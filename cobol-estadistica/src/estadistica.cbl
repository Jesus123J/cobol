IDENTIFICATION DIVISION.
PROGRAM-ID. ESTADISTICA.
*> ---------------------------------------------------------------
*> Analizador estadistico de datos economicos (PIB e inflacion)
*> Lee un CSV, calcula estadisticas y dibuja graficos de barras
*> ---------------------------------------------------------------

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT ARCHIVO-DATOS ASSIGN TO "data/economia.csv"
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS WS-ESTADO.

DATA DIVISION.
FILE SECTION.
FD ARCHIVO-DATOS.
01 REGISTRO-CSV        PIC X(200).

WORKING-STORAGE SECTION.
01 WS-ESTADO           PIC XX.
01 WS-FIN              PIC X VALUE "N".
01 WS-PRIMERA          PIC X VALUE "S".

01 WS-CAMPO-ANIO       PIC X(10).
01 WS-CAMPO-PIB        PIC X(20).
01 WS-CAMPO-INFL       PIC X(20).

01 WS-NUM              PIC 9(3) VALUE 0.
01 TABLA-DATOS.
   05 FILA OCCURS 100 TIMES.
      10 F-ANIO        PIC X(4).
      10 F-PIB         PIC S9(9)V99 COMP-3.
      10 F-INFL        PIC S9(3)V99  COMP-3.

01 I                   PIC 9(3).
01 WS-SUMA-PIB         PIC S9(12)V99  VALUE 0.
01 WS-SUMA-INFL        PIC S9(6)V99   VALUE 0.
01 WS-MEDIA-PIB        PIC S9(9)V99.
01 WS-MEDIA-INFL       PIC S9(3)V99.
01 WS-MIN-PIB          PIC S9(9)V99.
01 WS-MAX-PIB          PIC S9(9)V99.
01 WS-DIF              PIC S9(9)V99.
01 WS-SUMA-CUAD        PIC S9(15)V9(4) VALUE 0.
01 WS-VARIANZA         PIC S9(12)V9(4).
01 WS-DESVIACION       PIC S9(9)V99.
01 WS-CRECIMIENTO      PIC S9(4)V99.
01 WS-INFL-MAXABS      PIC S9(3)V99   VALUE 0.
01 WS-ABS              PIC S9(3)V99.

01 WS-BARRA            PIC X(200) VALUE SPACES.
01 WS-LARGO            PIC 9(3).
01 WS-BYTES            PIC 9(3).

01 ED-PIB              PIC Z,ZZZ,ZZ9.99.
01 ED-VAL              PIC ZZZ,ZZ9.99.
01 ED-PCT              PIC +ZZ9.99.
01 ED-NUM              PIC Z9.

PROCEDURE DIVISION.
PRINCIPAL.
    PERFORM CARGAR-DATOS
    PERFORM CALCULAR-ESTADISTICAS
    PERFORM MOSTRAR-INFORME
    PERFORM GRAFICO-PIB
    PERFORM GRAFICO-INFLACION
    DISPLAY " "
    DISPLAY "Fin del analisis. Generado con GnuCOBOL."
    STOP RUN.

*> ---------------- Carga del CSV ----------------
CARGAR-DATOS.
    OPEN INPUT ARCHIVO-DATOS
    IF WS-ESTADO NOT = "00"
       DISPLAY "ERROR: no se pudo abrir data/economia.csv "
               "(estado " WS-ESTADO ")"
       STOP RUN
    END-IF
    PERFORM UNTIL WS-FIN = "S"
       READ ARCHIVO-DATOS
          AT END
             MOVE "S" TO WS-FIN
          NOT AT END
             IF WS-PRIMERA = "S"
                MOVE "N" TO WS-PRIMERA
             ELSE
                ADD 1 TO WS-NUM
                UNSTRING REGISTRO-CSV DELIMITED BY ","
                   INTO WS-CAMPO-ANIO WS-CAMPO-PIB WS-CAMPO-INFL
                MOVE WS-CAMPO-ANIO TO F-ANIO(WS-NUM)
                COMPUTE F-PIB(WS-NUM) =
                        FUNCTION NUMVAL(WS-CAMPO-PIB)
                COMPUTE F-INFL(WS-NUM) =
                        FUNCTION NUMVAL(WS-CAMPO-INFL)
             END-IF
       END-READ
    END-PERFORM
    CLOSE ARCHIVO-DATOS.

*> ---------------- Estadisticas ----------------
CALCULAR-ESTADISTICAS.
    MOVE F-PIB(1) TO WS-MIN-PIB WS-MAX-PIB
    PERFORM VARYING I FROM 1 BY 1 UNTIL I > WS-NUM
       ADD F-PIB(I)  TO WS-SUMA-PIB
       ADD F-INFL(I) TO WS-SUMA-INFL
       IF F-PIB(I) < WS-MIN-PIB
          MOVE F-PIB(I) TO WS-MIN-PIB
       END-IF
       IF F-PIB(I) > WS-MAX-PIB
          MOVE F-PIB(I) TO WS-MAX-PIB
       END-IF
       COMPUTE WS-ABS = FUNCTION ABS(F-INFL(I))
       IF WS-ABS > WS-INFL-MAXABS
          MOVE WS-ABS TO WS-INFL-MAXABS
       END-IF
    END-PERFORM
    COMPUTE WS-MEDIA-PIB  = WS-SUMA-PIB  / WS-NUM
    COMPUTE WS-MEDIA-INFL = WS-SUMA-INFL / WS-NUM
    PERFORM VARYING I FROM 1 BY 1 UNTIL I > WS-NUM
       COMPUTE WS-DIF = F-PIB(I) - WS-MEDIA-PIB
       COMPUTE WS-SUMA-CUAD = WS-SUMA-CUAD + WS-DIF * WS-DIF
    END-PERFORM
    COMPUTE WS-VARIANZA  = WS-SUMA-CUAD / WS-NUM
    COMPUTE WS-DESVIACION = FUNCTION SQRT(WS-VARIANZA)
    COMPUTE WS-CRECIMIENTO =
            (F-PIB(WS-NUM) - F-PIB(1)) / F-PIB(1) * 100.

*> ---------------- Informe ----------------
MOSTRAR-INFORME.
    DISPLAY "================================================="
    DISPLAY "   ANALISIS ESTADISTICO ECONOMICO  (COBOL)"
    DISPLAY "   Periodo: " F-ANIO(1) " - " F-ANIO(WS-NUM)
    DISPLAY "================================================="
    MOVE WS-NUM TO ED-NUM
    DISPLAY "Observaciones ........... " ED-NUM
    MOVE WS-MEDIA-PIB TO ED-PIB
    DISPLAY "PIB medio ............... " ED-PIB
            "  (miles de millones EUR)"
    MOVE WS-MIN-PIB TO ED-PIB
    DISPLAY "PIB minimo .............. " ED-PIB
    MOVE WS-MAX-PIB TO ED-PIB
    DISPLAY "PIB maximo .............. " ED-PIB
    MOVE WS-DESVIACION TO ED-PIB
    DISPLAY "Desviacion estandar ..... " ED-PIB
    MOVE WS-CRECIMIENTO TO ED-PCT
    DISPLAY "Crecimiento del periodo . " ED-PCT " %"
    MOVE WS-MEDIA-INFL TO ED-PCT
    DISPLAY "Inflacion media anual ... " ED-PCT " %".

*> ---------------- Grafico de PIB ----------------
GRAFICO-PIB.
    DISPLAY " "
    DISPLAY "PIB por anio (escala: barra maxima = PIB maximo)"
    DISPLAY "-------------------------------------------------"
    PERFORM VARYING I FROM 1 BY 1 UNTIL I > WS-NUM
       COMPUTE WS-LARGO = F-PIB(I) / WS-MAX-PIB * 42
       IF WS-LARGO < 1
          MOVE 1 TO WS-LARGO
       END-IF
       COMPUTE WS-BYTES = WS-LARGO * 3
       MOVE SPACES TO WS-BARRA
       MOVE ALL "█" TO WS-BARRA(1:WS-BYTES)
       MOVE F-PIB(I) TO ED-VAL
       DISPLAY F-ANIO(I) " |" WS-BARRA(1:WS-BYTES) " " ED-VAL
    END-PERFORM.

*> ---------------- Grafico de inflacion ----------------
GRAFICO-INFLACION.
    DISPLAY " "
    DISPLAY "Inflacion anual %  (▒ = valor negativo/deflacion)"
    DISPLAY "-------------------------------------------------"
    PERFORM VARYING I FROM 1 BY 1 UNTIL I > WS-NUM
       COMPUTE WS-ABS = FUNCTION ABS(F-INFL(I))
       COMPUTE WS-LARGO = WS-ABS / WS-INFL-MAXABS * 40
       IF WS-LARGO < 1
          MOVE 1 TO WS-LARGO
       END-IF
       COMPUTE WS-BYTES = WS-LARGO * 3
       MOVE SPACES TO WS-BARRA
       IF F-INFL(I) < 0
          MOVE ALL "▒" TO WS-BARRA(1:WS-BYTES)
       ELSE
          MOVE ALL "█" TO WS-BARRA(1:WS-BYTES)
       END-IF
       MOVE F-INFL(I) TO ED-PCT
       DISPLAY F-ANIO(I) " |" WS-BARRA(1:WS-BYTES) " " ED-PCT " %"
    END-PERFORM.
