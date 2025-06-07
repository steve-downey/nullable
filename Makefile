#! /usr/bin/make -f
# cmake-format: off
# /Makefile -*-makefile-*-
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
# cmake-format: on

INSTALL_PREFIX?=.install/
BUILD_DIR?=.build
DEST?=$(INSTALL_PREFIX)
CMAKE_FLAGS?=

TARGETS := test clean all ctest

export

.update-submodules:
	git submodule update --init --recursive
	touch .update-submodules

.gitmodules: .update-submodules

CONFIG?=Asan

export

ifeq ($(strip $(TOOLCHAIN)),)
	_build_name?=build-system/
	_build_dir?=.build/
	_configuration_types?="RelWithDebInfo;Debug;Tsan;Asan;Gcov"
	_cmake_args=-DCMAKE_TOOLCHAIN_FILE=$(CURDIR)/etc/toolchain.cmake
else
	_build_name?=build-$(TOOLCHAIN)
	_build_dir?=.build/
	_configuration_types?="RelWithDebInfo;Debug;Tsan;Asan;Gcov"
	_cmake_args=-DCMAKE_TOOLCHAIN_FILE=$(CURDIR)/etc/$(TOOLCHAIN)-toolchain.cmake
endif


_build_path?=$(_build_dir)/$(_build_name)

define run_cmake =
	cmake \
	-G "Ninja Multi-Config" \
	-DCMAKE_CONFIGURATION_TYPES=$(_configuration_types) \
	-DCMAKE_INSTALL_PREFIX=$(abspath $(INSTALL_PREFIX)) \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
	-DCMAKE_PROJECT_TOP_LEVEL_INCLUDES="./cmake/use-fetch-content.cmake" \
	$(_cmake_args) \
	$(CURDIR)
endef

default: test

$(_build_path):
	mkdir -p $(_build_path)

$(_build_path)/CMakeCache.txt: | $(_build_path) .gitmodules
	cd $(_build_path) && $(run_cmake)
	-rm compile_commands.json
	ln -s $(_build_path)/compile_commands.json

TARGET:=all
compile: $(_build_path)/CMakeCache.txt ## Compile the project
	cmake --build $(_build_path)  --config $(CONFIG) --target all -- -k 0

compile-headers: $(_build_path)/CMakeCache.txt ## Compile the headers
	 cmake --build $(_build_path)  --config $(CONFIG) --target all_verify_interface_header_sets -- -k 0

install: $(_build_path)/CMakeCache.txt compile ## Install the project
	cmake --install $(_build_path) --config $(CONFIG) --component beman_nullable_development --verbose

ctest: $(_build_path)/CMakeCache.txt ## Run CTest on current build
	cd $(_build_path) && ctest --output-on-failure -C $(CONFIG)

ctest_ : compile
	cd $(_build_path) && ctest --output-on-failure -C $(CONFIG)

test: ctest_ ## Rebuild and run tests

cmake: |  $(_build_path)
	cd $(_build_path) && ${run_cmake}

clean: $(_build_path)/CMakeCache.txt ## Clean the build artifacts
	cmake --build $(_build_path)  --config $(CONFIG) --target clean

realclean: ## Delete the build directory
	rm -rf $(_build_path)

env:
	$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))

.PHONY : compile install ctest ctest_ test cmake clean realclean env

.PHONY: papers
papers:
	$(MAKE) -C papers/P2988 papers

.DEFAULT: $(_build_path)/CMakeCache.txt ## Other targets passed through to cmake
	cmake --build $(_build_path)  --config $(CONFIG) --target $@ -- -k 0

PYEXECPATH ?= $(shell which python3.12 || which python3.11 || which python3.10 || which python3.9 || which python3.8 || which python3.7 || which python3)
PYTHON ?= $(notdir $(PYEXECPATH))
VENV := .venv
ACTIVATE := . $(VENV)/bin/activate &&
PYEXEC := $(ACTIVATE) $(PYTHON)
MARKER=.initialized.venv.stamp

PIP := $(PYEXEC) -m pip
PIP_SYNC := $(PYEXEC) -m piptools sync
PIPTOOLS_COMPILE := $(PYEXEC) -m piptools compile --no-header --strip-extras

PRE_COMMIT := $(ACTIVATE) pre-commit

PHONY: venv
venv: ## Create python virtual env
venv: $(VENV)/$(MARKER)

.PHONY: clean-venv
clean-venv:
clean-venv: ## Delete python virtual env
	-rm -rf $(VENV)

realclean: clean-venv

.PHONY: show-venv
show-venv: venv
show-venv: ## Debugging target - show venv details
	$(PYEXEC) -c "import sys; print('Python ' + sys.version.replace('\n',''))"
	$(PIP) --version
	@echo venv: $(VENV)

requirements.txt: requirements.in | $(VENV)
	$(PIPTOOLS_COMPILE) --output-file=$@ $<

requirements-dev.txt: requirements-dev.in | $(VENV)
	$(PIPTOOLS_COMPILE) --output-file=$@ $<

$(VENV):
	$(PYEXECPATH) -m venv $(VENV)
	$(PIP) install --upgrade pip setuptools wheel
	$(PIP) install pip-tools

$(VENV)/$(MARKER): requirements.txt requirements-dev.txt | $(VENV)
	$(PIP_SYNC) requirements.txt
	$(PIP_SYNC) requirements-dev.txt
	touch $(VENV)/$(MARKER)

.PHONY: dev-shell
dev-shell: venv
dev-shell: ## Shell with the venv activated
	$(ACTIVATE) $(notdir $(SHELL))

.PHONY: bash zsh
bash zsh: venv
bash zsh: ## Run bash or zsh with the venv activated
	$(ACTIVATE) exec $@

.PHONY: lint
lint: venv
lint: ## Run all configured tools in pre-commit
	$(PRE_COMMIT) run -a

.PHONY: lint-manual
lint-manual: venv
lint-manual: ## Run all manual tools in pre-commit
	$(PRE_COMMIT) run --hook-stage manual -a

.PHONY: coverage
coverage: ## Build and run the tests with the GCOV profile and process the results
coverage: venv $(_build_path)/CMakeCache.txt
	$(ACTIVATE) cmake --build $(_build_path) --config Gcov
	$(ACTIVATE) ctest --build-config Gcov --output-on-failure --test-dir $(_build_path)
	$(ACTIVATE) cmake --build $(_build_path) --config Gcov --target process_coverage

.PHONY: view-coverage
view-coverage: ## View the coverage report
	sensible-browser $(_build_path)/coverage/coverage.html

# Help target
.PHONY: help
help: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[.a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'  $(MAKEFILE_LIST) | sort
