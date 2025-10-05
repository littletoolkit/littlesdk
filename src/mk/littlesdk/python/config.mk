
## List of Python nodules to use in the form MODULE[=VERSION]
USE_PYTHON?=

## Current Python version
PYTHON_VERSION?=3.12

## Python interpreter
PYTHON?=$(CMD) python
UV?=$(CMD) uv

PREP_ALL+=$(foreach M,$(USE_PYTHON),build/install-python-$M.task)
# EOF
