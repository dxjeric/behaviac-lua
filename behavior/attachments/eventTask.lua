------------------------------------------------------------------------------------------------------
-- 行为树 任务节点
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
module "behavior.attachments.eventTask"
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef    = d_ms.d_behaviorCommon.constBaseKeyStrDef
local triggerMode           = d_ms.d_behaviorCommon.triggerMode
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
------------------------------------------------------------------------------------------------------
class("cEventTask", d_ms.d_attachmentTask.cAttachmentTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cEventTask", cEventTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cEventTask", "cAttachmentTask")
------------------------------------------------------------------------------------------------------
function cEventTask:__init()
end

function cEventTask:onEnter(obj)
    return true
end

function cEventTask:onExit(obj, status)
    return true
end

function cEventTask:triggeredOnce()
    local pEventNode = self:getNode()
    return pEventNode.m_bTriggeredOnce
end

function cEventTask:getTriggerMode()
    local pEventNode = self:getNode()
    return pEventNode.m_triggerMode 
end

function cEventTask:getEventName()
    local pEventNode = self:getNode()
    return pEventNode.m_eventName 
end

function cEventTask:update(obj, childStatus)
    BEHAVIAC_ASSERT(self:getNode() and self:getNode():isEvent(), "cEventTask:update self:getNode():isEvent()")
    local pEventNode = self:getNode()
    if pEventNode.m_referencedBehaviorPath ~= "" then
        if obj then
            local tm = self:getTriggerMode()
            obj:bteventtree(pEventNode.m_referencedBehaviorPath, tm)
            obj:btexec()
        end
    end

    return EBTStatus.BT_SUCCESS
end