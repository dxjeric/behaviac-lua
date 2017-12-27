------------------------------------------------------------------------------------------------------
-- 行为树 动作节点
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
module "behavior.node.actions.selectorStochasticTask"
------------------------------------------------------------------------------------------------------
class("cWithPreconditionTask", d_ms.d_sequenceTask.cSequenceTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cWithPreconditionTask", cWithPreconditionTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cWithPreconditionTask", "cSequenceTask")
------------------------------------------------------------------------------------------------------
function cWithPreconditionTask:__init()

end

function cWithPreconditionTask:preconditionNode()
    BEHAVIAC_ASSERT(#self.m_children == 2, "cWithPreconditionTask:preconditionNode #self.m_children == 2")
    return self.m_children[1]
end

function cWithPreconditionTask:actionNode()
    BEHAVIAC_ASSERT(#self.m_children == 2, "cWithPreconditionTask:actionNode #self.m_children == 2")
    return self.m_children[2]
end

function cWithPreconditionTask:onEnter(obj)
    local pParent = self:getParent()
    -- when as child of SelctorLoop, it is not ticked normally
    BEHAVIAC_ASSERT(pParent and pParent:isSelectorLoopTask(), "cWithPreconditionTask:onEnter pParent:isSelectorLoopTask")
    return true
end

function cWithPreconditionTask:onExit(obj, status)
    local pParent = self:getParent()
    -- when as child of SelctorLoop, it is not ticked normally
    BEHAVIAC_ASSERT(pParent and pParent:isSelectorLoopTask(), "cWithPreconditionTask:onExit pParent:isSelectorLoopTask")
end

function cWithPreconditionTask:updateCurrent(obj, childStatus)
    return self:update(obj, childStatus)
end

function cWithPreconditionTask:update(obj, childStatus)
    -- REDO: 因为BEHAVIAC_ASSERT(false) 这个不应该被调用
    local pParent = self.getParent()
    BEHAVIAC_ASSERT(pParent and pParent:isSelectorLoopTask(), "cWithPreconditionTask:update pParent:isSelectorLoopTask")
    BEHAVIAC_ASSERT(#self.m_children == 2, "cWithPreconditionTask:update #self.m_children == 2")
    BEHAVIAC_ASSERT(false)
    return EBTStatus.BT_RUNNING
end