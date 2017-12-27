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
module "behavior.node.conditions.and"
------------------------------------------------------------------------------------------------------
class("cAnd", d_ms.d_conditionBase.cConditionBase)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cAnd", cAnd)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cAnd", "cConditionBase")
------------------------------------------------------------------------------------------------------
-- Boolean arithmetical operation &&
function cAnd:__init()
end

function cAnd:isValid(obj, task)
    if not task:getNode() or not task:getNode():isAnd() then
        return false
    end

    return d_ms.d_conditionBase.cConditionBase.isValid(self, obj, task)
end

function cAnd:evaluate(obj)
    local ret = true
    for _, child in ipairs(self.m_children) do
        ret = child:evaluate(obj)
        if not ret then
            break
        end
    end

    return ret
end

function cAnd:createTask()
    return d_ms.d_andTask.cAndTask.new()
end