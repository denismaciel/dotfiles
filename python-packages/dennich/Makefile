setup-dev:
	@ echo "Setting up development environment..."
	python3.11 -m venv venv
	./venv/bin/pip install -r dev-requirements.txt
	./venv/bin/pip install -e .

dependencies-compile-dev:
	@ echo "Compiling dependencies for development environment..."
	./venv/bin/pip-compile --resolver=backtracking --output-file dev-requirements.txt --extra dev pyproject.toml

mypy-run:
	@ ./venv/bin/mypy src
