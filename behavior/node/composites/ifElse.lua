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
module "behavior.node.composites.ifElse"
------------------------------------------------------------------------------------------------------
class("cIfElse", d_ms.d_behaviorNode.cBehaviorNode)
ADD_BEHAVIAC_DYNAMIC_TYPE("cIfElse", cIfElse)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cIfElse", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- this node has three children: 'condition' branch, 'if' branch, 'else' branch. first, it executes
-- conditon, until it returns success or failure. if it returns success, it then executes 'if' branch,
-- else if it returns failure, it then executes 'else' branch.
function cIfElse:__init()
end

function cIfElse:isValid(obj, task)
    if not task:getNode() or not task:getNode():isIfElse() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end

function cIfElse:createTask()
    return d_ms.d_ifElseTask.cIfElseTask.new()
end