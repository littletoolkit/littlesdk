# TODO: Support switching between Node and Bun as the runtime

JS_RUNTIME?=bun
JS_RUN=$(JS_RUNTIME) x
JS_DIST_PATH?=$(PATH_DIST)/lib/js
JS_BUILD_PATH?=$(PATH_BUILD)/lib/js

# --
# Bundle configuration for standalone production builds
JS_BUNDLE_ENTRY?=$(wildcard src/ts/$(PROJECT)/index.ts  src/js/$(PROJECT)/index.js)
JS_BUNDLE_OUTPUT?=$(if $(JS_BUNDLE_ENTRY),$(PATH_DIST)/$(PROJECT).min.js)
JS_BUNDLE_DEBUG_OUTPUT?=$(if $(JS_BUNDLE_ENTRY),$(PATH_DIST)/$(PROJECT).js)
JS_BUNDLE_EXTERNAL?=

# --
# Server entry point for standalone executable
JS_SERVER_ENTRY?=$(wildcard src/ts/$(PROJECT)/server/index.ts  src/js/$(PROJECT)/server/index.js)
JS_SERVER_OUTPUT?=dist/bin/$(PROJECT)-server

# --
# The version of Bun, can be the revision number like `1.1.13` or
# `latest`.
BUN_VERSION?=latest

# TODO: Should be `mise x -- bun`
BUN?=$(CMD) bun

## Default NodeJS version
NODE_VERSION?=

## Node command alias
NODE?=$(CMD) node$(if $(NODE_VERSION),-$(NODE_VERSION))

## NPM command alias
NPM?=$(CMD) npm$(if $(NODE_VERSION),-$(NODE_VERSION))

## List of Node nodules to use in the form MODULE[=VERSION]
USE_NODE?=

# TODO: We should make sure we do that with th
JS_PREP_ALL+=$(foreach M,$(USE_NODE),build/install-node-$M.task)

JS_BUILD_ALL=\
	$(patsubst src/js/%,$(JS_BUILD_PATH)/%,$(filter src/js/%,$(SOURCES_JS))) \
	$(patsubst src/ts/%.ts,$(JS_BUILD_PATH)/%.js,$(filter src/ts/%,$(SOURCES_TS)))

# Only add individual JS modules if DIST_MODE contains "js:module"
# DIST_ALL+=$(if $(findstring js:module,$(DIST_MODE)),$(DIST_JS))
# Add server executable if JS_SERVER_ENTRY is set
JS_DIST_ALL=\
	$(if $(JS_SERVER_ENTRY),$(JS_SERVER_OUTPUT))\
	$(if $(JS_BUNDLE_ENTRY),$(JS_BUNDLE_OUTPUT))\
	$(if $(JS_BUNDLE_ENTRY),,$(patsubst src/js/%,$(JS_DIST_PATH)/%,$(filter src/js/%,$(SOURCES_JS))))\
	$(if $(JS_BUNDLE_ENTRY),,$(patsubst src/ts/%.ts,$(JS_DIST_PATH)/%.js,$(filter src/ts/%,$(SOURCES_TS))))

JS_TEST_ALL+=$(if $(TESTS_JS)$(TESTS_TS),js-test)
JS_CHECK_ALL+=$(if $(SOURCES_JS)$(SOURCES_TS),js-check)
JS_FMT_ALL+=$(if $(SOURCES_JS)$(SOURCES_TS),js-fmt)


# Bindings to the main build system
PREP_ALL+=$(JS_PREP_ALL)
BUILD_ALL+=$(JS_BUILD_ALL)
DIST_ALL+=$(JS_DIST_ALL)
TEST_ALL+=$(JS_TEST_ALL)
CHECK_ALL+=$(JS_CHECK_ALL)
FMT_ALL+=$(JS_FMT_ALL)

# EOF
