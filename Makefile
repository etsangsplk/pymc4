.PHONY: help venv conda docker docstyle format style black test lint check
.DEFAULT_GOAL = help

PYTHON = python3
PIP = pip3
CONDA = conda
SHELL = bash

help:
	@printf "Usage:\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[1;34mmake %-10s\033[0m %s\n", $$1, $$2}'

conda:  # Set up a conda environment for development.
	@printf "Creating conda environment...\n"
	${CONDA} create --name env
	( \
	source env/bin/activate; \
	${CONDA} install -r requirements.txt; \
	${CONDA} install -r requirements-dev.txt; \
	deactivate; \
	)
	@printf "\n\nConda environment created! \033[1;34mRun \`source env/bin/activate\` to activate it.\033[0m\n\n\n"

venv:  # Set up a Python virtual environment for development.
	@printf "Creating Python virtual environment...\n"
	${PYTHON} -m venv venv
	( \
	source venv/bin/activate; \
	${PIP} install -U pip; \
	${PIP} install -r requirements.txt; \
	${PIP} install -r requirements-dev.txt; \
	deactivate; \
	)
	@printf "\n\nVirtual environment created! \033[1;34mRun \`source venv/bin/activate\` to activate it.\033[0m\n\n\n"

docker:  # Set up a Docker image for development.
	@printf "Creating Docker image...\n"
	${SHELL} ./scripts/container.sh --build
	@printf "\n\nDocker image created! \033[1;34mRun \`source venv/bin/activate\` to activate it.\033[0m\n\n\n"

docstyle:
	@echo "Checking documentation with pydocstyle..."
	pydocstyle pymc4/
	@echo "Pydocstyle passes!\n"


format:
	@echo "Checking code style with black..."
	black --check pymc4/
	@echo "Black passes!\n"

style:
	@echo "Checking code style with pylint..."
	pylint pymc4/
	@echo "Pylint passes!\n"

black:
	black pymc4/

test:
	pytest -v pymc4/tests/ --cov=pymc4/ --html=testing-report.html --self-contained-html


lint: docstyle format style

check: lint black test