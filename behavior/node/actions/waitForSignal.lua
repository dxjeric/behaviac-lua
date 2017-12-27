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
module "behavior.node.actions.waitForSignal"
------------------------------------------------------------------------------------------------------
class("cWaitForSignal", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cWaitForSignal", cWaitForSignal)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cWaitForSignal", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- Always return Running until the predicates of WaitforSignal node become true,
-- or executing child node and return execution result.
function cWaitForSignal:__init()
end

function cWaitForSignal:isValid(obj, task)
    if not task:getNode() or not task:getNode():isWaitForSignal() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end

function cWaitForSignal:checkIfSignaled(obj)
    return self:evaluteCustomCondition(obj)
end

function cWaitForSignal:createTask()
    return d_ms.d_waitForSignalTask.cWaitForSignalTask.new()
end