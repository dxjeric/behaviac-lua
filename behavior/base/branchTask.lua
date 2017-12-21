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
module "behavior.base.branchTask"
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef    = d_ms.d_behaviorCommon.constBaseKeyStrDef
local triggerMode           = d_ms.d_behaviorCommon.triggerMode
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
------------------------------------------------------------------------------------------------------
class("cBranchTask")
ADD_BEHAVIAC_DYNAMIC_TYPE("cBranchTask", cBranchTask)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cBranchTask", "cBehaviorTask")
------------------------------------------------------------------------------------------------------
function cBranchTask:__init()
    -- bookmark the current ticking node, it is different from m_activeChildIndex
    self.m_currentNodeId = -1
    self.m_currentTask   = false
end

function cBranchTask:traverse(childFirst, handler, obj, userData)
	handler(self, obj, userData)
end

-- Set the m_currentTask as task
-- if the leaf node is runninng ,then we should set the leaf's parent node also as running
function cBranchTask:setCurrentTask(behaviorTask)
    if behaviorTask then
        -- if the leaf node is running, then the leaf's parent node is also as running,
        -- the leaf is set as the tree's current task instead of its parent
        if not self.m_currentTask then
            self.m_currentTask = behaviorTask
            behaviorTask:setHasManagingParent(true)
        end
    else
        if self.m_status != EBTStatus.BT_RUNNING then
            self.m_currentTask = behaviorTask
        end
    end
end

function cBranchTask:getCurrentTask()
    return self.m_currentTask
end

function cBranchTask:getCurrentNodeId()
    return self.m_currentNodeId
end

function cBranchTask:setCurrentNodeId(id)
    self.m_currentNodeId = id
end

function getIdHandler(behaviorTask, obj, userData)
    local oldId = behaviorTask:getId()

    if oldId == userData.id_ then
        userdata.task_ = behaviorTask
        return false
    end

    return true
end

function cBranchTask:copyTo(behaviorTask)
    d_ms.d_behaviorTask.cBehaviorTask.copyTo(self, behaviorTask)

    if not behaviorTask:isBranchTask() then
        d_ms.d_log.error("cBranchTask:copyTo task is not cBranchTask")
        return
    end

    if self.m_currentTask then
        local id = self.m_currentTask:getId()
        local data = {id_ = id}
        behaviorTask:traverse(true, , false, data)
        behaviorTask.m_currentTask = data.task_
    end
end

function cBranchTask:execCurrentTask(obj, childStatus)
    if self.m_currentTask then
        if self.m_currentTask:getStatus() ~= EBTStatus.BT_RUNNING then
            d_ms.d_log.error("cBranchTask:execCurrentTask m_currentTask status (%d) is not running", self.m_currentTask:getStatus())
            return EBTStatus.BT_FAILURE
        end

        -- this->m_currentTask could be cleared in ::tick, to remember it        
        local status = self.m_currentTask:execByInputChildStatus(obj, childStatus)

        -- give the handling back to parents
        if status ~= EBTStatus.BT_RUNNING then
            if not (status == EBTStatus.BT_SUCCESS or status == EBTStatus.BT_FAILURE) then
                d_ms.d_log.error("status %d is error", status)
                return EBTStatus.BT_FAILURE
            end

            if self.m_currentTask.m_status ~= status then
                d_ms.d_log.error("status %d is error ~= m_currentTask.m_status", status)
                return EBTStatus.BT_FAILURE
            end

            local parentBranch = self.m_currentTask:getParent()
            self.m_currentTask = false
            -- back track the parents until the branch
            while parentBranch do
                if parentBranch == self then
                    status = parentBranch:udpate()
                else
                    status = parentBranch:execByInputChildStatus(obj, status)
                end

                if status == EBTStatus.BT_RUNNING then
                    return EBTStatus.BT_RUNNING
                end

                if parentBranch ~= self and parentBranch->m_status == status then
                    return EBTStatus.BT_FAILURE
                end

                if parentBranch == self then
                    break
                end

                parentBranch = parentBranch:getParent()
            end
        end
    end

    return EBTStatus.BT_FAILURE
end

function cBranchTask:onEvent(obj, eventName, eventParams)
    if self.m_node:hasEvents() then
        local bGoOn = true

        if self.m_currentTask then
            bGoOn = self:onEventCurrentNode(obj, eventName, eventParams)
        end

        if bGoOn then
            bGoOn = d_ms.d_behaviorTask.cBehaviorTask.onEvent(self, obj, eventName, eventParams)
        end
    end

    return true
end

function cBranchTask:onEnter()
    return true
end

function cBranchTask:onExit()
    -- do nothing
end

function cBranchTask:updateCurrent(obj, childStatus)
    local status = EBTStatus.BT_INVALID
    if self.m_currentTask then
        status = self:execCurrentTask(obj, childStatus)

    else
        status = self:update(obj, childStatus)
    end

    return status
end

function cBranchTask:resumeBranch(obj, status)
    if not self.m_currentTask then
        d_ms.d_log.error("cBranchTask:resumeBranch no current task")
        return EBTStatus.BT_INVALID
    end

    if not(status == EBTStatus.BT_SUCCESS or status == EBTStatus.BT_FAILURE) then
        d_ms.d_log.error("cBranchTask:resumeBranch error status %", status)
        return EBTStatus.BT_INVALID
    end

    local parent = false
    local _tNode = self.m_currentTask.m_node
    if _tNode:isManagingChildrenAsSubTrees() then
        parent = self.m_currentTask
    else
        parent = self.m_currentTask:getParent()
    end

    -- clear it as it ends and the next exec might need to set it
    self.m_currentTask = false
    return parent:execByInputChildStatus(obj, status)
end

function cBranchTask:onEventCurrentNode()
    if self.m_currentTask then
        local s = self.m_currentTask:getStatus()
        if not (s == EBTStatus.BT_RUNNING and self.m_node:hasEvents()) then
            d_ms.d_log.error("BEHAVIAC_ASSERT cBranchTask:onEventCurrentNode")
            return false
        end

        local bGoOn = self.m_currentTask:onEvent(obj, eventName, eventParams)
        -- give the handling back to parents
        if bGoOn and self.m_currentTask then
            parentBranch = self.m_currentTask:getParent()
            while parentBranch and parentBranch ~= self do
                if parentBranch:getStatus() == EBTStatus.BT_RUNNING then
                    d_ms.d_log.error("BEHAVIAC_ASSERT cBranchTask:onEventCurrentNode")
                    return false
                end

                bGoOn = parentBranch:onEvent(obj, eventName, eventParams)
                if not bGoOn then
                    return false
                end

                parentBranch = parentBranch:getParent()
            end
        end
    end
    return true
end