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
local EBTStatus              = d_ms.d_behaviorCommon.EBTStatus
local BehaviorParseFactory   = d_ms.d_behaviorCommon.BehaviorParseFactory
local constInvalidChildIndex = d_ms.d_behaviorCommon.constInvalidChildIndex
------------------------------------------------------------------------------------------------------
module "behavior.node.actions.parallelTask"
------------------------------------------------------------------------------------------------------
class("cParallelTask", d_ms.d_compositeTask.cCompositeTask)
ADD_BEHAVIAC_DYNAMIC_TYPE("cParallelTask", cParallelTask)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cParallelTask", "cCompositeTask")
------------------------------------------------------------------------------------------------------
-- Execute behaviors in parallel
-- There are two policies that control the flow of execution:
-- the policy for failure, and the policy for success.
function cParallelTask:__init()
end

function cParallelTask:onEnter(obj)
    BEHAVIAC_ASSERT(self.m_activeChildIndex == constInvalidChildIndex)
    return true
end

function cCompositeTask:onExit(obj, status)

end

function cCompositeTask:updateCurrent(obj, childStatus)
    return self:update(obj, childStatus)
end

function cCompositeTask:update(obj, childStatus)
    return self.m_node:parallelUpdate(obj, self.m_children)
end