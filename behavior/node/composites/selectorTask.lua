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
module "behavior.node.actions.selectorTask"
------------------------------------------------------------------------------------------------------
class("cSelectorTask", d_ms.d_compositeTask.cCompositeTask)
ADD_BEHAVIAC_DYNAMIC_TYPE("cSelectorTask", cSelectorTask)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSelectorTask", "cCompositeTask")
------------------------------------------------------------------------------------------------------
function cSelectorTask:__init()
end

function cSelectorTask:onEnter(obj)
    BEHAVIAC_ASSERT(#self.m_children > 0, "cSelectorTask:onEnter #self.m_children > 0")
    self.m_activeChildIndex = 1
    return true
end

function cSelectorTask:onExit(obj, status)
end

function cSelectorTask:update(obj, childStatus)
    BEHAVIAC_ASSERT(self.m_activeChildIndex <= #self.m_children, "cSelectorTask:update self.m_activeChildIndex <= #self.m_children")
    local status, self.m_activeChildIndex = self:selectorUpdate(obj, childStatus, self.m_activeChildIndex, self.m_children)
    return status
end