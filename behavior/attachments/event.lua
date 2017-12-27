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
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.attachments.event"
------------------------------------------------------------------------------------------------------
class("cEvent", d_ms.d_conditionBase.cConditionBase)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cEvent", cEvent)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cEvent", "cConditionBase")
------------------------------------------------------------------------------------------------------
function cEvent:__init()
    self.m_event            = false
    self.m_eventName        = ""
    self.m_triggerMode      = triggerMode.TM_Transfer
    self.m_bTriggeredOnce   = false
    self.m_referencedBehaviorPath = ""
end

function cEvent:release()
    d_ms.d_conditionBase.cConditionBase.release()
    self.m_event = false
end

function cEvent:isValid(obj, task)
    if not task:getNode() or not task:getNode():isEvent() then
    end
    return d_ms.d_conditionBase.cConditionBase.isValid(self, obj, task)
end

function cEvent:loadByProperties(version, agentType, properties)
    d_ms.d_conditionBase.cConditionBase.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "Task" then
            -- REDO: self.m_eventName out param
            self.m_event, self.m_eventName = BehaviorParseFactory.parseMethodOutMethodName(p.value)
        elseif p.name == "ReferenceFilename" then
            self.m_referencedBehaviorPath = p.value
            if d_ms.d_behaviorTreeMgr.preloadBehaviors() then
                local behaviorTree = d_ms.d_behaviorTreeMgr.loadBehaviorTree(p.value)
            end
        elseif p.name == "TriggeredOnce" then
            if p.value == "true" then
                self.m_bTriggeredOnce = true
            end
        elseif p.name == "TriggerMode" then
            if p.value == "Transfer" then
                self.m_triggerMode = triggerMode.TM_Transfer
            elseif p.value == "Return" then
                self.m_triggerMode = triggerMode.TM_Return
            else
                BEHAVIAC_ASSERT(false, "unrecognised trigger mode %s", p.value)
            end
        else
            -- BEHAVIAC_ASSERT(0, "unrecognised property %s", p.name);
        end
    end
end

function cEvent:GetEventName()
    return self.m_eventName
end

function cEvent:triggeredOnce()
    return self.m_bTriggeredOnce
end

function cEvent:getTriggerMode()
    return self.m_triggerMode
end

function cEvent:switchTo(obj, eventParams)
    if not stringUtils.isNullOrEmpty(self.m_referencedBehaviorPath) then
        if not obj then
            local tm = self:etTriggerMode()
            obj:bteventtree(self.m_referencedBehaviorPath, tm)
            local pCurrentTree = obj:btgetcurrent()     -- BehaviorTreeTask
            BEHAVIAC_ASSERT(pCurrentTree, "cEvent:switchTo pCurrentTree is nil")
            pCurrentTree:addVariables(eventParams)
            obj:btexec()
        end
    end
end

function cEvent:createTask()
    return d_ms.d_eventTask.cEventTask.new()
end