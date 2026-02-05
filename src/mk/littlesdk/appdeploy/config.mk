# -----------------------------------------------------------------------------
#
# APPDEPLOY MODULE CONFIGURATION
#
# -----------------------------------------------------------------------------

# Configuration for deploying shell scripts and application components.

# -----------------------------------------------------------------------------
#
# DEPLOYMENT SCRIPTS
#
# -----------------------------------------------------------------------------

# --
# ## Script Configuration

# List of shell script names to deploy (without .sh extension)
APPDEPLOY_SCRIPTS=env run check ## Scripts to deploy

# Source files for the shell scripts
APPDEPLOY_SOURCES=$(wildcard $(foreach S,$(APPDEPLOY_SCRIPTS),src/sh/$S.sh)) ## Script source files

# -----------------------------------------------------------------------------
#
# DISTRIBUTION
#
# -----------------------------------------------------------------------------

# --
# ## Distribution Targets

# Distribution files for appdeploy scripts
DIST_APPDEPLOY+=$(patsubst src/sh/%,$(PATH_DIST)/%,$(APPDEPLOY_SOURCES)) ## Script distribution files

# Add to distribution phase
DIST_ALL+=$(DIST_APPDEPLOY)

# EOF
