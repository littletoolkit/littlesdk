---
name: review-sh
description: Review and update shell script documentation following LittleSDK conventions.
---

## What I do

Review and update shell script documentation, ensuring clarity, consistency, and compliance with LittleSDK conventions. I check for:

- Proper shebang (`#!/usr/bin/env bash`)
- Section delimiters with separator lines (`# -----------------------------------------------------------------------------`)
- Function documentation using `function name { }` syntax
- Variable documentation with inline comments
- Proper color/logging library usage
- Library loading patterns for modular scripts
- Proper EOF marker at file end

## When to use me

- After writing or modifying a shell script
- When adding new functions or variables
- When refactoring script logic
- Before committing shell script changes
- When you need to ensure consistent documentation style across shell scripts

## Principles

- Be concise and direct
- Assume technical competence (documentation is a reference, not a tutorial)
- Use examples to illustrate usage for complex functions
- Use fenced code blocks for all examples
- Follow LittleSDK conventions from AGENTS.md
- Prefer `function name { }` syntax over `name() { }`

## Documentation Format

LittleSDK shell script conventions with markdown support.

### File Template

```bash
#!/usr/bin/env bash

# -----------------------------------------------------------------------------
#
# SECTION
#
# -----------------------------------------------------------------------------

# File: Description
# Brief description of what this file/module does

# Variable documentation
VARIABLE_NAME="value"  # Brief description

# -----------------------------------------------------------------------------
#
# FUNCTIONS
#
# -----------------------------------------------------------------------------

# Function: function_name ARG1 ARG2…
# Description of what the function does and its parameters
function function_name {
	# function body using $1, $2, etc.
}

# Function: another_function
# Another function with more detail.
# - arg1: Description of first argument
# - arg2: Description of second argument
# Returns: Description of return value or output
function another_function {
	local arg1="$1"
	local arg2="$2"
	# implementation
}

# EOF
```

### Rules

- **Shebang**: Always use `#!/usr/bin/env bash` as first line
- **Variables**: Use snake_case, document with inline comments using `#`
- **Section delimiters**: Use `# -----------------------------------------------------------------------------` separators with `# SECTION` headers
- **File header**: Use `# File: Description` at top of major sections
- **Functions**: Use `function name { }` syntax (not `name() { }`), document with `# Function: name ARGS…`
- **Parameters**: Document function parameters inline or with bullet points using `- param:`
- **Local variables**: Use `local` keyword within functions
- **Library loading**: Use `sdk_lib_load module_name` pattern for modular scripts
- **Color support**: Respect `NOCOLOR` environment variable, export color variables
- **Logging**: Use `log_action`, `log_message`, `log_error`, etc. from lib-log
- **EOF marker**: Files end with explicit `# EOF` comment

### Examples

```bash
#!/usr/bin/env bash

# -----------------------------------------------------------------------------
#
# COLORS
#
# -----------------------------------------------------------------------------

# File: Color definitions
# Provides ANSI color codes for terminal output

if [ -z "${NOCOLOR:-}" ]; then
	RED="$(tput setaf 124)"
	GREEN="$(tput setaf 34)"
	BOLD="$(tput bold)"
	RESET="$(tput sgr0)"
else
	RED=""
	GREEN=""
	BOLD=""
	RESET=""
fi
export RED GREEN BOLD RESET

# -----------------------------------------------------------------------------
#
# LOGGING
#
# -----------------------------------------------------------------------------

# Function: log_action ARG…
# Logs an action to stderr with an arrow prefix
function log_action {
	echo " → $@${RESET}" >&2
}

# Function: log_error ARG…
# Logs an error message with red coloring
function log_error {
	echo "${RED}ERR ${BOLD}$*${RESET}" >&2
}

# -----------------------------------------------------------------------------
#
# FILE OPERATIONS
#
# -----------------------------------------------------------------------------

# Function: ensure_dir PATH
# Creates directory if it doesn't exist.
# - PATH: Directory path to create
# Returns: 0 on success, 1 on failure
function ensure_dir {
	local path="$1"
	if [ ! -d "$path" ]; then
		if ! mkdir -p "$path"; then
			log_error "Failed to create directory: $path"
			return 1
		fi
	fi
	return 0
}

# EOF
```

### Library Usage

For modular scripts using the LittleSDK library system:

```bash
#!/usr/bin/env bash

# Load library modules
SDK_LIB_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SDK_LIB_PATH/lib.sh"

# Load required modules
sdk_lib_load colors log

# Now use loaded functions
log_action "Starting script"
log_error "Something went wrong"

# EOF
```
