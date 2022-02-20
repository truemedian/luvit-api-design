
# Luvit 3.0 API Design

The files provided here are just an idea, and only represent a potential path
that these libraries may be taken. 

## Definitions

Definitions in this project are being done via [EmmyLua](https://emmylua.github.io/).
The intent here is to provide types for the entire API.

### Require

Require is being reworked for Luvit 3.0.

However, to keep this repository simple for EmmyLua to handle: requires should use `.` separators and use the repository root as the base.

For example: `/std/fs/path.lua` is required with `require 'std.fs.path'`. 

