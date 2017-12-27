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
module "behavior.node.decorators.decoratorLoopTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorLoopTask", d_ms.d_decoratorCountTask.cDecoratorCountTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorLoopTask", cDecoratorLoopTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorLoopTask", "cDecoratorCountTask")
------------------------------------------------------------------------------------------------------
function cDecoratorLoopTask:__init()
end

function cDecoratorLoopTask:decorate(status)
    if self.m_n > 0 then
        self.m_n = self.m_n - 1
        if self.m_n == 0 then
            return EBTStatus.BT_SUCCESS
        end

        return EBTStatus.BT_RUNNING
    end

    if self.m_n == -1 then
        return EBTStatus.BT_RUNNING
    end

    BEHAVIAC_ASSERT(self.m_n == 0, "cDecoratorLoopTask:decorate self.m_n == 0")
    return EBTStatus.BT_SUCCESS
end

function cDecoratorLoopTask:update(obj, childStatus)
    BEHAVIAC_ASSERT(self.m_node and self.m_node:isDecoratorLoop(), "cDecoratorLoopTask:update self.m_node:isDecoratorLoop")
    if self.m_node.m_bDoneWithinFrame then
        BEHAVIAC_ASSERT(self.m_n >= 0, "cDecoratorLoopTask:update self.m_n")
        BEHAVIAC_ASSERT(self.m_root, "cDecoratorLoopTask:update self.m_root")

        local status = EBTStatus.BT_INVALID
        for i = 1, self.m_n then
            status = self.m_root:exec(obj, childStatus)
            if self.m_node.m_bDecorateWhenChildEnds then
                while status == EBTStatus.BT_RUNNING then
                    status = d_ms.d_decoratorCountTask.cDecoratorCountTask.update(self, obj, childStatus)
                end
            end

            if status == EBTStatus.BT_FAILURE then
                return EBTStatus.BT_FAILURE
            end
        end

        return EBTStatus.BT_SUCCESS
    end

    return d_ms.d_decoratorCountTask.cDecoratorCountTask.update(self, obj, childStatus)
end