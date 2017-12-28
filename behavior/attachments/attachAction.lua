-----------------------------------------------------------------------------------------------------
-- 行为树 节点基础类
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
local stringUtils           = d_ms.d_behaviorCommon.stringUtils
local triggerMode           = d_ms.d_behaviorCommon.triggerMode
local EOperatorType         = d_ms.d_behaviorCommon.EOperatorType
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.attachments.attachAction"
------------------------------------------------------------------------------------------------------
class("cAttachAction", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cAttachAction", cAttachAction)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cAttachAction", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
class("cActionConfig")
function cActionConfig:__init()
    self.m_opl          = false
    self.m_opr1         = false
    self.m_opr2         = false
    self.m_operator     = EOperatorType.E_INVALID
    self.m_comparator   = false
    self.__name         = "cActionConfig"
end

function cActionConfig:release()
    self.m_opl          = false
    self.m_opr1         = false
    self.m_opr2         = false
    self.m_operator     = EOperatorType.E_INVALID
    self.m_comparator   = false
end

function cActionConfig:load(properties)
    for _, p in ipairs(properties) do
        if p.name == "Opl" then
            if stringUtils.isValidString(p.value) then
                local pParenthesis = string.find(p.value, '%(')
                if not pParenthesis then
                    self.m_opl = BehaviorParseFactory.parseProperty(p.value)
                else
                    self.m_opl = BehaviorParseFactory.parseMethod(p.value)
                end
            end
        elseif p.name == "Opr1" then
            if stringUtils.isValidString(p.value) then
                local pParenthesis = string.find(p.value, '%(')
                if not pParenthesis then
                    self.m_opr1 = BehaviorParseFactory.parseProperty(p.value)
                else
                    self.m_opr1 = BehaviorParseFactory.parseMethod(p.value)
                end
            end
        elseif p.name == "Operator" then
            self.m_operator = BehaviorParseFactory.parseOperatorType(p.value)
        elseif p.name == "Opr2" then
            if stringUtils.isValidString(p.value) then
                local pParenthesis = string.find(p.value, '%(')
                if not pParenthesis then
                    self.m_opr2 = BehaviorParseFactory.parseProperty(p.value)
                else
                    self.m_opr2 = BehaviorParseFactory.parseMethod(p.value)
                end
            end
        else
            -- _G.BEHAVIAC_ASSERT(0, "unrecognised property %s", p.name);
        end
    end

    return self.m_opl
end

function cActionConfig:execute(obj)
    local bValid = false
    -- action
    if self.m_opl and self.m_operator == EOperatorType.E_INVALID then
        bValid = true
        if self.m_opl.run then
            self.m_opl:run(obj)
        end
    -- assign
    elseif self.m_operator == EOperatorType.E_ASSIGN then
        if self.m_opl then
            self.m_opl:setValueCast(obj, self.m_opr2, false)
            bValid = true
        end
    -- compute
    elseif self.m_operator >= EOperatorType.E_ADD and self.m_operator <= EOperatorType.E_DIV then
        if self.m_opl then
            self.m_opl:compute(obj, self.m_opr1, self.m_opr2, self.m_operator)
            bValid = true
        end
    -- compare
    elseif self.m_operator >= EOperatorType.E_EQUAL and self.m_operator <= EOperatorType.E_LESSEQUAL then
        if self.m_opl then
            bValid = self.m_opl:compare(obj, self.m_opr2, self.m_operator)
        end
    end
    return bValid
end
------------------------------------------------------------------------------------------------------
function cAttachAction:__init()
    self.m_ActionConfig = cActionConfig.new()
end

function cAttachAction:release()
    if self.m_ActionConfig then
        self.m_ActionConfig:release()
    end
    self.m_ActionConfig = false
end

function cAttachAction:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(self, version, agentType, properties)
    print("cAttachAction:loadByProperties", self.__name, "self.m_ActionConfig", self.m_ActionConfig.__name)
    self.m_ActionConfig:load(properties)
end

function cAttachAction:evaluate(obj)
    local bValid = self.m_ActionConfig:execute(obj)
    if not bValid then
        childStatus = EBTStatus.BT_INVALID
        bValid = (EBTStatus.BT_SUCCESS == self:updateImpl(obj, childStatus))
    end

    return bValid
end

function cAttachAction:evaluateWithStatus(obj, status)
    -- BEHAVIAC_UNUSED_VAR result
    local bValid = self.m_ActionConfig:execute(obj)
    if not bValid then
        childStatus = EBTStatus.BT_INVALID
        bValid = (EBTStatus.BT_SUCCESS == self:updateImpl(obj, childStatus))
    end

    return bValid
end

function cAttachAction:createTask()
    return nil
end