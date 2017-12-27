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
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.actions.assignment"
------------------------------------------------------------------------------------------------------
class("cAssignment", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cAssignment", cAssignment)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cAssignment", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- Assign a right value to left par or agent property. a right value can be a par or agent property.
function cAssignment:__init()
    self.m_opl      = false         -- IInstanceMember* 左值
    self.m_opr      = false         -- IInstanceMember* 右值
    self.m_bCast    = false
end

function cAssignment:release()
    d_ms.d_behaviorNode.cBehaviorNode.release(self)
    self.m_opl      = false
    self.m_opr      = false
end

-- handle the Assignment property
function cAssignment:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.load(self, version, agentType, properties)
    local propertyName

    for _, propertie in iparis(properties) do
        if propertie.name == "CastRight" then
            self.m_bCast = (propertie.value == "true")
        elseif propertie.name == "Opl" then
            -- self.m_opl = Condition::LoadLeft(propertie.value, propertyName);
            self.m_opl = BehaviorParseFactory.parseProperty(propertie.value)
        elseif propertie.name == "Opr" then
            local pParenthesis = string.find(propertie.value, '%(')
            if not pParenthesis then
                self.m_opr = BehaviorParseFactory.parseProperty(propertie.value)
            else
                self.m_opr = BehaviorParseFactory.parseMethod(propertie.value)
            end
        else
            -- BEHAVIAC_ASSERT(0 == "unrecognised property %s", p.name);
        end
    end
end
-- BehaviorTask
function cAssignment:isValid(obj, task)
    if task:getNode() and task:getNode():isAssignment() then
        return false
    end

    return d_ms.d_behaviorNode.cBehaviorNode.isValid(self, obj, task)
end

function cAssignment:createTask()
    return d_ms.d_assignmentTask.cAssignmentTask.new()
end