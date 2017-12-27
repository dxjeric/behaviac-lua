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
module "behavior.node.actions.waitForSignalTask"
------------------------------------------------------------------------------------------------------
class("cWaitForSignalTask", d_ms.d_leafTask.cLeafTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cWaitForSignalTask", cWaitForSignalTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cWaitForSignalTask", "cLeafTask")
------------------------------------------------------------------------------------------------------
function cWaitForSignalTask:__init()
    self.m_bTriggered = false
end

function cWaitForSignalTask:copyTo(target)
    d_ms.d_leafTask.cLeafTask.copyTo(target)
    BEHAVIAC_ASSERT(target:isWaitforSignalTask(), "cWaitForSignalTask:copyTo target:isWaitforSignalTask")
    target.m_bTriggered = self.m_bTriggered
end

function cWaitForSignalTask:save(target)
    d_ms.d_log.error("cWaitForSignalTask:save")
end

function cWaitForSignalTask:load(target)
    d_ms.d_log.error("cWaitForSignalTask:load")
end

function cWaitForSignalTask:onEnter(obj)
    self.m_bTriggered = false
    return true
end

function cWaitForSignalTask:onExit(obj)
end

function cWaitForSignalTask:update(obj, childStatus)
    if childStatus ~= EBTStatus.BT_RUNNING then
        return childStatus
    end

    if not self.m_bTriggered then
        self.m_bTriggered = self.m_node:checkIfSignaled(obj)
    end

    if self.m_bTriggered then
        if not self.m_root then
            return EBTStatus.BT_SUCCESS
        end
        return d_ms.d_leafTask.cLeafTask.update(obj, childStatus)
    end

    return EBTStatus.BT_RUNNING
end