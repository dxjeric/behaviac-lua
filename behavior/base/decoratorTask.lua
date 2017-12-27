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
module "behavior.base.decoratorTask"
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef        = d_ms.d_behaviorCommon.constBaseKeyStrDef
local triggerMode               = d_ms.d_behaviorCommon.triggerMode
local EBTStatus                 = d_ms.d_behaviorCommon.EBTStatus
local constInvalidChildIndex    = d_ms.d_behaviorCommon.constInvalidChildIndex
------------------------------------------------------------------------------------------------------
class("cDecoratorTask", d_ms.d_singeChildTask.cSingeChildTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorTask", cDecoratorTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorTask", "cSingeChildTask")
------------------------------------------------------------------------------------------------------
function cDecoratorTask:__init()
    self.m_bDecorateWhenChildEnds = false
end

-- BehaviorNode
function cDecoratorTask:init(node)
    d_ms.d_singeChildTask.cSingeChildTask.init(self, node)

    self.m_bDecorateWhenChildEnds = self.m_bDecorateWhenChildEnds
end

function cDecoratorTask:save(ioNode)
    d_ms.d_log.error("cDecoratorTask:save is empty")
end

function cDecoratorTask:load(ioNode)
    d_ms.d_log.error("cDecoratorTask:load is empty")
end

function cDecoratorTask:onEnter(obj)
    return true
end

function cDecoratorTask:update(obj, childStatus)
    BEHAVIAC_ASSERT(self.m_node:isDecoratorNode(), "cDecoratorTask:update isDecoratorNode")

    local dNode  = self.m_node
    local status = EBTStatus.BT_INVALID
    if childStatus ~= EBTStatus.BT_RUNNING then
        status = childStatus
        if not dNode.m_bDecorateWhenChildEnds or status ~= EBTStatus.BT_RUNNING then
            local result = self:decorate(status)
            if result ~= EBTStatus.BT_RUNNING then
                return result
            end
            
            return EBTStatus.BT_RUNNING
        end
    end

    status = d_ms.d_singeChildTask.cSingeChildTask.update(obj, childStatus)
    if not dNode.m_bDecorateWhenChildEnds or status ~= EBTStatus.BT_RUNNING then
        local result = self:decorate(status)
        if result ~= EBTStatus.BT_RUNNING then
            return result
        end
    end
    return EBTStatus.BT_RUNNING
end

-- called when the child's exec returns success or failure.
-- please note, it is not called if the child's exec returns running
function cDecoratorTask:decorate()
    d_ms.d_log.error("derived class must be rewrite cDecoratorTask:decorate")
    return EBTStatus.BT_RUNNING
end