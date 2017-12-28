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
module "behavior.node.actions.waitFramesTask"
------------------------------------------------------------------------------------------------------
class("cWaitFramesTask", d_ms.d_leafTask.cLeafTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cWaitFramesTask", cWaitFramesTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cWaitFramesTask", "cLeafTask")
------------------------------------------------------------------------------------------------------
function cWaitFramesTask:__init()
    self.m_start    = 0
    self.m_frames   = 0
end

function cWaitFramesTask:copyTo(target)
    d_ms.d_leafTask.cLeafTask.copyTo(self, target)

    _G.BEHAVIAC_ASSERT(target:isWaitFramesTask(), "cWaitFramesTask:copyTo target:isWaitFramesTask()")
    target.m_start  = self.m_start
    target.m_frames = self.m_frames
end

function cWaitFramesTask:getFrames(obj)
    _G.BEHAVIAC_ASSERT(self:getNode() and self:getNode():isWaitFrames(), "cWaitFramesTask:getFrames self:getNode():isWaitFrames()")

    local pWaitNode = self:getNode()

    if pWaitNode then
        pWaitNode:getFrames(obj)
    else
        return 0
    end
end

function cWaitFramesTask:onEnter(obj)
    self.m_start    = redoGetFrameSinceStartup()
    self.m_frames   = self:getFrames(obj)

    if self.m_frames <= 0 then
        return false
    end
    return true
end

function cWaitFramesTask:onExit(obj)
end

function cWaitFramesTask:update(obj, childStatus)
    local frame = redoGetFrameSinceStartup()

    if frame - self.m_start + 1 >= self.m_frames then
        return EBTStatus.BT_SUCCESS
    end
    return EBTStatus.BT_RUNNING
end