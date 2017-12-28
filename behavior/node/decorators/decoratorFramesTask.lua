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
module "behavior.node.decorators.decoratorFramesTask"
------------------------------------------------------------------------------------------------------
class("cDecoratorFramesTask", d_ms.d_decoratorTask.cDecoratorTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorFramesTask", cDecoratorFramesTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorFramesTask", "cDecoratorTask")
------------------------------------------------------------------------------------------------------
function cDecoratorFramesTask:__init()
    self.m_start    = 0
    self.m_frames   = 0
end

function cDecoratorFramesTask:getFrames(obj)
    _G.BEHAVIAC_ASSERT(self:getNode() and self:getNode():isDecoratorFrames(), "cDecoratorFramesTask:getFrames self:getNode() and self:getNode():isDecoratorFrames()")
    return self:getNode():getFrames(obj)
end

function cDecoratorFramesTask:copyTo(target)
    _G.BEHAVIAC_ASSERT(target:isDecoratorFramesTask(), "cDecoratorFramesTask:copyTo target:isDecoratorFramesTask")
    d_ms.d_decoratorTask.cDecoratorTask.copyTo(self, target)

    target.m_start  = self.m_start
    target.m_frames = self.m_frames
end

function cDecoratorFramesTask:save(node)
    d_ms.d_log.error("cDecoratorFramesTask:save")
end

function cDecoratorFramesTask:load(node)
    d_ms.d_log.error("cDecoratorFramesTask:load")
end

function cDecoratorFramesTask:onenter(obj)
    d_ms.d_decoratorTask.cDecoratorTask.onEnter(obj)

    self.m_start = redoGetFrameSinceStartup()
    self.m_frames = self:getFrames(obj)

    return self.m_frames > 0
end

function cDecoratorFramesTask:decorate(status)
    if redoGetFrameSinceStartup() - self.m_start + 1 >= self.m_frames then
        return EBTStatus.BT_SUCCESS
    end

    return EBTStatus.BT_RUNNING
end