
```
 __    _ _   _   _     _____ ____  _____
|  |  |_| |_| |_| |___|   __|    \|  |  |
|  |__| |  _|  _| | -_|__   |  |  |    -|
|_____|_|_| |_| |_|___|_____|____/|__|__|

```


*LittleSDK* is a lightweight and modular SDK that can be used as the baseline
to build, run, test, package, deploy and release projects across multiple
languages.

LittleSDK primarily relies on Make and Bash run, and is designed to be easily
extensible thanks to its modular and documented approach.

## Features

- **Modular Makefile System**: Organized into reusable modules for different tasks (e.g., `std`, `py`, `js`, `www`).
- **Shell Utilities**: Scripts for environment setup, prompt customization, and dependency management.
- **Consistent Project Structure**: Clear conventions for organizing source files, build outputs, and distributions.
- **Extensible**: Easy to add new modules or customize existing ones.
- **Multi-Language Support**: Built-in support for Python, JavaScript/TypeScript, and web assets.
- **Cloud Integrations**: Ready-to-use integrations for GitHub, Cloudflare, and secrets management.

## Getting Started

### Quickstart

Crate the following `Makefile`

```
#  LittleSDK Bootstrapping
SDK_PATH=deps/sdk
include $(if $(SDK_PATH),$(shell test ! -e "$(SDK_PATH)/setup.mk" && git clone git@github.com:littletoolkit/littlesdk.git "$(SDK_PATH)";echo "$(SDK_PATH)/setup.mk"))
# EOF -- vim: ft=make
```

and type `make prep`

### Prerequisites

- `gmake` (GNU make, 4.4+)
- `coreutils` (GNU)
- `bash`: Required for shell scripts.
- `git`: For version control and dependency management.

### Installation

```bash
# Clone
mkdir -p deps/sdk
git clone git@github.com:littletoolkit/littlesdk.git deps/sdk
# Copy the template
cp deps/sdk/Makefile.template Makefile
# Get started
make help
```

### Usage

- Prepare: `make prep`
- Build: `make build`
- Run: `make run`
- Shell: `make shell`
- Check: `make check`
- Format: `make fmt`
- Test: `make test`
- Distribute: `make dist`
- Package: `make dist-package`


## Project Structure

```
src/
├── mk/                  # Makefile modules
│   ├── littlesdk.mk      # Core module loader
│   ├── littlesdk/        # Module definitions
│   │   ├── std/          # Standard library (core functions)
│   │   ├── py/           # Python support
│   │   ├── js/           # JavaScript/TypeScript support
│   │   ├── www/          # Web assets (HTML/CSS)
│   │   ├── secrets/      # Secrets management
│   │   ├── mise/         # Mise tool manager
│   │   ├── github/       # GitHub integration
│   │   ├── cloudflare/   # Cloudflare integration
│   │   └── appdeploy/    # Application deployment
│   └── ...
└── sh/                  # Shell scripts
    ├── install.sh        # Dependency installation
    ├── std.prompt.sh     # Shell prompt configuration
    ├── lib.sh            # Library for loading modules
    └── lib-colors.sh     # Color definitions
```

## Modules

### Core
- **`std`** — Standard library providing core functions, build lifecycle, and utilities
  - Build phases: `prep`, `build`, `check`, `test`, `dist`, `clean`
  - Utility functions: file operations, formatting, shell helpers
  - Terminal colors and output formatting

### Languages
- **`py`** — Python project support
  - Linting with ruff, type checking, security auditing with bandit
  - Testing with pytest
  - Package management with pip/uv

- **`js`** — JavaScript/TypeScript support (Bun/Node)
  - Linting with Biome, type checking with TypeScript
  - Testing with Bun test runner
  - Bundle creation for production
  - Standalone server compilation

- **`www`** — Web asset processing
  - HTML validation and tidying
  - CSS-in-JS compilation
  - XML/XSLT transformations
  - Static file distribution

### Integrations
- **`secrets`** — Secrets management via LittleSecrets
  - Export secrets as environment variables
  - Integration with secret stores

- **`github`** — GitHub dependency management
  - Clone and install dependencies from GitHub repositories
  - Automatic linking of binaries and Python packages

- **`cloudflare`** — Cloudflare deployment
  - Wrangler CLI integration
  - Cloudflare Pages deployment
  - Local development server

- **`mise`** — Mise-En-Place (formerly rtx) integration
  - Tool version management
  - Automatic tool installation

- **`appdeploy`** — Application deployment utilities
  - Shell script deployment
  - Environment setup scripts

## Build Lifecycle

LittleSDK uses a phased build system:

1. **`prep`** — Prepare dependencies and environment
2. **`build`** — Compile and build all outputs
3. **`check`** — Run linters, audits, and checks
4. **`fix`** — Auto-fix formatting and linting issues
5. **`test`** — Run all tests
6. **`run`** — Run the project locally
7. **`dist`** — Create distribution packages
8. **`clean`** — Remove build artifacts

## Configuration

### Path Variables
- `PATH_SRC`: Directory for source files (default: `src`).
- `PATH_RUN`: Directory for runtime files (default: `run`).
- `PATH_DEPS`: Directory for dependencies (default: `deps`).
- `PATH_BUILD`: Directory for build artifacts (default: `build`).
- `PATH_DIST`: Directory for distribution files (default: `dist/package`).

### Phase Variables
- `PREP_ALL`: Dependencies to prepare before building
- `BUILD_ALL`: Files to build
- `CHECK_ALL`: Checks to run
- `FIX_ALL`: Auto-fixes to apply
- `TEST_ALL`: Test targets
- `RUN_ALL`: Runtime dependencies
- `DIST_ALL`: Distribution files


