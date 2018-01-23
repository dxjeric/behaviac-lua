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
module "behavior.node.decorators.decoratorCountOnceTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorCountOnceTask", d_ms.d_decoratorCountTask.cDecoratorCountTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorCountOnceTask", cDecoratorCountOnceTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorCountOnceTask", "cDecoratorCountTask")
------------------------------------------------------------------------------------------------------
function cDecoratorCountOnceTask:__init()
    self.m_bInited  = false
    self.m_bRunOnce = false
end

function cDecoratorCountOnceTask:copyTo(target)
    d_ms.d_decoratorCountTask.cDecoratorCountTask.copyTo(self, target)
    _G.BEHAVIAC_ASSERT(target:isDecoratorCountOnceTask(), "cDecoratorCountOnceTask:copyTo target:isDecoratorCountOnceTask")

    target.m_bInited = self.m_bInited
end

function cDecoratorCountOnceTask:save(IONode)
end

function cDecoratorCountOnceTask:load(IONode)
end

function cDecoratorCountOnceTask:onEnter(obj)
    if self.m_bRunOnce then
        return false
    end

    if self.m_status == EBTStatus.BT_RUNNING then
        return true
    end
    if self.m_node:checkIfReInit(obj) then
        self.m_bInited = false
    end

    if not self.m_bInited then
        self.m_bInited = true
        local count = self:getCount(obj)
        self.m_n = count
        _G.BEHAVIAC_ASSERT(self.m_n > 0, "cDecoratorCountOnceTask:onEnter false self.m_n > 0")
    end

    -- if self.m_n is -1, it is endless
    if self.m_n > 0 then
        self.m_n = self.m_n - 1
        return true
    elseif self.m_n == 0 then
        self.m_bRunOnce = true
        return false
    elseif self.m_n == -1 then
        self.m_bRunOnce = true
        return true
    end
    _G.BEHAVIAC_ASSERT(false, "cDecoratorCountOnceTask:onEnter false")
    return false
end

function cDecoratorCountOnceTask:decorate(status)
    _G.BEHAVIAC_ASSERT(self.m_n >= 0 or self.m_n == -1, "cDecoratorCountOnceTask:decorate self.m_n >= 0 or self.m_n == -1")
    return status
end