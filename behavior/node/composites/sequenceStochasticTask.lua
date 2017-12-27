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
module "behavior.node.actions.selectorStochasticTask"
------------------------------------------------------------------------------------------------------
class("cSequenceStochasticTask", d_ms.d_compositeStochasticTask.cCompositeStochasticTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cSequenceStochasticTask", cSequenceStochasticTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSequenceStochasticTask", "cCompositeStochasticTask")
------------------------------------------------------------------------------------------------------
function cSequenceStochasticTask:__init()
end

function cCompositeStochasticTask:update(obj, childStatus)
    BEHAVIAC_ASSERT(self.m_activeChildIndex <= #self.m_children, "cCompositeStochasticTask:update self.m_activeChildIndex <= #self.m_children")
    
    local bFirst = true
    local node = self.m_node
    --  Keep going until a child behavior says its running.
    local s = childStatus

    while true do
        if not bFirst or s == EBTStatus.BT_RUNNING then
            local childIndex = self.m_set[self.m_activeChildIndex]
            local pBehavior = self.m_children[childIndex]

            if node:checkIfInterrupted(obj) then
                return EBTStatus.BT_FAILURE
            end

            s = pBehavior:exec(obj)
        end

        bFirst = false
        --  If the child fails, or keeps running, do the same.
        if s ~= EBTStatus.BT_SUCCESS then
            return s
        end

        --  Hit the end of the array, job done!
        self.m_activeChildIndex = self.m_activeChildIndex + 1
        if self.m_activeChildIndex > #self.m_children then
            return EBTStatus.BT_SUCCESS
        end
    end
end