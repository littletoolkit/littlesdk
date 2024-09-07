## Alias to Git
GIT?=git
## Current Python version
PYTHON_VERSION?=3.12

## Python interpreter
PYTHON?=python$(PYTHON_VERSION)

## Default NodeJS version
NODE_VERSION?=22

## Node command alias
NODE?=node$(if $(NODE_VERSION),-$(NODE_VERSION))

## NPM command alias
NPM?=npm$(if $(NODE_VERSION),-$(NODE_VERSION))

## Forces non-interactive mode
NO_INTERACTIVE?=

## Removes color output
NO_COLOR?=
# EOF
