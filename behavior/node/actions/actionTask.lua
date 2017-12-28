------------------------------------------------------------------------------------------------------
-- 行为树 动作任务节点
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
local EBTStatus = d_ms.d_behaviorCommon.EBTStatus
------------------------------------------------------------------------------------------------------
module "behavior.node.actions.actionTask"
------------------------------------------------------------------------------------------------------
class("cActionTask", d_ms.d_leafTask.cLeafTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cActionTask", cActionTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cActionTask", "cLeafTask")
------------------------------------------------------------------------------------------------------
function cActionTask:__init()
end

function cActionTask:onenter(obj)
    return true
end

function cActionTask:onexit(obj, status)
end

function cActionTask:update(obj, childStatus)
    _G.BEHAVIAC_ASSERT(self:getNode() and self:getNode():isAction(), "cActionTask:update  self:getNode() and self:getNode():isAction()")
end