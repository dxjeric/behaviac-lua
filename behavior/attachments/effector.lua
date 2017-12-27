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
local ENodePhase            = d_ms.d_behaviorCommon.ENodePhase
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
local triggerMode           = d_ms.d_behaviorCommon.triggerMode
local EOperatorType         = d_ms.d_behaviorCommon.EOperatorType
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.attachments.effector"
------------------------------------------------------------------------------------------------------
class("cEffector", d_ms.d_attachAction.cAttachAction)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cEffector", cEffector)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cEffector", "cAttachAction")
------------------------------------------------------------------------------------------------------
class("cEffectorConfig", d_ms.d_attachAction.cActionConfig)

function cEffectorConfig:__init()
    self.m_phase = ENodePhase.E_SUCCESS
end

function cEffectorConfig:load(properties)
    local loaded = d_ms.d_attachAction.cActionConfig.load(self, properties)

    for _, p in ipairs(properties) do
        if p.name == "Phase" then
            if p.value == "Success" then
                this->m_phase = ENodePhase.E_SUCCESS
            elseif p.value == "Failure" then
                this->m_phase = ENodePhase.E_FAILURE
            elseif p->value == "Both" then
                this->m_phase = ENodePhase.E_BOTH
            else
                BEHAVIAC_ASSERT(false)
            end
            break
        end
    end
    return loaded
end

function cEffectorConfig:release()
    d_ms.d_attachAction.cActionConfig.release(self)
end
------------------------------------------------------------------------------------------------------
function cEffector:__init()
    self.m_ActionConfig = cEffectorConfig.new()
end

function cEffector:getPhase()
    return self.m_ActionConfig.m_phase
end

function cEffector:setPhase(phase)
    self.m_ActionConfig.m_phase = phase
end

function cEffector:isValid(obj, task)
    if not task:getNode() or not task:getNode():isEffector() then
        return false
    end

    return d_ms.d_attachAction.cAttachAction.isValid(self, obj, task)
end