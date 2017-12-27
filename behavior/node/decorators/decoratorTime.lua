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
module "behavior.node.decorators.decoratorTime"
------------------------------------------------------------------------------------------------------
class("cDecoratorTime", d_ms.d_decoratorNode.cDecoratorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorTime", cDecoratorTime)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorTime", "cDecoratorNode")
------------------------------------------------------------------------------------------------------
-- It returns Running result until it reaches the time limit specified, no matter which
-- value its child return. Or return the child's value.
function cDecoratorTime:__init()
    self.m_time = false
end

function cDecoratorNode:release()
    d_ms.d_decoratorNode.cDecoratorNode.release(self)
    self.m_time = false
end

function cDecoratorNode:loadByProperties(version, agentType, properties)
    d_ms.d_decoratorNode.cDecoratorNode.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "Time" then
            local pParenthesis = string.find(p.value, "%(")
            if not pParenthesis then
                self.m_time = BehaviorParseFactory.parseProperty(p.value)
            else
                self.m_time = BehaviorParseFactory.parseMethod(p.value)
            end
        end
    end
end

function cDecoratorTime:getTime(obj)
    local time = 0
    
    if self.m_time then
        time = self.m_time:getValue()
    end
    return time
end

function cDecoratorTime:getIntTime(obj)
    local time = 0
    
    if self.m_time then
        time = self.m_time:getValue()
    end
    return time
end

function cDecoratorTime:createTask()
    return d_ms.d_decoratorTimeTask.cDecoratorTimeTask.new()
end