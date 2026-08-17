//HERC02G JOB (1),'GRAFICO PIB',CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1)
//* Estadisticas economicas con grafico de barras en COBOL ANS (MVS 3.8j)
//COBOL   EXEC COBUCLG
//COB.SYSIN DD *
       IDENTIFICATION DIVISION.
       PROGRAM-ID. 'GRAFICO'.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       77  IND-I       PIC S9(3) COMP.
       77  IND-J       PIC S9(3) COMP.
       77  WS-LARGO    PIC S9(3) COMP.
       77  WS-SUMA     PIC S9(9)V99 COMP-3 VALUE +0.
       77  WS-MEDIA    PIC S9(6)V99 COMP-3.
       77  WS-MIN      PIC S9(6)V99 COMP-3.
       77  WS-MAX      PIC S9(6)V99 COMP-3.
       77  WS-DIF      PIC S9(6)V99 COMP-3.
       77  WS-SUMC     PIC S9(11)V99 COMP-3 VALUE +0.
       77  WS-VARZ     PIC S9(9)V99 COMP-3.
       77  WS-RAIZ     PIC S9(7)V9(4) COMP-3.
       77  WS-CREC     PIC S9(4)V99 COMP-3.
       01  DATOS-BRUTOS.
           05  FILLER PIC X(10) VALUE '2014103782'.
           05  FILLER PIC X(10) VALUE '2015107759'.
           05  FILLER PIC X(10) VALUE '2016111384'.
           05  FILLER PIC X(10) VALUE '2017116187'.
           05  FILLER PIC X(10) VALUE '2018120326'.
           05  FILLER PIC X(10) VALUE '2019124438'.
           05  FILLER PIC X(10) VALUE '2020111901'.
           05  FILLER PIC X(10) VALUE '2021122229'.
           05  FILLER PIC X(10) VALUE '2022137363'.
           05  FILLER PIC X(10) VALUE '2023146189'.
           05  FILLER PIC X(10) VALUE '2024153144'.
       01  TABLA REDEFINES DATOS-BRUTOS.
           05  FILA OCCURS 11 TIMES.
               10  F-ANIO PIC X(4).
               10  F-PIB  PIC 9(4)V99.
       01  WS-BARRA.
           05  BAR-CH PIC X OCCURS 40 TIMES.
       01  ED-VAL      PIC Z,ZZ9.99.
       01  ED-PCT      PIC +ZZ9.99.
       PROCEDURE DIVISION.
       INICIO.
           MOVE F-PIB (1) TO WS-MIN.
           MOVE F-PIB (1) TO WS-MAX.
           PERFORM ACUMULA VARYING IND-I FROM 1 BY 1
               UNTIL IND-I > 11.
           COMPUTE WS-MEDIA ROUNDED = WS-SUMA / 11.
           PERFORM DESVIOS VARYING IND-I FROM 1 BY 1
               UNTIL IND-I > 11.
           COMPUTE WS-VARZ ROUNDED = WS-SUMC / 11.
           COMPUTE WS-RAIZ = WS-VARZ / 2 + 1.
           PERFORM NEWTON 20 TIMES.
           COMPUTE WS-CREC ROUNDED =
               (F-PIB (11) - F-PIB (1)) * 100 / F-PIB (1).
           DISPLAY '============================================'.
           DISPLAY ' ANALISIS ESTADISTICO ECONOMICO - MVS 3.8J '.
           DISPLAY ' PERIODO 2014-2024  (PIB EN MILES DE MM)   '.
           DISPLAY '============================================'.
           MOVE WS-MEDIA TO ED-VAL.
           DISPLAY 'PIB MEDIO............. ' ED-VAL.
           MOVE WS-MIN TO ED-VAL.
           DISPLAY 'PIB MINIMO............ ' ED-VAL.
           MOVE WS-MAX TO ED-VAL.
           DISPLAY 'PIB MAXIMO............ ' ED-VAL.
           MOVE WS-RAIZ TO ED-VAL.
           DISPLAY 'DESVIACION ESTANDAR... ' ED-VAL.
           MOVE WS-CREC TO ED-PCT.
           DISPLAY 'CRECIMIENTO PERIODO... ' ED-PCT ' PCT'.
           DISPLAY ' '.
           DISPLAY 'PIB POR ANIO (ESCALA SOBRE EL MAXIMO)'.
           DISPLAY '--------------------------------------------'.
           PERFORM PINTA-FILA VARYING IND-I FROM 1 BY 1
               UNTIL IND-I > 11.
           DISPLAY '--------------------------------------------'.
           DISPLAY 'FIN DEL ANALISIS.'.
           STOP RUN.
       ACUMULA.
           ADD F-PIB (IND-I) TO WS-SUMA.
           IF F-PIB (IND-I) < WS-MIN
               MOVE F-PIB (IND-I) TO WS-MIN.
           IF F-PIB (IND-I) > WS-MAX
               MOVE F-PIB (IND-I) TO WS-MAX.
       DESVIOS.
           COMPUTE WS-DIF = F-PIB (IND-I) - WS-MEDIA.
           COMPUTE WS-SUMC = WS-SUMC + WS-DIF * WS-DIF.
       NEWTON.
           COMPUTE WS-RAIZ ROUNDED =
               (WS-RAIZ + WS-VARZ / WS-RAIZ) / 2.
       PINTA-FILA.
           COMPUTE WS-LARGO = F-PIB (IND-I) * 40 / WS-MAX.
           IF WS-LARGO < 1 MOVE 1 TO WS-LARGO.
           PERFORM LLENA VARYING IND-J FROM 1 BY 1
               UNTIL IND-J > 40.
           MOVE F-PIB (IND-I) TO ED-VAL.
           DISPLAY F-ANIO (IND-I) ' !' WS-BARRA '! ' ED-VAL.
       LLENA.
           IF IND-J NOT > WS-LARGO
               MOVE '*' TO BAR-CH (IND-J)
           ELSE
               MOVE ' ' TO BAR-CH (IND-J).
/*
//GO.SYSOUT DD SYSOUT=A
//
