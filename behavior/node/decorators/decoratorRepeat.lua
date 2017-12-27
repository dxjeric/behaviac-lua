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
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
local EOperatorType         = d_ms.d_behaviorCommon.EOperatorType
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.decorators.decoratorRepeat"
------------------------------------------------------------------------------------------------------
class("cDecoratorRepeat", d_ms.d_decoratorCount.cDecoratorCount)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorRepeat", cDecoratorRepeat)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorRepeat", "cDecoratorCount")
------------------------------------------------------------------------------------------------------
function cDecoratorRepeat:__init()
end

function cDecoratorRepeat:count(obj)
    return d_ms.d_decoratorCount.cDecoratorCount.getCount(self)
end

function cDecoratorRepeat:isValid(obj, task)
    if not task:getNode() or not task:getNode():isDecoratorRepeat() then
        return false
    end

    return d_ms.d_decoratorCount.cDecoratorCount.isValid(self, obj, task)
end

function cDecoratorRepeat:createTask()
    return d_ms.d_decoratorRepeatTask.cDecoratorRepeatTask.new()
end