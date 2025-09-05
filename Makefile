# Makefile para F60-SGEEV-and-DGEEV
# Autor: Carlos Dias
# Versão: 1.0

# Configurações
PROGRAM = eigenvalues_program
SOURCES = sgeev_module.f90 main_sgeev.f90
OBJECTS = $(SOURCES:.f90=.o)
MODULES = $(SOURCES:.f90=.mod)

# Compilador e flags
FC = gfortran
FFLAGS = -O3 -march=native -ffast-math -Wall -Wextra -pedantic
DEBUG_FLAGS = -g -fcheck=all -fbacktrace -ffpe-trap=invalid,zero,overflow
PROFILE_FLAGS = -pg -fprofile-arcs -ftest-coverage

# Docker
DOCKER_IMAGE = f60-sgeev
DOCKER_TAG = latest
REGISTRY = ghcr.io
NAMESPACE = filhotecmail

# Diretórios
BUILD_DIR = build
TEST_DIR = tests
DOCS_DIR = docs

# Versão (pode ser sobrescrita pela linha de comando)
VERSION ?= 1.0.0

# Targets padrão
.DEFAULT_GOAL := help
.PHONY: help build clean test docker run install uninstall debug profile docs all

# Ajuda
help: ## Mostra esta ajuda
	@echo "F60-SGEEV-and-DGEEV - Makefile"
	@echo "================================"
	@echo ""
	@echo "Targets disponíveis:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Variáveis:"
	@echo "  VERSION=$(VERSION)"
	@echo "  FC=$(FC)"
	@echo "  REGISTRY=$(REGISTRY)"
	@echo "  NAMESPACE=$(NAMESPACE)"

# Build padrão
build: $(PROGRAM) ## Compila o programa principal

$(PROGRAM): $(SOURCES)
	@echo "Compilando $(PROGRAM)..."
	$(FC) $(FFLAGS) -o $@ $^
	@echo "Build concluído com sucesso!"

# Build com debug
debug: FFLAGS += $(DEBUG_FLAGS) ## Compila com informações de debug
debug: $(PROGRAM)
	@echo "Build de debug concluído!"

# Build com profiling
profile: FFLAGS += $(PROFILE_FLAGS) ## Compila com profiling habilitado
profile: $(PROGRAM)
	@echo "Build com profiling concluído!"

# Compilação de objetos individuais (se necessário)
%.o: %.f90
	$(FC) $(FFLAGS) -c $< -o $@

# Limpeza
clean: ## Remove arquivos de build
	@echo "Limpando arquivos de build..."
	rm -f $(PROGRAM) $(OBJECTS) $(MODULES) *.gcda *.gcno *.gcov gmon.out
	rm -rf $(BUILD_DIR) $(TEST_DIR)/output.log
	@echo "Limpeza concluída!"

# Limpeza completa incluindo Docker
clean-all: clean ## Remove tudo, incluindo imagens Docker
	@echo "Limpando imagens Docker..."
	-docker rmi $(DOCKER_IMAGE):$(DOCKER_TAG) 2>/dev/null || true
	-docker image prune -f 2>/dev/null || true
	@echo "Limpeza completa concluída!"

# Testes
test: $(PROGRAM) ## Executa os testes do programa
	@echo "Executando testes..."
	@mkdir -p $(TEST_DIR)
	@echo "Teste 1: Execução básica do programa"
	timeout 30s ./$(PROGRAM) > $(TEST_DIR)/output.log 2>&1 || true
	@if grep -q "EIGENVALUES" $(TEST_DIR)/output.log; then \
		echo "✓ Teste 1 passou: Programa executou e gerou eigenvalues"; \
	else \
		echo "✗ Teste 1 falhou: Eigenvalues não encontrados na saída"; \
		exit 1; \
	fi
	@echo "Todos os testes passaram!"

# Executar o programa
run: $(PROGRAM) ## Executa o programa
	@echo "Executando $(PROGRAM)..."
	./$(PROGRAM)

# Build da imagem Docker
docker: ## Constrói a imagem Docker
	@echo "Construindo imagem Docker..."
	docker build \
		--build-arg VERSION=$(VERSION) \
		--build-arg BUILD_DATE=$$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
		--build-arg GIT_COMMIT=$$(git rev-parse --short HEAD 2>/dev/null || echo "unknown") \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
		-t $(DOCKER_IMAGE):$(VERSION) \
		.
	@echo "Imagem Docker criada: $(DOCKER_IMAGE):$(DOCKER_TAG)"

# Docker com multi-platform
docker-multiplatform: ## Constrói imagem Docker para múltiplas plataformas
	@echo "Construindo imagem Docker multi-platform..."
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg VERSION=$(VERSION) \
		--build-arg BUILD_DATE=$$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
		--build-arg GIT_COMMIT=$$(git rev-parse --short HEAD 2>/dev/null || echo "unknown") \
		-t $(REGISTRY)/$(NAMESPACE)/$(DOCKER_IMAGE):$(VERSION) \
		-t $(REGISTRY)/$(NAMESPACE)/$(DOCKER_IMAGE):latest \
		--push \
		.

# Executar container Docker
docker-run: ## Executa o programa via Docker
	@echo "Executando programa via Docker..."
	docker run --rm $(DOCKER_IMAGE):$(DOCKER_TAG)

# Docker Compose
compose-up: ## Inicia serviços com docker-compose
	docker-compose up -d

compose-down: ## Para serviços do docker-compose
	docker-compose down

compose-logs: ## Mostra logs do docker-compose
	docker-compose logs -f

# Desenvolvimento
dev: ## Inicia ambiente de desenvolvimento com docker-compose
	docker-compose --profile dev up -d sgeev-dev
	docker-compose exec sgeev-dev /bin/sh

# Push para registry
push: docker ## Faz push da imagem para o registry
	@echo "Fazendo push para $(REGISTRY)/$(NAMESPACE)/$(DOCKER_IMAGE)..."
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(REGISTRY)/$(NAMESPACE)/$(DOCKER_IMAGE):$(VERSION)
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(REGISTRY)/$(NAMESPACE)/$(DOCKER_IMAGE):latest
	docker push $(REGISTRY)/$(NAMESPACE)/$(DOCKER_IMAGE):$(VERSION)
	docker push $(REGISTRY)/$(NAMESPACE)/$(DOCKER_IMAGE):latest

# Instalação no sistema
install: $(PROGRAM) ## Instala o programa no sistema
	@echo "Instalando $(PROGRAM)..."
	sudo cp $(PROGRAM) /usr/local/bin/
	sudo chmod +x /usr/local/bin/$(PROGRAM)
	@echo "$(PROGRAM) instalado em /usr/local/bin/"

# Desinstalação
uninstall: ## Remove o programa do sistema
	@echo "Desinstalando $(PROGRAM)..."
	sudo rm -f /usr/local/bin/$(PROGRAM)
	@echo "$(PROGRAM) removido do sistema"

# Verificação de qualidade do código
lint: ## Verifica a qualidade do código
	@echo "Verificando qualidade do código Fortran..."
	@for file in $(SOURCES); do \
		echo "Analisando $$file..."; \
		$(FC) -fsyntax-only -Wall -Wextra -pedantic $$file || exit 1; \
	done
	@echo "Verificação de qualidade concluída!"

# Estatísticas do código
stats: ## Mostra estatísticas do código
	@echo "Estatísticas do código:"
	@echo "======================"
	@wc -l $(SOURCES)
	@echo ""
	@echo "Tamanho dos arquivos:"
	@du -h $(SOURCES)
	@if [ -f $(PROGRAM) ]; then \
		echo ""; \
		echo "Tamanho do executável:"; \
		du -h $(PROGRAM); \
	fi

# Gerar documentação
docs: ## Gera documentação do código
	@echo "Gerando documentação..."
	@mkdir -p $(DOCS_DIR)
	@echo "# F60-SGEEV-and-DGEEV Documentation" > $(DOCS_DIR)/README.md
	@echo "" >> $(DOCS_DIR)/README.md
	@echo "## Arquivos do projeto:" >> $(DOCS_DIR)/README.md
	@for file in $(SOURCES); do \
		echo "- $$file" >> $(DOCS_DIR)/README.md; \
	done
	@echo "Documentação gerada em $(DOCS_DIR)/"

# Target para fazer tudo
all: clean lint build test docker ## Executa limpeza, lint, build, testes e Docker

# Deploy completo
deploy: all push ## Deploy completo (build + test + docker + push)
	@echo "Deploy completo realizado para versão $(VERSION)"

# Informações do sistema
info: ## Mostra informações do sistema de build
	@echo "Informações do Sistema de Build"
	@echo "==============================="
	@echo "Compilador Fortran: $$($(FC) --version | head -n1)"
	@echo "Docker: $$(docker --version)"
	@echo "Git: $$(git --version)"
	@echo "Sistema: $$(uname -a)"
	@echo "Data: $$(date)"
	@echo "Usuário: $$(whoami)"
	@echo "Diretório: $$(pwd)"