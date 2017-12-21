-----------------------------------------------------------------------------------------------------
-- 行为树 节点基础类
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
local triggerMode           = d_ms.d_behaviorCommon.triggerMode
local EPreconditionPhase    = d_ms.d_behaviorCommon.EPreconditionPhase
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.attachments.precondition"
------------------------------------------------------------------------------------------------------
class("cPrecondition", d_ms.d_attachAction.cAttachAction)
ADD_BEHAVIAC_DYNAMIC_TYPE("cPrecondition", cPrecondition)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cPrecondition", "cAttachAction")
------------------------------------------------------------------------------------------------------
class("cPreconditionConfig", d_ms.d_attachAction.cActionConfig)

function cPreconditionConfig:__init()
    self.m_phase = EPreconditionPhase.E_ENTER
    self.m_bAnd  = false
end

function cPreconditionConfig:release()
    d_ms.d_attachAction.cActionConfig.release()
end

function cPreconditionConfig:load(properties)
    local loaded = d_ms.d_attachAction.cAttachAction.load(self, properties)

    for _, p in ipairs(properties) do
        if p.name == "BinaryOperator" then
            if p.value == "Or" then
                self.m_bAnd = false
            elseif p.value == "And" then
                self.m_bAnd = true
            else
                BEHAVIAC_ASSERT(false, "cPreconditionConfig:load BinaryOperator")
            end
        elseif p.name == "Phase" then
            if p.value == "Enter" then
                self.m_phase = EPreconditionPhase.E_ENTER
            elseif p.value, "Update" then
                self.m_phase = EPreconditionPhase.E_UPDATE
            elseif p.value, "Both" then
                self.m_phase = EPreconditionPhase.E_BOTH
            else
                BEHAVIAC_ASSERT(false, "cPreconditionConfig:load Phase")
            end
            break
        end
    end
end
------------------------------------------------------------------------------------------------------
function cPrecondition:__init()
    self.m_ActionConfig = cPreconditionConfig.new()
end

function cPrecondition:release()
    d_ms.d_attachAction.cAttachAction.release(self)
end

function cPrecondition:createTask()
    return nil
end

function cPrecondition:getPhase()
    return self.m_ActionConfig.m_phase
end

function cPrecondition:setPhase(phase)
    self.m_ActionConfig.m_phase = phase
end

function cPrecondition:isAnd()
    return self.m_ActionConfig.m_bAnd
end

function cPrecondition:setIsAnd(isAnd)
    self.m_ActionConfig.m_bAnd = isAnd
end

function cPrecondition:isValid(obj, task)
    if not task:getNode() or not task:getNode():isPrecondition() then
        return false
    end

    return d_ms.d_attachAction.cAttachAction.isValid(self, obj, task)
end