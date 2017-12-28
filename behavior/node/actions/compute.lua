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
local EOperatorType         = d_ms.d_behaviorCommon.EOperatorType
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.actions.compute"
------------------------------------------------------------------------------------------------------
class("cCompute", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cCompute", cCompute)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cCompute", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- Compute the result of Operand1 and Operand2 and assign it to the Left Operand.
-- Compute node can perform Add, Sub, Mul and Div operations. a left and right Operand
-- can be a agent property or a par value.
function cCompute:__init()
    self.m_opl      = false      -- IInstanceMember*
    self.m_opr1     = false      -- IInstanceMember*
    self.m_opr2     = false      -- IInstanceMember*
    self.m_operator = EOperatorType.E_INVALID
end

function cCompute:release()
    d_ms.d_behaviorNode.cBehaviorNode.release(self)
    self.m_opl      = false      -- IInstanceMember*
    self.m_opr1     = false      -- IInstanceMember*
    self.m_opr2     = false      -- IInstanceMember*
end

function cCompute:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(self, version, agentType, properties)

    for _, property in ipairs(properties) do
        if property.name == "Opl" then
            self.m_opl = BehaviorParseFactory.parseProperty(property.value)
        elseif property.name == "Operator" then
            _G.BEHAVIAC_ASSERT((propertyvalue == "Add" or propertyvalue == "Sub" or propertyvalue == "Mul" or propertyvalue == "Div"), "cCompute:loadByProperties propertyvalue must be add sub mul div")
            self.m_operator = BehaviorParseFactory.parseOperatorType(property.value)
        elseif property.name == "Opr1" then
            local pParenthesis = string.find(property.value, '%(')
            if not pParenthesis then
                self.m_opr1 = BehaviorParseFactory.parseProperty(property.value)
            else
                self.m_opr1 = BehaviorParseFactory.parseMethod(property.value)
            end
        elseif property.name == "Opr2" then
            local pParenthesis = string.find(property.value, '%(')
            if not pParenthesis then
                self.m_opr2 = BehaviorParseFactory.parseProperty(property.value)
            else
                self.m_opr2 = BehaviorParseFactory.parseMethod(property.value)
            end
        else
            -- do nothing
        end
    end
end

function cCompute:isValid(obj, task)
    if not task:getNode() or not task:getNode():isCompute() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(obj, task)
end

function cCompute:createTask()
    return d_ms.d_computeTask.cComputeTask.new()
end