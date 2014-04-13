--[[ Datastream 2.0
    Provides backwards compatibility for code using the old Datastream 1.0 module
    DEVELOPERS SHOULD NOT USE THIS MODULE; USE THE NET LIBRARY DIRECTLY INSTEAD.
    
    Copyright (c) 2011 Declan White
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

pcall(require, "netx") -- remove this when Garry gets net.*Table working properly (or if I never release netx)
pcall(require, "glon") -- only needed if your code uses the "encdata" argument of its callbacks (and there's no reason it should)

module("datastream", package.seeall)

local hackyglon_meta = {
    __index = function(self, k)
        -- if they call string.sub(enc, ...) rather than enc:sub(...), we're DOOMED! http://youtu.be/w7RIgs3eygo
        -- Unless we override the string.* functions... heh.. heh heh
        local string_f = string[k]
        if string_f then
            return function(self, ...)
                local res = {pcall(string_f, tostring(self), ...)} -- the name says it all!
                if table.remove(res, 1) then
                    return unpack(res)
                else
                    error(res[1], 2)
                end
            end
        end
    end,
    __tostring = function(self)
        local enc = rawget(self, "enc")
        if not enc then
            local worked
            worked, enc = pcall(glon.encode, rawget(self, "dec"))
            rawset(self, "enc", worked and enc or nil)
        end
        return enc
    end,
    __concat = function(a, b)
        return tostring(a)..tostring(b)
    end,
}
--setmetatable(hackyglon_meta, {__index = string}) -- if the developer uses string.__index.. too bad!

if SERVER then
    function Hook(name, callback, dont_confirm)
        net.Receive("$DS_"..name, function(len, ply)
            local id = net.ReadByte()
            if not dont_confirm then
                net.Start("$DSC_"..name)
                    net.WriteByte(id)
                    --net.WriteByte(len)
                net.Send(ply)
            end
            local data = net.ReadTable()
            callback(
                name,
                id,
                setmetatable({dec = data, enc = nil}, hackyglon_meta), -- let's hope no one actually uses this variable (the hack will probably fail!)
                data
            )
        end)
    end
    
    _operation_count = 0
    function StreamToClients(audience, name, data, callback)
        local audience_type = type(audience)
        if audience_type == "CRecipientFilter" then
            error("CRecipientFilters are no longer supported by datastream.", 2)
        elseif not (audience_type == "table" or audience_type == "Player") then
            error("bad argument #1 to 'datastream.StreamToClients' (table or Player expected, got "..audience_type..")", 2)
        end
        _operation_count = (_operation_count+1)%256
        net.Start("$DS_"..name)
            net.WriteByte(_operation_count) -- this isn't really needed
            net.WriteTable(data)
        net.Send(audience)
        if callback then
            callback(_operation_count)
        end
    end
    
    function _R.Player:SendData(name, data, callback)
        StreamToClients(self, name, data, callback)
    end
    
elseif CLIENT then
    function Hook(name, callback)
        net.Receive("$DS_"..name, function(len)
            local id, data = net.ReadByte(), net.ReadTable()
            callback(
                name,
                id,
                setmetatable({dec = dat, enc = nil}, hackyglon_meta),
                data
            )
        end)
    end
    
    _operations = {}
    function StreamToServer(name, data, callback, accept_callback)
        if accept_callback then
            accept_callback(true, _operation_count, _operation_count) -- let's just assume
        end
        local callbacks, id = _operations[name]
        if not callbacks then
            callbacks = {}
            net.Receive("$DSC_"..name, function(len)
                local id = net.ReadByte()
                local callback = table.remove(callbacks, id)
                if callback then callback(id) end
            end)
            _operations[name] = callbacks
            id = 0
        else
            id = (#callbacks+1)%256 -- if you're sending more than 256 streams at once: you're doing it wrong
        end
        callbacks[id] = callback
        net.Start("$DS_"..name)
            net.WriteByte(id)
            net.WriteTable(data)
        net.SendToServer()
    end
end

function DownstreamActive()
    --return "probably"
    return net.Incoming() -- does this function do what I think it does?
end
function GetProgress(id)
    return 9001
end
