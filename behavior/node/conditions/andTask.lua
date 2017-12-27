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
local string        = string
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
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.conditions.andTask"
------------------------------------------------------------------------------------------------------
class("cAndTask", d_ms.d_sequenceTask.cSequenceTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cAndTask", cAndTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cAndTask", "cSequenceTask")
------------------------------------------------------------------------------------------------------
function cAndTask:__init()
end

function cAndTask:update(obj, childStatus)
    for _, child in ipairs(self.m_children) do
        local status = child:exec(obj)
        -- If the child fails, fails
        if status == EBTStatus.BT_FAILURE then
            return status
        end

        BEHAVIAC_ASSERT(status == EBTStatus.BT_SUCCESS, "cAndTask:update status == EBTStatus.BT_SUCCESS")
    end

    return EBTStatus.BT_SUCCESS
end