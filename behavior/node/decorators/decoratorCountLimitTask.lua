------------------------------------------------------------------------------------------------------
-- 行为树 动作节点
------------------------------------------------------------------------------------------------------
local _G            = _G
local os            = os
local xml           = xml
local next          = next
local type          = type
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
module "behavior.node.decorators.decoratorCountLimitTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorCountLimitTask", d_ms.d_decoratorCountTask.cDecoratorCountTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorCountLimitTask", cDecoratorCountLimitTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorCountLimitTask", "cDecoratorCountTask")
------------------------------------------------------------------------------------------------------
function cDecoratorCountLimitTask:__init()
    self.m_bInited = false
end

function cDecoratorCountLimitTask:copyTo(target)
    d_ms.d_decoratorCountTask.cDecoratorCountTask.copyTo(self, target)
    BEHAVIAC_ASSERT(target:isDecoratorCountLimitTask(), "cDecoratorCountLimitTask:copyTo target:isDecoratorCountLimitTask")

    target.m_bInited = self.m_bInited
end

function cDecoratorCountLimitTask:save(IONode)
end

function cDecoratorCountLimitTask:load(IONode)
end

function cDecoratorCountLimitTask:onEnter(obj)
    if self.m_node:checkIfReInit(obj) then
        self.m_bInited = false
    end

    if not self.m_bInited then
        self.m_bInited = true
        local count = self:getCount(obj)
        self.m_n = count
    end

    -- if self.m_n is -1, it is endless
    if self.m_n > 0 then
        self.m_n = self.m_n - 1
        return true
    elseif self.m_n == 0 then
        return false
    elseif self.m_n == -1 then
        return true
    end
    BEHAVIAC_ASSERT(false, "cDecoratorCountLimitTask:onEnter false")
    return false
end

function cDecoratorCountLimitTask:decorate(status)
    EHAVIAC_ASSERT(self.m_n >= 0 or self.m_n == -1, "cDecoratorCountLimitTask:decorate self.m_n >= 0 or self.m_n == -1")
    return status
end