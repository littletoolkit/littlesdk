
```
 __    _ _   _   _     _____ ____  _____
|  |  |_| |_| |_| |___|   __|    \|  |  |
|  |__| |  _|  _| | -_|__   |  |  |    -|
|_____|_|_| |_| |_|___|_____|____/|__|__|

```


*LittleSDK* is a lightweight and modular SDK for building and managing projects efficiently.
## Overview

LittleSDK provides a structured approach to project management, offering a set of tools and conventions to streamline development workflows. It includes Makefile modules for various tasks, shell scripts for environment setup, and a clear project structure to ensure consistency and maintainability.

## Features

- **Modular Makefile System**: Organized into reusable modules for different tasks (e.g., `std`, `prep`, `py`, `js`).
- **Shell Utilities**: Scripts for environment setup, prompt customization, and dependency management.
- **Consistent Project Structure**: Clear conventions for organizing source files, build outputs, and distributions.
- **Extensible**: Easy to add new modules or customize existing ones.

## Getting Started

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
cp deps/sdk/Makefile.template .
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
│   ├── littlesdk.mk      # Core configuration
│   ├── std/              # Standard rules and configurations
│   ├── prep/             # Preparation rules
│   ├── py/               # Python-specific rules
│   ├── js/               # JavaScript-specific rules
│   └── ...
└── sh/                  # Shell scripts
    ├── install.sh        # Dependency installation
    ├── std.prompt.sh     # Shell prompt configuration
    ├── lib.sh            # Library for loading modules
    └── lib-colors.sh     # Color definitions
```

## Modules

Core:
- `std`, core functions and lifecycle

 Languages:
- `py`, python support
- `js`, JavaScript (Node, Bun) support
- `www`, HTML/CSS static files

Integrations:
- `secrets`, LittleSecrets integration
- `github`, GitHub Integration
- `cloudflare`, CloudFlare integration
- `appdeploy`, AppDeploy integration
- `mise`, Mise-En-Place integration

## Configuration

- `PATH_SRC`: Directory for source files (default: `src`).
- `PATH_RUN`: Directory for runtime files (default: `run`).
- `PATH_DEPS`: Directory for dependencies (default: `deps`).
- `PATH_BUILD`: Directory for build artifacts (default: `build`).
- `PATH_DIST`: Directory for distribution files (default: `dist/package`).


