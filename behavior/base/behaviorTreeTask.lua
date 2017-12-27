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
module "behavior.base.behaviorTreeTask"
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef        = d_ms.d_behaviorCommon.constBaseKeyStrDef
local triggerMode               = d_ms.d_behaviorCommon.triggerMode
local EBTStatus                 = d_ms.d_behaviorCommon.EBTStatus
local constInvalidChildIndex    = d_ms.d_behaviorCommon.constInvalidChildIndex
------------------------------------------------------------------------------------------------------
class("cBehaviorTreeTask", d_ms.d_singeChildTask.cSingeChildTask)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cBehaviorTreeTask", cBehaviorTreeTask)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cBehaviorTreeTask", "cSingeChildTask")
------------------------------------------------------------------------------------------------------
function cBehaviorTreeTask:__init()
    self.m_lastTreeTask = false     -- REDO: 默认值
    self.m_endStatus    = -1        -- REDO: 默认值
    self.m_localVars    = {}        -- behaviac::map<uint32_t, IInstantiatedVariable*>
end

function cBehaviorTreeTask:setRootTask(pRootBehaviorTask)
    self:addChild(pRootBehaviorTask)
end
------------------------------------------------------------------------------------------------------
-- 这块是不需要的处理处理
-- BehaviorTreeTask target
function cBehaviorTreeTask:CopyTo(target)
    -- 同copyTo()
    d_ms.d_log.error("cBehaviorTreeTask:CopyTo 不需要函数")
end

function cBehaviorTreeTask:Save(ioNode)
    d_ms.d_log.error("cBehaviorTreeTask:Save 不需要函数")
end

function cBehaviorTreeTask:Load(ioNode)
    d_ms.d_log.error("cBehaviorTreeTask:Load 不需要函数")
end

-- return false if the event handling  needs to be stopped
-- return true, the event hanlding will be checked furtherly
-- function cBehaviorTreeTask:onEvent(obj, eventName, eventParams)
-- end
------------------------------------------------------------------------------------------------------
function cBehaviorTreeTask:resume(obj, status)
    return d_ms.d_singeChildTask.cSingeChildTask.resumeBranch(self, obj, status)
end

-- template<typename VariableType> void BehaviorTreeTask::SetVariable(const char* variableName, VariableType value
function cBehaviorTreeTask:setVariable(variableName, value)
    self.m_localVars[variableName] = value
end

function cBehaviorTreeTask:addVariables(vars)
    if vars then
         for varName, var in pairs(vars) do
            self.m_localVars[varName] = var
         end
    end
end

-- return the path relative to the workspace path
function cBehaviorTreeTask:getName()
    BEHAVIAC_ASSERT(self.m_node, "cBehaviorTreeTask:getName m_node is not exist")
    BEHAVIAC_ASSERT(self.m_node:isBehaviorTree(), "cBehaviorTreeTask:getName m_node:isBehaviorTree")

    return self.m_node:getName()
end

function cBehaviorTreeTask:clear()
    if self.m_node then
        BEHAVIAC_ASSERT(self.m_node:isBehaviorTree(), "cBehaviorTreeTask:clear m_node:isBehaviorTree")
        -- self.m_node:unInstantiatePars(self.m_localVars)
        self.m_localVars = {}
    end

    d_ms.d_behaviorTask.cBehaviorTask.clear(self)

    self.m_root:release()
    self.m_root = false
    self.m_currentTask = false
end

function cBehaviorTreeTask:setEndStatus(status)
    self.m_endStatus = status
end

function endHandler(node, obj, userData)
    if (node.m_status == EBTStatus.BT_RUNNING || node.m_status == EBTStatus.BT_INVALID)  then
        node:onExitAction(obj, userData)
        node.m_status = userData
        node:setCurrentTask(false)
    end

    return true
end

function cBehaviorTreeTask:endDo(obj, status)
    self:traverse(true, endHandler, obj, status)
end

function cBehaviorTreeTask:init(behaviorNode)
    BEHAVIAC_ASSERT(behaviorNode, "cBehaviorTreeTask:init behaviorNode is nil")

    d_ms.d_singeChildTask.cSingeChildTask.init(self, behaviorNode)
    if self.m_node then
        BEHAVIAC_ASSERT(self.m_node:isBehaviorTree(), "cBehaviorTreeTask:init m_node:isBehaviorTree")
        self.m_node:instantiatePars(self.m_localVars)
    end
end

function cBehaviorTreeTask:onEnter(obj)
    print("cBehaviorTreeTask:onEnter", obj.m_objName, self:getName())
    return true
end

function cBehaviorTreeTask:onExit(obj, status)
    obj.m_excutingTreeTask = self.m_lastTreeTask
    print("cBehaviorTreeTask:onExit", obj.m_objName, self:getName())
    d_ms.d_singeChildTask.cSingeChildTask.onExit(self, obj, status)
end

function cBehaviorTreeTask:updateCurrent(obj, childStatus)
    BEHAVIAC_ASSERT(self.m_node, "cBehaviorTreeTask:updateCurrent self.m_node is nil")
    BEHAVIAC_ASSERT(self.m_node:isBehaviorTree(), "cBehaviorTreeTask:updateCurrent m_node:isBehaviorTree")

    self.m_lastTreeTask = obj.m_excutingTreeTask
    obj.m_excutingTreeTask = self

    local tree = self.m_node
    local status = EBTStatus.BT_RUNNING
    if tree:isFSM() then
        status = self:update(obj, childStatus)
    else
        status = d_ms.d_singeChildTask.cSingeChildTask.updateCurrent(self, obj, childStatus)
    end

    return status
end

function cBehaviorTreeTask:update(obj, childStatus)
    BEHAVIAC_ASSERT(self.m_node, "cBehaviorTreeTask:update self.m_node is false")
    BEHAVIAC_ASSERT(self.m_root, "cBehaviorTreeTask:update self.m_root is false")

    if childStatus ~= EBTStatus.BT_RUNNING then
        return childStatus
    end

    local status = EBTStatus.BT_INVALID
    self.m_endStatus = EBTStatus.BT_INVALID
    status = d_ms.d_singeChildTask.cSingeChildTask.update(self, obj, childStatus)
    BEHAVIAC_ASSERT(status ~= EBTStatus.BT_INVALID, "cBehaviorTreeTask:update status == EBTStatus.BT_INVALID")
    
    -- When the End node takes effect, it always returns BT_RUNNING
    -- and m_endStatus should always be BT_SUCCESS or BT_FAILURE
    if status == EBTStatus.BT_RUNNING and self.m_endStatus ~= EBTStatus.BT_INVALID then
        self:endDo(obj, self.m_endStatus)
        return self.m_endStatus
    end

    return status
end