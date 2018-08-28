#
# For more information on some of the magic targets, variables and flags used, see:
#
#  - [1] https://www.gnu.org/software/make/manual/html_node/Special-Targets.html
#  - [2] https://www.gnu.org/software/make/manual/html_node/Secondary-Expansion.html
#  - [3] https://www.gnu.org/software/make/manual/html_node/Suffix-Rules.html
#  - [4] https://www.gnu.org/software/make/manual/html_node/Options-Summary.html
#  - [5] https://www.gnu.org/software/make/manual/html_node/Special-Variables.html
#

# Ensure (intermediate) targets are deleted when an error occurred executing a recipe, see [1]
.DELETE_ON_ERROR:

# Enable a second expansion of the prerequisites, see [2] (Make 4.x+)
.SECONDEXPANSION:

# Disable built-in implicit rules and variables, see [3, 4]
.SUFFIXES:
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

# Disable printing of directory changes, see [4]
MAKEFLAGS += --no-print-directory

# Warn about undefined variables -- useful during development of makefiles, see [4]
MAKEFLAGS += --warn-undefined-variables

# Default shell to use
SHELL ?= /bin/bash

# Default target to run, see [5]
.DEFAULT_GOAL := help

#
# PROJECT TARGETS
#
# To learn more about automatic variables that can be used in target recipes, see:
#  https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html

FORCE ?= 0
VERSIONS = 5.6 7.0 7.1 7.2
XEBUGVERSIONS = $(foreach version,$(VERSIONS),$(version)-xdebug)

# These targets match actual files/directories, but should be considered PHONY, see:
#  https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: $(VERSIONS)

build : ## Build containers.
build : $(VERSIONS) $(XDEBUGVERSIONS)

$(VERSIONS) : # Magic target that builds the base container for each PHP version.
	docker inspect alcohol/php:$@ &> /dev/null && [[ $(FORCE) -eq 0 ]] \
	  || docker build --pull=true --file $@/Dockerfile --tag alcohol/php:$@ .

%-xdebug : $$* xdebug.ini # Magic target that builds the xdebug variant of each base container.
	docker inspect alcohol/php:$@ &> /dev/null && [[ $(FORCE) -eq 0 ]] \
	  || docker build --pull=true --file xdebug/Dockerfile --tag alcohol/php:$@ --build-arg VERSION=$* .

push : ## Push tagged containers to Docker Hub.
push : $(VERSIONS) $(XDEBUGVERSIONS)
	for version in $(VERSIONS); do \
	  docker push alcohol/php:$${version}; \
	  docker push alcohol/php:$${version}-xdebug; \
	done;

help:
	@echo
	@printf "%-10s %s\n" Target Description
	@echo
	@grep -E '^[a-zA-Z_-]+ : ## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'
	@echo
