# Bash Convention

Follow this template:

```
#!/usr/bin/env bash
# File: {name}
# {description}

set -euo pipefail

readonly MYSCRIPT_REQUIRES=("jq" "socat")

# -----------------------------------------------------------------------------
#
# CONFIGURATION
#
# -----------------------------------------------------------------------------

MYSCRIPT_{VAR}=…              # Configuration variables

# -----------------------------------------------------------------------------
#
# STATE
#
# -----------------------------------------------------------------------------

myscript_${VAR}=…             # Internal variables

# -----------------------------------------------------------------------------
#
# FUNCTIONS
#
# -----------------------------------------------------------------------------

# Function: myscript_function
# description
# arg -- description
myscript_function() {
  …
}

# -----------------------------------------------------------------------------
#
# MAIN
#
# -----------------------------------------------------------------------------

function myscript_main() {
}

myscript_main()

# EOF
```

Naming:
- Always prefix functions and variables with a module name
- Configuration variables are UPPER_CASE, should provide defaults
- Functions are `lower_case`

Writing:
- Follow structure (imports, config, functions, main)
- Document in Natural Docs, short and compact style
- Comment when using tricks or using hardcoded values
- Prefer long names for options

Behaviour:
- Always check for dependencies
- Encapsulate operations in functions
- When passing sensitive/secret data, do not leak through proc or env.
