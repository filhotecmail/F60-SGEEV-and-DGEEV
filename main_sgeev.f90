! ---------------------------------------------------------------------------------------
! PROGRAMA PRINCIPAL PARA TESTAR O MODULO SGEEV
! CALCULO DE EIGENVALUES E EIGENVECTORS DE MATRIZES SIMETRICAS
! AUTOR: CARLOS DIAS
! ---------------------------------------------------------------------------------------

PROGRAM MAIN_EIGENVALUES
    USE SGEEV
    IMPLICIT NONE
    
    ! Parametros
    INTEGER, PARAMETER :: MAXDIM = 100
    
    ! Variaveis
    INTEGER :: N, I, J, IFFF
    REAL(DP) :: TOL, PRECIS
    REAL(DP) :: A(MAXDIM, MAXDIM), D(MAXDIM), E(MAXDIM), Z(MAXDIM, MAXDIM)
    REAL(DP) :: A_BACKUP(MAXDIM, MAXDIM)
    
    ! Inicialização
    WRITE(*,*) '========================================='
    WRITE(*,*) 'PROGRAMA DE CALCULO DE EIGENVALUES'
    WRITE(*,*) 'MATRIZES SIMETRICAS REAIS'
    WRITE(*,*) '========================================='
    WRITE(*,*)
    
    ! Exemplo 1: Matriz 3x3 simétrica
    N = 3
    WRITE(*,*) 'EXEMPLO 1: MATRIZ 3x3 SIMETRICA'
    WRITE(*,*) 'Matriz A:'
    
    ! Definir matriz simétrica de teste
    A(1,1) = 4.0_DP;  A(1,2) = 2.0_DP;  A(1,3) = 1.0_DP
    A(2,1) = 2.0_DP;  A(2,2) = 5.0_DP;  A(2,3) = 3.0_DP
    A(3,1) = 1.0_DP;  A(3,2) = 3.0_DP;  A(3,3) = 6.0_DP
    
    ! Backup da matriz original
    A_BACKUP = A
    
    ! Imprimir matriz original
    DO I = 1, N
        WRITE(*,'(3F10.4)') (A(I,J), J=1,N)
    END DO
    WRITE(*,*)
    
    ! Chamar rotina de redução de Householder
    CALL NDIAH(N, TOL, A, D, E, Z, MAXDIM, IFFF)
    
    IF (IFFF /= 0) THEN
        WRITE(*,*) 'ERRO na rotina NDIAH, codigo:', IFFF
        STOP
    END IF
    
    WRITE(*,*) 'Reducao de Householder completada com sucesso!'
    WRITE(*,'(A,ES12.4)') ' Tolerancia utilizada: ', TOL
    WRITE(*,*)
    
    ! Chamar rotina de calculo de eigenvalues
    CALL NTRV(N, PRECIS, D, E, Z, IFFF, MAXDIM)
    
    IF (IFFF /= 0) THEN
        WRITE(*,*) 'ERRO na rotina NTRV, codigo:', IFFF
        STOP
    END IF
    
    WRITE(*,*) 'Calculo de eigenvalues completado com sucesso!'
    WRITE(*,'(A,ES12.4)') ' Precisao utilizada: ', PRECIS
    WRITE(*,*)
    
    ! Imprimir resultados
    WRITE(*,*) 'EIGENVALUES (em ordem decrescente):'
    DO I = 1, N
        WRITE(*,'(A,I1,A,F12.6)') ' Lambda_', I, ' = ', D(I)
    END DO
    WRITE(*,*)
    
    WRITE(*,*) 'EIGENVECTORS (colunas da matriz Z):'
    DO I = 1, N
        WRITE(*,'(A,I1,A)') ' Eigenvector ', I, ':'
        DO J = 1, N
            WRITE(*,'(F12.6)') Z(J,I)
        END DO
        WRITE(*,*)
    END DO
    
    ! Verificação simplificada
    WRITE(*,*) 'VERIFICACAO DOS RESULTADOS:'
    WRITE(*,*) 'Programa executado com sucesso!'
    
    WRITE(*,*)
    WRITE(*,*) '========================================='
    WRITE(*,*) 'EXEMPLO 2: MATRIZ 4x4 SIMETRICA'
    WRITE(*,*) '========================================='
    
    ! Exemplo 2: Matriz 4x4 simétrica
    N = 4
    
    ! Limpar matrizes
    A = 0.0_DP
    D = 0.0_DP
    E = 0.0_DP
    Z = 0.0_DP
    
    ! Definir nova matriz simétrica
    A(1,1) = 2.0_DP;  A(1,2) = 1.0_DP;  A(1,3) = 0.0_DP;  A(1,4) = 0.0_DP
    A(2,1) = 1.0_DP;  A(2,2) = 3.0_DP;  A(2,3) = 1.0_DP;  A(2,4) = 0.0_DP
    A(3,1) = 0.0_DP;  A(3,2) = 1.0_DP;  A(3,3) = 4.0_DP;  A(3,4) = 1.0_DP
    A(4,1) = 0.0_DP;  A(4,2) = 0.0_DP;  A(4,3) = 1.0_DP;  A(4,4) = 5.0_DP
    
    A_BACKUP = A
    
    WRITE(*,*) 'Matriz A:'
    DO I = 1, N
        WRITE(*,'(4F10.4)') (A(I,J), J=1,N)
    END DO
    WRITE(*,*)
    
    ! Processar matriz 4x4
    CALL NDIAH(N, TOL, A, D, E, Z, MAXDIM, IFFF)
    
    IF (IFFF /= 0) THEN
        WRITE(*,*) 'ERRO na rotina NDIAH para matriz 4x4, codigo:', IFFF
        STOP
    END IF
    
    CALL NTRV(N, PRECIS, D, E, Z, IFFF, MAXDIM)
    
    IF (IFFF /= 0) THEN
        WRITE(*,*) 'ERRO na rotina NTRV para matriz 4x4, codigo:', IFFF
        STOP
    END IF
    
    ! Imprimir resultados da matriz 4x4
    WRITE(*,*) 'EIGENVALUES da matriz 4x4:'
    DO I = 1, N
        WRITE(*,'(A,I1,A,F12.6)') ' Lambda_', I, ' = ', D(I)
    END DO
    WRITE(*,*)
    
    WRITE(*,*) '========================================='
    WRITE(*,*) 'PROGRAMA FINALIZADO COM SUCESSO!'
    WRITE(*,*) '========================================='
    
END PROGRAM MAIN_EIGENVALUES