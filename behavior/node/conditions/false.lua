------------------------------------------------------------------------------------------------------
-- 行为树 条件节点基础类
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
local EBTStatus     = d_ms.d_behaviorCommon.EBTStatus
local EOperatorType = d_ms.d_behaviorCommon.EOperatorType
------------------------------------------------------------------------------------------------------
module "behavior.node.conditions.true"
------------------------------------------------------------------------------------------------------
class("False", d_ms.d_conditionBase.cConditionBase)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cFalse", cFalse)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cFalse", "cConditionBase")
------------------------------------------------------------------------------------------------------
-- false is a leaf node that always return Failure.
function cFalse:__init()
end

function cFalse:isValid(obj, task)
    if not task:getNode() or not task:getNode():isFalse() then
        return false
    end

    return d_ms.d_conditionBase.cConditionBase.isValid(self, obj, task)
end

function cFalse:createTask()
    return d_ms.d_falseTask.cFalseTask.new()
end