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
module "behavior.node.decorators.decoratorLog"
------------------------------------------------------------------------------------------------------
class("cDecoratorLog", d_ms.d_decoratorNode.cDecoratorNode)
ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorLog", cDecoratorLog)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorLog", "cDecoratorNode")
------------------------------------------------------------------------------------------------------
-- Output message specified when it updates.
function cDecoratorLog:__init()
    self.m_message = ""
end

function cDecoratorLog:loadByProperties(version, agentType, properties)
    d_ms.d_decoratorNode.cDecoratorNode.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "Log" then
            self.m_message = p.value
        end
    end
end

function cDecoratorLog:isValid(obj, task)
    if not task:getNode() or not task:getNode():isDecoratorLog() then
        return false
    end

    return d_ms.d_decoratorNode.cDecoratorNode.isValid(self, obj, task)
end

function cDecoratorLog:createTask()
    return d_ms.d_decoratorLogTask.cDecoratorLogTask.new()
end