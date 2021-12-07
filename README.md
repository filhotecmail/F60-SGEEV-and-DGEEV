# F60-SGEEV-and-DGEEV

#Visão geral: Análise do Eigensystem

Um problema de eigensistema linear comum é representado pela equação Ax = lx, onde A denota uma matriz n x n. O valor l é um valor eigenvalue, e x ¹ 0 é o eigenvectorcorrespondente . O eigenvector é determinado até um fator escalar. Em todas as funções, este fator é escolhido para que x tenha comprimento euclidiano 1, e o componente de x de maior magnitude seja positivo. Se x é um vetor complexo, este componente de maior magnitude é dimensionado para ser real e positivo. A entrada onde este componente ocorre pode ser arbitrária para eigenvectors com valores de magnitude máxima não únicos.

Um problema de eigensistema linear generalizado é representado por Ax = lBx,onde A e B são n x n matrizes. O valor l é um eigenvalue generalizado, e x é o eigenvector generalizado correspondente. Os eigenvectors generalizados são normalizados da mesma forma que para problemas comuns do eigensystem.

Análise de erros e precisão
Esta seção discute problemas comuns de eigenvalue. Exceto em casos especiais, as funções não retornam o par exato de eigenvalue-eigenvector para o problema de eigenvalue comum Ax = lx. Normalmente, o par computado:

