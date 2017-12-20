--------------------------------------------------------------------------------------------------------------
-- 行为树 动作节点
--------------------------------------------------------------------------------------------------------------
require "base.behaviorCommon"
--------------------------------------------------------------------------------------------------------------
d_ms.d_behaviorNode = require "base.behaviorNode"
--------------------------------------------------------------------------------------------------------------
class("cAction", d_ms.d_behaviorNode.cBehaviorNode)
ADD_BEHAVIAC_DYNAMIC_TYPE("cAction", cAction)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cAction", "cBehaviorNode")
--------------------------------------------------------------------------------------------------------------
function cAction:__init()
    self.m_method        = false        -- REDO: 这个数据结构？
    self.m_resultFunctor = false        -- REDO: 这个数据结构？
    self.m_resultOption  = EBTStatus.BT_INVALID
end

function cAction:release()
    -- REDO: 释放数据
    self.m_method = false
    self.m_resultFunctor = false
end

-- 加载action数据
function cAction:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(version, agentType, properties)

    for _, propertie in ipairs(properties) do
        if propertie.name == "Method" then
            self.m_method = BehaviorParseFactory.parseMethod(propertie.value)
        elseif propertie.name == "ResultOption" then
            if propertie.value == "BT_INVALID" then
                self.m_resultOption = EBTStatus.BT_INVALID
            elseif propertie.value == "BT_FAILURE" then
                self.m_resultOption = EBTStatus.BT_FAILURE
            elseif propertie.value == "BT_RUNNING" then
                self.m_resultOption = EBTStatus.BT_RUNNING
            else
                self.m_resultOption = EBTStatus.BT_SUCCESS
            end
        elseif propertie.name == "ResultFunctor" then
            self.m_resultFunctor = BehaviorParseFactory.parseMethod(propertie.value)
        else
            -- do nothing
        end
    end
end

-- 执行处理
-- 参数1: 执行的对象
-- 返回值: 返回 EBTStatus
function cAction:execute(obj)
    local result = 
end

-- 执行处理
-- 参数1: 执行的对象
-- 参数2: 子节点状态
-- 返回值: 返回 EBTStatus
function cAction:executeByInputChildStatus(obj, childSatus)
end

-- 创建任务
function cAction:createTask()
end

-- 是否有有效
-- 参数1: 执行对象
-- 参数2: 需要检测的任务
-- 返回值: true(有效) false(无效)
function cAction:IsValid(obj, task)
    return false
end