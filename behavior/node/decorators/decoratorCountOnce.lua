------------------------------------------------------------------------------------------------------
-- 行为树 条件节点基础类
------------------------------------------------------------------------------------------------------
local _G            = _G
local os            = os
local xml           = xml
local bits          = bits
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
module "behavior.node.decorators.decoratorCountOnce"
------------------------------------------------------------------------------------------------------
class("cDecoratorCountOnce", d_ms.d_decoratorCount.cDecoratorCount)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorCountOnce", cDecoratorCountOnce)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorCountOnce", "cDecoratorCount")
------------------------------------------------------------------------------------------------------
-- 只会执行节点n次(n:配置的次数)，执行一轮之后不再会被执行
function cDecoratorCountOnce:__init()
end

function cDecoratorCountOnce:checkIfReInit(obj)
    return self:evaluteCustomCondition(obj)
end

function cDecoratorCountOnce:isValid(obj, task)
    if not task:getNode() or not task:getNode():isDecoratorCountOnce() then
        return false
    end

    return d_ms.d_decoratorCount.cDecoratorCount.isValid(self, obj, task)
end

function cDecoratorCountOnce:createTask()
    return d_ms.d_decoratorCountOnceTask.cDecoratorCountOnceTask.new()
end