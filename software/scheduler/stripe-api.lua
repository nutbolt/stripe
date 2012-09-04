-- Client interface code to push RPC calls over ZeroMQ using bencoded strings.

require 'zmq'
require 'bencode'
require 'serialization'

-- configuration
local PORT = 'tcp://127.0.0.1:9384'
local DEBUG = false

local M = {} -- public module interface

function M.apiVers () return {0,1} end

function M.apiDebug (flag) DEBUG = flag end

-- connect to the server/dispatcher via its known port
local context = zmq.init(1)
M.socket = context:socket(zmq.REQ)
M.socket:connect(PORT)

-- set up special behavior to capture all module accesses as function calls
-- this allows proxying "stripe.abc(...)" with arbitrary "abc" names and args
local mt = {}
setmetatable(M, mt)

-- translate a "stripe.abc(1,2,3)" call into a {'stripe',1,2,3} RPC request
function mt:__index(name, ...)
  return function (context, ...)
    local s = context.socket
    if DEBUG then print(serialization.serialize({name, ...})) end
    s:send(bencode.encode({name, ...})) -- send out as bencoded request
    local reply = bencode.decode(s:recv()) -- and wait for the bencoded reply
    if reply[1] == 0 then return reply[2] end
    return false, reply[2] -- use standard Lua convention for returning errors
  end
end

return M
