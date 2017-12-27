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
local EBTStatus     = d_ms.d_behaviorCommon.EBTStatus
local EOperatorType = d_ms.d_behaviorCommon.EOperatorType
------------------------------------------------------------------------------------------------------
module "behavior.node.conditions.or"
------------------------------------------------------------------------------------------------------
class("cOr", d_ms.d_conditionBase.cConditionBase)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cOr", cOr)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cOr", "cConditionBase")
------------------------------------------------------------------------------------------------------
-- Boolean arithmetical operation ||
function cOr:__init()
end

function cOr:isValid(obj, task)
    if not task:getNode() or not task:getNode():isOr() then
        return false
    end

    return d_ms.d_conditionBase.cConditionBase.isValid(self, obj, task)
end

function cOr:evaluate(obj)
    local ret = true
    for _, child in ipairs(self.m_children) do
        ret = child:evaluate(obj)
        if ret then
            break
        end
    end

    return ret
end

function cOr:createTask()
    return d_ms.d_orTask.cOrTask.new()
end