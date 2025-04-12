# TODO: Support switching between Node and Bun as the runtime

## Default NodeJS version
NODE_VERSION?=22

## Node command alias
NODE?=node$(if $(NODE_VERSION),-$(NODE_VERSION))

## NPM command alias
NPM?=npm$(if $(NODE_VERSION),-$(NODE_VERSION))

## List of Node nodules to use in the form MODULE[=VERSION]
USE_NODE?=

PREP_ALL+=$(foreach M,$(USE_NODE),build/install-node-$M.task)
DIST_WWW_JS=$(patsubst src/js/%,dist/www/lib/js/%,$(filter src/js/%,$(SOURCES_JS)))
DIST_JS=$(patsubst src/js/%,dist/www/lib/js/%,$(filter src/js/%,$(SOURCES_JS)))

# --
# The version of Bun, can be the revision number like `1.1.13` or
# `latest`.
BUN_VERSION?=latest

# EOF

