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
class("cSequenceStochastic", d_ms.d_compositeStochastic.cCompositeStochastic)
ADD_BEHAVIAC_DYNAMIC_TYPE("cSequenceStochastic", cSequenceStochastic)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSequenceStochastic", "cCompositeStochastic")
------------------------------------------------------------------------------------------------------
-- SequenceStochastic tick each of their children in a random order. If a child returns Failure,
-- so does the Sequence. If it returns Success, the Sequence will move on to the next child in line
-- and return Running.If a child returns Running, so does the Sequence and that same child will be
-- ticked again next time the Sequence is ticked.Once the Sequence reaches the end of its child list,
-- it returns Success and resets its child index – meaning the first child in the line will be ticked
-- on the next tick of the Sequence.
function cSequenceStochastic:__init()
end

function cSequenceStochastic:checkIfInterrupted(obj)
    return self:evaluteCustomCondition(obj)
end

function cSequenceStochastic:isValid(obj, task)
    if not task:getNode() or not task:getNode():isSequenceStochastic() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end

function cSequenceStochastic:createTask()
    return d_ms.d_sequenceStochastic.cSequenceStochastic.new()
end