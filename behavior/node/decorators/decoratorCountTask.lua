------------------------------------------------------------------------------------------------------
-- 行为树 动作节点
------------------------------------------------------------------------------------------------------
local _G            = _G
local os            = os
local xml           = xml
local next          = next
local type          = type
local class         = class
local table         = table
local print         = print
local error         = error
local pairs         = pairs
local string        = string
local assert        = assert
local ipairs        = ipairs
local rawget        = rawget
local getfenv       = getfenv
local tostring      = tostring
local setmetatable  = setmetatable
local getmetatable  = getmetatable
------------------------------------------------------------------------------------------------------
local d_ms = require "ms"
------------------------------------------------------------------------------------------------------
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.decorators.decoratorCountTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorCountTask", d_ms.d_decoratorTask.cDecoratorTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorCountTask", cDecoratorCountTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorCountTask", "cDecoratorTask")
------------------------------------------------------------------------------------------------------
function cDecoratorCountTask:__init()
    self.m_n = 0
end

function cDecoratorCountTask:copyTo(target)
    d_ms.d_decoratorTask.cDecoratorTask.copyTo(self, target)
    _G.BEHAVIAC_ASSERT(target:isDecoratorCountTask(), "cDecoratorCountTask:copyTo target:isDecoratorCountTask")
    target.m_n = self.m_n
end

function cDecoratorCountTask:getCount(obj)
    _G.BEHAVIAC_ASSERT(self:getNode() and self:getNode():isDecoratorCount(), "cDecoratorCountTask:getCount self:getNode():isDecoratorCount")
    if self:getNode() then
        return self:getNode():getCount()
    else
        return 0
    end
end

function cDecoratorCountTask:onEnter(obj)
    d_ms.d_decoratorTask.cDecoratorTask.onEnter(self)

    local count = self:getCount(obj)
    if count == 0 then
        return false
    end

    self.m_n = count
    return true
end