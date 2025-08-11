.PHONY: build-% test-% test-all test-matrix test-flask

VERSIONS := 3.8 3.9 3.10 3.11 3.12 3.13
FLASKS   := 2 3

build-%-nocache:
	@echo "🛠  Building (no cache) image for Python $*..."
	docker build --no-cache --pull --build-arg PYTHON_VERSION=$* \
		-t pico-ioc-flask-test:$* -f Dockerfile.test .
build-%:
	@echo "🛠  Building image for Python $*..."
	docker build --pull --build-arg PYTHON_VERSION=$* \
		-t pico-ioc-flask-test:$* -f Dockerfile.test .

test-%: build-%
	@echo "🚀 Running tox (default env) on Python $*..."
	docker run --rm pico-ioc-flask-test:$*

test-all: $(addprefix test-, $(VERSIONS))
	@echo "✅ All versions (default env) done."

test-matrix:
	@set -e; \
	for v in $(VERSIONS); do \
		for f in $(FLASKS); do \
			$(MAKE) test-flask VERSION=$$v FLASK=$$f; \
		done; \
	done; \
	echo "✅ Python × Flask matrix done."

test-flask: build-$(VERSION)
	@py="$(VERSION)"; fl="$(FLASK)"; \
	pyenv="py$$(echo "$$py" | tr -d '.')"; \
	envs="$$pyenv-flask$$fl"; \
	echo "🚀 Running tox envs: $$envs (Python $$py, Flask $$fl.x)"; \
	docker run --rm -e TOX_ENVS="$$envs" pico-ioc-flask-test:$(VERSION)

