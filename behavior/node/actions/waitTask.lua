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
module "behavior.node.actions.waitTask"
------------------------------------------------------------------------------------------------------
class("cWaitTask", d_ms.d_leafTask.cLeafTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cWaitTask", cWaitTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cWaitTask", "cLeafTask")
------------------------------------------------------------------------------------------------------
function cWaitTask:__init()
    self.m_start    = 0
    self.m_time     = 0
    self.m_intStart = 0
    self.m_intTime  = 0
end

function cWaitTask:copyTo(target)
    d_ms.d_leafTask.cLeafTask.copyTo(target)

    _G.BEHAVIAC_ASSERT(target:isWaitTask(), "cWaitTask:copyTo target:isWaitTask")
    target.m_start      = self.m_start
    target.m_time       = self.m_time
    target.m_intStart   = self.m_intStart
    target.m_intTime    = self.m_intTime
end

function cWaitTask:save(ioNode)
    d_ms.d_log.error("cWaitTask:save")
end

function cWaitTask:load(ioNode)
    d_ms.d_log.error("cWaitTask:load")
end

function cWaitTask:onEnter(obj)
    if d_ms.d_behaviorTreeMgr.getUseIntValue() then
        self.m_intStart = redoGetIntValueSinceStartup()
        self.m_intTime  = self:getIntTime(obj)
        if self.m_intTime <= 0 then
            return false
        end
    else
        self.m_start = GetDoubleValueSinceStartup()
        self.m_time  = self:getTime(obj)
        if self.m_time <= 0 then
            return false
        end
    end
    return true
end

function cWaitTask:onExit(obj, status)
end

function cWaitTask:update(obj, childStatus)
    if d_ms.d_behaviorTreeMgr.getUseIntValue() then
        if redoGetIntValueSinceStartup() - self.m_intStart >= self.m_intTime then
            return EBTStatus.BT_SUCCESS
        end
    else
        if GetDoubleValueSinceStartup() - self.m_start >= self.m_time then
            return EBTStatus.BT_SUCCESS
        end
    end
    return EBTStatus.BT_RUNNING
end

function cWaitTask:getTime(obj)
    local pWaitNode = self:getNode()

    if pWaitNode then
        return pWaitNode:getTime(obj)
    else
        return 0
    end
end

function cWaitTask:getIntTime(obj)
    local pWaitNode = self:getNode()

    if pWaitNode then
        return pWaitNode:getIntTime(obj)
    else
        return 0
    end
end