------------------------------------------------------------------------------------------------------
-- 行为树 动作节点
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
local string        = string
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
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.decorators.decoratorWeightTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorWeightTask", d_ms.d_decoratorTask.cDecoratorTask)
ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorWeightTask", cDecoratorWeightTask)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorWeightTask", "cDecoratorTask")
------------------------------------------------------------------------------------------------------
function cDecoratorWeightTask:__init()
end

function cDecoratorWeightTask:getWeight(obj)
    BEHAVIAC_ASSERT(self:getNode() and self:getNode():isDecoratorWeight(), "cDecoratorWeightTask:getWeight self:getNode():isDecoratorWeight")
    return self:getNode():getWeight(obj)
end

function cDecoratorWeightTask:decorate(status)
    return status
end

function cDecoratorWeightTask:save(IONode)
    d_ms.d_log.error("cDecoratorWeightTask:save")
end

function cDecoratorWeightTask:load(IONode)
    d_ms.d_log.error("cDecoratorWeightTask:load")
end