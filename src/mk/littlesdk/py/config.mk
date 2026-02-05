# -----------------------------------------------------------------------------
#
# PYTHON MODULE CONFIGURATION
#
# -----------------------------------------------------------------------------

# Configuration for Python project support including package management,
# linting, testing, and distribution.

# -----------------------------------------------------------------------------
#
# PYTHON SETTINGS
#
# -----------------------------------------------------------------------------

# --
# ## Python Environment

# List of Python modules to install in the form MODULE[=VERSION]
USE_PYTHON?= ## Python packages to install

# Python version to use
PYTHON_VERSION?=3.14 ## Target Python version

# Python interpreter command
PYTHON?=$(CMD) python ## Python interpreter path

# UV package manager command
UV?=$(CMD) uv ## UV package manager path

# --
# ## Security Auditing

# Options for bandit security scanner
BANDIT_OPTS?= ## Additional options for bandit security audit

# -----------------------------------------------------------------------------
#
# DISTRIBUTION
#
# -----------------------------------------------------------------------------

# --
# ## Python Distribution Files

# Map source Python files to distribution paths
DIST_PY=$(SOURCES_PY:$(PATH_SRC)/py/%.py=$(PATH_DIST)/lib/py/%.py) ## Python files for distribution

# Add Python distribution files to DIST_ALL
DIST_ALL+=$(DIST_PY)

# -----------------------------------------------------------------------------
#
# DEPENDENCY INTEGRATION
#
# -----------------------------------------------------------------------------

# --
# ## Dependency Python Sources

# Find all Python files in dependency modules and map to dist paths
# Format: deps/foo/src/py/pkg/api.py -> dist/package/lib/py/pkg/api.py
DEPS_PY_SOURCES?=$(foreach D,$(DEPS_PY_MODULES),$(call file_find,$D,*.py)) ## Python sources from dependencies

# --
# Function: py-dist-path
# Maps a dependency source path to distribution path.
# - SRC: Source file path in dependency
# Returns: Corresponding path in distribution

py-dist-path=$(foreach D,$(DEPS_PY_MODULES),$(if $(filter $D/%,$1),$(patsubst $D/%,$(PATH_DIST)/lib/py/%,$1)))

# Distribution files from dependencies
DIST_DEPS_PY=$(foreach F,$(DEPS_PY_SOURCES),$(call py-dist-path,$F)) ## Dependency Python files for distribution

# Add dependency files to distribution
DIST_ALL+=$(DIST_DEPS_PY)

# -----------------------------------------------------------------------------
#
# BUILD PHASES
#
# -----------------------------------------------------------------------------

# --
# ## Phase Registration

# Add Python module installations to prep phase
PREP_ALL+=$(foreach M,$(USE_PYTHON),build/install-python-$M.task)

# Add Python tests to test phase
TEST_ALL+=$(if $(TESTS_PY),py-test)

# Add Python checks to check phase
CHECK_ALL+=$(if $(SOURCES_PY),py-check py-audit)

# Add Python fixes to fix phase
FIX_ALL+=$(if $(SOURCES_PY),py-fix)

# EOF
