# Design

The overall design of the build system is based on the following principles:

- Clean: we make sure to capture all (or most of) the inputs needed
  to create something, so that we avoid dirty builds, where previous build
  artifacts are reused instead of new ones.

- Reproducible: we want to make sure that we get the same results given the
  same outputs, which translates into avoiding using timestamps in any build
  artifact.

- Parallelizable: we want to make sure that you can safely run builds in paralell
  without one build overwrite or contaminating the other.

- Relatively fast: let's not kid ourselves, we're using the shell as the main
  language for automation, which definitely has a performance cost, but we can
  leverage make to reuse as much work as possible and speed things up overall.

- Discoverable: it should be easy to discover the build system features, and
  to support it we need to be able to generate information that can be
  consumed by an LLM and help users/developers.

## Modules

The build system is based on modules, where each module is a directory
with a set of makefiles:

- `$MODULE/config.mk` defines variables (and their defaults) used by the module.
  Some of these variables may be user-overridable, while some others may be
  derived. It is important to document the user-overridable variables as they
  define the parameter space (outside of the source files) for the module.

- `$MODULE/lib.mk` defines constants and function that then become part of the
  Makefile library. This file typically is of interest for developers who
  write new build system rules and modules. Documentation should focus on
  what the functions are, illustrating with use cases.

- `$MODULE/rules.mk` defines the tasks and build rules offered by the module.
  Tasks are typically `.PHONY`, although they may contain a stem, and build rules
  would most likely contain a `/` in them as most build artifacts are placed
  in one of the main paths.

