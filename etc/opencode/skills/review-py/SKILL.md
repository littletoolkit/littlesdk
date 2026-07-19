---
name: review-py
description: Review and update Python module documentation using concise inline docs and markdown examples.
---

## What I do

Review and update Python module documentation for this codebase, ensuring clarity, consistency, and completeness. I check for:

- Compliance with code conventions
- Clear module-level context and concise public API documentation
- Brief docstrings for public methods and functions
- Parameter names embedded with backticks in descriptive text
- Accurate type references aligned with type hints and dataclass fields
- Appropriate examples for factory functions and complex APIs

## When to use me

- After writing or modifying a Python module's public API
- When adding new functions, classes, dataclasses, or exceptions
- When refactoring code that changes behavior, signatures, or return types
- Before committing documentation updates to Python modules
- When you need consistent documentation style across Python modules

## Principles

- Be concise and direct
- Assume technical competence (reference-first, not tutorial-first)
- Explain module concepts once at module level, then keep API docs focused
- Keep docs synchronized with actual signatures and type hints
- Prefer concrete behavior notes over implementation trivia
- Use fenced code blocks for all examples
- Follow AGENTS.md conventions, including trailing `# EOF` in source files

## Code Conventions

- `lowercase` for module names
- `UPPERCASE` for globals and constants
- `PascalCase` for classes and singletons
- `snake_case` for functions, methods, parameters and local variables
- `_` prefix to denote private/protected

## Documentation Format

Python module documentation with concise docstrings and markdown examples.

### File Template

```python
"""Module: {{module_name}} — {{short module overview and key concepts}}."""

from __future__ import annotations

from dataclasses import dataclass

# -----------------------------------------------------------------------------
#
# DEFINITIONS
#
# -----------------------------------------------------------------------------

# NOTE: Types first


@dataclass(slots=True)
class {{TypeName}}:
	"""{{Short purpose statement.}}"""

	{{field_name}}: {{FieldType}}


# NOTE: Then constants, singletons
{{CONST_NAME}} = {{value}}


# -----------------------------------------------------------------------------
#
# OPERATIONS
#
# -----------------------------------------------------------------------------

def {{function_name}}({{arg}}: {{ArgType}}) -> {{ReturnType}}:
	"""{{Behavior with embedded parameter like `arg`.}}"""
	...


# -----------------------------------------------------------------------------
#
# API
#
# -----------------------------------------------------------------------------

# NOTE: This is your high-level API/operations
class {{ClassName}}:
	"""{{Short purpose statement.}}"""

	def {{method_name}}(self, {{arg}}: {{ArgType}}) -> {{ReturnType}}:
		"""{{Behavior with embedded parameter like `arg`.}}"""
		...


# EOF
```

### Rules

- **Module docs**: Start each module with a short docstring describing scope and key concepts
- **Future annotations**: Start modules with `from __future__ import annotations`
- **Structure**: Group code as `DEFINITIONS`, `OPERATIONS` then `API` using section delimiters
- **Docstrings**: Public functions, methods, classes, and exceptions have brief, behavior-focused docstrings
- **Parameters**: Mention parameters inline using backticks (for example, `path`, `timeout`, `headers`)
- **Types**: Keep wording aligned with annotations; document optional/default behavior explicitly
- **Dataclasses**: Document intent and meaningful fields; mention constraints or units when needed
- **Imports**: Prefer package-relative imports within a package (for example, `from .model import Service`)
- **Examples**: Required for factory functions and complex APIs; optional for simple helpers
- **Formatting**: Tabs for indentation, concise comments
- **File ending**: Source files end with explicit `# EOF`

### Examples

```python
"""Module: routing — HTTP route registration and dispatch helpers."""

from __future__ import annotations

from dataclasses import dataclass

# -----------------------------------------------------------------------------
#
# DEFINITIONS
#
# -----------------------------------------------------------------------------

# NOTE: Types first


@dataclass(slots=True)
class Route:
	"""Represents a compiled route pattern and its handler binding."""

	method: str
	path: str


# -----------------------------------------------------------------------------
#
# OPERATIONS
#
# -----------------------------------------------------------------------------

def create_dispatcher(routes: list[Route]) -> Dispatcher:
	"""Factory that builds a dispatcher from `routes`."""
	return Dispatcher(routes)


# -----------------------------------------------------------------------------
#
# API
#
# -----------------------------------------------------------------------------

class Dispatcher:
	"""Matches incoming requests to registered routes."""

	def dispatch(self, method: str, path: str):
		"""Returns a route match for `method` and `path`, if any."""
		...


# EOF
```
