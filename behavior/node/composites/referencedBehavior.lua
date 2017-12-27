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
module "behavior.node.composites.parallel"
------------------------------------------------------------------------------------------------------
class("cReferencedBehavior", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cReferencedBehavior", cReferencedBehavior)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cReferencedBehavior", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
function cReferencedBehavior:__init()
    self.m_referencedBehaviorPath = false
    self.m_taskMethod   = false
    self.m_transitions  = false
    self.m_taskNode     = false
end

function cReferencedBehavior:release()
    d_ms.d_behaviorNode.cBehaviorNode.release(self)
    self.m_referencedBehaviorPath = false
    self.m_taskMethod   = false
    self.m_transitions  = false
    self.m_taskNode     = false
end

function cReferencedBehavior:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "ReferenceBehavior" then
            if stringUtils.isValidString(p.value) then
                local pParenthesis = string.find(p.value, '%(')
                if not pParenthesis then
                    self.m_referencedBehaviorPath = BehaviorParseFactory.parseProperty(p.value)
                else
                    self.m_referencedBehaviorPath = BehaviorParseFactory.parseMethod(p.value)
                end

                local szTreePath = self:getReferencedTree()
                -- conservatively make it true
                local bHasEvents = true
                if not stringUtils.isNullOrEmpty(szTreePath) then
                    if d_ms.d_behaviorTreeMgr.preloadBehaviors() then
                        -- it has a const tree path, so as to load the tree and check if that tree has events
                        local behaviorTree = d_ms.d_behaviorTreeMgr.loadBehaviorTree(szTreePath)
                        BEHAVIAC_ASSERT(behaviorTree, "")
                        if behaviorTree then
                            bHasEvents = behaviorTree:hasEvents()
                        end
                    end
                    self.m_bHasEvents = self.m_bHasEvents or bHasEvents
                end
            end
        elseif p.name == "Task" then
            BEHAVIAC_ASSERT(not stringUtils.isNullOrEmpty(p.value))
            self.m_taskMethod = BehaviorParseFactory.parseMethod(p.value)
        else
            -- BEHAVIAC_ASSERT(0, "unrecognised property %s", p.name)
        end
    end
end

function cReferencedBehavior:setTaskParams(obj, treeTask)
    if self.m_taskMethod then
        self.m_taskMethod:setTaskParams(obj, treeTask)
    end
end

function cReferencedBehavior:rootTaskNode(obj)
    if not self.m_taskNode then
        local bt = d_ms.d_behaviorTreeMgr.loadBehaviorTree(self:getReferencedTree(obj))

        if bt and bt:getChildrenCount() == 1 then
            self.m_taskNode = bt:getChild(1)
        end
    end

    return self.m_taskNode
end

function cReferencedBehavior:getReferencedTree(obj)
    BEHAVIAC_ASSERT(self.m_referencedBehaviorPath, "cReferencedBehavior:getReferencedTree m_referencedBehaviorPath")
    if self.m_referencedBehaviorPath then
        local str = self.m_referencedBehaviorPath:getValueByRetrunType(obj, false, "const char*")
        return str
    end
    return nil
end

function cReferencedBehavior:attach(pAttachment, bIsPrecondition, bIsEffector, bIsTransition)
    if bIsTransition then
        BEHAVIAC_ASSERT(not bIsEffector and not bIsPrecondition, "cReferencedBehavior:attach not bIsEffector and not bIsPrecondition")
        
        if not self.m_transitions then
            self.m_transitions = {}
        end

        BEHAVIAC_ASSERT(pAttachment:isTransition(), "cReferencedBehavior:attach pAttachment:isTransition")
        table.insert(self.m_transitions, pAttachment)
        return
    end

    BEHAVIAC_ASSERT(not bIsTransition, "cReferencedBehavior:attach bIsTransition")
    d_ms.d_behaviorNode.cBehaviorNode.attach(self, pAttachment, bIsPrecondition, bIsEffector, bIsTransition)
end

function cReferencedBehavior:isValid(obj, task)
    if not task:getNode() or not task:getNode():isReferencedBehavior() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end

function cReferencedBehavior:createTask()
    return d_ms.d_referencedBehaviorTask.cReferencedBehaviorTask.new()
end