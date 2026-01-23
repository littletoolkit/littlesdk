# File: appdeploy/config

APPDEPLOY_SCRIPTS=env run check
APPDEPLOY_SOURCES=$(wildcard $(foreach S,$(APPDEPLOY_SCRIPTS),src/sh/$S.sh))

DIST_APPDEPLOY+=$(patsubst src/sh/%,$(PATH_DIST)/%,$(APPDEPLOY_SOURCES))
DIST_ALL+=$(DIST_APPDEPLOY)
# EOF
