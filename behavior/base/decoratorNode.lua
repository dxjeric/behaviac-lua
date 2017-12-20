------------------------------------------------------------------------------------------------------
-- 行为树 描述节点
------------------------------------------------------------------------------------------------------
local d_ms = {}
d_ms.d_behaviorNode    = require "base.behaviorNode"
d_ms.d_event           = require "attachments.event"
d_ms.d_behaviorCommon  = require "base.behaviorCommon"
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef = d_behaviorCommon.constBaseKeyStrDef
------------------------------------------------------------------------------------------------------
class("cDecoratorNode", d_ms.d_behaviorNode.cBehaviorNode)
ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorNode", cDecoratorNode)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorNode", "cBehaviorNode")
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
