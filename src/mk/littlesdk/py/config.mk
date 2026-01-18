
## List of Python nodules to use in the form MODULE[=VERSION]
USE_PYTHON?=

## Current Python version
PYTHON_VERSION?=3.14

## Python interpreter
PYTHON?=$(CMD) python
UV?=$(CMD) uv

DIST_PY=$(SOURCES_PY:$(PATH_SRC)/py/%.py=$(PATH_DIST)/lib/py/%.py)
PREP_ALL+=$(foreach M,$(USE_PYTHON),build/install-python-$M.task)
TEST_ALL+=$(if $(SOURCES_PY),py-test)
CHECK_ALL+=$(if $(SOURCES_PY),py-check)
FIX_ALL+=$(if $(SOURCES_PY),py-fix)
DIST_ALL+=$(DIST_PY)


# EOF
