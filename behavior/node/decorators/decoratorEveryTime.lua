------------------------------------------------------------------------------------------------------
-- 行为树 条件节点基础类
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
local string        = string
local getfenv       = getfenv
local tostring      = tostring
local setmetatable  = setmetatable
local getmetatable  = getmetatable
------------------------------------------------------------------------------------------------------
local d_ms = require "ms"
------------------------------------------------------------------------------------------------------
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
local EOperatorType         = d_ms.d_behaviorCommon.EOperatorType
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.decorators.decoratorEveryTime"
------------------------------------------------------------------------------------------------------
class("cDecoratorEveryTime", d_ms.d_decoratorTime.cDecoratorTime)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorEveryTime", cDecoratorEveryTime)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorEveryTime", "cDecoratorNode")
------------------------------------------------------------------------------------------------------
-- 每隔多少毫秒执行一次
function cDecoratorEveryTime:__init()
    self.m_time = false
end

function cDecoratorEveryTime:createTask()
    return d_ms.d_decoratorEveryTimeTask.cDecoratorEveryTimeTask.new()
end