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
module "behavior.node.decorators.decoratorWeight"
------------------------------------------------------------------------------------------------------
class("cDecoratorWeight", d_ms.d_decoratorNode.cDecoratorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorWeight", cDecoratorWeight)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorWeight", "cDecoratorNode")
------------------------------------------------------------------------------------------------------
function cDecoratorWeight:__init()
    self.m_weight = false
end

function cDecoratorWeight:loadByProperties(version, agentType, properties)
    d_ms.d_decoratorNode.cDecoratorNode.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "Weight" then
            self.m_weight = BehaviorParseFactory.parseProperty(p.value)
        end
    end
end

function cDecoratorWeight:getWeight(obj)
    if self.m_weight then
        local count = self.m_weight:getValue(obj)
        if count == 0xFFFFFFFF then
            return -1
        else
            return bits.bitAnd(count, 0x0000FFFF)
        end
    end

    return 0
end

function cDecoratorWeight:isManagingChildrenAsSubTrees()
    return false
end

function cDecoratorWeight:createTask()
    return d_ms.d_decoratorWeightTask.cDecoratorWeightTask.new()
end