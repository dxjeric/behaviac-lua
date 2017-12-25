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
module "behavior.node.decorators.decoratorLogTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorLogTask", d_ms.d_decoratorTask.cDecoratorTask)
ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorLogTask", cDecoratorLogTask)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorLogTask", "cDecoratorTask")
------------------------------------------------------------------------------------------------------
function cDecoratorLogTask:__init()
end

function cDecoratorLogTask:save(node)
    d_ms.d_log.error("cDecoratorLogTask:save")
end

function cDecoratorLogTask:load(node)
    d_ms.d_log.error("cDecoratorLogTask:load")
end

function cDecoratorLogTask:onenter(obj)
    d_ms.d_decoratorTask.cDecoratorTask.onEnter(obj)

    self.m_start = redoGetFrameSinceStartup()
    self.m_frames = self:getFrames(obj)

    return self.m_frames > 0
end

function cDecoratorLogTask:decorate(status)
    BEHAVIAC_ASSERT(self:getNode() and self:getNode():isDecoratorLog(), "cDecoratorLogTask:decorate self:getNode():isDecoratorLog")
    BEHAVIAC_LOGINFO("DecoratorLogTask:%s\n", self:getNode().m_message)
    return status
end