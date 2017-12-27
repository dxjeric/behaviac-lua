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
local stringUtils           = d_ms.d_behaviorCommon.stringUtils
local EOperatorType         = d_ms.d_behaviorCommon.EOperatorType
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.composites.sequence"
------------------------------------------------------------------------------------------------------
class("cSequence", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cSequence", cSequence)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSequence", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- Sequences tick each of their children one at a time from top to bottom. If a child returns Failure,
-- so does the Sequence. If it returns Success, the Sequence will move on to the next child in line
-- and return Running.If a child returns Running, so does the Sequence and that same child will be
-- ticked again next time the Sequence is ticked.Once the Sequence reaches the end of its child list,
-- it returns Success and resets its child index meaning the first child in the line will be ticked
-- on the next tick of the Sequence.
function cSequence:__init()
end

function cSequence:SequenceUpdate(obj, childStatus, outActiveChildIndex, children)
    local s = childStatus
    local childSize = #children

    while true do
        BEHAVIAC_ASSERT(activeChildIndex <= childSize, "cSequence:SequenceUpdate activeChildIndex <= childSize")
        if s == EBTStatus.BT_RUNNING then
            local pBehavior = children[activeChildIndex]
            if self:checkIfInterrupted(obj) then
                return EBTStatus.BT_FAILURE, activeChildIndex
            end

            s = pBehavior:exec(obj)
        end

        --  If the child fails, or keeps running, do the same.
        if s ~= EBTStatus.BT_SUCCESS then
            return s, activeChildIndex
        end

        --  Hit the end of the array, job done!
        activeChildIndex = activeChildIndex + 1
        if activeChildIndex > childSize then
            return EBTStatus.BT_SUCCESS, activeChildIndex
        end

        s = EBTStatus.BT_RUNNING
    end

    return s, activeChildIndex
end

function cSequence:checkIfInterrupted(obj)
    return self:evaluteCustomCondition(obj)
end

function cSequence:evaluate(obj)
    local ret = true    
    for _, child in ipairs(self.m_children) do
        ret = child:evaluate(obj)
        if not ret then
            break
        end
    end

    return ret
end

function cSequence:isValid(obj, task)
    if not task:getNode() or not task:getNode():isSelectorStochastic() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end

function cSequence:createTask()
    return d_ms.d_sequenceTask.cSequenceTask.new()
end