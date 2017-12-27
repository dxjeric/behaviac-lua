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
module "behavior.node.composites.selectorStochastic"
------------------------------------------------------------------------------------------------------
class("cSelectorStochastic", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cSelectorStochastic", cSelectorStochastic)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSelectorStochastic", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- the Selector runs the children from the first sequentially until the child which returns success.
-- for SelectorStochastic, the children are not sequentially selected, instead it is selected stochasticly.
-- for example: the children might be [0, 1, 2, 3, 4]
-- Selector always select the child by the order of 0, 1, 2, 3, 4
-- while SelectorStochastic, sometime, it is [4, 2, 0, 1, 3], sometime, it is [2, 3, 0, 4, 1], etc.

function cSelectorStochastic:__init()
end

function cSelectorStochastic:isValid(obj, task)
    if not task:getNode() or not task:getNode():isSelectorStochastic() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end

function cSelectorStochastic:checkIfInterrupted(obj)
    return self:evaluteCustomCondition(obj)
end

function cSelectorStochastic:createTask()
    return d_ms.d_selectorStochasticTask.cSelectorStochasticTask.new()
end