! ---------------------------------------------------------------------------------------
! PROGRAMA LINEAR ALGEBRA EIGENVALUES AND EIGENVECTORS OF SYMMETRIC MATRICES
! ANALISTA: CARLOS DIAS
! LEOPARD REPORT - 2012
! OBJETIVO.: CALCULA E RESOLVE O PROBLEMA DE CALCULO DE EIGENVALUES PARA UMA MATRIZ REAL SIMETRICA
! SOBRE
!
! 
! ASSOCIADOS COM UMA TRANSFORMACAO LINEAR  ESTAO OS SEUS AUTOVETORES, QUE, COMO VEREMOS,
! SAO DIRECOES ESPECIAIS PARA ESTA TRANSFORMAAOO .
! POR ESTA RAZAO, SAO TAMBEM CONHECIDOS COMO VETORES PROPRIOS OU VETORES CARACTERISTICOS DE .
! APARECEM EM MUITAS APLICACOES, POIS NOS AJUDAM A ENTENDER MAIS PROFUNDAMENTE A TRANSFORMACO LINEAR .
! FONTE.: HTTPS://WWW.UFRGS.BR/REAMAT/ALGEBRALINEAR/LIVRO/S11-AUTOVALORES_AUTOVETORES_E_AUTOESPAX00E7OS_ASSOCIADOS
! 
!----------------------------------------------------------------------------------------

MODULE SGEEV

IMPLICIT NONEOF
INTEGER, PARAMETER  :: DP = SELECTED_REAL_KIND(12, 60)

REAL (DP), PARAMETER  :: ZEROOF = 0.0_DP, ONEOF = 1.0_DP

CONTAINS

SUBROUTINE NDIAH (N, TOL, A, D, E, Z, MAXDIM, IFFF)

INTEGER, INTENT(IN)      :: N
REAL (DP), INTENT(OUT)   :: TOL
INTEGER, INTENT(IN OUT)  :: MAXDIM
REAL (DP), INTENT(IN)    :: A(MAXDIM,MAXDIM)
REAL (DP), INTENT(OUT)   :: D(MAXDIM)
REAL (DP), INTENT(OUT)   :: E(MAXDIM)
REAL (DP), INTENT(OUT)   :: Z(MAXDIM,MAXDIM)
INTEGER, INTENT(OUT)     :: IFFF

REAL (DP), PARAMETER  :: HDA = 1.0D-37, HPE = 1.0D-14

INTEGER    :: I, I1, J, J1, K, L
REAL (DP)  :: F, G, H, HH

TOL=HDA/HPE
IFFF=1
IF (N <= 1) RETURN
IFFF=0
DO  I=1,N
  Z(I,1:I)=A(I,1:I)
END DO
I=N
DO  I1=2,N
  L=I-2
  F=Z(I,I-1)
  G=ZEROOF
  IF (L < 1) GO TO 30
  G = SUM( Z(I,1:L)**2 )
  30 H=G + F*F

  IF (G > TOL) GO TO 40
  E(I)=F
  D(I)=ZEROOF
  GO TO 100

  40 L=L+1

 ! CALCULA A RAIZ QUADRADA DE H
  G=SQRT(H)
  IF (F >= ZEROOF) 
   G=-G  
   E(I)=G 
   H=H - F*G  
 ! DEFINE A MATRIZ MULTIDIMENSIONAL DE Z 
   Z(I,I-1)=F-G  
   F=ZEROOF
 
 ! PERCORRO A MATRIZ MULTIDIMENSIONAL DE L 
 ! CADA ELEMENTO DE Z CORRESPONDE A DIVISAO MA MATRIZ I PELO NUMERO REAL DE H
  DO  J=1,L
    Z(J,I)=Z(I,J)/H
    G=ZEROOF
 ! PERCORRO A MATRIZ MULTIDIMENSIONAL DE K INICIANDO DE 1   
    DO  K=1,J
      G=G + Z(J,K)*Z(I,K)
    END DO
    IF (J >= L) GO TO 70
 ! SALTO PARA A INSTRUCAO 70 CASO O ELEMENTO J SEJA MAIOR QUE O ELEMENTO L ENCONTRADO    
    J1=J+1
    DO  K=J1,L
      G=G + Z(K,J)*Z(I,K)
    END DO

 ! INSTRUCAO 70     
    70 E(J)=G/H     
    F=F + G*Z(J,I)  
  END DO              
 ! IMPORTANTE , DEFINO O VALOR REAL DE HH   

  HH=F/(H+H)
  
  DO  J=1,L
    F=Z(I,J)
    G=E(J)-HH*F
    E(J)=G
    DO  K=1,J
      Z(J,K)=Z(J,K) - F*E(K) - G*Z(I,K)
    END DO
  END DO
  D(I)=H
  100 I=I-1
END DO
D(1)=ZEROOF
E(1)=ZEROOF

DO  I=1,N
  L=I-1
  IF (D(I) == ZEROOF .OR. L == 0) GO TO 140
  DO  J=1,L
    G=ZEROOF
    DO  K=1,L
      G=G + Z(I,K)*Z(K,J)
    END DO
    DO  K=1,L
      Z(K,J)=Z(K,J) - G*Z(K,I)
    END DO
  END DO
  140 D(I)=Z(I,I)
  Z(I,I)=ONEOF
  IF (L == 0) CYCLE
  DO  J=1,L
    Z(I,J)=ZEROOF
    Z(J,I)=ZEROOF
  END DO
END DO
RETURN
END SUBROUTINE NDIAH

! ATENCAO AO INVOKAR A NTRVSUBROTINA PARAMETOS MMSTS,TRPAIR ESTAO SENDO INICIALIZADOS 
SUBROUTINE NTRV (N, PRECIS, D, E, Z, IFFF, MAXDIM)

INTEGER, INTENT(IN)        :: N
REAL (DP), INTENT(OUT)     :: PRECIS
INTEGER, INTENT(IN)        :: MAXDIM
REAL (DP), INTENT(IN OUT)  :: D(MAXDIM)
REAL (DP), INTENT(OUT)     :: E(MAXDIM)
REAL (DP), INTENT(IN OUT)  :: Z(MAXDIM,MAXDIM)
INTEGER, INTENT(OUT)       :: IFFF

INTEGER, PARAMETER    :: MMSTS = 30
REAL (DP), PARAMETER  :: TRPAIR = 2.0D0

INTEGER    :: I, I1, J, JJ, K, L, M, M1, N1
REAL (DP)  :: B, C, F, G, H, P, PR, R, S

PRECIS=1.0D-14
IFFF=2
IF (N <= 1) RETURN
IFFF=1
N1=N-1
DO  I=2,N
  E(I-1)=E(I)
END DO
E(N)=ZEROOF
B=ZEROOF
F=ZEROOF
DO  L=1,N
  JJ=0
  H=PRECIS*(ABS(D(L))+ABS(E(L)))
  IF (B < H) B=H

  DO  M1=L,N
    M=M1
    IF (ABS(E(M)) <= B) EXIT
  END DO
  IF (M == L) GO TO 90
  40 IF (JJ == MMSTS) RETURN
  JJ=JJ+1
 
  P=(D(L+1)-D(L))/(TRPAIR*E(L))
  R=SQRT(P*P + ONEOF)
  PR=P+R
  IF (P < ZEROOF) PR=P-R
  H=D(L)-E(L)/PR
  DO  I=L,N
    D(I)=D(I)-H
  END DO
  F=F+H
  
  P=D(M)
  C=ONEOF
  S=ZEROOF
  M1=M-1
  I=M
  DO  I1=L,M1
    J=I
    I=I-1
    G=C*E(I)
    H=C*P
    IF (ABS(P) >= ABS(E(I))) GO TO 60
    C=P/E(I)
    R=SQRT(C*C + ONEOF)
    E(J)=S*E(I)*R
    S=ONEOF/R
    C=C/R
    GO TO 70
    60 C=E(I)/P
    R=SQRT(C*C + ONEOF)
    E(J)=S*P*R
    S=C/R
    C=ONEOF/R
    70 P=C*D(I) - S*G
    D(J)=H + S*(C*G + S*D(I))
  
    DO  K=1,N
      H=Z(K,J)
      Z(K,J)=S*Z(K,I) + C*H
      Z(K,I)=C*Z(K,I) - S*H
    END DO
  END DO
  E(L)=S*P
  D(L)=C*P
  IF (ABS(E(L)) > B) GO TO 40
  90 D(L)=D(L) + F
END DO

DO  I=1,N1
  K=I
  P=D(I)
  I1=I+1
  DO  J=I1,N
    IF (D(J) <= P) CYCLE
    K=J
    P=D(J)
  END DO
  IF (K == I) CYCLE
  D(K)=D(I)
  D(I)=P
  DO  J=1,N
    P=Z(J,I)
    Z(J,I)=Z(J,K)
    Z(J,K)=P
  END DO
END DO
IFFF=0
RETURN
END SUBROUTINE NTRV

END MODULE SGEEV
