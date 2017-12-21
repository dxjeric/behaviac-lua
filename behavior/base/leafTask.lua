------------------------------------------------------------------------------------------------------
-- 行为树 任务节点
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
module "behavior.base.leafTask"
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef    = d_ms.d_behaviorCommon.constBaseKeyStrDef
local triggerMode           = d_ms.d_behaviorCommon.triggerMode
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
------------------------------------------------------------------------------------------------------
class("cLeafTask")
ADD_BEHAVIAC_DYNAMIC_TYPE("cLeafTask", cLeafTask)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cLeafTask", "cBehaviorTask")
------------------------------------------------------------------------------------------------------
function cLeafTask:__init()
    
end

function cLeafTask:traverse(childFirst, handler, obj, userData)
    handler(self, obj, userData)
end