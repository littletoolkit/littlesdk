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

## List of Github nodules to use in the form REPO/USER[@BRANCH]
USE_GITHUB?=
## List of Python nodules to use in the form MODULE[=VERSION]
USE_PYTHON?=
## List of Node nodules to use in the form MODULE[=VERSION]
USE_NODE?=

PREP_ALL+=\
	$(foreach M,$(USE_GITHUB),build/install-github-$M.task)\
	$(foreach M,$(USE_PYTHON),build/install-python-$M.task)\
	$(foreach M,$(USE_NODE),build/install-node-$M.task)


# EOF
