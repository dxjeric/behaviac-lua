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
module "behavior.node.decorators.decoratorLoopUntilTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorLoopUntilTask", d_ms.d_decoratorCountTask.cDecoratorCountTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorLoopUntilTask", cDecoratorLoopUntilTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorLoopUntilTask", "cDecoratorCountTask")
------------------------------------------------------------------------------------------------------
-- Returns BT_RUNNING until the child returns BT_SUCCESS. if the child returns BT_FAILURE, it still returns BT_RUNNING
-- however, if m_until is false, the checking condition is inverted.
-- i.e. it Returns BT_RUNNING until the child returns BT_FAILURE. if the child returns BT_SUCCESS, it still returns BT_RUNNING

function cDecoratorLoopUntilTask:__init()
end

function cDecoratorLoopUntilTask:save()
    d_ms.d_log.error("cDecoratorLoopUntilTask:save")
end

function cDecoratorLoopUntilTask:load()
    d_ms.d_log.error("cDecoratorLoopUntilTask:load")
end

function cDecoratorLoopUntilTask:decorate(status)
    if self.m_n > 0 then
        self.m_n = self.m_n - 1
    end

    if self.m_n == 0 then
        return EBTStatus.BT_SUCCESS
    end

    BEHAVIAC_ASSERT(self:getNode() and self:getNode():isDecoratorLoopUntil(), "cDecoratorLoopUntilTask:decorate self:getNode():isDecoratorLoopUntil")
    local pDecoratorLoopUntil = self:getNode()
    if pDecoratorLoopUntil.m_until then
        if status == EBTStatus.BT_SUCCESS then
            return EBTStatus.BT_SUCCESS
        end
    else
        if status == EBTStatus.BT_FAILURE then
            return EBTStatus.BT_FAILURE
        end
    end

    return EBTStatus.BT_RUNNING
end