# F60-SGEEV-and-DGEEV 📊

[![CI/CD Pipeline](https://github.com/your-username/F60-SGEEV-and-DGEEV/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/your-username/F60-SGEEV-and-DGEEV/actions/workflows/ci-cd.yml)
[![Docker Image](https://ghcr.io/your-username/f60-sgeev-and-dgeev/badge.svg)](https://ghcr.io/your-username/f60-sgeev-and-dgeev)
[![Security Scan](https://img.shields.io/badge/security-scanned-green.svg)](https://github.com/your-username/F60-SGEEV-and-DGEEV/security)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Fortran](https://img.shields.io/badge/Fortran-95%2B-734f96.svg)](https://fortran-lang.org)

## 🎯 Visão Geral: Análise do Eigensystem

Um problema de eigensistema linear comum é representado pela equação **Ax = λx**, onde:
- **A** denota uma matriz n x n
- **λ** é um eigenvalue (autovalor)
- **x ≠ 0** é o eigenvector (autovetor) correspondente

O eigenvector é determinado até um fator escalar. Em todas as funções, este fator é escolhido para que x tenha comprimento euclidiano 1, e o componente de x de maior magnitude seja positivo. Se x é um vetor complexo, este componente de maior magnitude é dimensionado para ser real e positivo.

### 🔄 Problema Generalizado

Um problema de eigensistema linear generalizado é representado por **Ax = λBx**, onde A e B são matrizes n x n. O valor λ é um eigenvalue generalizado, e x é o eigenvector generalizado correspondente. Os eigenvectors generalizados são normalizados da mesma forma que para problemas comuns do eigensystem.

## ⚙️ Características

- 📊 **Cálculo de Eigenvalues e Eigenvectors** usando LAPACK SGEEV/DGEEV
- 🐳 **Containerização Docker** com imagem otimizada
- 🚀 **CI/CD automatizado** com GitHub Actions
- 🔒 **Scans de segurança** integrados
- 🧪 **Testes automatizados** em múltiplas versões do compilador
- 📊 **Métricas de qualidade** de código

## 🛠️ Instalação e Uso

### 📦 Via Docker (Recomendado)

```bash
# Baixar a imagem mais recente
docker pull ghcr.io/your-username/f60-sgeev-and-dgeev:latest

# Executar o programa
docker run --rm -it ghcr.io/your-username/f60-sgeev-and-dgeev:latest

# Executar com volume para dados
docker run --rm -it -v $(pwd)/data:/app/data ghcr.io/your-username/f60-sgeev-and-dgeev:latest
```

### 🔨 Compilação Local

**Pré-requisitos:**
- gfortran 9.0+
- LAPACK library

```bash
# Clonar o repositório
git clone https://github.com/your-username/F60-SGEEV-and-DGEEV.git
cd F60-SGEEV-and-DGEEV

# Compilar
gfortran -O3 -o eigenvalues_program sgeev_module.f90 main_sgeev.f90

# Executar
./eigenvalues_program
```

### 🐋 Desenvolvimento com Docker Compose

```bash
# Ambiente de desenvolvimento
docker-compose --profile dev up sgeev-dev

# Executar testes
docker-compose --profile test up sgeev-test

# Ambiente de produção
docker-compose up sgeev
```

## 📊 Análise de Erros e Precisão

Esta seção discute problemas comuns de eigenvalue. Exceto em casos especiais, as funções não retornam o par exato de eigenvalue-eigenvector para o problema de eigenvalue comum **Ax = λx**.

Normalmente, o par computado satisfaz:
- **Precisão numérica**: Limitada pela precisão da máquina
- **Estabilidade**: Algoritmos numericamente estáveis do LAPACK
- **Convergência**: Métodos iterativos garantem convergência

## 🏧 Arquitetura do CI/CD

O pipeline CI/CD implementa as seguintes etapas:

1. **🧪 Testes Fortran**: Compilação e execução em múltiplas versões
2. **📊 Análise de Qualidade**: Linting, métricas de código
3. **🐳 Docker Build**: Build multi-plataforma com cache otimizado
4. **🔒 Security Scan**: Trivy vulnerability scanner
5. **🚀 Deploy**: Publicação no GitHub Container Registry
6. **📩 Notificações**: Relatórios detalhados e métricas

### 📊 Matrix Strategy

Testes são executados nas seguintes configurações:
- **Compiladores**: gfortran 9, 10, 11, 12
- **Build Types**: debug, release
- **Plataformas**: linux/amd64, linux/arm64

## 📦 Estrutura do Projeto

```
F60-SGEEV-and-DGEEV/
├── 📄 sgeev_module.f90      # Módulo principal com algoritmos SGEEV
├── 📄 main_sgeev.f90        # Programa principal
├── 🐳 Dockerfile             # Container de produção
├── 🐋 docker-compose.yml    # Orquestração de ambientes
├── 🔨 Makefile              # Build automation
├── 🚀 .github/workflows/    # CI/CD pipelines
│   └── ci-cd.yml
├── 📋 scripts/build.sh      # Scripts de build
└── 📄 README.md
```

## 🔒 Segurança

- **🔍 Vulnerability Scanning**: Trivy scanner integrado
- **🔐 Container Security**: Usuário não-root, imagem minimal
- **📜 SBOM Generation**: Software Bill of Materials
- **✍️ Image Signing**: Cosign para releases
- **📊 Security Monitoring**: GitHub Security advisories

## 🧪 Testes

```bash
# Executar todos os testes
make test

# Testes com Docker
docker-compose --profile test up

# Testes de performance
make benchmark
```

## 📈 Monitoramento

- **GitHub Actions**: Status do pipeline
- **Container Registry**: Métricas de download
- **Security Advisories**: Vulnerabilidades detectadas
- **Artifacts**: Binários e relatórios gerados

## 👥 Contribuição

1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📜 Licença

Distribuído sob a licença MIT. Veja `LICENSE` para mais informações.

## 📧 Contato

- **Projeto**: [F60-SGEEV-and-DGEEV](https://github.com/your-username/F60-SGEEV-and-DGEEV)
- **Issues**: [GitHub Issues](https://github.com/your-username/F60-SGEEV-and-DGEEV/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/F60-SGEEV-and-DGEEV/discussions)

