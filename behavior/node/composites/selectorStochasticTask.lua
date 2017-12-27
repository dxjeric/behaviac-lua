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
class("cSelectorStochasticTask", d_ms.d_compositeStochasticTask.cCompositeStochasticTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cSelectorStochasticTask", cSelectorStochasticTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSelectorStochasticTask", "cCompositeStochasticTask")
------------------------------------------------------------------------------------------------------
function cSelectorStochasticTask:__init()
end

function cSelectorStochasticTask:update()
    local bFirst = true
    BEHAVIAC_ASSERT(self.m_activeChildIndex ~= constInvalidChildIndex, "cSelectorStochasticTask:update self.m_activeChildIndex ~= constInvalidChildIndex")

    -- Keep going until a child behavior says its running.
    while true do
        local s = childStatus
        if not bFirst or s == EBTStatus.BT_RUNNING then
            local childIndex = self.m_set[self.m_activeChildIndex]
            local pBehavior = self.m_children[childIndex]
            s = pBehavior:exec(obj)
        end

        bFirst = false
        -- If the child succeeds, or keeps running, do the same.
        if s ~= EBTStatus.BT_FAILURE then
            return s
        end

        -- Hit the end of the array, job done!
        self.m_activeChildIndex = self.m_activeChildIndex + 1
        if self.m_activeChildIndex > #self.m_children then
            return EBTStatus.BT_FAILURE
        end
    end
end