//HERC02I JOB (1),'INFORME CTAS',CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1),
//            USER=HERC02,PASSWORD=CUL8TR
//* Programa "de produccion": lista las cuentas y saca totales.
//* TU TICKET: anadir la columna INTERES (ahorro A=2 pct, corriente
//* C=0.5 pct del saldo) y el total de intereses al pie.
//COBOL   EXEC COBUCLG
//COB.SYSIN DD *
       IDENTIFICATION DIVISION.
       PROGRAM-ID. 'INFORME'.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ARCH-CTAS ASSIGN TO UT-S-CUENTAS.
       DATA DIVISION.
       FILE SECTION.
       FD  ARCH-CTAS
           LABEL RECORDS ARE STANDARD
           RECORDING MODE IS F.
       01  REG-CTA.
           05  R-CUENTA PIC X(10).
           05  R-NOMBRE PIC X(20).
           05  R-SALDO  PIC 9(7)V99.
           05  R-TIPO   PIC X.
           05  FILLER   PIC X(40).
       WORKING-STORAGE SECTION.
       77  WS-FIN      PIC X VALUE 'N'.
       77  WS-CUANTAS  PIC S9(5) COMP-3 VALUE +0.
       77  WS-TOTAL    PIC S9(9)V99 COMP-3 VALUE +0.
       77  ED-SALDO    PIC Z,ZZZ,ZZ9.99.
       77  ED-TOTAL    PIC ZZ,ZZZ,ZZ9.99.
       77  ED-NUM      PIC ZZ9.
       PROCEDURE DIVISION.
       INICIO.
           OPEN INPUT ARCH-CTAS.
           DISPLAY '=============================================='.
           DISPLAY '   INFORME DIARIO DE CUENTAS - BANCO TK4      '.
           DISPLAY '=============================================='.
           DISPLAY 'CUENTA     TITULAR              SALDO      TIPO'.
           DISPLAY '----------------------------------------------'.
           PERFORM LEE-CTA.
           PERFORM PROCESA UNTIL WS-FIN = 'S'.
           DISPLAY '----------------------------------------------'.
           MOVE WS-CUANTAS TO ED-NUM.
           DISPLAY 'TOTAL CUENTAS....... ' ED-NUM.
           MOVE WS-TOTAL TO ED-TOTAL.
           DISPLAY 'SUMA DE SALDOS...... ' ED-TOTAL.
           CLOSE ARCH-CTAS.
           STOP RUN.
       PROCESA.
           ADD 1 TO WS-CUANTAS.
           ADD R-SALDO TO WS-TOTAL.
           MOVE R-SALDO TO ED-SALDO.
           DISPLAY R-CUENTA ' ' R-NOMBRE ED-SALDO '  ' R-TIPO.
           PERFORM LEE-CTA.
       LEE-CTA.
           READ ARCH-CTAS AT END MOVE 'S' TO WS-FIN.
/*
//GO.SYSOUT  DD SYSOUT=A
//GO.CUENTAS DD DSN=HERC02.BANCO.CUENTAS,DISP=SHR
//
