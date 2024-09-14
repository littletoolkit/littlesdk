
# --
# ## Phases
PREP_ALL?=## Dependencies that will be met by `make prep`
BUILD_ALL?=## Files to be built
RUN_ALL?=## Dependencies that will be met by `make run`
SOURCES_ALL?=## All the source files known by the kit
PACKAGE_ALL?=## All the files that will be packaged in distributions
DIST_ALL?=## All the distribution files

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
