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
class("cWithPrecondition", d_ms.d_behaviorNode.cBehaviorNode)
ADD_BEHAVIAC_DYNAMIC_TYPE("cWithPrecondition", cWithPrecondition)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cWithPrecondition", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- WithPrecondition is the precondition of SelectorLoop child. must be used in conjunction with SelectorLoop.
-- WithPrecondition can return SUCCESS or FAILURE. child would execute when it returns SUCCESS, or not.
function cWithPrecondition:__init()

end

function cWithPrecondition:isValid(obj, task)
    if not task:getNode() or not task:getNode():isWithPrecondition() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end

function cWithPrecondition:createTask()
    return d_ms.d_withPrecondition.cWithPrecondition.new()
end