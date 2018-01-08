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
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.actions.computeTask"
------------------------------------------------------------------------------------------------------
class("cComputeTask", d_ms.d_leafTask.cLeafTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cComputeTask", cComputeTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cComputeTask", "cLeafTask")
------------------------------------------------------------------------------------------------------
function cComputeTask:__init()
end

function cComputeTask:onEnter(obj)
    return true
end

function cComputeTask:onExit(obj, status)
end

function cComputeTask:update(obj, childStatus)
    _G.BEHAVIAC_ASSERT(childStatus == EBTStatus.BT_RUNNING, "cComputeTask:update childStatus == EBTStatus.BT_RUNNING")
    _G.BEHAVIAC_ASSERT(self:getNode() and self:getNode():isCompute(), "cComputeTask:update self:getNode():isCompute()")
    local result = EBTStatus.BT_SUCCESS
    local pComputeNode = self:getNode()

    if pComputeNode.m_opl then
        pComputeNode.m_opl:compute(obj, pComputeNode.m_opr1, pComputeNode.m_opr2, pComputeNode.m_operator)
    else
        result = pComputeNode:updateImpl(obj, childStatus)
    end
    return result
end