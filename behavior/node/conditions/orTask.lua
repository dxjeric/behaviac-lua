------------------------------------------------------------------------------------------------------
-- 行为树 动作节点
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
module "behavior.node.conditions.orTask"
------------------------------------------------------------------------------------------------------
class("cOrTask", d_ms.d_selectorTask.cSelectorTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cOrTask", cOrTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cOrTask", "cSelectorTask")
------------------------------------------------------------------------------------------------------
function cOrTask:__init()
end

function cOrTask:update(obj, childStatus)
    for _, child in ipairs(self.m_children) do
        local status = child:exec(obj)
        -- If the child succeeds, succeeds
        if status == EBTStatus.BT_SUCCESS then
            return status
        end

        _G.BEHAVIAC_ASSERT(status == EBTStatus.BT_FAILURE, "cOrTask:update status == EBTStatus.BT_FAILURE")
    end

    return EBTStatus.BT_FAILURE
end