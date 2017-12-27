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
module "behavior.node.decorators.decoratorNot"
------------------------------------------------------------------------------------------------------
class("cDecoratorNot", d_ms.d_decoratorNode.cDecoratorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorNot", cDecoratorNot)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorNot", "cDecoratorNode")
------------------------------------------------------------------------------------------------------
-- Not Node inverts the return value of child. But keeping the Running value unchanged.
function cDecoratorNot:__init()
end

function cDecoratorNot:isValid(obj, task)
    if not task:getNode() or not task:getNode():isDecoratorNot() then
        return false
    end

    return d_ms.d_decoratorNode.cDecoratorNode.isValid(self, obj, task)
end

function cDecoratorNot:evaluate(obj)
    BEHAVIAC_ASSERT(#self.m_children == 1, "cDecoratorNot:evaluate #self.m_children == 1")
    return not self.m_children[1]:evaluate(obj)
end

function cDecoratorNot:createTask()
    return d_ms.d_decoratorNotTask.cDecoratorNotTask.new()
end