The goal is to create an extensible build system that uses primarily `make`
and `bash` and support modern workflows, from local development for homelabs to
hybrid cloud deployments for the enteprise.

Some of the key goals are:

- Language agnostic: this should work for any language as long as it has
  CLI tooling for automation.

- Extensible: it should be easy to extend the build system, either by
  contributing modules, or locally in your project by adding specialised
  modules.

- Mostly Reproducible: try to be as reproducible and deterministic as possible,
  so that build artifacts are stable given the same inputs.

- Self-contained: the prerequisite should be a few common UNIX CLIs and a
  POSIX system, so that developers can do `make run` on fresh clone and
  be up and running.

- Local & CI: you should be able to run everything on your local machine
  and perform the very same tasks and get the very same outputs on CI
  with ease.

- Discoverable: it should be easy to see what you can do, and if commands
  fail, it should be easy to recover or know what to do next.

Project structure:

- `src/$LANG/*` contains the sources by language
- `build` where the build system will create build outputs
- `dist` where the build system will place distribution outputs
- `run` where runtime files will be installed

The build system will generate files in the following paths:

- `build/$COMPONENT/$COMPONENT_REVISION/*` to store build artifacts for the
   given revision of the components.
- `dist/$REVISION/*` to store distribution artifacts for the given
   revision of the project.
- `run/bin` to alias CLI binaries to be used
- `run/{share,man,lib}` local supporting files
- `run/$COMPONENT/*` per-component runtimefiles (eg. `postgres`, `bun`, etc)

The build system defines the following phases:

- `prep(-*)` (`PREP_*`) for preparing the environment, such as installing and
  configuring dependencies, obtaining credentials, etc.
- `run(-*)` (`RUN_*`) for running components and supporting services.
- `test(-*)` (`TEST_*`) for testing components and supporting services.
- `build(-*)` (`BUILD_*`) for building components and artifacts
- `package(-*)` (`PACKAGE_*`) for packaging artifacts together
- `dist(-*)` (`DIST_*`) for distributing packages and artifacts
- `(de)provision(-*)` for provisioning resources (on-prem, cloud)
- `(un)deploy(`-*)` for deploying components and services

Typically the workflow is like so (← denoting dependencies)

```
prep ← build ← run
       build ← test
       # Noting here that test may be a prerequisit to distribution
       build ← package ← (test) ← dist
       # Noting here that some artifacts may be built post-provisioning
                                  dist  ← provision ← (build) ← deploy
                                                                deploy ← undeploy ← deprovision
```
