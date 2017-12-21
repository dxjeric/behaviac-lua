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
local stringUtils           = d_ms.d_behaviorCommon.stringUtils
local EOperatorType         = d_ms.d_behaviorCommon.EOperatorType
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.actions.waitFrames"
------------------------------------------------------------------------------------------------------
class("cWaitFrames", d_ms.d_behaviorNode.cBehaviorNode)
ADD_BEHAVIAC_DYNAMIC_TYPE("cWaitFrames", cWaitFrames)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cWaitFrames", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- Wait for the specified frames. always return Running until exceeds count.
function cWaitFrames:__init()
    self.m_frames   = false     -- IInstanceMember
end

function cWaitFrames:release()
    d_ms.d_behaviorNode.cBehaviorNode.release(self)
    self.m_frames = false
end

function cWaitFrames:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.release(self)

    for _, property in ipairs(properties) do
        if property.name == "Frames" then
            local pParenthesis = string.finde(property.value, "%(")
            if pParenthesis then
                self.m_frames = BehaviorParseFactory.parseMethod(property.value)
            else
                self.m_frames = BehaviorParseFactory.parseProperty(property.value)
            end
        end
    end
end

function cWaitFrames:getFrames(obj)
    if self.m_frames then
        local frames = self.m_frames:getValue(obj)
        if frames == 0xFFFFFFFF then
            return -1
        else
            return bits.and(frames, 0x0000FFFF)
        end
    end
    return 0
end

function cWaitFrames:createTask()
    return d_ms.d_waitFramesTask.cWaitFramesTask.new()
end