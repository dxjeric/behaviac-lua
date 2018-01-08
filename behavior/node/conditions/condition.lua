------------------------------------------------------------------------------------------------------
-- 行为树 条件节点基础类
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
local string        = string
local getfenv       = getfenv
local tostring      = tostring
local setmetatable  = setmetatable
local getmetatable  = getmetatable
------------------------------------------------------------------------------------------------------
local d_ms = require "ms"
------------------------------------------------------------------------------------------------------
local EBTStatus     = d_ms.d_behaviorCommon.EBTStatus
local EOperatorType = d_ms.d_behaviorCommon.EOperatorType
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.conditions.condition"
------------------------------------------------------------------------------------------------------
class("cCondition", d_ms.d_conditionBase.cConditionBase)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cCondition", cCondition)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cCondition", "cConditionBase")
------------------------------------------------------------------------------------------------------
function cCondition:__init()
    self.m_opl      = false
    self.m_opr      = false
    self.m_operator = EOperatorType.E_EQUAL
end

function cCondition:release()
    d_ms.d_conditionBase.cConditionBase.release(self)
    self.m_opl      = false
    self.m_opr      = false
end

function cCondition:loadByProperties(version, agentType, properties)
    d_ms.d_conditionBase.cConditionBase.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "Operator" then
            self.m_operator = BehaviorParseFactory.parseOperatorType(p.value)
        elseif p.name == "Opl" then
            local pParenthesis = string.find(p.value, '%(')
            if not pParenthesis then
                self.m_opl = BehaviorParseFactory.parseProperty(p.value)
            else
                self.m_opl = BehaviorParseFactory.parseMethod(p.value)
            end
        elseif p.name == "Opr" then
            local pParenthesis = string.find(p.value, '%(')
            if not pParenthesis then
                self.m_opr = BehaviorParseFactory.parseProperty(p.value)
            else
                self.m_opr = BehaviorParseFactory.parseMethod(p.value)
            end
        else
            _G.BEHAVIAC_ASSERT(false, "unrecognised property %s", p.name)
        end
    end
end

function cCondition:isValid(obj, task)
    if not task:getNode() or not task:getNode():isCondition() then
        return false
    end
    return d_ms.d_conditionBase.cConditionBase.isValid(self, obj, task)
end

function cCondition:evaluate(obj)
    if self.m_opl and self.m_opr then
        return self.m_opl:compare(obj, self.m_opr, self.m_operator)
    else
        local result = self:updateImpl(obj, EBTStatus.BT_INVALID)
        return result == EBTStatus.BT_SUCCESS
    end
end

function cCondition:createTask()
    return d_ms.d_conditionTask.cConditionTask.new()
end

function cCondition:cleanUp()
    d_ms.d_log.error("cCondition:cleanUp 静态函数 要怎么处理")
end