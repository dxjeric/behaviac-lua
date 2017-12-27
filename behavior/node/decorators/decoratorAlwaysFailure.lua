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
module "behavior.node.decorators.decoratorAlwaysFailure"
------------------------------------------------------------------------------------------------------
class("cDecoratorAlwaysFailure", d_ms.d_decoratorNode.cDecoratorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorAlwaysFailure", cDecoratorAlwaysFailure)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorAlwaysFailure", "cDecoratorNode")
------------------------------------------------------------------------------------------------------
-- No matter what child return. DecoratorAlwaysFailure always return Failure. it can only has one child node.
function cDecoratorAlwaysFailure:__init()

end

function cDecoratorAlwaysFailure:isValid(obj, task)
    if not task:getNode() or not task:getNode():isDecoratorAlwaysFailure() then
        return false
    end

    return d_ms.d_decoratorNode.cDecoratorNode.isValid(self, obj, task)
end

function cDecoratorAlwaysFailure:createTask()
    return d_ms.d_decoratorAlwaysFailureTask.cDecoratorAlwaysFailureTask.new()
end