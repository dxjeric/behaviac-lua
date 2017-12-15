------------------------------------------------------------------------------------------------------
-- 行为树 任务节点
------------------------------------------------------------------------------------------------------
local table = table
------------------------------------------------------------------------------------------------------
d_ms.d_behaviorCommon = require("base.behaviorCommon")
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef    = d_ms.d_behaviorCommon.constBaseKeyStrDef
local triggerMode           = d_ms.d_behaviorCommon.triggerMode
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
------------------------------------------------------------------------------------------------------
class("cBehaviorTask")
ADD_BEHAVIAC_DYNAMIC_TYPE("cBehaviorTask", cBehaviorTask)
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
    self.m_parent   = 0
    self.m_id       = -1
    self.m_node     = 0
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
end

function cBehaviorTask:updateCurrent(obj, childStatus)
end

function cBehaviorTask:getCurrentTask()
end

function cBehaviorTask:getTopManageBranchTask()
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
end

function cBehaviorTask:onExitAction(obj, status)
end

------------------------------------------------------------------------------------------------------
function getRunningNodesHandler()
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

function abortHandler()
end

function cBehaviorTask:abort(obj)
    self:traverse(true, abortHandler, obj)
end

function resetHandler()
end
function cBehaviorTask:reset(obj)
    self:traverse(true, resetHandler, obj)
end
------------------------------------------------------------------------------------------------------
function cBehaviorTask:getRootTask()
    local task = self
    while task.m_parent do
        task = task.m_parent
    end

    assert(task.isBehaviorTreeTask(), "cBehaviorTask:getRootTask is not BehaviorTreeTask")
    return tree;
end



