# --
# Project name (defaults to current directory name)
PROJECT?=$(notdir $(CURDIR))

DEFAULT_RULE?=help


## Alias to Git
GIT?=git

## Forces non-interactive mode
NO_INTERACTIVE?=

## Removes color output
NO_COLOR?=
# --
# Where the sources are
PATH_SRC?=src
# --
# Where the runtime files are store
PATH_RUN?=run
# --
# Where source dependencies are downloaded
PATH_DEPS?=deps
# --
# Where assets are built
PATH_BUILD?=build

# --
# Where distribution assets are built
PATH_DIST?=dist/package

# --
# Revision identifier for distributions
REVISION?=$(shell git rev-parse --short HEAD)

# --
# Distribution mode controls what gets included in dist output.
# Supports multiple space-separated modes:
#   js:module - Include individual JS modules in dist/lib/js/*
#   js:bundle - Include bundled JS assets in dist/www/
DIST_MODE?=js:module

# --
# Where tests are located
PATH_TESTS?=tests

# -- ## Environment
BASE_PATH?=$(PATH)
BASE_PYTHONPATH?=$(PYTHONPATH)
BASE_LDLIBRARYPATH?=$(LDLIBRARYPATH)

# -- ## Commands
CMD=mise x --

# -- ## Phases
PREP_ALL?=## Dependencies that will be met by `make prep`
BUILD_ALL?=## Files to be built
CHECK_ALL?=## Checks that will be run by `make check`
FIX_ALL?=## Checks that will be run by `make check`
RUN_ALL?=## Dependencies that will be met by `make run`
TEST_ALL?=## Dependencies that will be met by `make test`
SOURCES_ALL?=## All the source files known by the kit
PACKAGE_ALL?=## All the files that will be packaged in distributions
DIST_ALL?=## All the distribution files
DIST_PACKAGES=$(addprefix dist/$(PROJECT)-$(REVISION).tar., $(DIST_FORMATS))
DIST_PACKAGE=$(firstword $(DIST_PACKAGES))

# Compression formats and levels for distribution archives
DIST_FORMATS?=bz2 ## Supports: bz2, gz, xz
COMPRESS_GZ_LEVEL?=9 ## Compression level for gzip (1-9, 9=best)
COMPRESS_BZ2_LEVEL?=9 ## Compression level for bzip2 (1-9, 9=best)
COMPRESS_XZ_LEVEL?=9 ## Compression level for xz (0-9, 9=best)

# --
# This manages the dependencies (in deps/). When dependencies follow conventions,
# they will automatically populate the DEPS_PATH, DEPS_PYTHONPATH and DEPS_JSPATH
# variables.
DEPS_ALL?=$(wildcard $(PATH_DEPS)/*)
DEPS_BIN?=$(foreach D,$(DEPS_ALL),$(if $(wildcard $D/bin),$D/bin))
DEPS_PY_MODULES?=$(foreach D,$(DEPS_ALL),$(if $(wildcard $D/$(PATH_SRC)/py),$D/$(PATH_SRC)/py))
DEPS_JS_MODULES?=$(foreach D,$(DEPS_ALL),$(if $(wildcard $D/$(PATH_SRC)/js),$D/$(PATH_SRC)/js))
DEPS_CSS_MODULES?=$(foreach D,$(DEPS_ALL),$(if $(wildcard $D/$(PATH_SRC)/css),$D/$(PATH_SRC)/css))

DEPS_PATH?=$(subst $(SPACE),:,$(foreach P,$(DEPS_BIN),$(realpath $P)))
DEPS_PYTHONPATH?=$(subst $(SPACE),:,$(foreach P,$(DEPS_PY_MODULES),$(realpath $P)))
DEPS_JSPATH?=$(subst $(SPACE),$(COMMA),$(foreach D,$(DEPS_JS_MODULES),$(foreach M,$(wildcard $D/*),"@$(firstword $(subst .,$(SPACE),$(notdir $M)))":"$(realpath $M)")))

# --
# This is fed to `use_env`
ENV_PATH=$(realpath bin):$(realpath $(PATH_RUN)/bin):$(DEPS_PATH):$(BASE_PATH)
ENV_PYTHONPATH=$(realpath $(PATH_SRC)/py):$(DEPS_PYTHONPATH):$(BASE_PYTHONPATH)

# --
# ## Sources
SOURCES_JS=$(call file_find,$(PATH_SRC)/js,*.js) ## List of JavaScript sources
SOURCES_TS=$(call file_find,$(PATH_SRC)/ts,*.ts) ## List of JavaScript sources
SOURCES_PY=$(call file_find,$(PATH_SRC)/py,*.py) ## List of Python sources
SOURCES_MK=$(call file_find,$(PATH_SRC)/mk,*.mk) ## List of Makefile sources
SOURCES_HTML=$(call file_find,$(PATH_SRC)/html,*.html) ## List of HTML sources
SOURCES_CSS=$(call file_find,$(PATH_SRC)/css,*.css) ## List of CSS sources
SOURCES_CSS_JS=$(call file_find,$(PATH_SRC)/css,*.js) ## List of CSS/JS sources
SOURCES_XML=$(call file_find,$(PATH_SRC)/xml,*.xml) ## List of XML sources
SOURCES_XSLT=$(call file_find,$(PATH_SRC)/xslt,*.xslt) ## List of XSLT sources
SOURCES_JSON=$(call file_find,$(PATH_SRC)/json,*.json) ## List of JSON sources
SOURCES_MD=$(call file_find,$(PATH_SRC)/md,*.md) ## List of Markdown sources
SOURCES_DATA=$(call file_find,$(PATH_SRC)/data,*) ## List of data files
SOURCES_STATIC=$(call file_find,$(PATH_SRC)/static,*) ## List of static files
SOURCES_ETC=$(call file_find,$(PATH_SRC)/etc,*) ## List of etc files



SDK_DOTFILES=$(filter $(SDK_PATH)/etc/_%,$(call file_find,$(SDK_PATH)/etc,*)) ## List of dotfiles in SDK
SDK_ETCFILES=$(filter-out $(SDK_PATH)/etc/_%,$(call file_find,$(SDK_PATH)/etc,*)) ## List of dotfiles in SDK

PREP_SDK=\
	$(SDK_DOTFILES:$(SDK_PATH)/etc/_%=.%)\
	$(SDK_ETCFILES:$(SDK_PATH)/etc/%=%)
PREP_SDK_FILE=$(foreach F,$(PREP_SDK),$(if $(wildcard $F/*),DIR=$F,NOTDIR=$F))

PREP_ALL+=$(PREP_SDK)
# --
# ## Tests

TESTS_TS=$(call file_find,$(PATH_TESTS),*.test.ts) ## List of TypeScript tests
TESTS_JS=$(call file_find,$(PATH_TESTS),*.test.js) ## List of JavaScript tests
TESTS_PY=$(call file_find,$(PATH_TESTS),*.test.py) ## List of Python tests
TESTS_SH=$(call file_find,$(PATH_TESTS),*.test.sh) ## List of shell tests
TESTS_ALL?=$(foreach _,JS TS PY SH,$(TESTS_$_)) ## All test files

ifeq ($(SOURCES_ALL),)
SOURCES_ALL+=$(foreach _,JS TS PY HTML CSS CSS_JS XML XSLT,$(SOURCES_$_))
endif

# --
# Lists all source files defined in the modules like `std/lib.mk std/vars.mk`
MODULES_SOURCES:=$(patsubst $(MODULES_PATH)/%,%,$(wildcard $(MODULES_PATH)/*/*.mk))

# --
# Lists all available modules, like `std prep run`
MODULES_AVAILABLE:=$(foreach M,$(wildcard $(MODULES_PATH)/*),$(if $(wildcard $M/*.mk),$(notdir $M)))

USE_CLI_CHECK+=|| which $1 2> /dev/null
# EOF
