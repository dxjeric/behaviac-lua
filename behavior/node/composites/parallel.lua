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
class("cParallel", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cParallel", cParallel)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cParallel", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- options when a parallel node is considered to be failed.
-- FAIL_ON_ONE: the node fails as soon as one of its children fails.
-- FAIL_ON_ALL: the node failes when all of the node's children must fail
-- If FAIL_ON_ONE and SUCEED_ON_ONE are both active and are both trigerred, it fails
EFAILURE_POLICY = {
    FAIL_ON_ONE = 0,
    FAIL_ON_ALL = 1,
}

-- options when a parallel node is considered to be succeeded.
-- SUCCEED_ON_ONE: the node will return success as soon as one of its children succeeds.
-- SUCCEED_ON_ALL: the node will return success when all the node's children must succeed.
ESUCCESS_POLICY = {
    SUCCEED_ON_ONE = 0,
    SUCCEED_ON_ALL = 1,
}

-- options when a parallel node is exited
-- EXIT_NONE: the parallel node just exit.
-- EXIT_ABORT_RUNNINGSIBLINGS: the parallel node abort all other running siblings.
EEXIT_POLICY = {
    EXIT_NONE = 0,
    EXIT_ABORT_RUNNINGSIBLINGS = 1
}

-- the options of what to do when a child finishes
-- CHILDFINISH_ONCE: the child node just executes once.
-- CHILDFINISH_LOOP: the child node runs again and again.
ECHILDFINISH_POLICY = {
    CHILDFINISH_ONCE = 0,
    CHILDFINISH_LOOP = 1
}

function cParallel:__init()
    self.m_failPolicy           = EFAILURE_POLICY.FAIL_ON_ONE
    self.m_succeedPolicy        = ESUCCESS_POLICY.SUCCEED_ON_ALL
    self.m_exitPolicy           = EEXIT_POLICY.EXIT_NONE
    self.m_childFinishPolicy    = ECHILDFINISH_POLICY.CHILDFINISH_LOOP
end

function cParallel:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(self, version, agentType, properties)

    for _, p in ipairs(properties) do
        if p.name == "FailurePolicy" then
            if p.value == "FAIL_ON_ONE" then
                self.m_failPolicy = EFAILURE_POLICY.FAIL_ON_ONE
            elseif p.value == "FAIL_ON_ALL" then
                self.m_failPolicy = EFAILURE_POLICY.FAIL_ON_ALL
            else
                _G.BEHAVIAC_ASSERT(false, "cParallel:loadByProperties FailurePolicy error value = %s", p.value)
            end
        elseif p.name == "SuccessPolicy" then
            if p.value == "SUCCEED_ON_ONE" then
                self.m_succeedPolicy = ESUCCESS_POLICY.SUCCEED_ON_ONE
            elseif p.value == "SUCCEED_ON_ALL" then
                self.m_succeedPolicy = ESUCCESS_POLICY.SUCCEED_ON_ALL
            else
                _G.BEHAVIAC_ASSERT(false, "cParallel:loadByProperties SuccessPolicy error value = %s", p.value)
            end
        elseif p.name == "ExitPolicy" then
            if p.value == "EXIT_NONE" then
                self.m_exitPolicy = EEXIT_POLICY.EXIT_NONE
            elseif p.value == "EXIT_ABORT_RUNNINGSIBLINGS" then
                self.m_exitPolicy = EEXIT_POLICY.EXIT_ABORT_RUNNINGSIBLINGS
            else
                _G.BEHAVIAC_ASSERT(false, "cParallel:loadByProperties ExitPolicy error value = %s", p.value)
            end
        elseif p.name == "ChildFinishPolicy" then
            if p.value == "CHILDFINISH_ONCE" then
                self.m_childFinishPolicy = ECHILDFINISH_POLICY.CHILDFINISH_ONCE
            elseif p.value == "CHILDFINISH_LOOP" then
                self.m_childFinishPolicy = ECHILDFINISH_POLICY.CHILDFINISH_LOOP
            else
                _G.BEHAVIAC_ASSERT(false, "cParallel:loadByProperties ChildFinishPolicy error value = %s", p.value)
            end
        else
            -- _G.BEHAVIAC_ASSERT(false)
        end
    end
end

function cParallel:parallelUpdate(obj, children)
    local sawSuccess    = false
    local sawFail       = false
    local sawRunning    = false
    local sawAllFails   = true
    local sawAllSuccess = true

    local bLoop = (self.m_childFinishPolicy == ECHILDFINISH_POLICY.CHILDFINISH_LOOP)

    -- go through all m_children
    for _, pChild in ipairs(children) do
        local treeStatus = pChild:getStatus()
        if bLoop or treeStatus == EBTStatus.BT_RUNNING or treeStatus == EBTStatus.BT_INVALID then
            local status = pChild:exec(obj)
            if status == EBTStatus.BT_FAILURE then
                sawFail = true
                sawAllSuccess = false
            elseif status == EBTStatus.BT_SUCCESS then
                sawSuccess = true
                sawAllFails = false
            elseif status == EBTStatus.BT_RUNNING then
                sawRunning = true
                sawAllFails = false
                sawAllSuccess = false
            end
        elseif treeStatus == EBTStatus.BT_SUCCESS then
            sawSuccess = true
            sawAllFails = false
        else
            _G.BEHAVIAC_ASSERT(treeStatus == EBTStatus.BT_FAILURE)
            sawFail = true
            sawAllSuccess = false
        end
    end

    local result = sawRunning and EBTStatus.BT_RUNNING or EBTStatus.BT_FAILURE
    if (self.m_failPolicy == EFAILURE_POLICY.FAIL_ON_ALL and sawAllFails) or
       (self.m_failPolicy == EFAILURE_POLICY.FAIL_ON_ONE and sawFail) then
        result = EBTStatus.BT_FAILURE
    elseif (self.m_succeedPolicy == ESUCCESS_POLICY.SUCCEED_ON_ALL and sawAllSuccess) or
       (self.m_succeedPolicy == ESUCCESS_POLICY.SUCCEED_ON_ONE and sawSuccess) then
        result = EBTStatus.BT_SUCCESS
    end

    if self.m_exitPolicy == EEXIT_POLICY.EXIT_ABORT_RUNNINGSIBLINGS and (result == EBTStatus.BT_FAILURE or result == EBTStatus.BT_SUCCESS) then
        for _, pChild in ipairs(children) do
            local treeStatus = pChild:getStatus()
            if treeStatus == EBTStatus.BT_RUNNING then
                pChild:abort(obj)
            end
        end
    end

    return result
end

function cParallel:isManagingChildrenAsSubTrees()
    return true
end

function cParallel:isValid(obj, task)
    if not task:getNode() or not task:getNode():isParallel() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end

function cParallel:setPolicy(failPolicy, successPolicy, exitPolicty)
    if not failPolicy then
        failPolicy = EFAILURE_POLICY.FAIL_ON_ALL
        d_ms.d_log.error("cParallel:setPolicy failPolicy default is = FAIL_ON_ALL")
    end
    
    if not successPolicy then
        successPolicy = ESUCCESS_POLICY.SUCCEED_ON_ALL
        d_ms.d_log.error("cParallel:setPolicy successPolicy default is = SUCCEED_ON_ALL")
    end
    if not exitPolicty then
        exitPolicty = EEXIT_POLICY.EXIT_NONE
        d_ms.d_log.error("cParallel:setPolicy exitPolicty default is = EXIT_NONE")
    end
    self.m_failPolicy    = failPolicy
    self.m_succeedPolicy = successPolicy
    self.m_exitPolicy    = exitPolicty
end

function cParallel:createTask()
    return d_ms.d_parallelTask.cParallelTask.new()
end

