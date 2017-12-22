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
module "behavior.node.composites.compositeStochastic"
------------------------------------------------------------------------------------------------------
class("cCompositeStochastic", d_ms.d_behaviorNode.cBehaviorNode)
ADD_BEHAVIAC_DYNAMIC_TYPE("cCompositeStochastic", cCompositeStochastic)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cCompositeStochastic", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
function cCompositeStochastic:__init()
    self.m_method   = false
end

function cCompositeStochastic:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "RandomGenerator" then
            self.m_method = BehaviorParseFactory.parseMethod(p.value)
        -- else
            -- BEHAVIAC_ASSERT(0, "unrecognised property %s", p.name)
        end
    end
end

function cCompositeStochastic:isValid(obj, task)
    if not task:getNode() or not task:getNode():isCompositeStochastic() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end