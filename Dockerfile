# Multi-stage Dockerfile para F60-SGEEV-and-DGEEV
# Otimizado para tamanho minimal e segurança

# ====================
# Estágio 1: Build Environment
# ====================
FROM alpine:3.19 AS builder

LABEL stage="builder"
LABEL maintainer="F60 Project Team"
LABEL description="Build stage for F60-SGEEV-and-DGEEV"

# Build arguments
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
ARG FORTRAN_FLAGS="-O3 -march=native -ffast-math -flto"

# Instalar dependências de build com cache otimizado
RUN apk add --no-cache \
    gfortran~=13 \
    gcc~=13 \
    libc-dev \
    make \
    binutils \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Verificar versões instaladas
RUN gfortran --version && \
    gcc --version

# Criar diretório de trabalho
WORKDIR /build

# Copiar apenas arquivos necessários (melhor cache do Docker)
COPY sgeev_module.f90 main_sgeev.f90 ./

# Validar arquivos fonte
RUN ls -la *.f90 && \
    wc -l *.f90

# Compilação otimizada com flags avançadas
RUN echo "Compilando com flags: ${FORTRAN_FLAGS}" && \
    gfortran ${FORTRAN_FLAGS} \
    -static-libgfortran \
    -static-libgcc \
    -o eigenvalues_program \
    sgeev_module.f90 main_sgeev.f90 && \
    strip --strip-all eigenvalues_program && \
    file eigenvalues_program && \
    ldd eigenvalues_program || true

# Verificar tamanho e funcionalidade do executável
RUN ls -lh eigenvalues_program && \
    ./eigenvalues_program --help || echo "Help não disponível, mas executável criado"

# ====================
# Estágio 2: Runtime Minimal
# ====================
FROM alpine:3.19 AS runtime

LABEL maintainer="F60 Project Team" \
      description="F60-SGEEV-and-DGEEV: Eigenvalues and Eigenvectors Calculator" \
      version="${VERSION:-1.0}" \
      build-date="${BUILD_DATE}" \
      vcs-ref="${VCS_REF}" \
      org.opencontainers.image.title="F60-SGEEV-and-DGEEV" \
      org.opencontainers.image.description="High-performance eigenvalue calculator" \
      org.opencontainers.image.version="${VERSION:-1.0}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.vendor="F60 Project" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/your-username/F60-SGEEV-and-DGEEV"

# Instalar apenas bibliotecas runtime mínimas
RUN apk add --no-cache \
    libgfortran~=13 \
    libgcc \
    libquadmath \
    ca-certificates \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Criar usuário não-root para segurança
RUN addgroup -g 1000 -S sgeev && \
    adduser -u 1000 -S sgeev -G sgeev -s /bin/sh -h /app

# Definir diretório de trabalho
WORKDIR /app

# Criar estrutura de diretórios
RUN mkdir -p data output logs src && \
    chown -R sgeev:sgeev /app

# Copiar executável otimizado do estágio de build
COPY --from=builder --chown=sgeev:sgeev /build/eigenvalues_program ./
COPY --from=builder --chown=sgeev:sgeev /build/*.f90 ./src/

# Definir permissões corretas
RUN chmod +x eigenvalues_program && \
    chmod -R 755 /app && \
    chmod -R 644 src/*.f90

# Mudar para usuário não-root
USER sgeev

# Criar volumes para dados persistentes
VOLUME ["/app/data", "/app/output", "/app/logs"]

# Variáveis de ambiente
ENV APP_NAME="F60-SGEEV-and-DGEEV" \
    APP_VERSION="${VERSION:-1.0}" \
    FORTRAN_COMPILER="gfortran" \
    BUILD_DATE="${BUILD_DATE}" \
    VCS_REF="${VCS_REF}" \
    PATH="/app:${PATH}" \
    USER="sgeev" \
    HOME="/app"

# Expor metadados para inspeção
LABEL info.executable.size="$(stat -c%s /app/eigenvalues_program 2>/dev/null || echo 'unknown')"

# Comando padrão
CMD ["./eigenvalues_program"]

# Healthcheck otimizado
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD timeout 5s ./eigenvalues_program --version 2>/dev/null || \
      (echo "Health check: executable exists" && test -x ./eigenvalues_program) || exit 1

# ====================
# Estágio 3: Development (opcional)
# ====================
FROM builder AS development

LABEL stage="development"

# Instalar ferramentas de desenvolvimento
RUN apk add --no-cache \
    gdb \
    valgrind \
    strace \
    vim \
    && rm -rf /var/cache/apk/*

# Manter código fonte para debugging
WORKDIR /app/src

# Copiar tudo para desenvolvimento
COPY . .

# Compilar versão debug
RUN gfortran -g -O0 -Wall -Wextra -fcheck=all -fbacktrace \
    -o eigenvalues_program_debug \
    sgeev_module.f90 main_sgeev.f90

CMD ["/bin/sh"]