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
module "behavior.node.composites.selectorProbability"
------------------------------------------------------------------------------------------------------
class("cSelectorProbability", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cSelectorProbability", cSelectorProbability)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSelectorProbability", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- Choose a child to execute based on the probability have set. then return the child execute result.
function cSelectorProbability:__init()
    self.m_method = false
end

function cSelectorProbability:release()
    d_ms.d_behaviorNode.cBehaviorNode.release()
    self.m_method = false
end

function cSelectorProbability:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "RandomGenerator" then
            if p.value[0] ~= "" then
                this->m_method = BehaviorParseFactory.parseMethod(p.value)
            end
        else
            -- BEHAVIAC_ASSERT(0, "unrecognised property %s", p.name);
        end
    end
end

function cSelectorProbability:isValid(obj, task)
    if not task:getNode() or not task:getNode():isSelectorProbability() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end

function cSelectorProbability:addChild(pBehavior)
    BEHAVIAC_ASSERT(pBehavior:isDecoratorWeight(), "cSelectorProbability:addChild pBehavior:isDecoratorWeight")

    d_ms.d_behaviorNode.cBehaviorNode.addChild(self, pBehavior)
end

function cSelectorProbability:createTask()
    return d_ms.d_selectorProbabilityTask.cSelectorProbabilityTask.new()
end