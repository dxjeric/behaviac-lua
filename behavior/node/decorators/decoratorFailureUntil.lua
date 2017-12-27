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
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
local EOperatorType         = d_ms.d_behaviorCommon.EOperatorType
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.decorators.decoratorFailureUntil"
------------------------------------------------------------------------------------------------------
class("cDecoratorFailureUntil", d_ms.d_decoratorCount.cDecoratorCount)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorFailureUntil", cDecoratorFailureUntil)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorFailureUntil", "cDecoratorCount")
------------------------------------------------------------------------------------------------------
-- UntilFailureUntil node always return Failure until it reaches a specified number of count.
-- when reach time exceed the count specified return Success. If the specified number of count
-- is -1, then always return failed
function cDecoratorFailureUntil:__init()
end

function cDecoratorFailureUntil:isValid(obj, task)
    if not task:getNode() or not task:getNode():isDecoratorFailureUntil() then
        return false
    end

    return d_ms.d_decoratorCount.cDecoratorCount.isValid(self, obj, task)
end

function cDecoratorFailureUntil:createTask()
    return d_ms.d_decoratorFailureUntilTask.cDecoratorFailureUntilTask.new()
end