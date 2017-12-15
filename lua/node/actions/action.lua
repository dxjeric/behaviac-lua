--------------------------------------------------------------------------------------------------------------
-- 行为树 动作节点
--------------------------------------------------------------------------------------------------------------
require "base.behaviorCommon"
--------------------------------------------------------------------------------------------------------------
local d_behaviorNode = require "base.behaviorNode"
--------------------------------------------------------------------------------------------------------------
class("cAction", d_behaviorNode.cBehaviorNode)
--------------------------------------------------------------------------------------------------------------
function cAction:__init()
    self.m_method        = {}
    self.m_resultFunctor = {}
    self.m_resultOption  = EBTStatus.BT_INVALID
end

-- 加载action数据
function cAction:load()
end

-- 执行处理
-- 参数1: 执行的对象
-- 参数2: 子节点状态
-- 返回值: 返回 EBTStatus
function cAction:Execute(obj, childSatus)
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