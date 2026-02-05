# -----------------------------------------------------------------------------
#
# STANDARD LIBRARY CONFIGURATION
#
# -----------------------------------------------------------------------------

# Standard configuration variables and defaults for LittleSDK projects.
# These can be overridden in project Makefile or through environment.

# -----------------------------------------------------------------------------
#
# PROJECT CONFIGURATION
#
# -----------------------------------------------------------------------------

# --
# ## Project Identity

# Project name (defaults to current directory name)
PROJECT?=$(notdir $(CURDIR)) ## Project identifier used for distributions

# Default rule to run when `make` is invoked without arguments
DEFAULT_RULE?=help ## Default target when running `make`

# -----------------------------------------------------------------------------
#
# TOOLS AND COMMANDS
#
# -----------------------------------------------------------------------------

# --
# ## External Tools

# Git command alias
GIT?=git ## Path to git executable

# Forces non-interactive mode for scripts
NO_INTERACTIVE?= ## Set to disable interactive prompts

# Removes color output (respects https://no-color.org/)
NO_COLOR?= ## Set to disable colored output

# -----------------------------------------------------------------------------
#
# DIRECTORY STRUCTURE
#
# -----------------------------------------------------------------------------

# --
# ## Paths

# Where source files are located
PATH_SRC?=src ## Source directory path

# Where runtime files are stored
PATH_RUN?=run ## Runtime directory path

# Where source dependencies are downloaded
PATH_DEPS?=deps ## Dependencies directory path

# Where build artifacts are stored
PATH_BUILD?=build ## Build output directory path

# Where distribution assets are built
PATH_DIST?=dist/package ## Distribution output directory

# Where tests are located
PATH_TESTS?=tests ## Test files directory

# -----------------------------------------------------------------------------
#
# DISTRIBUTION SETTINGS
#
# -----------------------------------------------------------------------------

# --
# ## Distribution Configuration

# Revision identifier for distributions (defaults to git short SHA)
REVISION?=$(shell git rev-parse --short HEAD) ## Build revision identifier

# Distribution mode controls what gets included in dist output.
# Supports multiple space-separated modes:
#   js:module - Include individual JS modules in dist/lib/js/*
#   js:bundle - Include bundled JS assets in dist/www/
DIST_MODE?=js:module ## Distribution packaging mode

# Compression formats for distribution archives
DIST_FORMATS?=bz2 ## Supported: bz2, gz, xz

# Compression level for gzip (1-9, 9=best compression)
COMPRESS_GZ_LEVEL?=9 ## Gzip compression level

# Compression level for bzip2 (1-9, 9=best compression)
COMPRESS_BZ2_LEVEL?=9 ## Bzip2 compression level

# Compression level for xz (0-9, 9=best compression)
COMPRESS_XZ_LEVEL?=9 ## XZ compression level

# -----------------------------------------------------------------------------
#
# BUILD PHASES
#
# -----------------------------------------------------------------------------

# --
# ## Phase Dependencies

# Dependencies that will be met by `make prep`
PREP_ALL?= ## Targets for preparation phase

# Files to be built by `make build`
BUILD_ALL?= ## Targets for build phase

# Checks that will be run by `make check`
CHECK_ALL?= ## Targets for check phase

# Fixes that will be run by `make fix`
FIX_ALL?= ## Targets for fix phase

# Dependencies that will be met by `make run`
RUN_ALL?= ## Targets for run phase

# Dependencies that will be run by `make test`
TEST_ALL?= ## Targets for test phase

# All source files known by the kit
SOURCES_ALL?= ## All source files

# Files that will be packaged in distributions
PACKAGE_ALL?= ## Files to include in distribution

# All distribution files
DIST_ALL?= ## Distribution file targets

# Generated distribution package paths
DIST_PACKAGES=$(addprefix dist/$(PROJECT)-$(REVISION).tar., $(DIST_FORMATS))

# -----------------------------------------------------------------------------
#
# ENVIRONMENT
#
# -----------------------------------------------------------------------------

# --
# ## Environment Variables

# Base PATH before SDK modifications
BASE_PATH?=$(PATH)

# Base PYTHONPATH before SDK modifications
BASE_PYTHONPATH?=$(PYTHONPATH)

# Base LD_LIBRARY_PATH before SDK modifications
BASE_LDLIBRARYPATH?=$(LDLIBRARYPATH)

# Combined PATH for SDK environment
ENV_PATH=$(realpath bin):$(realpath $(PATH_RUN)/bin):$(DEPS_PATH):$(BASE_PATH)

# Combined PYTHONPATH for SDK environment
ENV_PYTHONPATH=$(realpath $(PATH_SRC)/py):$(DEPS_PYTHONPATH):$(BASE_PYTHONPATH)

# -----------------------------------------------------------------------------
#
# COMMANDS
#
# -----------------------------------------------------------------------------

# --
# ## Command Wrappers

# Mise command wrapper for tool execution
CMD=mise x -- ## Command prefix for running tools via mise

# -----------------------------------------------------------------------------
#
# SOURCE FILE DISCOVERY
#
# -----------------------------------------------------------------------------

# --
# ## Source Lists

SOURCES_JS=$(call file_find,$(PATH_SRC)/js,*.js) ## JavaScript source files
SOURCES_TS=$(call file_find,$(PATH_SRC)/ts,*.ts) ## TypeScript source files
SOURCES_PY=$(call file_find,$(PATH_SRC)/py,*.py) ## Python source files
SOURCES_MK=$(call file_find,$(PATH_SRC)/mk,*.mk) ## Makefile source files
SOURCES_HTML=$(call file_find,$(PATH_SRC)/html,*.html) ## HTML source files
SOURCES_CSS=$(call file_find,$(PATH_SRC)/css,*.css) ## CSS source files
SOURCES_CSS_JS=$(call file_find,$(PATH_SRC)/css,*.js) ## CSS-related JS files
SOURCES_XML=$(call file_find,$(PATH_SRC)/xml,*.xml) ## XML source files
SOURCES_XSLT=$(call file_find,$(PATH_SRC)/xslt,*.xslt) ## XSLT source files
SOURCES_JSON=$(call file_find,$(PATH_SRC)/json,*.json) ## JSON source files
SOURCES_MD=$(call file_find,$(PATH_SRC)/md,*.md) ## Markdown source files
SOURCES_DATA=$(call file_find,$(PATH_SRC)/data,*) ## Data files
SOURCES_STATIC=$(call file_find,$(PATH_SRC)/static,*) ## Static files
SOURCES_ETC=$(call file_find,$(PATH_SRC)/etc,*) ## Configuration files

# -----------------------------------------------------------------------------
#
# SDK INTERNALS
#
# -----------------------------------------------------------------------------

# --
# ## SDK Setup Files

# Dotfiles in SDK etc directory (prefixed with _)
SDK_DOTFILES=$(filter $(SDK_PATH)/etc/_%,$(call file_find,$(SDK_PATH)/etc,*)) ## SDK dotfiles

# Regular files in SDK etc directory
SDK_ETCFILES=$(filter-out $(SDK_PATH)/etc/_%,$(call file_find,$(SDK_PATH)/etc,*)) ## SDK config files

# Files to link during SDK preparation
PREP_SDK=\
	$(SDK_DOTFILES:$(SDK_PATH)/etc/_%=.%)\
	$(SDK_ETCFILES:$(SDK_PATH)/etc/%=%)

# Categorized prep SDK files
PREP_SDK_FILE=$(foreach F,$(PREP_SDK),$(if $(wildcard $F/*),DIR=$F,NOTDIR=$F))

# Add SDK files to prep phase
PREP_ALL+=$(PREP_SDK)

# -----------------------------------------------------------------------------
#
# TEST FILES
#
# -----------------------------------------------------------------------------

# --
# ## Test Lists

TESTS_TS=$(call file_find,$(PATH_TESTS),*.test.ts) ## TypeScript test files
TESTS_JS=$(call file_find,$(PATH_TESTS),*.test.js) ## JavaScript test files
TESTS_PY=$(call file_find,$(PATH_TESTS),*.test.py) ## Python test files
TESTS_SH=$(call file_find,$(PATH_TESTS),*.test.sh) ## Shell test files
TESTS_ALL?=$(foreach _,JS TS PY SH,$(TESTS_$_)) ## All test files

# Populate SOURCES_ALL if empty
ifeq ($(SOURCES_ALL),)
SOURCES_ALL+=$(foreach _,JS TS PY HTML CSS CSS_JS XML XSLT,$(SOURCES_$_))
endif

# -----------------------------------------------------------------------------
#
# MODULE SYSTEM
#
# -----------------------------------------------------------------------------

# --
# ## Module Discovery

# Lists all module source files
MODULES_SOURCES:=$(patsubst $(MODULES_PATH)/%,%,$(wildcard $(MODULES_PATH)/*/*.mk)) ## All module source files

# Lists all available modules (directories with .mk files)
MODULES_AVAILABLE:=$(foreach M,$(wildcard $(MODULES_PATH)/*),$(if $(wildcard $M/*.mk),$(notdir $M))) ## Available module names

# -----------------------------------------------------------------------------
#
# UTILITY
#
# -----------------------------------------------------------------------------

# --
# ## CLI Checks

# Check command for ensuring CLI tools exist
USE_CLI_CHECK+=|| which $1 2> /dev/null ## Shell command to verify CLI tool availability

# EOF
