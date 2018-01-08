------------------------------------------------------------------------------------------------------
-- 行为树 条件节点基础类
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
module "behavior.node.decorators.decoratorLoop"
------------------------------------------------------------------------------------------------------
class("cDecoratorLoop", d_ms.d_decoratorCount.cDecoratorCount)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorLoop", cDecoratorLoop)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorLoop", "cDecoratorCount")
------------------------------------------------------------------------------------------------------
-- DecoratorLoop can be set a integer Count value. It increases inner count value when it updates.
-- It always return Running until inner count less equal than integer Count value. Or returns the child
-- value. It always return Running when the count limit equal to -1.
function cDecoratorLoop:__init()
    self.m_bDoneWithinFrame = false
end

function cDecoratorLoop:loadByProperties(version, agentType, properties)
    d_ms.d_decoratorCount.cDecoratorCount.loadByProperties(self, version, agentType, properties)
    for _, p in ipairs(properties) do
        if p.name == "DoneWithinFrame" then
            self.m_bDoneWithinFrame = (p.value == "true")
        end
    end   
end

function cDecoratorLoop:isValid(obj, task)
    if not task:getNode() or not task:getNode():isDecoratorLoop() then
        return false
    end

    return d_ms.d_decoratorNode.cDecoratorNode.isValid(self, obj, task)
end

function cDecoratorLoop:createTask()
    return d_ms.d_decoratorLoopTask.cDecoratorLoopTask.new()
end