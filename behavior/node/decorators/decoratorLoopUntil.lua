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
module "behavior.node.decorators.decoratorLoopUntil"
------------------------------------------------------------------------------------------------------
class("cDecoratorLoopUntil", d_ms.d_decoratorCount.cDecoratorCount)
ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorLoopUntil", cDecoratorLoopUntil)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorLoopUntil", "cDecoratorCount")
------------------------------------------------------------------------------------------------------
-- DecoratorLoopUntil can be set two conditions, loop count 'C' and a return value 'R'.
-- if current update count less equal than 'C' and child return value not equal to 'R',
-- it returns Running. Or returns child value.
function cDecoratorLoopUntil:__init()
    self.m_until = false
end

function cDecoratorLoopUntil:createTask()
    return d_ms.d_decoratorLoopUntilTask.cDecoratorLoopUntilTask.new()
end

function cDecoratorLoopUntil:loadByProperties(version, agentType, properties)
    d_ms.d_decoratorCount.cDecoratorCount.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "Until" then
            self.m_until = (p.value == "true")
        end
    end
end