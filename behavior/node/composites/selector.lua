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
module "behavior.node.composites.selector"
------------------------------------------------------------------------------------------------------
class("cSelector", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cSelector", cSelector)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSelector", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- Selectors tick each of their children one at a time from top to bottom. If a child returns
-- Success, then so does the Selector. If it returns Failure, the Selector will move on to the
-- next child in line and return Running.If a child returns Running, so does the Selector and
-- that same child will be ticked again next time the Selector is ticked. Once the Selector
-- reaches the end of its child list, it returns Failure and resets its child index – meaning
-- the first child in the line will be ticked on the next tick of the Selector.
function cSelector:__init()
end

function cSelector:isValid(obj, task)
    if not task:getNode() or not task:getNode():isSelector() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end

function cSelector:SelectorUpdate(obj, childStatus, outActiveChildIndex, children)
    local s = childStatus
    local childSize = #children

    if outActiveChildIndex == 0 then
        d_ms.d_log.error("cSelector:SelectorUpdate outActiveChildIndex == 0")
        outActiveChildIndex = 1
    end

    while true do
        _G.BEHAVIAC_ASSERT(outActiveChildIndex <= childSize, "cSelector:SelectorUpdate outActiveChildIndex %d < childSize %d", outActiveChildIndex, childSize)
        if s == EBTStatus.BT_RUNNING then
            local pBehavior = children[outActiveChildIndex]

            if self:checkIfInterrupted(obj) then
                return EBTStatus.BT_FAILURE, outActiveChildIndex
            end

            s = pBehavior:exec(obj)
        end

        -- If the child succeeds, or keeps running, do the same.
        if s ~= EBTStatus.BT_FAILURE then
            return s, outActiveChildIndex
        end

        -- Hit the end of the array, job done!
        outActiveChildIndex = outActiveChildIndex + 1

        if outActiveChildIndex > childSize then
            return EBTStatus.BT_FAILURE, outActiveChildIndex
        end

        s = EBTStatus.BT_RUNNING, outActiveChildIndex
    end
end

function cSelector:evaluate(obj)
    local ret = true
    for _, child in ipairs(self.m_children) do
        ret = child:evaluate(obj)
        if ret then
            break
        end
    end
    return ret
end

function cSelector:checkIfInterrupted(obj)
    return self:evaluteCustomCondition(pAgent);
end

function cSelector:createTask()
    return d_ms.d_selectorTask.cSelectorTask.new()
end