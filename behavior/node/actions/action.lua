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
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.actions.action"
------------------------------------------------------------------------------------------------------
class("cAction", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cAction", cAction)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cAction", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- Action node is the bridge between behavior tree and agent member function.
-- a member function can be assigned to an action node. function will be
-- invoked when Action node ticked. function attached can be up to eight parameters most.
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
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(self, version, agentType, properties)

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
    local result = EBTStatus.BT_RUNNING
    if self.m_method then
        self.m_method:run(obj)
    else
        result = self.updateImpl(obj, EBTStatus.BT_RUNNING)
    end

    return result
end

-- 执行处理
-- 参数1: 执行的对象
-- 参数2: 子节点状态
-- 返回值: 返回 EBTStatus
-- Execute(Agent* pAgent)method hava be change to Execute(Agent* pAgent, EBTStatus childStatus)
function cAction:executeByInputChildStatus(obj, childSatus)
    local result = EBTStatus.BT_SUCCESS
    if self.m_method then
        if self.m_resultOption ~= EBTStatus.BT_INVALID then
            self.m_method:run(obj)
            result = self.m_resultOption
        else
            if self.m_resultFunctor then
                -- REDO: 这块还不是只结果从 m_method中获得 还需要查看 例子去做
                -- ?? result = self.m_method(obj)
                d_ms.d_log.error("self.m_resultFunctor 这个是做什么的！")
                result = self.m_resultFunctor:getIValueFrom(obj, self.m_method)
                -- IValue* returnValue = this->m_resultFunctor->GetIValueFrom((Agent*)pAgent, this->m_method);
                -- result = ((TValue<EBTStatus>*)returnValue)->value;
            else
                -- REDO: 这块还不是只结果从 m_method中获得
                -- ?? result = self.m_method(obj)
                d_ms.d_log.error("self.m_resultFunctor 这个是做什么的！")
                result = self.m_method:getIValue(obj)
                -- IValue* returnValue = this->m_method->GetIValue((Agent*)pAgent);
                -- _G.BEHAVIAC_ASSERT((TValue<EBTStatus>*)(returnValue), "method's return type is not EBTStatus");
                -- result = ((TValue<EBTStatus>*)returnValue)->value;
            end
        end
    else
        result = self:updateImpl(obj, childStatus);
    end
    return result
end

function cAction:parseMethodNames(fullName, agentIntanceName, agentClassName, methodName)
    d_ms.d_log.error("cAction:parseMethodNames REDO:")
end

-- 创建任务
function cAction:createTask()
    return d_ms.d_actionTask.cActionTask.new()
end

-- 是否有有效
-- 参数1: 执行对象
-- 参数2: 需要检测的任务
-- 返回值: true(有效) false(无效)
function cAction:isValid(obj, task)
    local node = task:getNode()
    if not node or not node:isAction() then
        return false
    end
    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end