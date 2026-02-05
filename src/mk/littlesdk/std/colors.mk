# -----------------------------------------------------------------------------
#
# COLOR DEFINITIONS
#
# -----------------------------------------------------------------------------

# Extended color palette for terminal output. Respects NO_COLOR environment
# variable per https://no-color.org/. Colors are defined using tput for
# maximum terminal compatibility.

# -----------------------------------------------------------------------------
#
# COLOR SETTINGS
#
# -----------------------------------------------------------------------------

# --
# ## Color Control

# Disable colors if NO_COLOR is set
NO_COLOR?= ## Set to any value to disable colors

# Disable interactive features if set
NO_INTERACTIVE?= ## Set to disable interactive prompts

# Terminal type for color support
TERM?= ## Terminal type (auto-detected if not set)

# -----------------------------------------------------------------------------
#
# COLOR VARIABLES
#
# -----------------------------------------------------------------------------

# --
# ## Color Definitions

# Primary colors (initially empty, populated if tput available)
YELLOW        ?= ## Yellow color
ORANGE        ?= ## Orange color
GREEN         ?= ## Green color
GOLD          ?= ## Gold color
GOLD_DK       ?= ## Dark gold color
BLUE_DK       ?= ## Dark blue color
BLUE          ?= ## Blue color
BLUE_LT       ?= ## Light blue color
CYAN          ?= ## Cyan color
RED           ?= ## Red color
PURPLE_DK     ?= ## Dark purple color
PURPLE        ?= ## Purple color
PURPLE_LT     ?= ## Light purple color
GRAY          ?= ## Gray color
GRAYLT        ?= ## Light gray color
REGULAR       ?= ## Regular/default color
RESET         ?= ## Reset all attributes
BOLD          ?= ## Bold text
UNDERLINE     ?= ## Underlined text
REV           ?= ## Reverse video
DIM           ?= ## Dim text

# -----------------------------------------------------------------------------
#
# TERMINAL COLOR INITIALIZATION
#
# -----------------------------------------------------------------------------

# --
# ## Color Setup

# Initialize colors using tput if available and NO_COLOR is not set
ifneq (,$(shell which tput 2> /dev/null))
ifeq (,$(NO_COLOR))

# Set default terminal type
TERM?=xterm-color ## Default terminal type

# Populate color variables using tput
BLUE_DK       :=$(shell TERM="$(TERM)" echo $$(tput setaf 27))
BLUE          :=$(shell TERM="$(TERM)" echo $$(tput setaf 33))
BLUE_LT       :=$(shell TERM="$(TERM)" echo $$(tput setaf 117))
YELLOW        :=$(shell TERM="$(TERM)" echo $$(tput setaf 226))
ORANGE        :=$(shell TERM="$(TERM)" echo $$(tput setaf 208))
GREEN         :=$(shell TERM="$(TERM)" echo $$(tput setaf 118))
GOLD          :=$(shell TERM="$(TERM)" echo $$(tput setaf 214))
GOLD_DK       :=$(shell TERM="$(TERM)" echo $$(tput setaf 208))
CYAN          :=$(shell TERM="$(TERM)" echo $$(tput setaf 51))
RED           :=$(shell TERM="$(TERM)" echo $$(tput setaf 196))
PURPLE_DK     :=$(shell TERM="$(TERM)" echo $$(tput setaf 55))
PURPLE        :=$(shell TERM="$(TERM)" echo $$(tput setaf 92))
PURPLE_LT     :=$(shell TERM="$(TERM)" echo $$(tput setaf 163))
GRAY          :=$(shell TERM="$(TERM)" echo $$(tput setaf 153))
GRAYLT        :=$(shell TERM="$(TERM)" echo $$(tput setaf 231))
REGULAR       :=$(shell TERM="$(TERM)" echo $$(tput setaf 7))
RESET         :=$(shell TERM="$(TERM)" echo $$(tput sgr0))
BOLD          :=$(shell TERM="$(TERM)" echo $$(tput bold))
UNDERLINE     :=$(shell TERM="$(TERM)" echo $$(tput smul))
REV           :=$(shell TERM="$(TERM)" echo $$(tput rev))
DIM           :=$(shell TERM="$(TERM)" echo $$(tput dim))

endif
endif

# EOF
