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
module "behavior.node.actions.noop"
------------------------------------------------------------------------------------------------------
class("cNoop", d_ms.d_behaviorNode.cBehaviorNode)
ADD_BEHAVIAC_DYNAMIC_TYPE("cNoop", cNoop)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cNoop", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- Nothing to do, just return success.
function cNoop:__init()
end

-- function cNoop:loadByProperties(version, agentType, properties)
--     d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(self, version, agentType, properties)
-- end

function cNoop:IsValid(obj, pTask)
    if not pTask:getNode() or not pTask:getNode():isNoop() then
        return false
    end

    return true
end

function cNoop:createTask()
    return d_ms.d_noopTask.cNoopTask.new()
end