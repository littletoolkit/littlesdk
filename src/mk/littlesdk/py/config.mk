
## List of Python nodules to use in the form MODULE[=VERSION]
USE_PYTHON?=

## Current Python version
PYTHON_VERSION?=3.14

## Python interpreter
PYTHON?=$(CMD) python
UV?=$(CMD) uv

## Bandit security auditing options
BANDIT_OPTS?=

DIST_PY=$(SOURCES_PY:$(PATH_SRC)/py/%.py=$(PATH_DIST)/lib/py/%.py)
PREP_ALL+=$(foreach M,$(USE_PYTHON),build/install-python-$M.task)
TEST_ALL+=$(if $(TESTS_PY),py-test)
CHECK_ALL+=$(if $(SOURCES_PY),py-check py-audit)
FIX_ALL+=$(if $(SOURCES_PY),py-fix)
DIST_ALL+=$(DIST_PY)

# --
# Deps Python: Find all Python files in dependency modules and map to dist paths
# deps/foo/src/py/pkg/api.py -> dist/package/lib/py/pkg/api.py
DEPS_PY_SOURCES?=$(foreach D,$(DEPS_PY_MODULES),$(call file_find,$D,*.py))
# Strip the matching DEPS_PY_MODULE prefix from each source to get relative path
py-dist-path=$(foreach D,$(DEPS_PY_MODULES),$(if $(filter $D/%,$1),$(patsubst $D/%,$(PATH_DIST)/lib/py/%,$1)))
DIST_DEPS_PY=$(foreach F,$(DEPS_PY_SOURCES),$(call py-dist-path,$F))
DIST_ALL+=$(DIST_DEPS_PY)

# EOF
