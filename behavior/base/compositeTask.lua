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
module "behavior.base.compositeTask"
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef    = d_ms.d_behaviorCommon.constBaseKeyStrDef
local triggerMode           = d_ms.d_behaviorCommon.triggerMode
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
------------------------------------------------------------------------------------------------------
class("cCompositeTask", d_ms.d_branchTask.cBranchTask)
ADD_BEHAVIAC_DYNAMIC_TYPE("cCompositeTask", cCompositeTask)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cCompositeTask", "cBranchTask")
------------------------------------------------------------------------------------------------------
-- 无效值
local constInvalidChildIndex = d_ms.d_behaviorCommon.constInvalidChildIndex
------------------------------------------------------------------------------------------------------
function cCompositeTask:__init()
    -- book mark the current child
    self.m_activeChildIndex = constInvalidChildIndex
    self.m_children         = {}
end

function cCompositeTask:release()
    d_ms.d_branchTask.cBranchTask.release(self)

    for _, child in ipairs(self.m_children) do
        child:release()
    end

    self.m_children = {}
end

function cCompositeTask:traverse(childFirst, handler, obj, userData)
    if childFirst then
        for _, child in ipairs(self.m_children) do
            child:traverse(childFirst, handler, obj, userData)
        end
        handler(self, obj, userData)
    else
        if handler(self, obj, userData) then
            for _, child in ipairs(self.m_children) do
                child:traverse(childFirst, handler, obj, userData)
            end
        end
    end
end

function cCompositeTask:getChildById(nodeId)
    for _, child in ipairs(self.m_children) do
        if child:getId() == nodeId then
            return child
        end
    end

    return nil
end

function cCompositeTask:init(node)
    d_ms.d_branchTask.cBranchTask.init(self, node)
    BEHAVIAC_ASSERT(node:getChildrenCount() > 0, "node:getChildrenCount() > 0")

    local childrenCount = node:getChildrenCount()
    for index = 1, childrenCount do
        local childNode = node:getChild(index)
        local childTask = childNode:createAndInitTask()
        self:addChild(childTask)
    end
end

function cCompositeTask:copyTo(targetTask)
    d_ms.d_branchTask.cBranchTask.copyTo(self, targetTask)

    BEHAVIAC_ASSERT(targetTask:isCompositeTask(), "targetTask:isCompositeTask()")
    targetTask.m_activeChildIndex = self.m_activeChildIndex

    BEHAVIAC_ASSERT(#self.m_children > 0, "self.m_children > 0")
    BEHAVIAC_ASSERT(#self.m_children == #targetTask.m_children, "#self.m_children == #targetTask.m_children")

    local count = #self.m_children
    for index = 1, count do
        local childTask = self.m_children[index]
        local childTTask = targetTask.m_children[index]
        childTask:copyTo(childTTask)
    end
end

function cCompositeTask:save(node)
    d_ms.d_log.error("cCompositeTask:save empty")
end

function cCompositeTask:load(node)
    d_ms.d_log.error("cCompositeTask:load empty")
end

function cCompositeTask:addChild(behaviorTask)
    behaviorTask:setParent(self)
    table.insert(self.m_children, behaviorTask)
end

function cCompositeTask:getTaskById(id)
    BEHAVIAC_ASSERT(id ~= -1, "getTaskById id ~= -1")
    
    local behaviorTask = d_ms.d_branchTask.cBranchTask.getTaskById(self, id)
    if behaviorTask then
        return behaviorTask
    end

    local count = #self.m_children
    for index = 1, count do
        local behaviorTaskChild = self.m_children[index]
        local childTask = behaviorTaskChild:getTaskById(id)

        if childTask then
            return childTask
        end
    end

    return nil
end