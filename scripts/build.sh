#!/bin/bash
# Script de build e deploy para F60-SGEEV-and-DGEEV
# Autor: Carlos Dias
# Versão: 1.0

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
PROJECT_NAME="f60-sgeev"
VERSION="${VERSION:-1.0.0}"
REGISTRY="${REGISTRY:-ghcr.io}"
NAMESPACE="${NAMESPACE:-filhotecmail}"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Funções auxiliares
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
Script de Build e Deploy - F60-SGEEV-and-DGEEV

USO:
    $0 [COMANDO] [OPÇÕES]

COMANDOS:
    build       Build da aplicação localmente
    test        Executa testes locais
    docker      Build da imagem Docker
    push        Push da imagem para registry
    deploy      Deploy completo (build + push)
    clean       Limpa artifacts de build
    help        Mostra esta ajuda

OPÇÕES:
    -v, --version VERSION    Especifica versão (padrão: ${VERSION})
    -r, --registry REGISTRY  Registry Docker (padrão: ${REGISTRY})
    -n, --namespace NAMESPACE Namespace (padrão: ${NAMESPACE})
    --no-cache              Build sem cache
    --platform PLATFORM     Platform específica (ex: linux/amd64)

EXEMPLOS:
    $0 build                    # Build local
    $0 docker --no-cache        # Build Docker sem cache
    $0 deploy -v 2.0.0          # Deploy versão 2.0.0
    $0 push --platform linux/amd64  # Push para plataforma específica

VARIÁVEIS DE AMBIENTE:
    VERSION     Versão da aplicação
    REGISTRY    Registry Docker
    NAMESPACE   Namespace/organização
    
EOF
}

# Verificar dependências
check_dependencies() {
    log_info "Verificando dependências..."
    
    local deps=("docker" "gfortran" "git")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -ne 0 ]]; then
        log_error "Dependências faltando: ${missing[*]}"
        log_info "Execute: sudo apt-get install -y ${missing[*]}"
        exit 1
    fi
    
    log_success "Todas as dependências estão disponíveis"
}

# Build local da aplicação
build_local() {
    log_info "Iniciando build local..."
    
    if [[ ! -f "sgeev_module.f90" || ! -f "main_sgeev.f90" ]]; then
        log_error "Arquivos fonte não encontrados!"
        exit 1
    fi
    
    # Limpar builds anteriores
    rm -f eigenvalues_program *.mod *.o
    
    # Compilar com otimizações
    log_info "Compilando código Fortran..."
    gfortran -O3 -march=native -ffast-math -Wall -Wextra \
        -o eigenvalues_program \
        sgeev_module.f90 main_sgeev.f90
    
    # Verificar se compilou corretamente
    if [[ -x "eigenvalues_program" ]]; then
        log_success "Build local concluído com sucesso!"
        log_info "Executável: ./eigenvalues_program"
        log_info "Tamanho: $(du -h eigenvalues_program | cut -f1)"
    else
        log_error "Falha no build local"
        exit 1
    fi
}

# Executar testes
run_tests() {
    log_info "Executando testes..."
    
    if [[ ! -x "eigenvalues_program" ]]; then
        log_warning "Executável não encontrado, fazendo build primeiro..."
        build_local
    fi
    
    # Criar diretório de testes se não existir
    mkdir -p tests
    
    # Executar programa e capturar saída
    log_info "Testando execução do programa..."
    if timeout 30s ./eigenvalues_program > tests/output.log 2>&1; then
        log_success "Programa executado com sucesso!"
        
        # Verificar se a saída contém resultados esperados
        if grep -q "EIGENVALUES" tests/output.log && grep -q "Lambda_" tests/output.log; then
            log_success "Resultados de eigenvalues encontrados na saída"
        else
            log_warning "Resultados esperados não encontrados na saída"
        fi
        
        # Mostrar estatísticas
        log_info "Linhas de saída: $(wc -l < tests/output.log)"
    else
        log_error "Falha na execução do programa"
        cat tests/output.log
        exit 1
    fi
}

# Build da imagem Docker
build_docker() {
    local no_cache=""
    local platform=""
    
    # Processar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-cache)
                no_cache="--no-cache"
                shift
                ;;
            --platform)
                platform="--platform $2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    log_info "Iniciando build da imagem Docker..."
    
    local image_tag="${REGISTRY}/${NAMESPACE}/${PROJECT_NAME}:${VERSION}"
    local latest_tag="${REGISTRY}/${NAMESPACE}/${PROJECT_NAME}:latest"
    
    # Build da imagem
    log_info "Building image: $image_tag"
    
    docker build \
        $no_cache \
        $platform \
        --build-arg VERSION="$VERSION" \
        --build-arg BUILD_DATE="$BUILD_DATE" \
        --build-arg GIT_COMMIT="$GIT_COMMIT" \
        --tag "$image_tag" \
        --tag "$latest_tag" \
        .
    
    # Verificar se o build foi bem-sucedido
    if docker images "$image_tag" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -q "$VERSION"; then
        log_success "Imagem Docker criada com sucesso!"
        log_info "Tags: $image_tag, $latest_tag"
        
        # Mostrar informações da imagem
        docker images "$image_tag" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    else
        log_error "Falha no build da imagem Docker"
        exit 1
    fi
}

# Push da imagem para registry
push_image() {
    local platform=""
    
    # Processar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --platform)
                platform="--platform $2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    log_info "Fazendo push da imagem para registry..."
    
    local image_tag="${REGISTRY}/${NAMESPACE}/${PROJECT_NAME}:${VERSION}"
    local latest_tag="${REGISTRY}/${NAMESPACE}/${PROJECT_NAME}:latest"
    
    # Verificar se está logado no registry
    if ! docker info | grep -q "Registry"; then
        log_warning "Faça login no registry primeiro:"
        log_info "docker login $REGISTRY"
    fi
    
    # Push das imagens
    log_info "Pushing $image_tag..."
    docker push "$image_tag"
    
    log_info "Pushing $latest_tag..."
    docker push "$latest_tag"
    
    log_success "Push concluído com sucesso!"
    log_info "Imagem disponível em: $image_tag"
}

# Deploy completo
deploy() {
    log_info "Iniciando deploy completo..."
    
    # Verificar dependências
    check_dependencies
    
    # Build local para testes
    build_local
    run_tests
    
    # Build e push da imagem Docker
    build_docker "$@"
    push_image "$@"
    
    log_success "Deploy completo realizado com sucesso!"
    log_info "Versão deployada: $VERSION"
    log_info "Registry: $REGISTRY"
    log_info "Namespace: $NAMESPACE"
}

# Limpar artifacts
clean() {
    log_info "Limpando artifacts de build..."
    
    # Limpar arquivos locais
    rm -f eigenvalues_program *.mod *.o
    rm -rf tests/output.log
    
    # Limpar imagens Docker antigas (opcional)
    if command -v docker &> /dev/null; then
        log_info "Limpando imagens Docker órfãs..."
        docker image prune -f
    fi
    
    log_success "Limpeza concluída!"
}

# Função principal
main() {
    # Verificar se está no diretório correto
    if [[ ! -f "sgeev_module.f90" ]]; then
        log_error "Execute este script no diretório raiz do projeto"
        exit 1
    fi
    
    # Processar argumentos globais
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--version)
                VERSION="$2"
                shift 2
                ;;
            -r|--registry)
                REGISTRY="$2"
                shift 2
                ;;
            -n|--namespace)
                NAMESPACE="$2"
                shift 2
                ;;
            -h|--help|help)
                show_help
                exit 0
                ;;
            build)
                shift
                check_dependencies
                build_local
                exit 0
                ;;
            test)
                shift
                check_dependencies
                run_tests
                exit 0
                ;;
            docker)
                shift
                check_dependencies
                build_docker "$@"
                exit 0
                ;;
            push)
                shift
                check_dependencies
                push_image "$@"
                exit 0
                ;;
            deploy)
                shift
                deploy "$@"
                exit 0
                ;;
            clean)
                shift
                clean
                exit 0
                ;;
            *)
                log_error "Comando desconhecido: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Se nenhum comando foi especificado, mostrar ajuda
    show_help
}

# Executar função principal com todos os argumentos
main "$@"