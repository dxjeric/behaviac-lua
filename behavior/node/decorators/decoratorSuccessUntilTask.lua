------------------------------------------------------------------------------------------------------
-- 行为树 动作节点
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
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.decorators.decoratorSuccessUntilTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorSuccessUntilTask", d_ms.d_decoratorCountTask.cDecoratorCountTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorSuccessUntilTask", cDecoratorSuccessUntilTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorSuccessUntilTask", "cDecoratorCountTask")
------------------------------------------------------------------------------------------------------
-- Returns BT_SUCCESS for the specified number of iterations, then returns BT_FAILURE after that
function cDecoratorSuccessUntilTask:__init()
end

function cDecoratorSuccessUntilTask:save(IONode)
    d_ms.d_log.error("cDecoratorSuccessUntilTask:save")
end

function cDecoratorSuccessUntilTask:load(IONode)
    d_ms.d_log.error("cDecoratorSuccessUntilTask:load")
end

function cDecoratorSuccessUntilTask:onReset(obj)
    self.m_n = 0
end

function cDecoratorSuccessUntilTask:onEnter(obj)
    -- don't reset the m_n if it is restarted
    if self.m_n == 0 then
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

function cDecoratorSuccessUntilTask:decorate(status)
    if self.m_n > 0 then
        self.m_n = self.m_n - 1
        if self.m_n == 0 then
            return EBTStatus.BT_FAILURE
        end
        return EBTStatus.BT_SUCCESS
    end

    if self.m_n == -1 then
        return EBTStatus.BT_SUCCESS
    end

    BEHAVIAC_ASSERT(self.m_n == 0, "cDecoratorSuccessUntilTask:decorate self.m_n == 0")
    return EBTStatus.BT_FAILURE
end