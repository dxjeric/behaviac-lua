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
local State                  = d_ms.d_behaviorCommon.State
local EBTStatus              = d_ms.d_behaviorCommon.EBTStatus
local BehaviorParseFactory   = d_ms.d_behaviorCommon.BehaviorParseFactory
local constInvalidChildIndex = d_ms.d_behaviorCommon.constInvalidChildIndex
------------------------------------------------------------------------------------------------------
module "behavior.node.actions.parallelTask"
------------------------------------------------------------------------------------------------------
class("cReferencedBehaviorTask", d_ms.d_singeChildTask.cSingeChildTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cReferencedBehaviorTask", cReferencedBehaviorTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cReferencedBehaviorTask", "cSingeChildTask")
------------------------------------------------------------------------------------------------------
function cReferencedBehaviorTask:__init()
    self.m_nextStateId  = -1
    self.m_subTree      = false
end

function cReferencedBehaviorTask:onEvent(obj, eventName, eventParams)
    if self.m_status == EBTStatus.BT_RUNNING and self.m_node:hasEvents() then
        BEHAVIAC_ASSERT(self.m_subTree, "cReferencedBehaviorTask:onEvent self.m_subTree")

        if not self.m_subTree:onEvent(pAgent, eventName, eventParams) then
            return false
        end
    end

    return true
end

function cReferencedBehaviorTask:onEnter(obj)
    BEHAVIAC_ASSERT(self.m_node and self.m_node:isReferencedBehavior(), "cReferencedBehaviorTask:onEnter self.m_node:isReferencedBehavior")
    self.m_nextStateId = -1
    local szTreePath = self.m_node:getReferencedTree(obj)
    
    -- to create the task on demand
    if szTreePath and (not self.m_subTree or stringUtils.compare(szTreePath, self.m_subTree:getName(), true)) then
        if self.m_subTree then
            d_ms.d_behaviorTreeMgr.destroyBehaviorTreeTask(self.m_subTree, obj)
        end
        self.m_subTree = d_ms.d_behaviorTreeMgr.createBehaviorTreeTask(szTreePath)
        self.m_node:setTaskParams(obj, self.m_subTree)
    elseif self.m_subTree then
        self.m_subTree:reset(obj)
    end
    return true
end

function cReferencedBehaviorTask:onExit(obj, status)
end

function cReferencedBehaviorTask:getNextStateId()
    return self.m_nextStateId
end

function cReferencedBehaviorTask:checkPreconditions(obj, bIsAlive)
    return d_ms.behaviorTask.cBehaviorTask.checkPreconditions(self, obj, bIsAlive);
end

function cReferencedBehaviorTask:update(obj, childStatus)
    BEHAVIAC_ASSERT(self:getNode() and self:getNode():isReferencedBehavior(), "cReferencedBehaviorTask:update self:getNode():isReferencedBehavior")
    local result = self.m_subTree:exec(obj)
    local bTransitioned, nextStateId = State.updateTransitions(obj, self.m_node, self.m_node.m_transitions, self.m_nextStateId, result)
    self.m_nextStateId = nextStateId

    if bTransitioned then
        if result == EBTStatus.BT_RUNNING then
            -- subtree not exited, but it will transition to other states
            self.m_subTree:abort(obj)
        end

        result = EBTStatus.BT_SUCCESS
    end

    return result
end