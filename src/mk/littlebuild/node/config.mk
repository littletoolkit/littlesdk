## Default NodeJS version
NODE_VERSION?=22

## Node command alias
NODE?=node$(if $(NODE_VERSION),-$(NODE_VERSION))

## NPM command alias
NPM?=npm$(if $(NODE_VERSION),-$(NODE_VERSION))

## List of Node nodules to use in the form MODULE[=VERSION]
USE_NODE?=

PREP_ALL+=$(foreach M,$(USE_NODE),build/install-node-$M.task)

# EOF

