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
module "behavior.node.decorators.decoratorTimeTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorTimeTask", d_ms.d_decoratorTask.cDecoratorTask)
ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorTimeTask", cDecoratorTimeTask)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorTimeTask", "cDecoratorTask")
------------------------------------------------------------------------------------------------------
function cDecoratorTimeTask:__init()
    self.m_start    = 0
    self.m_time     = 0
    self.m_intStart = 0
    self.m_intTime  = 0
end

function cDecoratorTimeTask:save(IONode)
    d_ms.d_log.error("cDecoratorTimeTask:save")
end

function cDecoratorTimeTask:load(IONode)
    d_ms.d_log.error("cDecoratorTimeTask:load")
end

function cDecoratorTimeTask:copyTo(target)
    d_ms.d_decoratorTask.cDecoratorTask.copyTo(self, target)
    BEHAVIAC_ASSERT(target:isDecoratorTimeTask(), "cDecoratorTimeTask:copyTo target:isDecoratorTimeTask")
    target.m_start      = self.m_start
    target.m_time       = self.m_time
    target.m_intStart   = self.m_intStart
    target.m_intTime    = self.m_intTime
end

function cDecoratorTimeTask:onEnter(obj)
    d_ms.d_decoratorTask.cDecoratorTask.onEnter(self, obj)

    local bUseIntValue = d_ms.d_behaviorTreeMgr.getUseIntValue()
    if bUseIntValue then
        self.m_intStart = redoGetIntValueSinceStartup()
        self.m_intTime = self:getIntTime(obj)

        if self.m_intTime <= 0 then
            return false
        end
    else
        self.m_start = redoGetDoubleValueSinceStartup()
        self.m_time = self:getTime(obj)

        if self.m_time <= 0 then
            return false
        end
    end
    return true
end

function cDecoratorTimeTask:decorate(status)
    local bUseIntValue = d_ms.d_behaviorTreeMgr.getUseIntValue()
    
    if bUseIntValue then
        local time = redoGetIntValueSinceStartup()
        if time - self.m_intStart >= self.m_intTime then
            return EBTStatus.BT_SUCCESS
        end
    else
        local time = redoGetDoubleValueSinceStartup()

        if time - self.m_start >= self.m_time then
            return EBTStatus.BT_SUCCESS
        end
    end

    return EBTStatus.BT_RUNNING
end

function cDecoratorTimeTask:getTime(obj)
    BEHAVIAC_ASSERT(self.getNode() and self:getNode():isDecoratorTime(), "cDecoratorTimeTask:getTime self:getNode():isDecoratorTime")
    return self.getNode():getTime(obj)
end

function cDecoratorTimeTask:getIntTime(obj)
    BEHAVIAC_ASSERT(self.getNode() and self:getNode():isDecoratorTime(), "cDecoratorTimeTask:getTime self:getNode():isDecoratorTime")
    return self.getNode():getIntTime(obj)
end