DEFAULT_RULE?=help

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
PATH_DIST?=dist

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
SOURCES_PY=$(call file_find,$(PATH_SRC)/js,*.py) ## List of Python sources
SOURCES_HTML=$(call file_find,$(PATH_SRC)/html,*.html) ## List of HTML sources
SOURCES_CSS=$(call file_find,$(PATH_SRC)/css,*.css) ## List of CSS sources
SOURCES_CSS_JS=$(call file_find,$(PATH_SRC)/css,*.js) ## List of CSS/JS sources
SOURCES_XML=$(call file_find,$(PATH_SRC)/xml,*.xml) ## List of XML sources
SOURCES_XSLT=$(call file_find,$(PATH_SRC)/xslt,*.xslt) ## List of XSLT sources
SOURCES_JSON=$(call file_find,$(PATH_SRC)/json,*.json) ## List of JSON sources
SOURCES_MD=$(call file_find,$(PATH_SRC)/md,*.md) ## List of JSON sources
SOURCES_ETC=$(call file_find,$(PATH_SRC)/etc,*) ## List of JSON sources

# --
# ## Tests

TESTS_TS=$(call file_find,$(PATH_TESTS),*.ts) ## List of TypeScript tests
TESTS_JS=$(call file_find,$(PATH_TESTS),*.js) ## List of TypeScript tests

ifeq ($(SOURCES_ALL),)
SOURCES_ALL+=$(foreach _,JS TS PY HTML CSS CSS_JS XML XSLT,$(SOURCES_$_))
endif

# --
# The prefix used in logging output
FMT_PREFIX?=[kit]

# --
# Lists all source files defined in the modules like `std/lib.mk std/vars.mk`
MODULES_SOURCES:=$(patsubst $(MODULES_PATH)/%,%,$(wildcard $(MODULES_PATH)/*/*.mk))

# --
# Lists all available modules, like `std prep run`
MODULES_AVAILABLE:=$(foreach M,$(wildcard $(MODULES_PATH)/*),$(if $(wildcard $M/*.mk),$(notdir $M)))

USE_CLI_CHECK+=|| which $1 2> /dev/null
# EOF
