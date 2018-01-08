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
module "behavior.node.composites.ifElseTask"
------------------------------------------------------------------------------------------------------
class("cIfElseTask", d_ms.d_compositeTask.cCompositeTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cIfElseTask", cIfElseTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cIfElseTask", "cCompositeTask")
------------------------------------------------------------------------------------------------------
function cIfElseTask:__init()
end

function cIfElseTask:onEnter(obj)
    self.m_activeChildIndex = constInvalidChildIndex
    if #self.m_children == 3 then
        return true
    end

    _G.BEHAVIAC_ASSERT(false, "IfElseTask has to have three children: condition, if, else")
    return false
end

function cIfElseTask:onExit(obj, status)
end

function cIfElseTask:update(obj, childStatus)
    _G.BEHAVIAC_ASSERT(childStatus ~= EBTStatus.BT_INVALID, "cIfElseTask:update childStatus ~= EBTStatus.BT_INVALID")
    _G.BEHAVIAC_ASSERT(#self.m_children == 3, "cIfElseTask:update #self.m_children == 3")

    local conditionResult = EBTStatus.BT_INVALID

    if childStatus == EBTStatus.BT_SUCCESS or childStatus == EBTStatus.BT_FAILURE then
        -- if the condition returned running then ended with childStatus
        conditionResult = childStatus
    end

    if self.m_activeChildIndex == constInvalidChildIndex then
        local pCondition = self.m_children[1]
        if conditionResult == EBTStatus.BT_INVALID then
            -- condition has not been checked
            conditionResult = pCondition:exec(obj)
        end

        if conditionResult == EBTStatus.BT_SUCCESS then
            -- if
            self.m_activeChildIndex = 2
        elseif conditionResult == EBTStatus.BT_FAILURE then
            -- else
            self.m_activeChildIndex = 3
        end
    else
        return childStatus
    end

    if self.m_activeChildIndex ~= constInvalidChildIndex then
        local pBehavior = self.m_children[self.m_activeChildIndex]
        local s = pBehavior:exec(obj)
        return s
    end

    return EBTStatus.BT_RUNNING
end