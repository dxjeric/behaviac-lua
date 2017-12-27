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
class("cConditionBaseTask", d_ms.d_leafTask.cLeafTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cConditionBaseTask", cConditionBaseTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cConditionBaseTask", "cLeafTask")
------------------------------------------------------------------------------------------------------
function cConditionBaseTask:__init()
end

function cConditionBaseTask:onEnter(obj)
    return true
end

function cConditionBaseTask:onExit(obj, status)
end

function cConditionBaseTask:update(obj, childStatus)
    return EBTStatus.BT_SUCCESS
end
