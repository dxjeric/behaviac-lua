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
local EBTStatus              = d_ms.d_behaviorCommon.EBTStatus
local BehaviorParseFactory   = d_ms.d_behaviorCommon.BehaviorParseFactory
local constInvalidChildIndex = d_ms.d_behaviorCommon.constInvalidChildIndex
------------------------------------------------------------------------------------------------------
module "behavior.node.actions.selectorLoopTask"
------------------------------------------------------------------------------------------------------
class("cSelectorLoopTask", d_ms.d_compositeTask.cCompositeTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cSelectorLoopTask", cSelectorLoopTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSelectorLoopTask", "cCompositeTask")
------------------------------------------------------------------------------------------------------
function cSelectorLoopTask:__init()
end

function cSelectorLoopTask:copyTo(target)
    d_ms.d_compositeTask.cCompositeTask.copyTo(target)

    _G.BEHAVIAC_ASSERT(target:isSelectorLoopTask(), "cSelectorLoopTask:copyTo target:isSelectorLoopTask")
    target.m_activeChildIndex = self.m_activeChildIndex
end

function cSelectorLoopTask:addChild(pBehaviorTask)
    d_ms.d_compositeTask.cCompositeTask.addChild(self, pBehaviorTask)
    _G.BEHAVIAC_ASSERT(pBehaviorTask:isWithPreconditionTask(), "cSelectorLoopTask:addChild pBehaviorTask:isWithPreconditionTask")
end

function cSelectorLoopTask:onEnter(obj)
    self.m_activeChildIndex = constInvalidChildIndex
    d_ms.d_compositeTask.cCompositeTask.onEnter(self, obj)
end

function cSelectorLoopTask:updateCurrent(obj, childStatus)
    return self:update(obj, childStatus)
end

function cSelectorLoopTask:update(obj, childStatus)
    local idx = 0

    if childStatus ~= EBTStatus.BT_RUNNING then
        _G.BEHAVIAC_ASSERT(self.m_activeChildIndex ~= constInvalidChildIndex, "cSelectorLoopTask:update self.m_activeChildIndex ~= constInvalidChildIndex")
        if childStatus == EBTStatus.BT_SUCCESS then
            return EBTStatus.BT_SUCCESS;
        elseif childStatus == EBTStatus.BT_FAILURE then
            -- the next for starts from (idx + 1), so that it starts from next one after this failed one
            idx = self.m_activeChildIndex
        else
            _G.BEHAVIAC_ASSERT(false)
        end
    end

    -- checking the preconditions and take the first action tree
    local index = -1
    for i = idx + 1, i < #self.m_children do
        local pSubTree = self.m_children[i]
        _G.BEHAVIAC_ASSERT(pSubTree:isWithPreconditionTask(), "cSelectorLoopTask:update pSubTree:isWithPreconditionTask")
        local preBehaviorTask = pSubTree:preconditionNode()
        local status = preBehaviorTask:exec(obj)
        if status == EBTStatus.BT_SUCCESS then
            index = i
            break
        end
    end

    -- clean up the current ticking action tree
    if index ~= -1 then
        if self.m_activeChildIndex ~= constInvalidChildIndex then
            local abortChild = self.m_activeChildIndex ~= index
            if not abortChild then
                local pSelectorLoop = self:getNode():isSelectorLoop()
                _G.BEHAVIAC_ASSERT(pSelectorLoop, "cSelectorLoopTask:update pSelectorLoop")

                if pSelectorLoop then
                    abortChild = pSelectorLoop.m_bResetChildren
                end
            end

            if abortChild then
                local pCurrentSubTree = self.m_children[self.m_activeChildIndex]
                _G.BEHAVIAC_ASSERT(pCurrentSubTree:isWithPreconditionTask(), "cSelectorLoopTask:update pCurrentSubTree:isWithPreconditionTask")
                pCurrentSubTree:abort(obj)
            end
        end

        local i = index
        for i = index, i <= #self.m_children do
            -- WithPreconditionTask
            local pSubTree = self.m_children[i]
            _G.BEHAVIAC_ASSERT(pSubTree:isWithPreconditionTask(), "cSelectorLoopTask:update pSubTree:isWithPreconditionTask")

            if i > index then
                local pre = pSubTree:preconditionNode()
                local status = pre:exec(obj)

                -- to search for the first one whose precondition is success
                if status == EBTStatus.BT_SUCCESS then
                    local action = pSubTree:actionNode()
                    local s = action:exec(obj)
        
                    if s == EBTStatus.BT_RUNNING then
                        self.m_activeChildIndex = i
                        pSubTree.m_status = EBTStatus.BT_RUNNING
                        return s
                    else
                        pSubTree.m_status = s
                        if s ~= EBTStatus.BT_FAILURE then
                            -- THE ACTION failed, to try the next one
                            _G.BEHAVIAC_ASSERT(s == EBTStatus.BT_RUNNING or s == EBTStatus.BT_SUCCESS, "cSelectorLoopTask:update s == EBTStatus.BT_RUNNING or s == EBTStatus.BT_SUCCESS")
                            return s
                        end
                    end
                end
            end
        end
    end
    return EBTStatus.BT_FAILURE
end
