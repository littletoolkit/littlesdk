# -----------------------------------------------------------------------------
# CONFIG
# -----------------------------------------------------------------------------

# --
# List of shell scripts to be deployed
# These scripts are copied to the distribution directory during the build process.
APPDEPLOY_SCRIPTS=env run check

# --
# Sources for the shell scripts
# This variable finds all the shell scripts defined in APPDEPLOY_SCRIPTS.
APPDEPLOY_SOURCES=$(wildcard $(foreach S,$(APPDEPLOY_SCRIPTS),src/sh/$S.sh))

# --
# Distribution targets for the shell scripts
# These targets are added to the DIST_ALL variable to ensure they are built.
DIST_APPDEPLOY+=$(patsubst src/sh/%,$(PATH_DIST)/%,$(APPDEPLOY_SOURCES))
DIST_ALL+=$(DIST_APPDEPLOY)

# EOF
