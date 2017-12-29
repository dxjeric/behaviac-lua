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
local string        = string
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
module "behavior.node.actions.wait"
------------------------------------------------------------------------------------------------------
class("cWait", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cWait", cWait)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cWait", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- Wait for the specified milliseconds. always return Running until time over.
function cWait:__init()
    self.m_time = false         -- REDO: 为什么不是使用时间
end

function cWait:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(self, version, agentType, properties)

    for _, property in ipairs(properties) do
        if property.name == "Time" then
            if stringUtils.isValidString(property.value) then
                local pParenthesis = string.find(property.value, "%(")
                if not pParenthesis then
                    self.m_time = BehaviorParseFactory.parseProperty(property.value)
                else
                    self.m_time = BehaviorParseFactory.parseMethod(property.value)
                end
            end
        end
    end
end

function cWait:getTime(obj)
    local time = 0
    print("cWait:getTime", self.m_time)
    if self.m_time then
        -- REDO: 需要简化
        -- local typeNumberId = self.m_time:getClassTypeNumberId();
        -- if (typeNumberId == GetClassTypeNumberId<int>()) {
        --     time = *(int*)this->m_time->GetValue(pAgent);
        -- }
        -- else if (typeNumberId == GetClassTypeNumberId<double>()) {
        --     time = *(double*)this->m_time->GetValue(pAgent);
        -- }
        -- else if (typeNumberId == GetClassTypeNumberId<float>()) {
        --     time = *(float*)this->m_time->GetValue(pAgent);
        -- }
        -- else {
        --     _G.BEHAVIAC_ASSERT(false);
        -- }
        print("self.m_time:getValue(obj)", self.m_time:getValue(obj))
        return self.m_time:getValue(obj)
    end

    return time
end

function cWait:getIntTime(obj)
    return self:getTime(obj)
end

function cWait:createTask()
    return d_ms.d_waitTask.cWaitTask.new()
end