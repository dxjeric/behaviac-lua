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
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.actions.assignmentTask"
------------------------------------------------------------------------------------------------------
class("cAssignmentTask", d_ms.d_leafTask.cLeafTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cAssignmentTask", cAssignmentTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cAssignmentTask", "cLeafTask")
------------------------------------------------------------------------------------------------------
function cAssignmentTask:__init()
end


function cAssignmentTask:onEnter(obj)
    return true
end

function cAssignmentTask:onExit(obj, status)
end

function cAssignmentTask:update(obj, childStatus)
    BEHAVIAC_ASSERT(childStatus == EBTStatus.BT_RUNNING, "cAssignmentTask:update childStatus == EBTStatus.BT_RUNNING")
    BEHAVIAC_ASSERT(self:getNode() and self:getNode():isAssignment(), "cAssignmentTask:update self:getNode():isAssignment()")

    local pAssignmentNode = self:getNode()
    local result = EBTStatus.BT_SUCCESS

    if pAssignmentNode.m_opl then
        pAssignmentNode.m_opl:setValueCast(obj, pAssignmentNode.m_opr, pAssignmentNode->m_bCast)
    else
        result = pAssignmentNode:updateImpl(obj, childStatus)
    end

    return result
end
