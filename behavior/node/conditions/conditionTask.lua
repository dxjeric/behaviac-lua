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
module "behavior.node.conditions.conditionBaseTask"
------------------------------------------------------------------------------------------------------
class("cConditionTask", d_ms.d_conditionBaseTask.cConditionBaseTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cConditionTask", cConditionTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cConditionTask", "cConditionBaseTask")
------------------------------------------------------------------------------------------------------
function cConditionTask:__init()
end

function cConditionTask:onEnter(obj)
    return true
end

function cConditionTask:onExit(obj, status)
end

function cConditionTask:update(obj, childStatus)
    _G.BEHAVIAC_ASSERT(self:getNode():isCondition(), "cConditionTask:update self:getNode():isCondition")

    local pConditionNode = self:getNode()
    if pConditionNode:evaluate(obj) then
        return EBTStatus.BT_SUCCESS
    else
        return EBTStatus.BT_FAILURE
    end
end