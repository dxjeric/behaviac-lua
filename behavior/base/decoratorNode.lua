------------------------------------------------------------------------------------------------------
-- 行为树 描述节点
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
module "behavior.base.decoratorNode"
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef    = d_ms.d_behaviorCommon.constBaseKeyStrDef
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
------------------------------------------------------------------------------------------------------
class("cDecoratorNode", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorNode", cDecoratorNode)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorNode", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
function cDecoratorNode:__init()
    self.m_bDecorateWhenChildEnds = false
end

function cDecoratorNode:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(version, agentType, properties)

    for _, oneProperty in ipairs(properties) do
        if oneProperty.name == "DecorateWhenChildEnds" then
            if oneProperty.value == "true" then
                self.m_bDecorateWhenChildEnds = true
            end
        else
        end
    end
end

function cDecoratorNode:isManagingChildrenAsSubTrees()
    return true
end

function cDecoratorNode:isDecoratorNode()
    return true
end

function cDecoratorNode:isValid(obj, behaviorTask)
    -- REDO: DynamicCast 这个做完之后需要回顾
    local node = behaviorTask:getNode()
    if not (node and node:isDecoratorNode()) then
        return false
    end
    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, behaviorTask)
end
