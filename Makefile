MANIFEST_FILE ?= "manifest.json"
SERVICE_NAME ?= $(shell cat $(MANIFEST_FILE) | jq -r .service.name)
SERVICE_VERSION_FILE ?= $(shell cat $(MANIFEST_FILE) | jq -r .service.versionFile)
SERVICE_VERSION ?=""

GRADLE_EXE ?= $(shell cat $(MANIFEST_FILE) | jq -r .gradle.exe)
GRADLE_BUILD_COMMAND ?= $(shell cat $(MANIFEST_FILE) | jq -r .gradle.build)

# e.g.: docker.io
DOCKER_REMOTE_REGISTRY_HOST ?= $(shell cat $(MANIFEST_FILE) | jq -r .ci.dockerRegistry.host)

DOCKER_COMPOSE_UP_ARGS=$(shell cat $(MANIFEST_FILE) | jq -r .docker.compose.up)
DOCKER_COMPOSE_DOWN_ARGS=$(shell cat $(MANIFEST_FILE) | jq -r .docker.compose.down)
DOCKER_APP_BUILD_COMMAND_ARGS=$(shell cat $(MANIFEST_FILE) | jq -r .docker.app.build)
DOCKER_APP_TAG_PREFIX_LOCAL=$(shell cat $(MANIFEST_FILE) | jq -r .docker.app.imageTagPrefix.local)
DOCKER_APP_TAG_PREFIX_REMOTE=$(shell cat $(MANIFEST_FILE) | jq -r .docker.app.imageTagPrefix.remote)
DOCKER_APP_TAG_LOCAL=$(DOCKER_APP_TAG_PREFIX_LOCAL)$(SERVICE_NAME):$(SERVICE_VERSION)
DOCKER_APP_TAG_REMOTE=$(DOCKER_APP_TAG_PREFIX_REMOTE)$(SERVICE_NAME):$(SERVICE_VERSION)


USAGE="USAGE ... manifest=$(MANIFEST_FILE) service.name=$(SERVICE_NAME) service.version=$(SERVICE_VERSION)"
guard-%:
	@if [ "${${*}}" == "" ]; then \
			echo "CONFIGURATION ERROR! Environment variable $* not set"; \
			echo "USAGE : $(USAGE)"; \
			exit 1; \
	fi

usage:
	@echo "$(USAGE)";


manifest.verify: guard-MANIFEST_FILE guard-SERVICE_NAME guard-SERVICE_VERSION_FILE
manifest.verify.gradle: guard-GRADLE_EXE guard-GRADLE_BUILD_COMMAND
manifest.verify.docker: guard-DOCKER_APP_BUILD_COMMAND_ARGS guard-DOCKER_APP_TAG_PREFIX_LOCAL guard-DOCKER_APP_TAG_LOCAL guard-DOCKER_APP_TAG_PREFIX_REMOTE guard-DOCKER_APP_TAG_REMOTE
manifest.verify.docker-compose: guard-DOCKER_COMPOSE_UP_ARGS guard-DOCKER_COMPOSE_DOWN_ARGS


devtools.jq.brew:
	brew install jq
devtools.gradle.brew:
	brew install gradle
devtools.docker.brew:
	brew cask install docker-toolbox

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



app.clean: manifest.verify manifest.verify.gradle version.clean
	$(GRADLE_EXE) clean
app.build: manifest.verify app.clean version.create guard-SERVICE_VERSION manifest.verify.gradle manifest.verify.docker
	@echo "build service: $(SERVICE_NAME) version: $(SERVICE_VERSION) ..."
	mkdir -p src/main/resources/public/ && cp -rf $(SERVICE_VERSION_FILE) src/main/resources/public/version.txt
	$(GRADLE_EXE) $(GRADLE_BUILD_COMMAND)
	docker build -t $(DOCKER_APP_TAG_LOCAL) $(DOCKER_APP_BUILD_COMMAND_ARGS)

clean: app.clean
build: app.build
up: manifest.verify version.expose guard-SERVICE_VERSION manifest.verify.docker-compose
	docker ps
	export SERVICE_VERSION=$(SERVICE_VERSION) && export SERVICE_NAME=$(SERVICE_NAME) && docker-compose $(DOCKER_COMPOSE_UP_ARGS)
up.d: manifest.verify version.expose guard-SERVICE_VERSION manifest.verify.docker-compose
	docker ps
	export SERVICE_VERSION=$(SERVICE_VERSION) && export SERVICE_NAME=$(SERVICE_NAME) && docker-compose $(DOCKER_COMPOSE_UP_ARGS) -d

down: manifest.verify version.expose guard-SERVICE_VERSION manifest.verify.docker-compose
	export SERVICE_VERSION=$(SERVICE_VERSION) && export SERVICE_NAME=$(SERVICE_NAME) && docker-compose $(DOCKER_COMPOSE_DOWN_ARGS)
	docker ps
down.v: manifest.verify version.expose guard-SERVICE_VERSION manifest.verify.docker-compose
	export SERVICE_VERSION=$(SERVICE_VERSION) && export SERVICE_NAME=$(SERVICE_NAME) && docker-compose $(DOCKER_COMPOSE_DOWN_ARGS) -v
	docker ps

app.push: manifest.verify version.expose guard-SERVICE_VERSION manifest.verify.docker
	#docker login $(DOCKER_REMOTE_REGISTRY)
	docker tag $(DOCKER_APP_TAG_LOCAL) $(DOCKER_APP_TAG_REMOTE)
	@echo "docker push $(DOCKER_APP_TAG_REMOTE)"
	docker push $(DOCKER_APP_TAG_REMOTE)
app.pull: manifest.verify version.expose guard-SERVICE_VERSION manifest.verify.docker
	#docker login $(DOCKER_REMOTE_REGISTRY)
	docker tag $(DOCKER_APP_TAG_LOCAL) $(DOCKER_APP_TAG_REMOTE)
	@echo "docker pull $(DOCKER_APP_TAG_REMOTE)"
	docker pull $(DOCKER_APP_TAG_REMOTE)

app.deploy: manifest.verify version.expose guard-SERVICE_VERSION guard-DEPLOY_CONCERN
	$(eval K8S_CONTEXT := $(shell cat $(MANIFEST_FILE) | jq -r .k8s.concern.$(DEPLOY_CONCERN).k8sContext))
	$(eval K8S_DEPLOYMENT := $(shell cat $(MANIFEST_FILE) | jq -r .k8s.concern.$(DEPLOY_CONCERN).k8sDeployment))
	$(eval K8S_APP_NAME := $(shell cat $(MANIFEST_FILE) | jq -r .k8s.concern.$(DEPLOY_CONCERN).k8sApp))
	@echo "=== k8s: context='$(K8S_CONTEXT)' deloyment='$(K8S_DEPLOYMENT)' app='$(K8S_APP_NAME)' image='$(DOCKER_APP_TAG_REMOTE)' ... ==="
	# check image exist
	docker pull $(DOCKER_APP_TAG_REMOTE)
	# deploy it
	$ kubectl config use-context $(K8S_CONTEXT)
	$ kubectl config current-context
	# describe pods
	@echo "=== k8s: OLD IMAGE ... ==="
	kubectl get pods --all-namespaces -o=jsonpath="{..image}" -l app=$(K8S_APP_NAME) || true
	@echo "=== k8s: CURRENT PODs ... ==="
	kubectl get pods --all-namespaces -l app=$(K8S_APP_NAME) || true
	# change image
	@echo "=== k8s: deploying ... ==="
	$ kubectl set image deployment/$(K8S_DEPLOYMENT) $(K8S_APP_NAME)=$(DOCKER_APP_TAG_REMOTE)
	# describe pods
	@echo "=== k8s: deployed - current pods (images) ... ==="
	kubectl get pods --all-namespaces -o=jsonpath="{..image}" -l app=$(K8S_APP_NAME) || true
	@echo "=== k8s: deployed - current pods ... ==="
	kubectl get pods --all-namespaces -l app=$(K8S_APP_NAME) || true