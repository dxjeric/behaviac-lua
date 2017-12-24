-----------------------------------------------------------------------------------------------------
-- 行为树 节点基础类
------------------------------------------------------------------------------------------------------
local _G            = _G
local os            = os
local xml           = xml
local next          = next
local type          = type
local math          = math
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
local triggerMode           = d_ms.d_behaviorCommon.triggerMode
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.behaviorTreeMgr"
------------------------------------------------------------------------------------------------------
local behaviorTrees = {}
function loadBehaviorTree(path)
    return tree
end

function destroyBehaviorTreeTask(behaviorTreeTask, obj)

end

function createBehaviorTreeTask(path)
        
end
------------------------------------------------------------------------------------------------------
-- REDO: 这个后续可以修改
function getRandomValue(method, obj)
    local value = 0
    if method then
        value = method:getValue(obj)
    else
        value = math.random(10000)/10000
    end
    return value
end
------------------------------------------------------------------------------------------------------
local constPreloadBehaviors = true
function preloadBehaviors()
    return constPreloadBehaviors
end

local constUseIntValue = true
function getUseIntValue()
    return constUseIntValue
end
------------------------------------------------------------------------------------------------------
