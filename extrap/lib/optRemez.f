C
C-----------------------------------------------------------------------
C SUBROUTINE: REMEZ
C   THIS SUBROUTINE IMPLEMENTS THE REMEZ EXCHANGE ALGORITHM
C   FOR THE WEIGHTED CHEBYSHEV APPROXIMATION OF A CONTINUOUS
C   FUNCTION WITH A SUM OF COSINES.  INPUTS TO THE SUBROUTINE
C   ARE A DENSE GRID WHICH REPLACES THE FREQUENCY AXIS, THE
C   DESIRED FUNCTION ON THIS GRID, THE WEIGHT FUNCTION ON THE
C   GRID, THE NUMBER OF COSINES, AND AN INITIAL GUESS OF THE
C   EXTREMAL FREQUENCIES.  THE PROGRAM MINIMIZES THE CHEBYSHEV
C   ERROR BY DETERMINING THE BEST LOCATION OF THE EXTREMAL
C   FREQUENCIES (POINTS OF MAXIMUM ERROR) AND THEN CALCULATES
C   THE COEFFICIENTS OF THE BEST APPROXIMATION.
C-----------------------------------------------------------------------
C
      SUBROUTINE OPTREMEZ (NKX, OPLX, WEIGHT, OPKX, KGRID, OPX, NI, EXT)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION WEIGHT(*), OPKX(*), KGRID(*), OPX(*)
      INTEGER NKX, OPLX, EXT(*)

      COMMON PI2,AD,DEV,X,Y,GRID,DES,WT,ALPHA,IEXT,NFCNS,NGRID
      COMMON /OOPS/NITER
      DIMENSION IEXT(66),AD(66),ALPHA(66),X(66),Y(66)
      DIMENSION DES(1045),GRID(1045),WT(1045)
      DIMENSION A(66),P(65),Q(65)
      DOUBLE PRECISION PI2,DNUM,DDEN,DTEMP,A,P,Q
      DOUBLE PRECISION DK,DAK,PI
      DOUBLE PRECISION AD,DEV,X,Y
      DOUBLE PRECISION GEED,DD
C --------------------------------------------------------
C Added rcsid for debugging and 
C software maintenance purposes
C

      character*160 rcsid
      save rcsid

      rcsid=
     +"$RCSfile: optRemez.f,v $"//
     +"$Revision: 1.2 $"//
     +"$Date: 1998/03/10 13:14:57 $"

C 
C End rcsid
C ----------------------------------------------------------

      PI=4.0*DATAN(1.0D0)
      PI2=2.0D00*PI
      NGRID = NKX
      NFCNS = OPLX

      DO 555 J=1,NGRID
		GRID(J) = KGRID(J)
		WT(J) = WEIGHT(J)
		DES(J) = OPKX(J)
  555 CONTINUE

C
C  INITIAL GUESS FOR THE EXTREMAL FREQUENCIES--EQUALLY
C  SPACED ALONG THE GRID
C
C      TEMP=FLOAT(NGRID-1)/FLOAT(NFCNS)
C      DO 222 J=1,NFCNS
C      XT=J-1
C  222 IEXT(J)=XT*TEMP+1.0
C      IEXT(NFCNS+1)=NGRID

      DO 222 J=1,NFCNS+1
  222 IEXT(J)=EXT(J)

C      OPEN (1, FILE='out', STATUS='OLD')
C	  write(1,*)'nfcs=',NFCNS
C	  write(1,*)'ngrid=',NGRID

C      DO 333 J=1,NGRID
C  333 write(1,'("grid(",I3,") = ",F8.5," DES = ",F6.3, " WT = ",E8.3)')J,GRID(J),DES(J),WT(J)

C      DO 334 J=1,NFCNS+1
C  334 write(*,'("iext(",I2,") = ",I5)')J,IEXT(J)

C
C  THE PROGRAM ALLOWS A MAXIMUM NUMBER OF ITERATIONS OF 25
C
      ITRMAX=25
      DEVL=-1.0
      NZ=NFCNS+1
      NZZ=NFCNS+2
      NITER=0
  100 CONTINUE
      IEXT(NZZ)=NGRID+1
      NITER=NITER+1
      IF(NITER.GT.ITRMAX) GO TO 400
      DO 110 J=1,NZ
      JXT=IEXT(J)
      DTEMP=GRID(JXT)
      DTEMP=DCOS(DTEMP*PI2)
  110 X(J)=DTEMP
      JET=(NFCNS-1)/15+1
      DO 120 J=1,NZ
  120 AD(J)=DD(J,NZ,JET)
      DNUM=0.0
      DDEN=0.0
      K=1
      DO 130 J=1,NZ
      L=IEXT(J)
      DTEMP=AD(J)*DES(L)
      DNUM=DNUM+DTEMP
      DTEMP=FLOAT(K)*AD(J)/WT(L)
      DDEN=DDEN+DTEMP
  130 K=-K
      DEV=DNUM/DDEN
C      WRITE(1,131) DEV
C  131 FORMAT(1X,12HDEVIATION = ,F12.9)
      NU=1
      IF(DEV.GT.0.0) NU=-1
      DEV=-FLOAT(NU)*DEV
      K=NU
      DO 140 J=1,NZ
      L=IEXT(J)
      DTEMP=FLOAT(K)*DEV/WT(L)
      Y(J)=DES(L)+DTEMP
  140 K=-K
      IF(DEV.GT.DEVL) GO TO 150
      NITER = -1
C      CALL OUCH
      GO TO 400
  150 DEVL=DEV
      JCHNGE=0
      K1=IEXT(1)
      KNZ=IEXT(NZ)
      KLOW=0
      NUT=-NU
      J=1
C
C  SEARCH FOR THE EXTREMAL FREQUENCIES OF THE BEST
C  APPROXIMATION
C
  200 IF(J.EQ.NZZ) YNZ=COMP
      IF(J.GE.NZZ) GO TO 300
      KUP=IEXT(J+1)
      L=IEXT(J)+1
      NUT=-NUT
      IF(J.EQ.2) Y1=COMP
      COMP=DEV
      IF(L.GE.KUP) GO TO 220
      ERR=GEED(L,NZ)
      ERR=(ERR-DES(L))*WT(L)
      DTEMP=FLOAT(NUT)*ERR-COMP
      IF(DTEMP.LE.0.0) GO TO 220
      COMP=FLOAT(NUT)*ERR
  210 L=L+1
      IF(L.GE.KUP) GO TO 215
      ERR=GEED(L,NZ)
      ERR=(ERR-DES(L))*WT(L)
      DTEMP=FLOAT(NUT)*ERR-COMP
      IF(DTEMP.LE.0.0) GO TO 215
      COMP=FLOAT(NUT)*ERR
      GO TO 210
  215 IEXT(J)=L-1
      J=J+1
      KLOW=L-1
      JCHNGE=JCHNGE+1
      GO TO 200
  220 L=L-1
  225 L=L-1
      IF(L.LE.KLOW) GO TO 250
      ERR=GEED(L,NZ)
      ERR=(ERR-DES(L))*WT(L)
      DTEMP=FLOAT(NUT)*ERR-COMP
      IF(DTEMP.GT.0.0) GO TO 230
      IF(JCHNGE.LE.0) GO TO 225
      GO TO 260
  230 COMP=FLOAT(NUT)*ERR
  235 L=L-1
      IF(L.LE.KLOW) GO TO 240
      ERR=GEED(L,NZ)
      ERR=(ERR-DES(L))*WT(L)
      DTEMP=FLOAT(NUT)*ERR-COMP
      IF(DTEMP.LE.0.0) GO TO 240
      COMP=FLOAT(NUT)*ERR
      GO TO 235
  240 KLOW=IEXT(J)
      IEXT(J)=L+1
      J=J+1
      JCHNGE=JCHNGE+1
      GO TO 200
  250 L=IEXT(J)+1
      IF(JCHNGE.GT.0) GO TO 215
  255 L=L+1
      IF(L.GE.KUP) GO TO 260
      ERR=GEED(L,NZ)
      ERR=(ERR-DES(L))*WT(L)
      DTEMP=FLOAT(NUT)*ERR-COMP
      IF(DTEMP.LE.0.0) GO TO 255
      COMP=FLOAT(NUT)*ERR
      GO TO 210
  260 KLOW=IEXT(J)
      J=J+1
      GO TO 200
  300 IF(J.GT.NZZ) GO TO 320
      IF(K1.GT.IEXT(1)) K1=IEXT(1)
      IF(KNZ.LT.IEXT(NZ)) KNZ=IEXT(NZ)
      NUT1=NUT
      NUT=-NU
      L=0
      KUP=K1
      COMP=YNZ*(1.00001)
      LUCK=1
  310 L=L+1
      IF(L.GE.KUP) GO TO 315
      ERR=GEED(L,NZ)
      ERR=(ERR-DES(L))*WT(L)
      DTEMP=FLOAT(NUT)*ERR-COMP
      IF(DTEMP.LE.0.0) GO TO 310
      COMP=FLOAT(NUT)*ERR
      J=NZZ
      GO TO 210
  315 LUCK=6
      GO TO 325
  320 IF(LUCK.GT.9) GO TO 350
      IF(COMP.GT.Y1) Y1=COMP
      K1=IEXT(NZZ)
  325 L=NGRID+1
      KLOW=KNZ
      NUT=-NUT1
      COMP=Y1*(1.00001)
  330 L=L-1
      IF(L.LE.KLOW) GO TO 340
      ERR=GEED(L,NZ)
      ERR=(ERR-DES(L))*WT(L)
      DTEMP=FLOAT(NUT)*ERR-COMP
      IF(DTEMP.LE.0.0) GO TO 330
      J=NZZ
      COMP=FLOAT(NUT)*ERR
      LUCK=LUCK+10
      GO TO 235
  340 IF(LUCK.EQ.6) GO TO 370
      DO 345 J=1,NFCNS
      NZZMJ=NZZ-J
      NZMJ=NZ-J
  345 IEXT(NZZMJ)=IEXT(NZMJ)
      IEXT(1)=K1
      GO TO 100
  350 KN=IEXT(NZZ)
      DO 360 J=1,NFCNS
  360 IEXT(J)=IEXT(J+1)
      IEXT(NZ)=KN
      GO TO 100
  370 IF(JCHNGE.GT.0) GO TO 100
C
C  CALCULATION OF THE COEFFICIENTS OF THE BEST APPROXIMATION
C  USING THE INVERSE DISCRETE FOURIER TRANSFORM
C
  400 CONTINUE
      NM1=NFCNS-1
      FSH=1.0E-06
      GTEMP=GRID(1)
      X(NZZ)=-2.0
      CN=2*NFCNS-1
      DELF=1.0/CN
      L=1
      KKK=0
      IF(GRID(1).LT.0.01.AND.GRID(NGRID).GT.0.49) KKK=1
      IF(NFCNS.LE.3) KKK=1
      IF(KKK.EQ.1) GO TO 405
      DTEMP=DCOS(PI2*GRID(1))
      DNUM=DCOS(PI2*GRID(NGRID))
      AA=2.0/(DTEMP-DNUM)
      BB=-(DTEMP+DNUM)/(DTEMP-DNUM)
  405 CONTINUE
      DO 430 J=1,NFCNS
      FT=J-1
      FT=FT*DELF
      XT=DCOS(PI2*FT)
      IF(KKK.EQ.1) GO TO 410
      XT=(XT-BB)/AA
      XT1=SQRT(1.0-XT*XT)
      FT=ATAN2(XT1,XT)/PI2
  410 XE=X(L)
      IF(XT.GT.XE) GO TO 420
      IF((XE-XT).LT.FSH) GO TO 415
      L=L+1
      GO TO 410
  415 A(J)=Y(L)
      GO TO 425
  420 IF((XT-XE).LT.FSH) GO TO 415
      GRID(1)=FT
      A(J)=GEED(1,NZ)
  425 CONTINUE
      IF(L.GT.1) L=L-1
  430 CONTINUE
      GRID(1)=GTEMP
      DDEN=PI2/CN
      DO 510 J=1,NFCNS
      DTEMP=0.0
      DNUM=J-1
      DNUM=DNUM*DDEN
      IF(NM1.LT.1) GO TO 505
      DO 500 K=1,NM1
      DAK=A(K+1)
      DK=K
  500 DTEMP=DTEMP+DAK*DCOS(DNUM*DK)
  505 DTEMP=2.0*DTEMP+A(1)
  510 ALPHA(J)=DTEMP
      DO 550 J=2,NFCNS
  550 ALPHA(J)=2.0*ALPHA(J)/CN
      ALPHA(1)=ALPHA(1)/CN
      IF(KKK.EQ.1) GO TO 545
      P(1)=2.0*ALPHA(NFCNS)*BB+ALPHA(NM1)
      P(2)=2.0*AA*ALPHA(NFCNS)
      Q(1)=ALPHA(NFCNS-2)-ALPHA(NFCNS)
      DO 540 J=2,NM1
      IF(J.LT.NM1) GO TO 515
      AA=0.5*AA
      BB=0.5*BB
  515 CONTINUE
      P(J+1)=0.0
      DO 520 K=1,J
      A(K)=P(K)
  520 P(K)=2.0*BB*A(K)
      P(2)=P(2)+A(1)*2.0*AA
      JM1=J-1
      DO 525 K=1,JM1
  525 P(K)=P(K)+Q(K)+AA*A(K+1)
      JP1=J+1
      DO 530 K=3,JP1
  530 P(K)=P(K)+AA*A(K-1)
      IF(J.EQ.NM1) GO TO 540
      DO 535 K=1,J
  535 Q(K)=-A(K)
      NF1J=NFCNS-1-J
      Q(1)=Q(1)+ALPHA(NF1J)
  540 CONTINUE
      DO 543 J=1,NFCNS
  543 ALPHA(J)=P(J)
  545 CONTINUE

C
C  CALCULATE THE IMPULSE RESPONSE.
C
      NEG = 0
      NODD = 1
      NM1=NFCNS-1
      NZ=NFCNS+1

      IF(NEG) 600,600,620
  600 IF(NODD.EQ.0) GO TO 610
      DO 605 J=1,NM1
      NZMJ=NZ-J
  605 OPX(J)=0.5*ALPHA(NZMJ)
      OPX(NFCNS)=ALPHA(1)
      GO TO 645
  610 OPX(1)=0.25*ALPHA(NFCNS)
      DO 615 J=2,NM1
      NZMJ=NZ-J
      NF2J=NFCNS+2-J
  615 OPX(J)=0.25*(ALPHA(NZMJ)+ALPHA(NF2J))
      OPX(NFCNS)=0.5*ALPHA(1)+0.25*ALPHA(2)
      GO TO 645
  620 IF(NODD.EQ.0) GO TO 630
      OPX(1)=0.25*ALPHA(NFCNS)
      OPX(2)=0.25*ALPHA(NM1)
      DO 625 J=3,NM1
      NZMJ=NZ-J
      NF3J=NFCNS+3-J
  625 OPX(J)=0.25*(ALPHA(NZMJ)-ALPHA(NF3J))
      OPX(NFCNS)=0.5*ALPHA(1)-0.25*ALPHA(3)
      OPX(NZ)=0.0
      GO TO 645
  630 OPX(1)=0.25*ALPHA(NFCNS)
      DO 635 J=2,NM1
      NZMJ=NZ-J
      NF2J=NFCNS+2-J
  635 OPX(J)=0.25*(ALPHA(NZMJ)-ALPHA(NF2J))
      OPX(NFCNS)=0.5*ALPHA(1)-0.25*ALPHA(2)

  645 CONTINUE
C      CLOSE(1)
      NI = NITER
      DO 777 J=1,NFCNS+1
  777 EXT(J)=IEXT(J)

      IF(NFCNS.GT.3) RETURN
      ALPHA(NFCNS+1)=0.0
      ALPHA(NFCNS+2)=0.0
      RETURN
      END
C
C-----------------------------------------------------------------------
C FUNCTION: DD
C   FUNCTION TO CALCULATE THE LAGRANGE INTERPOLATION
C   COEFFICIENTS FOR USE IN THE FUNCTION GEED.
C-----------------------------------------------------------------------
C
      DOUBLE PRECISION FUNCTION DD(K,N,M)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON PI2,AD,DEV,X,Y,GRID,DES,WT,ALPHA,IEXT,NFCNS,NGRID
      DIMENSION IEXT(66),AD(66),ALPHA(66),X(66),Y(66)
      DIMENSION DES(1045),GRID(1045),WT(1045)
      DOUBLE PRECISION AD,DEV,X,Y
      DOUBLE PRECISION Q
      DOUBLE PRECISION PI2
      DD=1.0
      Q=X(K)
      DO 3 L=1,M
      DO 2 J=L,N,M
      IF(J-K)1,2,1
    1 DD=2.0*DD*(Q-X(J))
    2 CONTINUE
    3 CONTINUE
      DD=1.0/DD
      RETURN
      END
C
C-----------------------------------------------------------------------
C FUNCTION: GEED
C   FUNCTION TO EVALUATE THE FREQUENCY RESPONSE USING THE
C   LAGRANGE INTERPOLATION FORMULA IN THE BARYCENTRIC FORM
C-----------------------------------------------------------------------
C
      DOUBLE PRECISION FUNCTION GEED(K,N)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON PI2,AD,DEV,X,Y,GRID,DES,WT,ALPHA,IEXT,NFCNS,NGRID
      DIMENSION IEXT(66),AD(66),ALPHA(66),X(66),Y(66)
      DIMENSION DES(1045),GRID(1045),WT(1045)
      DOUBLE PRECISION P,C,D,XF
      DOUBLE PRECISION PI2
      DOUBLE PRECISION AD,DEV,X,Y
      P=0.0
      XF=GRID(K)
      XF=DCOS(PI2*XF)
      D=0.0
      DO 1 J=1,N
      C=XF-X(J)
      C=AD(J)/C
      D=D+C
    1 P=P+C*Y(J)
      GEED=P/D
      RETURN
      END
C
C-----------------------------------------------------------------------
C SUBROUTINE: OUCH
C   WRITES AN ERROR MESSAGE WHEN THE ALGORITHM FAILS TO
C   CONVERGE.  THERE SEEM TO BE TWO CONDITIONS UNDER WHICH
C   THE ALGORITHM FAILS TO CONVERGE: (1) THE INITIAL
C   GUESS FOR THE EXTREMAL FREQUENCIES IS SO POOR THAT
C   THE EXCHANGE ITERATION CANNOT GET STARTED, OR
C   (2) NEAR THE TERMINATION OF A CORRECT DESIGN,
C   THE DEVIATION DECREASES DUE TO ROUNDING ERRORS
C   AND THE PROGRAM STOPS.  IN THIS LATTER CASE THE
C   FILTER DESIGN IS PROBABLY ACCEPTABLE, BUT SHOULD
C   BE CHECKED BY COMPUTING A FREQUENCY RESPONSE.
C-----------------------------------------------------------------------
C
C      SUBROUTINE OUCH
C      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C      COMMON /OOPS/NITER
C      WRITE(*,1)NITER
C    1 FORMAT(44H ************ FAILURE TO CONVERGE **********/
C     141H0PROBABLE CAUSE IS MACHINE ROUNDING ERROR/
C     223H0NUMBER OF ITERATIONS =,I4/
C     339H0IF THE NUMBER OF ITERATIONS EXCEEDS 3,/
C     462H0THE DESIGN MAY BE CORRECT, BUT SHOULD BE VERIFIED WITH AN FFT)
C      RETURN
C      END
