# TODO: Support switching between Node and Bun as the runtime

JS_RUNTIME?=bun
JS_DIST_PATH?=dist/lib/js
JS_BUILD_PATH?=build/lib/js

# --
# Project name (defaults to current directory name)
PROJECT?=$(notdir $(CURDIR))

# --
# Bundle configuration for standalone production builds
JS_BUNDLE_ENTRY?=
JS_BUNDLE_OUTPUT?=dist/www/$(PROJECT).min.js
JS_BUNDLE_DEBUG_OUTPUT?=dist/www/$(PROJECT).js
JS_BUNDLE_EXTERNAL?=

# --
# Icons configuration (for iconify bundling)
JS_BUNDLE_ICONS_OUTPUT?=build/icons.json
JS_BUNDLE_ICONS_SOURCES?=$(SOURCES_TS)

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

JS_RUN=$(BUN) x

# TODO: We should make sure we do that with th
PREP_ALL+=$(foreach M,$(USE_NODE),build/install-node-$M.task)

BUILD_JS=\
	$(patsubst src/js/%,$(JS_BUILD_PATH)/%,$(filter src/js/%,$(SOURCES_JS))) \
	$(patsubst src/ts/%.ts,$(JS_BUILD_PATH)/%.js,$(filter src/ts/%,$(SOURCES_TS)))
BUILD_ALL+=$(BUILD_JS)

DIST_JS=\
	$(patsubst src/js/%,$(JS_DIST_PATH)/%,$(filter src/js/%,$(SOURCES_JS))) \
	$(patsubst src/ts/%.ts,$(JS_DIST_PATH)/%.js,$(filter src/ts/%,$(SOURCES_TS)))

TEST_ALL+=js-test
CHECK_ALL+=js-check
FIX_ALL+=js-fix
# Only add individual JS modules if DIST_MODE contains "js:module"
DIST_ALL+=$(if $(findstring js:module,$(DIST_MODE)),$(DIST_JS))

# EOF
