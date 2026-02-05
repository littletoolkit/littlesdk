# -----------------------------------------------------------------------------
#
# STANDARD LIBRARY FUNCTIONS
#
# -----------------------------------------------------------------------------

# Core utility functions and shell helpers for LittleSDK Makefiles.

# -----------------------------------------------------------------------------
#
# CORE VARIABLES
#
# -----------------------------------------------------------------------------

# --
# ## String Constants

NULL:= ## Empty string for building other constants
SPACE:=$(NULL) $(NULL) ## Space character constant
COMMA:=, ## Comma character constant

# --
# Function: EOL
# Defines an end-of-line character sequence for use in make functions.
# Returns: Newline character

define EOL
$(if 1,
,)
endef

# -----------------------------------------------------------------------------
#
# POSITIONAL ARGUMENTS
#
# -----------------------------------------------------------------------------

# --
# ## Argument Placeholders

# Define positional arguments to suppress undefined variable warnings
1?=
2?=
3?=
4?=
5?=
6?=
7?=

# -----------------------------------------------------------------------------
#
# TERMINAL COLORS
#
# -----------------------------------------------------------------------------

# --
# ## Terminal Capabilities

# Respect NO_COLOR environment variable (https://no-color.org/)
NO_COLOR?=

# --
# Function: termcap
# Retrieves terminal capability codes using tput, respecting NO_COLOR setting.
# - CAP: Terminal capability name (e.g., setaf, bold, sgr0)
# Returns: Terminal escape sequence or empty string if NO_COLOR is set

ifneq (,$(shell which tput 2> /dev/null))
termcap=$(if $(NO_COLOR),,$(shell TERM="$(TERM)" echo $$(tput $1)))
else
termcap=
endif

# Terminal type fallback
TERM?=
TERM?=xterm-color ## Default terminal type for color support

# Color definitions
GRAY                  :=$(call termcap,setaf 153) ## Light gray
RESET                 :=$(call termcap,sgr0) ## Reset all attributes
BOLD                  :=$(call termcap,bold) ## Bold text
HI                    :=$(call termcap,smso) ## Standout (highlight)
NOHI                  :=$(call termcap,rmso) ## Remove standout
UNDERLINE             :=$(call termcap,smul) ## Underline
NOLINE                :=$(call termcap,rmul) ## Remove underline
REV                   :=$(call termcap,rev) ## Reverse video
DIM                   :=$(call termcap,dim) ## Dim text
COLOR_DETAIL          :=$(call termcap,setaf 38) ## Detail color (teal)
COLOR_DEBUG           :=$(call termcap,setaf 31) ## Debug color (red)
COLOR_INFO            :=$(call termcap,setaf 75) ## Info color (light blue)
COLOR_CHECKPOINT      :=$(call termcap,setaf 81) ## Checkpoint color (cyan)
COLOR_WARNING         :=$(call termcap,setaf 202) ## Warning color (orange)
COLOR_ERROR           :=$(call termcap,setaf 160) ## Error color (bright red)
COLOR_EXCEPTION       :=$(call termcap,setaf 124) ## Exception color (dark red)
COLOR_ALERT           :=$(call termcap,setaf 89) ## Alert color (purple)
COLOR_CRITICAL        :=$(call termcap,setaf 163) ## Critical color (magenta)

# -----------------------------------------------------------------------------
#
# RULE FUNCTIONS
#
# -----------------------------------------------------------------------------

# --
# ## Rule Pre/Post Commands

# --
# Function: rule_pre_cmd
# Pre-command hook for rules. Creates parent directories for build rules
# and logs action messages.
# Returns: Shell commands to execute before rule body

define rule_pre_cmd
	case "$@" in
		*/*)
			if [ -n "$(dir $@)" ] && [ ! -e "$(dir $@)" ]; then
				mkdir -p "$(dir $@)"
			fi
			echo "$(call fmt_action,Make $(call fmt_path,$@)) 🖫"
		;;
		*run*|*clean*)
			echo "$(call fmt_action,Does $(call fmt_rule,$@)) …"
			;;
		*)
			echo "$(call fmt_action,Make $(call fmt_rule,$@)) …"
		;;
	esac
	$(call use_env)
endef

# --
# Function: rule_post_cmd
# Post-command hook for rules. Logs completion messages.
# - FILES: Optional list of files created (for build rules)
# Returns: Shell command to execute after rule body

define rule_post_cmd
	echo "       ⤷  $(if $1,🗅 × $(words $1) : $(BOLD)$(strip $1),Made 🖸  $(BOLD)$@$(RESET) ← ($^))$(RESET)"
endef

# -----------------------------------------------------------------------------
#
# SHELL HELPERS
#
# -----------------------------------------------------------------------------

# --
# ## Validation Functions

# --
# Function: sh_check_defined
# Fails with an error if the specified variable is empty.
# - VAR: Name of variable to check
# Returns: Shell commands that exit with error if VAR is undefined

define sh_check_defined
if [ -z "$($1)" ]; then
	echo "$(call fmt_error,Variable is undefined: $1)"
	exit 1
fi
endef

# --
# Function: sh_check_exists
# Fails if PATH is undefined or does not exist.
# - PATH: Path to verify
# Returns: Shell commands that exit with error if path is missing

define sh_check_exists
if [ -z "$1" ]; then
	echo "$(call fmt_error,Variable is undefined)"
	exit 1
elif [ ! -e "$1" ]; then
	echo "$(call fmt_error,Path does not exist: $(call fmt_path,$1))"
	exit 1
fi
endef

# --
# Function: sh_install_tool
# Installs a tool from PATH into run/bin directory.
# - TOOL_PATH: Path to the tool executable
# Returns: Shell commands to create symlink in run/bin

define sh_install_tool
if [ ! -e "$1" ]; then
	echo "$(call fmt_error,Cannot install tool as it is missing: $(call fmt_path,$1))"
	exit 1
fi
if [ ! -d "run/bin" ]; then
	mkdir -p "run/bin"
fi
echo "$(call fmt_action,Installing tool $(BOLD)$(notdir $1))"
ln -sfr "$1" "run/bin/$(notdir $1)"
endef

# -----------------------------------------------------------------------------
#
# DEPENDENCY MANAGEMENT
#
# -----------------------------------------------------------------------------

# --
# ## Environment and CLI

# --
# Function: use_cmd
# Returns the command to use.
# - CMD: Command to return
# Returns: Command string

use_cmd=$1

# --
# Function: use_env
# Sets up environment variables for shell execution.
# - VARS: Variable names to export (defaults to PATH, PYTHONPATH)
# Returns: Shell export commands

use_env=$(foreach E,$(if $1,$1 $2 $3 $4 $5 $6,PATH PYTHONPATH),export $E=$(ENV_$E);)

# --
# Function: use_cli
# Generates CLI task file paths.
# - TOOLS: Names of CLI tools to check
# Returns: List of build/cli-<tool>.task paths

use_cli=$(foreach M,$1 $2 $3 $4 $5 $6 $7,build/cli-$M.task)

# -----------------------------------------------------------------------------
#
# FILE OPERATIONS
#
# -----------------------------------------------------------------------------

# --
# ## File Discovery

# --
# Function: file_find
# Finds files matching pattern within path (up to 10 levels deep).
# - PATH: Directory to search (defaults to current directory)
# - PATTERN: File pattern to match (e.g., *.py, defaults to all files)
# Returns: Space-separated list of matching files

file_find=$(wildcard $(subst SUF,$(strip $(if $2,$2,.)),$(strip $(subst PRE,$(if $1,$1,.),PRE/SUF PRE/*/SUF PRE/*/*/SUF PRE/*/*/*/SUF PRE/*/*/*/*/SUF PRE/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/*/SUF PRE/*/*/*/*/*/*/*/*/*/SUF))))

# -----------------------------------------------------------------------------
#
# SHELL EXECUTION
#
# -----------------------------------------------------------------------------

# --
# ## Command Execution

# --
# Function: shell_create_if
# Executes a command and creates a marker file on success.
# - COMMAND: The command to run
# - FAILMESSAGE: Error message if command fails (optional)
# - SUCCESS: Command to run on success (defaults to touch $@)
# - CLEANUP: Command to run on failure (defaults to removing $@)
# Returns: Shell commands with success/failure handling

define shell_create_if
	if $1; then
		$(if $3,$3,touch "$@")
	else
			echo "$(call fmt_error,$(if $2,$2,Command failed: $(subst ",',$1)))"
		$(if $4,$4,test -e "$@" && unlink "$@")
		exit 1
	fi
endef

# --
# Function: shell_try
# Executes a command and exits on failure.
# - COMMAND: The command to run
# - FAILMESSAGE: Error message if command fails (optional)
# - CLEANUP: Command to run on failure (defaults to removing $@)
# Returns: Shell commands with error handling

define shell_try
	if ! $1; then
		echo "$(call fmt_error,$(if $2,$2,Command failed: $(subst ",',$1)))"
		$(if $4,$4,test -e "$@" && unlink "$@")
		exit 1
	fi
endef

# -----------------------------------------------------------------------------
#
# LIST OPERATIONS
#
# -----------------------------------------------------------------------------

# --
# ## List Utilities

# --
# Function: uniq
# Removes duplicate elements from a list while preserving order.
# - LIST: Space-separated list
# Returns: List with duplicates removed

uniq=$(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))

# --
# Function: filter_find
# Filters list to include only items containing pattern.
# - PATTERN: String to search for
# - LIST: Space-separated list to filter
# Returns: Filtered list

filter_find=$(foreach V,$2,$(if $(findstring $1,$V),$V,,))

# --
# Function: filter_find_not
# Filters list to exclude items containing pattern.
# - PATTERN: String to search for
# - LIST: Space-separated list to filter
# Returns: Filtered list without matches

filter_find_not=$(foreach V,$2,$(if $(findstring $1,$V),,$V))

# -----------------------------------------------------------------------------
#
# FORMATTING FUNCTIONS
#
# -----------------------------------------------------------------------------

# --
# ## Output Formatting

# --
# Function: fmt_prefix
# Returns formatted prefix for log messages.
# Returns: Bold prefix string

fmt_prefix=$(BOLD)$(FMT_PREFIX)$(RESET)

# --
# Function: fmt_error
# Returns formatted error prefix.
# Returns: Error-colored prefix

fmt_error=$(COLOR_ERROR)$(FMT_PREFIX)$(RESET)

# --
# Function: fmt_warn
# Returns formatted warning message.
# - MESSAGE: Warning text to display
# Returns: Formatted warning string

fmt_warn =$(COLOR_WARNING)$(FMT_PREFIX)$(RESET) $1$(RESET)

# --
# Function: fmt_tip
# Returns formatted tip/hint message.
# - MESSAGE: Tip text to display
# Returns: Formatted tip string with arrow

fmt_tip   =$(call fmt_prefix)$(SPACE)👉   $1$(RESET)

# --
# Function: fmt_action
# Returns formatted action message.
# - MESSAGE: Action text to display
# Returns: Formatted action string with arrow

fmt_action=$(call fmt_prefix)  →  $1$(RESET)

# --
# Function: fmt_result
# Returns formatted result message.
# - MESSAGE: Result text to display
# Returns: Formatted result string with arrow

fmt_result=$(call fmt_prefix)  ←  $1$(RESET)

# --
# Function: fmt_path
# Returns formatted file path with icon.
# - PATH: File path to format
# Returns: Formatted path with directory and filename

fmt_path=🗅  $(dir $1)$(BOLD)$(notdir $1)$(RESET)

# --
# Function: fmt_module
# Returns formatted module name with icon.
# - PATH: Module path to format
# Returns: Formatted module name with directory/filename

fmt_module=🖸  $(lastword $(strip $(subst /,$(SPACE),$(dir $1))))/$(BOLD)$(notdir $1)$(RESET)

# --
# Function: fmt_rule
# Returns formatted rule name with optional icon.
# - RULE: Rule name to format
# - ICON: Optional icon (defaults to arrow)
# Returns: Formatted rule string

fmt_rule=$(if $2,$2,➳)  $(BOLD)$1$(RESET)

# EOF
