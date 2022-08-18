
# Luvit 3.0 API Design

[Style Guide](https://github.com/truemedian/luvit-api-design/blob/master/style.md)

The files provided here are just an idea, and only represent a potential path
that these libraries may be taken.

## Definitions

Definitions in this project are being done via [EmmyLua](https://emmylua.github.io/).
The intent here is to provide types for the entire API.

### Require

Require is being reworked for Luvit 3.0 and renamed `import` to avoid clobbering Lua's normal require functionality.

#### Short Description of `module` fields.

- `is_bundled`: Whether or not this file is inside a luvi bundle.
  - If `true`, it cannot import files on the filesystem, and will only look inside the bundle.
- If `false`, then it will first attempt to load packages from the filesystem and, if available, luvi.
- `file`: The full path for the file this module represents
- `dir`: The full path to the directory that contains this module (should always be `path.dirname(module.file)`)
- `root`: The "root" directory of this package, relative imports cannot be outside of this directory.
  - This will be equal to `project` if the module represents a file in the application.
- `project`: The "root" directory of this entire application, this is where `deps` will be.

#### Implementation

- Must be bootstrapped so that it can access `fs` and `fs.path`.
- Does not require luvi, it will error if you attempt to tell it to use a bundled file.
  - When luvi is not present, `module.is_bundled` should never be true.
- Import will attempt to load packages before relative files.
- Packages will be imported as follows (implemented in `resolvePackage`):
  - `{project}/deps/{name}.lua`
  - `{project}/deps/{name}/init.lua`
- Relative files will be imported as (implemented in `resolveRelative`):
  - `{dir}/{name}`
- Relative files are not allowed to be imported outside of `root`
- Single file packages, like `timer`, will have no `root`, and are therefore not allowed to do *any* relative imports.
- There is no way to force `import` to use the bundle or filesystem
  - Files in the bundle will only look in the bundle
  - Files on the filesystem will look on the filesystem before using the bundle, if available.
- Does not attempt to read a file until after it has found the file it will use (it uses `stat` to find a file).
- Packages must be imported without a file extension
- Relative modules must be imported with a file extension
- import.loaders.ext will be called when importing a file of any kind
  - See import.loaders.lua for an example and arguments

## Reimplementations or Reworkings

### Luvit

- [x] path
- [ ] stream
- [ ] tls
- [ ] buffer
- [x] childprocess
- [x] codec
- [x] core (as std.class and std.Emitter)
- [ ] dgram
- [ ] dns
- [x] fs
- [ ] hooks
- [x] http-codec
- [ ] http-header
- [ ] http
- [ ] https
- [ ] json
- [ ] net
- [x] pathjoin
- [x] pretty-print
- [x] process
- [x] querystring
- [ ] readline
- [ ] resource
- [ ] thread
- [x] timer
- [x] url (as uri)
- [ ] ustring
- [ ] utils

### Lit (minus duplicates)

- [ ] git
- [x] sha1
- [x] base64
- [ ] coro-channel
- [ ] coro-fs
- [ ] coro-net
- [x] coro-spawn (merged into std.ChildProcess)
- [ ] coro-split
- [ ] coro-websocket
- [ ] coro-wrapper
- [ ] md5
- [ ] prompt
- [ ] semver
- [ ] ssh-rsa
- [x] websocket-codec

### To Be Removed

- [ ] helpful: only provides string.levenshtein
- [ ] repl: too specific
- [ ] require: replace with new import
- [ ] weblit-app: needs own repo
- [ ] weblit-auto-headers: needs own repo
- [ ] weblit-router: needs own repo
- [ ] weblit-server: needs own repo
- [ ] weblit-websocket: needs own repo
- [ ] tls: replace with secure-socket
- [ ] coro-http: merge with http, https and http-header
