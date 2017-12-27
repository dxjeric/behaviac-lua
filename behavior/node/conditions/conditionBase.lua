------------------------------------------------------------------------------------------------------
-- 行为树 条件节点基础类
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
local EBTStatus = d_ms.d_behaviorCommon.EBTStatus
------------------------------------------------------------------------------------------------------
module "behavior.node.conditions.conditionBase"
------------------------------------------------------------------------------------------------------
class("cConditionBase", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cConditionBase", cConditionBase)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cConditionBase", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
function cConditionBase:__init()
end

function cConditionBase:isValid(obj, task)
    if not task:getNode() or not task:getNode():isConditionBase() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end