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
module "behavior.node.composites.sequenceTask"
------------------------------------------------------------------------------------------------------
class("cSequenceTask", d_ms.d_compositeTask.cCompositeTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cSequenceTask", cSequenceTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSequenceTask", "cCompositeTask")
------------------------------------------------------------------------------------------------------
function cSequenceTask:__init()
end

function cSequenceTask:onEnter(obj)
    self.m_activeChildIndex = 1
    return true
end

function cSequenceTask:update(obj, childStatus)
    BEHAVIAC_ASSERT(self.m_activeChildIndex <= #self.m_children, "cSequenceTask:update self.m_activeChildIndex <= #self.m_children")

    local s, activeChildIndex = self.m_node:sequenceUpdate(obj, childStatus, self.m_activeChildIndex, self.m_children)
    self.m_activeChildIndex = activeChildIndex
    return s
end