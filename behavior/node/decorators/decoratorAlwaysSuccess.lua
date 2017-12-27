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
module "behavior.node.decorators.decoratorAlwaysSuccess"
------------------------------------------------------------------------------------------------------
class("cDecoratorAlwaysSuccess", d_ms.d_decoratorNode.cDecoratorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorAlwaysSuccess", cDecoratorAlwaysSuccess)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorAlwaysSuccess", "cDecoratorNode")
------------------------------------------------------------------------------------------------------
-- No matter what child return. DecoratorAlwaysSuccess always return Success. it can only has one child node.
function cDecoratorAlwaysSuccess:__init()

end

function cDecoratorAlwaysSuccess:isValid(obj, task)
    if not task:getNode() or not task:getNode():isDecoratorAlwaysSuccess() then
        return false
    end

    return d_ms.d_decoratorNode.cDecoratorNode.isValid(self, obj, task)
end

function cDecoratorAlwaysSuccess:createTask()
    return d_ms.d_decoratorAlwaysSuccessTask.cDecoratorAlwaysSuccessTask.new()
end