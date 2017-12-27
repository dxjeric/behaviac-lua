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
module "behavior.node.composites.selectorLoop"
------------------------------------------------------------------------------------------------------
class("cSelectorLoop", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cSelectorLoop", cSelectorLoop)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSelectorLoop", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- Behavives similarly to SelectorTask, i.e. executing chidren until the first successful one.
-- however, in the following ticks, it constantly monitors the higher priority nodes.if any
-- one's precondtion node returns success, it picks it and execute it, and before executing,
-- it first cleans up the original executing one. all its children are WithPreconditionTask
function cSelectorLoop:__init()
    self.m_bResetChildren = false
end

function cSelectorLoop:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "ResetChildren" then
            self.m_bResetChildren = (p.value == "true")
            break
        end
    end
end

function cSelectorLoop:isManagingChildrenAsSubTrees()
    return true
end

function cSelectorLoop:createTask()
    return d_ms.d_selectorLoopTask.cSelectorLoopTask.new()
end