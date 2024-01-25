clean:
	rm -rf .venv
	rm -rf .pytest_cache
	rm -rf .tox
	rm -rf .mypy_cache

install:
	poetry install
	poetry run pre-commit install --install-hooks

server:
	poetry run tgtg_server

start:
	poetry run scanner -d --base_url http://localhost:8080

test:
	poetry run pytest -v -m "not tgtg_api" --cov=tgtg_scanner

lint:
	poetry run pre-commit run -a

tox:
	tox

executable:
	rm -r ./build ||:
	rm -r ./dist ||:
	poetry run pyinstaller ./scanner.spec
	cp ./config.sample.ini ./dist/config.ini
	zip -j ./dist/scanner.zip ./dist/*

custom:
	@if [ -z "${PLATFORM}" ]; then \
		echo "No platform specified. You must specify platform by setting the environment variable\nPLATFORM. For example:\n\n    PLATFORM=linux/arm/v7 make custom\n"; \
		return 1; \
	fi
	@if [ -d "dist/${PLATFORM}" ]; then \
		rm -r dist/${PLATFORM}; \
	fi
	mkdir -p ./dist/${PLATFORM}
	cp config.sample.ini dist/${PLATFORM}/config.ini
	cp README.md dist/${PLATFORM}
	cp LICENSE dist/${PLATFORM}
	docker build --platform=${PLATFORM} --output=./dist/${PLATFORM} -f docker/Dockerfile.build .
	zip -j dist/${PLATFORM}/scanner.zip dist/${PLATFORM}/*

images:
	docker build -f ./docker/Dockerfile -t tgtg-scanner:latest .
	docker build -f ./docker/Dockerfile.alpine -t tgtg-scanner:latest-alpine .
