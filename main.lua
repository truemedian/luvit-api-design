local luvi = require('luvi')
luvi.bundle.register('import', 'deps/import.lua')

local import = require('import')

import.new("init.lua", true):import('init.lua')

require('uv').run()
