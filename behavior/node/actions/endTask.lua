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
module "behavior.node.actions.endTask"
------------------------------------------------------------------------------------------------------
class("cEndTask", d_ms.d_leafTask.cLeafTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cEndTask", cEndTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cEndTask", "cLeafTask")
------------------------------------------------------------------------------------------------------
function cEndTask:__init()
end

function cEndTask:onEnter(obj)
    return true
end

function cEndTask:onExit(obj, status)
end

function cEndTask:update(obj, childStatus)
    local rootTask = nil    -- BehaviorTreeTask

    if self:getEndOutside() then
        rootTask = self:getRootTask()
    elseif obj then
        rootTask = obj:btgetcurrent()
    end

    if rootTask then
        rootTask:setEndStatus(self:getStatus(obj))
    end
end

function cEndTask:getEndOutsides()
    local pEndNode = self:getNode()
    if pEndNode and pEndNode:isEnd() then
        return pEndNode:getEndOutside()
    end
    return false
end

function cEndTask:getStatus(obj)
    local pEndNode = self:getNode()
    local status = EBTStatus.BT_SUCCESS
    if pEndNode and pEndNode:isEnd() then
        status = pEndNode:getStatus(obj)
    end
    BEHAVIAC_ASSERT(status == EBTStatus.BT_SUCCESS or status == EBTStatus.BT_FAILURE, "cEndTask:getStatus status must be BT_SUCCESS BT_FAILURE")
    return status
end