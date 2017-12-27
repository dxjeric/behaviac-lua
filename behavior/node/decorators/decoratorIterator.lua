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
module "behavior.node.decorators.decoratorIterator"
------------------------------------------------------------------------------------------------------
class("cDecoratorIterator", d_ms.d_decoratorNode.cDecoratorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cDecoratorIterator", cDecoratorIterator)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cDecoratorIterator", "cDecoratorNode")
------------------------------------------------------------------------------------------------------
function cDecoratorIterator:__init()
    self.m_opl = false
    self.m_opr = false
end

function cDecoratorIterator:release()
    d_ms.d_decoratorNode.cDecoratorNode.release(self)
    self.m_opl = false
    self.m_opr = false
end

function cDecoratorIterator:loadByProperties(version, agentType, properties)
    d_ms.d_decoratorNode.cDecoratorNode.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "Opl" then
            local pParenthesis = string.find(p.value, '%(')
            if not pParenthesis then
                self.m_Iterator = BehaviorParseFactory.parseProperty(p.value)
            else
                BEHAVIAC_ASSERT(false, "cDecoratorIterator:loadByProperties Opl if function")
            end
        elseif p.name == "Opr" then
            local pParenthesis = string.find(p.value, '%(')
            if not pParenthesis then
                self.m_Iterator = BehaviorParseFactory.parseProperty(p.value)
            else
                self.m_Iterator = BehaviorParseFactory.parseMethod(p.value)
            end
        else
            -- do nothing
        end
    end
end

function cDecoratorIterator:isValid(obj, task)
    if not task:getNode() or not task:getNode():isDecoratorIterator() then
        return false
    end

    return d_ms.d_decoratorNode.cDecoratorNode.isValid(self, obj, task)
end

function cDecoratorIterator:iterateIt(obj, index, outCount)
    if self.m_opl and self.m_opr then
        outCount = self.m_opr:getCount(obj)
        if index >= 0 and index < outCount then
            self.m_opl:setValueElement(obj, self.m_opr, index)
            return true, outCount
        end
    else
        BEHAVIAC_ASSERT(false, "cDecoratorIterator:iterateIt ")
    end

    return false, outCount
end

function cDecoratorIterator:createTask()
    BEHAVIAC_ASSERT(false, "cDecoratorIterator:createTask is empty")
    return false
end