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
module "behavior.base.behaviorTask"
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef    = d_ms.d_behaviorCommon.constBaseKeyStrDef
local triggerMode           = d_ms.d_behaviorCommon.triggerMode
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
------------------------------------------------------------------------------------------------------
class("cBehaviorTask")
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cBehaviorTask", cBehaviorTask)
------------------------------------------------------------------------------------------------------
function cBehaviorTask:__init()
    self.m_attachments  = false
    self.m_status       = EBTStatus.BT_INVALID
    self.m_node         = false
    self.m_parent       = false
    self.m_id           = -1
    self.m_bHasManagingParent = false
end
------------------------------------------------------------------------------------------------------
function cBehaviorTask:init(node)
    self.m_node = node
    self.m_id   = node:getId()
end

function cBehaviorTask:destroyTask(behaviorTask)
    behaviorTask:release()
end

function cBehaviorTask:release()
    self:freeAttachments()
end

function cBehaviorTask:freeAttachments()
    if self.m_attachments then
        for _, oneAttachment in ipairs(self.m_attachments) do
            oneAttachment:release()
        end

        self.m_attachments = false
    end
end

function cBehaviorTask:clear()
    self.m_status   = EBTStatus.BT_INVALID
    self.m_parent   = false
    self.m_id       = -1
    self.m_node     = false
    self:freeAttachments()
end
------------------------------------------------------------------------------------------------------
function cBehaviorTask:getTickInfoByNode(obj, node, action)
    d_ms.d_log.error("getTickInfoByNode is empty")
    return "cBehaviorTask:getTickInfoByNode"
end

function cBehaviorTask:getTickInfoByTask(obj, task, action)
    d_ms.d_log.error("getTickInfoByTask is empty")
    return "cBehaviorTask:getTickInfoByTask"
end

function cBehaviorTask:getId()
    return self.m_id
end

function cBehaviorTask:setId(id)
    self.m_id = id
end

function cBehaviorTask:getNode()
    return self.m_node
end

function cBehaviorTask:getStatus()
    return self.m_status
end

-- parent is BranchTask
function cBehaviorTask:setParent(parent)
    assert(parent.isBranchTask(), "cBehaviorTask:setParent must be BranchTask")
    self.m_parent = parent
end

-- 返回值 BranchTask
function cBehaviorTask:getParent()
    return self.m_parent
end

function cBehaviorTask:SetHasManagingParent(bHasManagingParent)
    self.m_bHasManagingParent = bHasManagingParent
end

function cBehaviorTask:getCurrentTask()
    return nil
end

function cBehaviorTask:setCurrentTask(taskNode)
    d_ms.d_log.error("derived class must be rewrite cBehaviorTask:setCurrentTask")
end

function cBehaviorTask:getRootTask()
    local task = self
    while task.m_parent do
        task = task.m_parent
    end

    assert(task.isBehaviorTreeTask(), "cBehaviorTask:getRootTask is not BehaviorTreeTask")
    return task
end
------------------------------------------------------------------------------------------------------
function cBehaviorTask:attach(attachment)
    if not self.m_attachments then
        self.m_attachments = {}
    end

    table.insert(self.m_attachments, attachment)
end

function cBehaviorTask:getTaskById(id)
    if self.m_id == id then
        return self
    end

    return nil
end

function cBehaviorTask:getNextStateId()
    d_ms.d_log.error("cBehaviorTask:getNextStateId return default -1")
    return -1
end

function cBehaviorTask:copyTo(behaviorTask)
    behaviorTask.m_status = self.m_status
end

function cBehaviorTask:save()
    d_ms.d_log.error("cBehaviorTask:save is empty")
end

function cBehaviorTask:load()
    d_ms.d_log.error("cBehaviorTask:load is empty")
end

function cBehaviorTask:getClassNameString()
    if self.m_node then
        return self.m_node:getClassNameString()
    end

    return "SubBT"
end
------------------------------------------------------------------------------------------------------
function cBehaviorTask:exec(obj)
    self:execByInputChildStatus(obj, EBTStatus.BT_RUNNING)
end

-- 同 EBTStatus exec(Agent* pAgent, EBTStatus childStatus)
function cBehaviorTask:execByInputChildStatus(obj, childStatus)
    local bEnterResult = false
    if self.m_status == EBTStatus.BT_RUNNING then
        bEnterResult = true
    else
        self.m_status = EBTStatus.BT_INVALID
        bEnterResult = self:onEnterAction(obj)
    end

    if bEnterResult then
        local bValid = self:checkParentUpdatePreconditions(obj)
        if bValid then
            self.m_status = self:updateCurrent(obj, childStatus)
        else
            self.m_status = EBTStatus.BT_FAILURE
            if self:getCurrentTask() then
                self:updateCurrent(obj, EBTStatus.BT_FAILURE)
            end
        end

        if self.m_status == EBTStatus.BT_RUNNING then
            -- clear it
            self:onExitAction(obj, self.m_status)
            -- this node is possibly ticked by its parent or by the topBranch who records it as currrent node so, we can't here reset the topBranch's current nod
        else
            local tree = self:getTopManageBranchTask()
            if tree then
                tree:setCurrentTask(self)
            end
        end
    else
        self.m_status = EBTStatus.BT_FAILURE
    end
    
    return self.m_status
end

function cBehaviorTask:checkParentUpdatePreconditions(obj)
    local bValid = true
    if self.m_bHasManagingParent then
        local bHasManagingParent    = false
        local kMaxParentsCount      = 512
        local parentsCount          = 0

        local parents = {}
        local parentBranch = self:getParent()
        table.insert(parents, self)        
        
        while parentBranch do
            if #parents < kMaxParentsCount then
                d_ms.d_log.error("cBehaviorTask:checkParentUpdatePreconditions  weird tree!")
                break
            end

            table.insert(parents, parentBranch)
            if parentBranch:getCurrentTask() == self then
                bHasManagingParent = true
                break
            end
            parentBranch = parentBranch:getParent()
        end

        if bHasManagingParent then
            for k = #parents, 1, -1 do
                bValid = parents[k]:checkPreconditions(obj, true)
                if not bValid then
                    break
                end
            end
        end
    else
        bValid = self:checkPreconditions(obj, true)
    end

    return bValid
end

function cBehaviorTask:update(obj, childStatus)
    return EBTStatus.BT_SUCCESS
end

function cBehaviorTask:updateCurrent(obj, childStatus)
    return self:update(obj, childStatus)
end

function cBehaviorTask:onReset(obj)
    d_ms.d_log.error("derived class must be rewrite cBehaviorTask:onReset")
end

-- return boolean
function cBehaviorTask:onEnter(obj)
    d_ms.d_log.error("derived class must be rewrite cBehaviorTask:onEnter")
    return true
end

function cBehaviorTask:onExit(obj, status)
    d_ms.d_log.error("derived class must be rewrite cBehaviorTask:onExit")
end

-- Get the Root of branch task
function cBehaviorTask:getTopManageBranchTask()
    local tree = nil
    local behaviorTask = self.m_parent

    while behaviorTask then
        if not behaviorTask:isBehaviorTreeTask() then
            -- to overwrite the child branch
            tree = behaviorTask
            break
        elseif behaviorTask.m_node and behaviorTask.m_node:isManagingChildrenAsSubTrees() then
            -- until it is Parallel/SelectorLoop, it's child is used as tree to store current task
            break
        elseif behaviorTask:isBranchTask() then
            tree = behaviorTask
        else
            assert(false, "cBehaviorTask:getTopManageBranchTask")
        end
        behaviorTask = behaviorTask.m_parent
    end

    return tree
end
------------------------------------------------------------------------------------------------------
function cBehaviorTask:isLeafTask()
    return false
end

function cBehaviorTask:isBehaviorTask()
    return true
end
------------------------------------------------------------------------------------------------------
function cBehaviorTask:onEnterAction(obj)
    local bResult = self:checkPreconditions(obj, false)
    if bResult then
        self.m_bHasManagingParent = false
        self:setCurrentTask(false)

        bResult = self:onEnter(obj)
        if not bResult then
            return false
        else
            -- do nothing
        end
    end

    return bResult
end

function cBehaviorTask:onExitAction(obj, status)
    self:onExit(obj, status)

    if self.m_node then
        local phase = ENodePhase.E_SUCCESS

        if status == EBTStatus.BT_FAILURE then
            phase = ENodePhase.E_FAILURE
        else
            assert(status == EBTStatus.BT_SUCCESS, string.format("status (%d) == EBTStatus.BT_SUCCESS", status))
        end
        self.m_node:applyEffects(obj, phase)
    end
end

------------------------------------------------------------------------------------------------------
function getRunningNodesHandler(node, obj, retNodes)
    if node.m_status == EBTStatus.BT_RUNNING then
        table.insert(retNodes, node)
    end

    return true
end

function cBehaviorTask:getRunningNodes(onlyLeaves)
    if onlyLeaves == nil then
        d_ms.d_log.error("cBehaviorTask:getRunningNodes onlyLeaves default value must be true")
        onlyLeaves = true
    end

    local nodes = {}
    self:traverse(true, getRunningNodesHandler, nil, nodes)
    if onlyLeaves and #nodes > 0 then
        local leaves = {}
        for _, one in ipairs(nodes) do
            if one:isLeafTask() then
                table.insert(leaves, one)
            end
        end
        return leaves
    end

    return nodes
end

function abortHandler(node, obj, voidInfo)
    if node.m_status == EBTStatus.BT_RUNNING then
        node:onExitAction(obj, EBTStatus.BT_FAILURE)
        node.m_status = EBTStatus.BT_FAILURE
        node:setCurrentTask(false)
    end

    return true
end

function cBehaviorTask:abort(obj)
    self:traverse(true, abortHandler, obj)
end

function resetHandler(node, obj, voidInfo)
    node.m_status = EBTStatus.BT_INVALID
    node:setCurrentTask(false)
    node:onReset(obj)
    return true
end

function cBehaviorTask:reset(obj)
    self:traverse(true, resetHandler, obj)
end

function endHandler(node, obj, status)
    if node.m_status == EBTStatus.BT_RUNNING or node.m_status == EBTStatus.BT_RUNNING then
        node:onExitAction(obj, status)
        node.m_status = status
        node:setCurrentTask(false)
    end

    return true
end

function checkEventHandler()
    d_ms.d_log.error("checkEventHandler not be used")
end

function cBehaviorTask:traverse(childFirst, handler, pAgent, userData)
    d_ms.d_log.error("derived class must be rewrite cBehaviorTask:onExit")    
end
------------------------------------------------------------------------------------------------------
-- return false if the event handling needs to be stopped an event can be configured to stop being checked if triggered
function cBehaviorTask:checkEvents(eventName, obj, eventParams)
    return self.m_node:checkEvents(eventName, obj, eventParams)
end

-- return false if the event handling  needs to be stopped
-- return true, the event hanlding will be checked furtherly
function cBehaviorTask:onEvent(obj, eventName, eventParams)
    if self.m_status == EBTStatus.BT_RUNNING and self.m_node.m_bHasEvents then
        if not self:checkEvents(eventName, obj, eventParams) then
            return false
        end
    end

    return true
end

function cBehaviorTask:checkPreconditions(obj, bIsAlive)
    local bResult = true
    if self.m_node then
        if #self.m_node.m_preconditions > 0 then
            bResult = self.m_node:checkPreconditions(obj, bIsAlive)
        end
    end
    return bResult
end