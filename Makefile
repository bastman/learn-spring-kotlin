MANIFEST_FILE ?= "manifest.json"
SERVICE_NAME ?= $(shell cat $(MANIFEST_FILE) | jq -r .service.name)
SERVICE_VERSION_FILE ?= $(shell cat $(MANIFEST_FILE) | jq -r .service.versionFile)
SERVICE_VERSION ?=""

GRADLE_EXE ?= $(shell cat $(MANIFEST_FILE) | jq -r .gradle.exe)
GRADLE_BUILD_COMMAND ?= $(shell cat $(MANIFEST_FILE) | jq -r .gradle.build)

DOCKER_COMPOSE_UP_ARGS=$(shell cat $(MANIFEST_FILE) | jq -r .docker.compose.up)
DOCKER_COMPOSE_DOWN_ARGS=$(shell cat $(MANIFEST_FILE) | jq -r .docker.compose.down)
DOCKER_APP_BUILD_COMMAND_ARGS=$(shell cat $(MANIFEST_FILE) | jq -r .docker.app.build)
DOCKER_APP_TAG_LOCAL=local/$(SERVICE_NAME):$(SERVICE_VERSION)

USAGE="USAGE ... manifest=$(MANIFEST_FILE) service.name=$(SERVICE_NAME) service.version=$(SERVICE_VERSION)"
guard-%:
	@if [ "${${*}}" == "" ]; then \
			echo "CONFIGURATION ERROR! Environment variable $* not set"; \
			echo "USAGE : $(USAGE)"; \
			exit 1; \
	fi

usage:
	@echo "$(USAGE)";

#.PHONY: manifest.verify
manifest.verify: guard-MANIFEST_FILE guard-SERVICE_NAME guard-SERVICE_VERSION_FILE
manifest.verify.gradle: guard-GRADLE_EXE guard-GRADLE_BUILD_COMMAND
manifest.verify.docker: guard-DOCKER_APP_BUILD_COMMAND_ARGS guard-DOCKER_APP_TAG_LOCAL
manifest.verify.docker-compose: guard-DOCKER_COMPOSE_UP_ARGS guard-DOCKER_COMPOSE_DOWN_ARGS

app.clean: manifest.verify manifest.verify.gradle version.clean
	$(GRADLE_EXE) clean

.PHONY: version.show
version.show: manifest.verify
	@echo "service.version: $(SERVICE_VERSION)"

.PHONY: version.clean
version.clean: manifest.verify
	@echo "remove service.version: $(SERVICE_VERSION)"
	$(eval SERVICE_VERSION := "")
	rm $(SERVICE_VERSION_FILE) || true
	@echo "service.version: $(SERVICE_VERSION)"

.PHONY: version.create
version.create: manifest.verify
	@echo "create new service.version ..."
	@echo "(old) service.version: $(SERVICE_VERSION)"
	$(eval SERVICE_VERSION := $(shell ./bin/version.sh))
	@echo "(new) service.version: $(SERVICE_VERSION)"

version.expose: manifest.verify
	$(eval SERVICE_VERSION := $(shell cat $(SERVICE_VERSION_FILE)))
	@echo "expose service.version: $(SERVICE_VERSION)"

debug: manifest.verify app.clean version.show
	@echo "debug service.version: $(SERVICE_VERSION)"
app.build: manifest.verify app.clean version.create guard-SERVICE_VERSION manifest.verify.gradle manifest.verify.docker
	@echo "build service: $(SERVICE_NAME) version: $(SERVICE_VERSION) ..."
	mkdir -p src/main/resources/public/ && cp -rf $(SERVICE_VERSION_FILE) src/main/resources/public/version.txt
	$(GRADLE_EXE) $(GRADLE_BUILD_COMMAND)
	docker build -t $(DOCKER_APP_TAG_LOCAL) $(DOCKER_APP_BUILD_COMMAND_ARGS)
app.up: manifest.verify version.expose guard-SERVICE_VERSION manifest.verify.docker-compose
	docker ps
	export SERVICE_VERSION=$(SERVICE_VERSION) && export SERVICE_NAME=$(SERVICE_NAME) && docker-compose $(DOCKER_COMPOSE_UP_ARGS)
app.down: manifest.verify version.expose guard-SERVICE_VERSION manifest.verify.docker-compose
	export SERVICE_VERSION=$(SERVICE_VERSION) && export SERVICE_NAME=$(SERVICE_NAME) && docker-compose $(DOCKER_COMPOSE_DOWN_ARGS)
	docker ps
