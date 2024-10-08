
# -- ## Environment
BASE_PATH?=$(PATH)
BASE_PYTHONPATH?=$(PYTHONPATH)
BASE_LDLIBRARYPATH?=$(LDLIBRARYPATH)

# -- ## Phases
PREP_ALL?=## Dependencies that will be met by `make prep`
BUILD_ALL?=## Files to be built
RUN_ALL?=## Dependencies that will be met by `make run`
SOURCES_ALL?=## All the source files known by the kit
PACKAGE_ALL?=## All the files that will be packaged in distributions
DIST_ALL?=## All the distribution files

# --
# This manages the dependencies (in deps/). When dependencies follow conventions,
# they will automatically populate the DEPS_PATH, DEPS_PYTHONPATH and DEPS_JSPATH
# variables.
DEPS_ALL?=$(wildcard deps/*)
DEPS_BIN?=$(foreach D,$(DEPS_ALL),$(if $(wildcard $D/bin),$D/bin))
DEPS_PY_MODULES?=$(foreach D,$(DEPS_ALL),$(if $(wildcard $D/src/py),$D/src/py))
DEPS_JS_MODULES?=$(foreach D,$(DEPS_ALL),$(if $(wildcard $D/src/js),$D/src/js))
DEPS_CSS_MODULES?=$(foreach D,$(DEPS_ALL),$(if $(wildcard $D/src/css),$D/src/css))

DEPS_PATH?=$(subst $(SPACE),:,$(foreach P,$(DEPS_BIN),$(realpath $P)))
DEPS_PYTHONPATH?=$(subst $(SPACE),:,$(foreach P,$(DEPS_PY_MODULES),$(realpath $P)))
DEPS_JSPATH?=$(subst $(SPACE),$(COMMA),$(foreach D,$(DEPS_JS_MODULES),$(foreach M,$(wildcard $D/*),"@$(firstword $(subst .,$(SPACE),$(notdir $M)))":"$(realpath $M)")))

# --
# ## Sources
SOURCES_JS=$(call file-find,src/js,*.js) ## List of JavaScript sources
SOURCES_PY=$(call file-find,src/js,*.py) ## List of Python sources
SOURCES_HTML=$(call file-find,src/html,*.html) ## List of HTML sources
SOURCES_CSS=$(call file-find,src/css,*.css) ## List of CSS sources
SOURCES_CSS_JS=$(call file-find,src/css,*.js) ## List of CSS/JS sources
SOURCES_XML=$(call file-find,src/xml,*.xml) ## List of XML sources
SOURCES_XSLT=$(call file-find,src/xslt,*.xslt) ## List of XSLT sources
SOURCES_JSON=$(call file-find,src/json,*.json) ## List of JSON sources
SOURCES_MD=$(call file-find,src/md,*.md) ## List of JSON sources
SOURCES_ETC=$(call file-find,src/etc,*) ## List of JSON sources
ifeq ($(SOURCES_ALL),)
SOURCES_ALL+=$(foreach _,JS PY HTML CSS CSS_JS XML XSLT,$(SOURCES_$_))
endif

# --
# The prefix used in logging output
FMT_PREFIX?=[kit]

# --
# Lists all source files defined in the modules like `std/lib.mk std/vars.mk`
KIT_MODULES_SOURCES:=$(patsubst $(KIT_MODULES_PATH)/%,%,$(wildcard $(KIT_MODULES_PATH)/*/*.mk))

# --
# Lists all available modules, like `std prep run`
KIT_MODULES_AVAILABLE:=$(foreach M,$(wildcard $(KIT_MODULES_PATH)/*),$(if $(wildcard $M/*.mk),$(notdir $M)))
# EOF
