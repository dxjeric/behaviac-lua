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
module "behavior.base.singeChildTask"
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef        = d_ms.d_behaviorCommon.constBaseKeyStrDef
local triggerMode               = d_ms.d_behaviorCommon.triggerMode
local EBTStatus                 = d_ms.d_behaviorCommon.EBTStatus
local constInvalidChildIndex    = d_ms.d_behaviorCommon.constInvalidChildIndex
------------------------------------------------------------------------------------------------------
class("cSingeChildTask", d_ms.d_branchTask.cBranchTask)
ADD_BEHAVIAC_DYNAMIC_TYPE("cSingeChildTask", cSingeChildTask)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cSingeChildTask", "cBranchTask")
------------------------------------------------------------------------------------------------------
function cSingeChildTask:__init()
    self.m_root = false     -- BehaviorTask
end

function cSingeChildTask:release()
    d_ms.d_branchTask.cBranchTask.release(self)
    if self.m_root then
        self.m_root:release()
    end
    self.m_root = false
end

function cSingeChildTask:traverse(childFirst, handler, obj, userData)
    if childFirst then
        if self.m_root then
            self.m_root:traverse(childFirst, handler, obj, userData)
        end
        handler(self, obj, userData)
    else
        if handler(self, obj, userData) then
            if self.m_root then
                self.m_root:traverse(childFirst, handler, obj, userData)
            end
        end
    end
end

function cSingeChildTask:init(behaviorNode)
    d_ms.d_branchTask.cBranchTask.init(self, behaviorNode)
    BEHAVIAC_ASSERT(behaviorNode:getChildrenCount() <= 1, "cSingeChildTask:init behaviorNode:getChildrenCount() <= 1")
    
    if behaviorNode:getChildrenCount() == 1 then
        local childNode = behaviorNode:getChild(1)
        local childTask = childNode:createAndInitTask()
        self.addChild(childTask)
    else
        d_ms.d_log.error("cSingeChildTask:init do nothing")
    end
end

-- BehaviorTask
function cSingeChildTask:copyTo(target)
    d_ms.d_branchTask.cBranchTask.copyTo(self, target)
    BEHAVIAC_ASSERT(target:isSingeChildTask(), "cSingeChildTask:copyTo target:isSingeChildTask")
    
    if self.m_root then
        if target.m_root then
            local pNode = self.m_root:getNode()
            BEHAVIAC_ASSERT(pNode:isBehaviorTree(), "cSingeChildTask:copyTo pNode:isBehaviorTree")
            target.m_root = pNode:createAndInitTask()
        end

        BEHAVIAC_ASSERT(target.m_root, "cSingeChildTask:copyTo target.m_root")
        self.m_root:copyTo(target.m_root)
    end
end

function cSingeChildTask:save()
    d_ms.d_log.error("cSingeChildTask:save is empty")
end

function cSingeChildTask:load()
    d_ms.d_log.error("cSingeChildTask:save is empty")
end

function cSingeChildTask:update(obj, childStatus)
    if self.m_root then
        return self.m_root:execByInputChildStatus(obj, childStatus)
    end

    return EBTStatus.BT_FAILURE
end

-- BehaviorTask pBehavior
function cSingeChildTask:addChild(pBehavior)
    pBehavior:setParent(self)
    self.m_root = pBehavior
end

function cSingeChildTask:getTaskById(id)
    BEHAVIAC_ASSERT(id ~= -1);
    
    local behaviorTask = d_ms.d_branchTask.cBranchTask.getTaskById(self, id)
    if behaviorTask then
        return behaviorTask
    end

    if self.m_root:getId() == id then
        return self.m_root
    end

    return self.m_root:getTaskById(id)
end