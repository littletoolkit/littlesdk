Some thoughts:

- Support for concurrent build, like isolating `build` per revision while allowing
  for artifact sharing.

- Ensuring that anything in `dist` has a version with it, as otherwise that breaks
  concurrent build.

- Improve the management of dependencies, especially environment variables reference
  by scripts.
