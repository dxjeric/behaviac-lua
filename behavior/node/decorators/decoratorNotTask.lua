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
module "behavior.node.decorators.decoratorNotTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorNotTask", d_ms.d_decoratorTask.cDecoratorTask)
ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorNotTask", cDecoratorNotTask)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorNotTask", "cDecoratorTask")
------------------------------------------------------------------------------------------------------
function cDecoratorNotTask:__init()
end

function cDecoratorNotTask:save()
    d_ms.d_log.error("cDecoratorNotTask:save")
end

function cDecoratorNotTask:load()
    d_ms.d_log.error("cDecoratorNotTask:load")
end

function cDecoratorNotTask:decorate(status)
    if status == EBTStatus.BT_FAILURE then
        return EBTStatus.BT_SUCCESS
    end

    if status == EBTStatus.BT_SUCCESS then
        return EBTStatus.BT_FAILURE
    end

    return status
end