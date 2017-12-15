require('LuaXML')

local __t_pirnt = false
local function _printValue(name, value, subCount, tab)
    name = tostring(name)
    if name == "__class" or name == "_M" or name == "_PACKAGE" then return end 

    if type(value) == "number" then
        print(tab .. name, "=", value)
    elseif type(value) == "string" then
        print(tab .. name, "=", "\"" .. value .. "\"")
    elseif type(value) == "table" then
        if not __t_pirnt[value] then
            __t_pirnt[value] = true
        else
            -- 已经打印过了
            print(tab .. name, "=", value)
            return
        end 
        print(tab .. name, "=", value)
        if subCount == 0 then
            return
        end 

        if subCount < 0 or subCount >= 1 then
            subCount = subCount - 1 
            print(tab .. "{")
            for id, v in pairs(value) do
                _printValue(id, v, subCount, tab .. '\t')
            end 
            print(tab .. "}")
        end 
    elseif type(value) == "boolean" then
        print(tab .. name, "=", tostring(value))
    elseif type(value) == "userdata" then
        print(tab .. name, "=", tostring(value))
    else
        print(tab .. name, "=", tostring(value))
    end
end

function printValue(name, value, subCount)
    if not subCount then subCount = -1 end
    local tab = ""
    __t_pirnt = {}

    print("[".. os.date("%x %X"), "passtime =", os.time(), "]")
    _printValue(name, value, subCount, tab)
end

-- load XML data from file "test.xml" into local table xfile
local xfile = xml.load("test.xml")
-- for k, v in pairs(xfile) do
--     print("len", k, #v)
--     printValue(k, v)
-- end



toTable(xfile)