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
.DEFAULT_GOAL := all

#
# PROJECT TARGETS
#
# To learn more about automatic variables that can be used in target recipes, see:
#  https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html

VERSIONS = 5.6 7.0 7.1 7.2
XEBUGVERSIONS = $(foreach version,$(VERSIONS),$(version)-xdebug)

# These targets match actual files/directories, but should be considered PHONY, see:
#  https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: $(VERSIONS)

all : $(VERSIONS) $(XDEBUGVERSIONS)

$(VERSIONS) :
	docker build --file $@/Dockerfile --tag alcohol/php:$@ .

%-xdebug : $$* xdebug.ini
	docker build --file xdebug/Dockerfile --tag alcohol/php:$@ --build-arg VERSION=$* .

push : $(VERSIONS) $(XDEBUGVERSIONS)
	for version in $(VERSIONS); do docker push alcohol/php:$${version} && docker push alcohol/php:$${version}-xdebug; done
