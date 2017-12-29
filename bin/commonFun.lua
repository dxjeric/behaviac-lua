-------------------------------------------------------------------------------------------------------------
local _G            = _G
local os            = os
local xml           = xml
local next          = next
local type          = type
local table         = table
local print         = print
local error         = error
local pairs         = pairs
local assert        = assert
local ipairs        = ipairs
local rawget        = rawget
local getfenv       = getfenv
local tostring      = tostring
local setmetatable  = setmetatable
local getmetatable  = getmetatable
-------------------------------------------------------------------------------------------------------------
require "luaXML"
local xml   = xml
-------------------------------------------------------------------------------------------------------------
function isLinux()
    return false
end

function isTest()
    return true
end
-------------------------------------------------------------------------------------------------------------
-- REDO: 需要替换
function redoGetIntValueSinceStartup()
    return os.time()
end

function redoGetDoubleValueSinceStartup()
    return os.clock()
end

function redoGetFrameSinceStartup()
    return os.time()
end

function table.copy(t)
    local r = t
    
    return r
end
-------------------------------------------------------------------------------------------------------------
bits = {}
function bits.bitAnd(a, b)
    if b ~= 0xf or b ~= 0xff or b ~= 0xfff or b ~= 0xffff or b ~= 0xfffff or b ~= 0xffffff or b ~= 0xfffffff or b ~= 0xfffffff then
    else
        print("bits.bitAnd error b must be 0xff", b)
    end
    return a%(b+1)
end
-------------------------------------------------------------------------------------------------------------
module "commonFun"
-------------------------------------------------------------------------------------------------------------
-- 打印数据
-- name     : 打印数据的名字
-- value    : 要打印的数据
-- subCount : 子表打印层次
-- tab      : 分割符
-------------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------------
-- 方便集成到内网
-------------------------------------------------------------------------------------------------------------
-- 局部函数 : access_deny，输出访问拒绝消息，可以用作元表的__index、__newindex字段
-- 参数     : obj，一个由class的new方法创建的对象
--            field_name，字符串，访问字段名
--            field_value，任意类型，要设置的字段值
-- 返回值   : 无
local function access_deny(obj, field_name, field_value)
    error("the class '" .. obj.__class.__fullname .. "' has no field '" .. field_name .. "'.")
end
-------------------------------------------------------------------------------------------------------------
-- 局部函数 : super_classes，返回一个class的所有super class列表
-- 参数     : class，由class方法创建的class对象
-- 返回值   : 数组，所有super class对象，
local function super_classes(class)
    local super_classes = {}

    local super = class.__super
    while super do
        table.insert(super_classes, super)
        super = super.__super
    end 

    return super_classes
end
------------------------------------------------------------------------------------------------------------
-- 局部函数 : derive_function，对象继承它的类中的所有函数,
--            在对象的table中加入所有class的函数，包括所有基类的函数
-- 参数     : object，由class的new方法创建的对象
--            class，创建object的class
-- 返回值   : nil
local function derive_function(object, class)
    for k, v in pairs(class) do
        if type(v) == "function" and rawget(object, k) == nil and k ~= "new" and k ~= "__init" then
            object[k] = v
        end
    end

    local supers = super_classes(class)
    for i=1, #supers do
        for k, v in pairs(supers[i]) do
            if type(v) == "function" and rawget(object, k) == nil and k ~= "new" and k ~= "__init" then
                object[k] = v
            end
        end
    end
end
-------------------------------------------------------------------------------------------------------------
-- 局部函数 : derive_variable, 对象继承它的类中的所有变量,
--            依次运行所有基类的__init函数, 从最上层的类开始
-- 参数     : object，由class的new方法创建的对象
--            class，创建object的class
-- 返回值   ：nil
local function derive_variable(object, class, ...)
    local supers = super_classes(class)
    for i=#supers, 1, -1 do
        supers[i].__init(object, ...)
    end

    class.__init(object, ...)
end
-------------------------------------------------------------------------------------------------------------
-- 输出函数 ：class，定义一个类，并将该类加入调用此函数的函数的环境中
-- 参数     ：class_name，字符串
--            super，基类，必须也是一个由class创建的类对象
-- 返回值   : nil
function _G.class(class_name, super, heavy)
    local new_class = {}
    new_class.__name = class_name
    new_class.__super = super

    if super then
        setmetatable(new_class, { __index = super })
    end
    new_class.new = function (...)
                        local object = {__release = false}
                        if heavy then
                            derive_function(object, new_class)
                        end
                        object.__class = new_class
                        setmetatable(object, { __index = new_class })
                        derive_variable(object, new_class, ...)
                        local mt = getmetatable(object)
                        mt.__newindex = access_deny
                        if _G.isTest() then
                            local testMt = {
                                __index     = object,
                                __newindex  = function(t, k, v)
                                    if k == "m_status" and not v then
                                        assert(false, "status is nil")
                                    else
                                        object[k] = v
                                    end
                                end
                            }
                            return setmetatable({}, testMt)
                        else
                            return object
                        end
                    end

    new_class.super = function(self) return self.__super end
    local env = getfenv(2)
    if env._NAME then
        new_class.__fullname = env._NAME .. "." .. class_name
    else
        new_class.__fullname = class_name
    end
    env[class_name] = new_class
end
-------------------------------------------------------------------------------------------------------------
-- <behavior name="player" agenttype="CBTPlayer" version="5">
-- <pars>
--   <par name="CurStep" type="int" value="0" />
--   <par name="CurStep1" type="int" value="1" />
-- </pars>
-- </behavior>
-- {
--         attrs   =       table: 0043B968
--         {
--                 agenttype       =       "CBTPlayer"
--                 version =       "5"
--                 name    =       "player"
--         }
--         data    =       table: 0043B8C8
--         {
--                 1       =       table: 0043B8F0
--                 {
--                         data    =       table: 0043B940
--                         {
--                                 1       =       table: 0043B918
--                                 {
--                                         attrs   =       table: 0043B990
--                                         {
--                                                 value   =       "0"
--                                                 type    =       "int"
--                                                 name    =       "CurStep"
--                                         }
--                                         nodeName        =       "par"
--                                 }
--                                 2       =       table: 0043B918
--                                 {
--                                         attrs   =       table: 0043B990
--                                         {
--                                                 value   =       "1"
--                                                 type    =       "int"
--                                                 name    =       "CurStep1"
--                                         }
--                                         nodeName        =       "par"
--                                 }
--                         }
--                         nodeName        =       "pars"
--                 }
--         }
--         nodeName        =       "behavior"
-- }

local mt = {}
function mt:getAttrValue(attrName)
    if self.attrs then
        return self.attrs[attrName]
    else
        return nil
    end
end

function mt:getFirstAttr()
    if self.attrs then
        return next(self.attrs)
    else
        return nil
    end
end

function mt:getNodeName()
    return self.nodeName
end

function mt:getNodeData()
    return self.data
end

function mt:getFirstNodeData()
    if self.data then
        return self.data[1]
    end
    return nil
end

function mt:getChildeByName(childeName)
    if self.data then
        return self.data[childeName]
    end
    return nil    
end

function transferXmlNode(nodeData, key)
    assert(nodeData[0], "node kye = ("..key..") data not name")
    local nodeName = nodeData[0]
    nodeData[0] = nil

    local ret = setmetatable({nodeName = nodeName}, {__index = mt})
    local len = #nodeData

    for k = 1, len do
        if not ret.data then
            ret.data = {}
        end
        local childe = transferXmlNode(nodeData[k], nodeName.."["..k.."]")
        table.insert(ret.data, childe)
        
        local childeName = childe:getNodeName()
        if not ret.data[childeName] then
            ret.data[childeName] = {}
        end
        table.insert(ret.data[childeName], childe)
        nodeData[k] = nil
    end

    for k, v in pairs(nodeData) do
        if not ret.attrs then
            ret.attrs = {}
        end
        ret.attrs[k] = v
    end
    return ret
end

function loadXml(xmlPath)
    local xmlSrouceData = xml.load(xmlPath)
    local root = setmetatable({nodeName = "root"}, {__index = mt})
    local ret = transferXmlNode(xmlSrouceData, xmlPath.."= root")
    root.data = {
        [1]                 = ret,
        [ret:getNodeName()] = ret
    }
    
    return root
end