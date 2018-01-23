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
module "behavior.node.decorators.decoratorEveryTimeTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorEveryTimeTask", d_ms.d_decoratorTimeTask.cDecoratorTimeTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorEveryTimeTask", cDecoratorEveryTimeTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorEveryTimeTask", "cDecoratorTimeTask")
------------------------------------------------------------------------------------------------------
function cDecoratorEveryTimeTask:__init()
    self.m_start    = 0
    self.m_time     = 0
    self.m_intStart = 0
    self.m_intTime  = 0
    self.m_bInited  = false
end

function cDecoratorEveryTimeTask:save(IONode)
    d_ms.d_log.error("cDecoratorEveryTimeTask:save")
end

function cDecoratorEveryTimeTask:load(IONode)
    d_ms.d_log.error("cDecoratorEveryTimeTask:load")
end

function cDecoratorEveryTimeTask:copyTo(target)
    d_ms.d_decoratorTimeTask.cDecoratorTimeTask.copyTo(self, target)
    _G.BEHAVIAC_ASSERT(target:isDecoratorEveryTimeTask(), "cDecoratorEveryTimeTask:copyTo target:isDecoratorEveryTimeTask")
    target.m_start      = self.m_start
    target.m_time       = self.m_time
    target.m_intStart   = self.m_intStart
    target.m_intTime    = self.m_intTime
end

function cDecoratorEveryTimeTask:checkTime(obj)
    local bUseIntValue = d_ms.d_behaviorTreeMgr.getUseIntValue()    
    if bUseIntValue then
        local time = _G.redoGetIntValueSinceStartup()
        if time - self.m_intStart >= self.m_intTime then
            self.m_intStart = time
            return true
        end
    else
        local time = _G.redoGetDoubleValueSinceStartup()
        if time - self.m_start >= self.m_time then
            self.m_start = time
            return true
        end
    end
    return false
end

function cDecoratorEveryTimeTask:decorate(status)
    return status
end

function cDecoratorEveryTimeTask:onEnter(obj)
    if self.m_bInited then
        if self.m_status == EBTStatus.BT_RUNNING then
            return true
        else
        return self:checkTime(obj)
        end
    end

    if d_ms.d_decoratorTimeTask.cDecoratorTimeTask.onEnter(self, obj) then
        self.m_bInited = true
        return self:checkTime(obj)
    else
        return false
    end
end

function cDecoratorEveryTimeTask:getTime(obj)
    _G.BEHAVIAC_ASSERT(self:getNode() and self:getNode():isDecoratorEveryTime(), "cDecoratorEveryTimeTask:getTime self:getNode():isDecoratorEveryTime")
    return self:getNode():getTime(obj)
end

function cDecoratorEveryTimeTask:getIntTime(obj)
    _G.BEHAVIAC_ASSERT(self:getNode() and self:getNode():isDecoratorEveryTime(), "cDecoratorEveryTimeTask:getTime self:getNode():isDecoratorEveryTime")
    return self:getNode():getIntTime(obj)
end