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
class("cTrue", d_ms.d_conditionBase.cConditionBase)
ADD_BEHAVIAC_DYNAMIC_TYPE("cTrue", cTrue)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cTrue", "cConditionBase")
------------------------------------------------------------------------------------------------------
-- True is a leaf node that always return Success.
function cTrue:__init()
end

function cTrue:isValid(obj, task)
    if not task:getNode() or not task:getNode():isTrue() then
        return false
    end

    return d_ms.d_conditionBase.cConditionBase.isValid(self, obj, task)
end

function cTrue:createTask()
    return d_ms.d_trueTask.cTrueTask.new()
end