------------------------------------------------------------------------------------------------------
-- 行为树 条件节点基础类
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
local EOperatorType         = d_ms.d_behaviorCommon.EOperatorType
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.decorators.decoratorFrames"
------------------------------------------------------------------------------------------------------
class("cDecoratorFrames", d_ms.d_decoratorNode.cDecoratorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorFrames", cDecoratorFrames)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorFrames", "cDecoratorNode")
------------------------------------------------------------------------------------------------------
function cDecoratorFrames:__init()
    self.m_frames = false
end

function cDecoratorFrames:loadByProperties(version, agentType, properties)
    d_ms.d_decoratorNode.cDecoratorNode.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "Frames" then
            local pParenthesis = string.find(p.value, '%(')
            if not pParenthesis then
                self.m_frames = BehaviorParseFactory.parseProperty(p.value)
            else
                self.m_frames = BehaviorParseFactory.parseMethod(p.value)
            end
        end
    end
end

function cDecoratorFrames:getFrames(obj)
    if self.m_frames then
        local frames = self.m_frames:getValue(obj)

        if frames == 0xFFFFFFFF then
            return -1
        else
            return bits.bitAnd(frames, 0x0000FFFF)
        end
    end

    return 0
end

function cDecoratorFrames:createTask()
    return d_ms.d_decoratorFramesTask.cDecoratorFramesTask.new()
end