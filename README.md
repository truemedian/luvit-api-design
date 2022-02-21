
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

## Reimplmentations or Reworkings

### Luvit

- [x] path
- [ ] stream
- [ ] tls
- [ ] buffer
- [ ] childprocess
- [ ] codec
- [ ] core
- [ ] dgram
- [ ] dns
- [x] fs
- [ ] hooks
- [ ] http-codec
- [ ] http-header
- [ ] http
- [ ] https
- [ ] json
- [ ] net
- [x] pathjoin
- [ ] pretty-print
- [x] process
- [x] querystring
- [ ] readline
- [ ] resource
- [ ] thread
- [x] timer
- [x] url
- [ ] ustring
- [ ] utils

### Lit (minus duplicates)

- [ ] git
- [ ] sha1
- [ ] base64
- [ ] coro-channel
- [ ] coro-fs
- [ ] coro-net
- [ ] coro-spawn
- [ ] coro-split
- [ ] coro-websocket
- [ ] coro-wrapper
- [ ] md5
- [ ] prompt
- [ ] semver
- [ ] ssh-rsa
- [ ] websocket-codec

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
