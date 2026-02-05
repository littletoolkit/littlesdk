# NOTE: Future enhancement to support both Node.js and Bun as JavaScript runtimes (currently defaults to Bun)

JS_RUNTIME?=bun
JS_DIST_PATH?=$(PATH_DIST)/lib/js
JS_BUILD_PATH?=build/lib/js

# --
# Project name (defaults to current directory name)
PROJECT?=$(notdir $(CURDIR))

# --
# Server entry point for standalone executable
JS_SERVER_ENTRY?=

# --
# Bundle configuration for standalone production builds
JS_BUNDLE_ENTRY?=
JS_BUNDLE_OUTPUT?=$(PATH_DIST)/www/$(PROJECT).min.js
JS_BUNDLE_DEBUG_OUTPUT?=$(PATH_DIST)/www/$(PROJECT).js
JS_BUNDLE_EXTERNAL?=

# --
# Icons configuration (for iconify bundling)
JS_BUNDLE_ICONS_OUTPUT?=build/icons.json
JS_BUNDLE_ICONS_SOURCES?=$(SOURCES_TS)

# NOTE: Server output path is project-specific; consider making this configurable per project type
JS_SERVER_ENTRY?=
JS_SERVER_OUTPUT?=dist/bin/$(PROJECT)-server

# --
# The version of Bun, can be the revision number like `1.1.13` or
# `latest`.
BUN_VERSION?=latest

# NOTE: Should use mise-managed Bun: `$(call mise_exec,bun)` instead of direct PATH lookup
BUN?=$(CMD) bun

## Default NodeJS version
NODE_VERSION?=

## Node command alias
NODE?=$(CMD) node$(if $(NODE_VERSION),-$(NODE_VERSION))

## NPM command alias
NPM?=$(CMD) npm$(if $(NODE_VERSION),-$(NODE_VERSION))

## List of Node nodules to use in the form MODULE[=VERSION]
USE_NODE?=

JS_RUN=$(BUN) x

# NOTE: Ensures Node.js modules in USE_NODE are prepared before build phase
PREP_ALL+=$(foreach M,$(USE_NODE),build/install-node-$M.task)

BUILD_JS=\
	$(patsubst src/js/%,$(JS_BUILD_PATH)/%,$(filter src/js/%,$(SOURCES_JS))) \
	$(patsubst src/ts/%.ts,$(JS_BUILD_PATH)/%.js,$(filter src/ts/%,$(SOURCES_TS)))
BUILD_ALL+=$(BUILD_JS)

DIST_JS=\
	$(patsubst src/js/%,$(JS_DIST_PATH)/%,$(filter src/js/%,$(SOURCES_JS))) \
	$(patsubst src/ts/%.ts,$(JS_DIST_PATH)/%.js,$(filter src/ts/%,$(SOURCES_TS)))

TEST_ALL+=$(if $(TESTS_JS)$(TESTS_TS),js-test)
CHECK_ALL+=$(if $(SOURCES_JS)$(SOURCES_TS),js-check)
FIX_ALL+=$(if $(SOURCES_JS)$(SOURCES_TS),js-fix)

# Only add individual JS modules if DIST_MODE contains "js:module"
DIST_ALL+=$(if $(findstring js:module,$(DIST_MODE)),$(DIST_JS))
# Add server executable if JS_SERVER_ENTRY is set
DIST_ALL+=$(if $(JS_SERVER_ENTRY),$(JS_SERVER_OUTPUT))

# EOF
