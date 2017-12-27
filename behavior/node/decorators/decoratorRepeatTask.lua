------------------------------------------------------------------------------------------------------
-- 行为树 动作节点
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
module "behavior.node.decorators.decoratorRepeatTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorRepeatTask", d_ms.d_decoratorCountTask.cDecoratorCountTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorRepeatTask", cDecoratorRepeatTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorRepeatTask", "cDecoratorCountTask")
------------------------------------------------------------------------------------------------------
function cDecoratorRepeatTask:__init()
end

function cDecoratorRepeatTask:save(IONode)
    d_ms.d_log.error("cDecoratorRepeatTask:save")
end

function cDecoratorRepeatTask:load(IONode)
    d_ms.d_log.error("cDecoratorRepeatTask:load")
end

function cDecoratorRepeatTask:decorate(status)
    BEHAVIAC_ASSERT(false, "cDecoratorRepeatTask:decorate")
    return EBTStatus.BT_INVALID
end

function cDecoratorRepeatTask:update(obj, childStatus)
    BEHAVIAC_ASSERT(self.m_node and self.m_node:isDecoratorNode(), "cDecoratorRepeatTask:update self.m_node:isDecoratorNode")
    BEHAVIAC_ASSERT(self.m_n >= 0, "cDecoratorRepeatTask:update self.m_n >= 0")
    BEHAVIAC_ASSERT(self.m_root,  "cDecoratorRepeatTask:update self.m_root")

    local status = EBTStatus.BT_INVALID

    for i = 1, self.m_n do
        status = self.m_root:exec(obj, childStatus)

        if self.m_node.m_bDecorateWhenChildEnds then
            while status == EBTStatus.BT_RUNNING do
                status = d_ms.d_decoratorCountTask.cDecoratorCountTask.update(self, obj, childStatus)
            end
        end

        if status == EBTStatus.BT_FAILURE then
            return EBTStatus.BT_FAILURE
        end
    end

    return EBTStatus.BT_SUCCESS
end