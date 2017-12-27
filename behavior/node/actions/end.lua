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
local stringUtils           = d_ms.d_behaviorCommon.stringUtils
local EOperatorType         = d_ms.d_behaviorCommon.EOperatorType
local BehaviorParseFactory  = d_ms.d_behaviorCommon.BehaviorParseFactory
------------------------------------------------------------------------------------------------------
module "behavior.node.actions.end"
------------------------------------------------------------------------------------------------------
class("cEnd", d_ms.d_behaviorNode.cBehaviorNode)
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cEnd", cEnd)
_G.BEHAVIAC_DECLARE_DYNAMIC_TYPE("cEnd", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
-- The behavior tree return success or failure.
function cEnd:__init()
    self.m_endStatus    = false
    self.m_endOutside   = false
end

function cEnd:release()
    d_ms.d_behaviorNode.cBehaviorNode.release()
    self.m_endStatus    = false
end

function cEnd:getStatus(obj)
    if self.m_endStatus then
        return self.m_endStatus:getValue(obj)
    else
        return EBTStatus.BT_SUCCESS
    end
end

function cEnd:getEndOutside()
    return self.m_endOutside
end

function cEnd:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(self, version, agentType, properties)

    for _, property in ipairs(properties) do
        if property.name == "EndStatus" then
            if stringUtils.isValidString(property.value) then
                local pParenthesis = string.find(property.value, '%(')

                if not pParenthesis then                    
                    self.m_endStatus = BehaviorParseFactory.parseProperty(property.value)
                else
                    self.m_endStatus = BehaviorParseFactory.parseMethod(property.value)
                end
            end
        elseif property.name == "EndOutside" then
            self.m_endOutside = (property.value == "true")
        end
    end
end