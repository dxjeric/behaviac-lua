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
module "behavior.node.decorators.decoratorFailureUntilTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorFailureUntilTask", d_ms.d_decoratorCountTask.cDecoratorCountTask)
ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorFailureUntilTask", cDecoratorFailureUntilTask)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorFailureUntilTask", "cDecoratorCountTask")
------------------------------------------------------------------------------------------------------
-- Returns BT_FAILURE for the specified number of iterations, then returns BT_SUCCESS after that
function cDecoratorFailureUntilTask:__init()
end

function cDecoratorFailureUntilTask:onReset(obj)
    self.m_n = 0
end

function cDecoratorFailureUntilTask:onEnter(obj)
    -- don't reset the m_n if it is restarted
    if self.m_n == 0  then
        local count = self:getCount(obj)
        if count == 0 then
            return false
        end

        self.m_n = count
    else
        -- do nothing
    end

    return true
end

function cDecoratorFailureUntilTask:decorate(status)
    if self.m_n > 0 then
        self.m_n = self.m_n - 1
        if self.m_n == 0 then
            return EBTStatus.BT_SUCCESS
        end

        return EBTStatus.BT_FAILURE
    end

    if self.m_n == -1 then
        return EBTStatus.BT_FAILURE
    end

    BEHAVIAC_ASSERT(self.m_n == 0, "cDecoratorFailureUntilTask:decorate self.m_n == 0")

    return EBTStatus.BT_SUCCESS
end    