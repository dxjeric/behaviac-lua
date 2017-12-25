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
module "behavior.node.decorators.decoratorSuccessUntil"
------------------------------------------------------------------------------------------------------
class("cDecoratorSuccessUntil", d_ms.d_decoratorCount.cDecoratorCount)
ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorSuccessUntil", cDecoratorSuccessUntil)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorSuccessUntil", "cDecoratorCount")
------------------------------------------------------------------------------------------------------
-- UntilFailureUntil node always return Success until it reaches a specified number of count.
-- when reach time exceed the count specified return Failure. If the specified number of count
-- is -1, then always return Success.
function cDecoratorSuccessUntil:__init()
end

function cDecoratorSuccessUntil:isValid(obj, task)
    if not task:getNode() or not task:getNode():isDecoratorSuccessUntil() then
        return false
    end

    return d_ms.d_decoratorCount.cDecoratorCount.isValid(self, obj, task)
end

function cDecoratorSuccessUntil:createTask()
    return d_ms.d_decoratorSuccessUntilTask.cDecoratorSuccessUntilTask.new()
end