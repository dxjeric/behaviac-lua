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
local EBTStatus              = d_ms.d_behaviorCommon.EBTStatus
local BehaviorParseFactory   = d_ms.d_behaviorCommon.BehaviorParseFactory
local constInvalidChildIndex = d_ms.d_behaviorCommon.constInvalidChildIndex
------------------------------------------------------------------------------------------------------
module "behavior.node.composites.selectorProbabilityTask"
------------------------------------------------------------------------------------------------------
class("cSelectorProbabilityTask", d_ms.d_compositeTask.cCompositeTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cSelectorProbabilityTask", cSelectorProbabilityTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSelectorProbabilityTask", "cCompositeTask")
------------------------------------------------------------------------------------------------------
-- For example, if there were two children with a weight of one, each would have a 50% chance of being executed.
-- If another child with a weight of eight were added, the previous children would have a 10% chance of being executed, and the new child would have an 80% chance of being executed.
-- This weight system is intended to facilitate the fine-tuning of behaviors.

function cSelectorProbabilityTask:__init()
    self.m_totalSum     = 0
    self.m_weightingMap = {}
end

function cSelectorProbabilityTask:onEnter(obj)
    _G.BEHAVIAC_ASSERT(#self.m_children > 0, "cSelectorProbabilityTask:onEnter #self.m_children > 0")
    self.m_activeChildIndex = constInvalidChildIndex

    self.m_weightingMap = {}
    self.m_totalSum     = 0

    for _, task in ipairs(self.m_children) do
        _G.BEHAVIAC_ASSERT(task:isDecoratorWeightTask(), "cSelectorProbabilityTask:onEnter task:isDecoratorWeightTask")
        local weight = task:getWeight(obj)
        table.insert(self.m_weightingMap, weight)
        self.m_totalSum = weight
    end

    _G.BEHAVIAC_ASSERT(#self.m_weightingMap == #self.m_children, "cSelectorProbabilityTask:onEnter #self.m_weightingMap == self.m_children")
    return true
end

function cSelectorProbabilityTask:onExit(obj, status)
    self.m_activeChildIndex = constInvalidChildIndex
end

function cSelectorProbabilityTask:update(obj, childStatus)
    _G.BEHAVIAC_ASSERT(self:getNode() and self:getNode():isSelectorProbability(), "cSelectorProbabilityTask:update self:getNode():isSelectorProbability")
    if childStatus ~= EBTStatus.BT_RUNNING then
        return childStatus
    end

    local pSelectorProbabilityNode = self:getNode()
    -- check if we've already chosen a node to run
    if self.m_activeChildIndex ~= constInvalidChildIndex then
        local pNode = self.m_children[self.m_activeChildIndex]
        return pNode:exec(obj)
    end

    _G.BEHAVIAC_ASSERT(#self.m_weightingMap == #self.m_children, "cSelectorProbabilityTask:update #self.m_weightingMap == #self.m_children")
    -- generate a number between 0 and the sum of the weights
    local chosen = self.m_totalSum * d_ms.d_behaviorTreeMgr.getRandomValue(pSelectorProbabilityNode.m_method, obj)
    local sum = 0

    for i = 1, #self.m_children do
        local w = self.m_weightingMap[i]
        sum = sum + w

        if w > 0 and sum >= chosen then
            local pChild = self.m_children[i]
            local status = pChild:exec(obj)
            if status == EBTStatus.BT_RUNNING then
                self.m_activeChildIndex = i
            else
                self.m_activeChildIndex = constInvalidChildIndex
            end
            return status
        end
    end
    return EBTStatus.BT_FAILURE
end