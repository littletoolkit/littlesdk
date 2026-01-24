
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

- **Make**: Ensure `make` is installed on your system.
- **Bash**: Required for shell scripts.
- **Git**: For version control and dependency management.

### Installation

1. Clone the repository:

   ```bash
   git clone git@github.com:sebastien/littlesdk.git
   cd littlesdk
   ```

2. Install dependencies:

   ```bash
   make prep
   ```

3. Build the project:

   ```bash
   make build
   ```

### Usage

- **Build the project**:
  ```bash
  make build
  ```

- **Run the project**:
  ```bash
  make run
  ```

- **Create distributions**:
  ```bash
  make dist
  ```

- **Open a development shell**:
  ```bash
  make shell
  ```

- **View available commands**:
  ```bash
  make help
  ```

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

## Makefile Modules

### Core Modules
- **`littlesdk.mk`**: Core configuration and module loading.
- **`std/config.mk`**: Standard configuration variables.
- **`std/rules.mk`**: Standard build rules and targets.
- **`std/lib.mk`**: Standard library functions.
- **`std/colors.mk`**: Color definitions for Makefile output.

### Task-Specific Modules
- **`prep/rules.mk`**: Rules for preparing the environment.
- **`py/rules.mk`**: Python-specific build rules.
- **`js/rules.mk`**: JavaScript-specific build rules.
- **`www/rules.mk`**: Web-specific build rules.
- **`secrets/rules.mk`**: Secrets management rules.
- **`github/rules.mk`**: GitHub-specific rules.
- **`cloudflare/rules.mk`**: Cloudflare-specific rules.
- **`appdeploy/rules.mk`**: Application deployment rules.

## Shell Scripts

- **`install.sh`**: Installs dependencies and sets up the environment.
- **`std.prompt.sh`**: Configures the shell prompt for a better development experience.
- **`lib.sh`**: Library for loading shell modules dynamically.
- **`lib-colors.sh`**: Defines color variables for shell output.

## Configuration

### Environment Variables

- **`PATH_SRC`**: Directory for source files (default: `src`).
- **`PATH_RUN`**: Directory for runtime files (default: `run`).
- **`PATH_DEPS`**: Directory for dependencies (default: `deps`).
- **`PATH_BUILD`**: Directory for build artifacts (default: `build`).
- **`PATH_DIST`**: Directory for distribution files (default: `dist/package`).


