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
module "behavior.node.decorators.decoratorCountLimit"
------------------------------------------------------------------------------------------------------
class("cDecoratorCountLimit", d_ms.d_decoratorCount.cDecoratorCount)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorCountLimit", cDecoratorCountLimit)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorCountLimit", "cDecoratorCount")
------------------------------------------------------------------------------------------------------
-- DecoratorCountLimit can be set a integer Count limit value. DecoratorCountLimit node tick its child until
-- inner count less equal than count limit value. Whether node increase inner count depend on
-- the return value of its child when it updates. if DecorateChildEnds flag is true, node increase count
-- only when its child node return value is Success or Failure. The inner count will never reset until
-- attachment on the node evaluate true.
function cDecoratorCountLimit:__init()
end

function cDecoratorCountLimit:checkIfReInit(obj)
    return self:evaluteCustomCondition(obj)
end

function cDecoratorCountLimit:isValid(obj, task)
    if not task:getNode() or not task:getNode():isDecoratorCountLimit() then
        return false
    end

    return d_ms.d_decoratorCount.cDecoratorCount.isValid(self, obj, task)
end

function cDecoratorCountLimit:createTask()
    return d_ms.d_decoratorCountLimitTask.cDecoratorCountLimitTask.new()
end