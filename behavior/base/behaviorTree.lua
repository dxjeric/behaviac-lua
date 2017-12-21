------------------------------------------------------------------------------------------------------
-- 行为树
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
module "behavior.base.behaviorTree"
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef = d_ms.d_behaviorCommon.constBaseKeyStrDef
local EBTStatus          = d_ms.d_behaviorCommon.EBTStatus
------------------------------------------------------------------------------------------------------
class("cBehaviorTree", d_ms.d_behaviorNode.cBehaviorNode)
ADD_BEHAVIAC_DYNAMIC_TYPE("cBehaviorTree", cBehaviorTree)
BEHAVIAC_DECLARE_DYNAMIC_TYPE("cBehaviorTree", "cBehaviorNode")
------------------------------------------------------------------------------------------------------
function cBehaviorTree:__init()
    self.m_name         = ""
    self.m_domains      = ""
    self.m_bIsFSM       = false
    self.m_localProps   = {}
end

function cBehaviorTree:getName()
    return self.m_name
end

function cBehaviorTree:setName(name)
    if name then
        self.m_name = name
    end
end

function cBehaviorTree:getDomains()
    return self.m_domains
end

function cBehaviorTree:setDomains(domains)
    self.m_domains = domains
end

function cBehaviorTree:isFSM()
    return self.m_bIsFSM
end

function cBehaviorTree:behaviorLoadXml(xmlPath)
    local xmlNodes = loadXml(xmlPath)
    if not xmlNodes then
        d_ms.d_log.error("behaviorLoadXml %s is not xml file", xmlPath)
        return
    end

    local childNodes = xmlNodes:getChildeByName(constBaseKeyStrDef.kStrBehavior)
    if not childNodes then
        d_ms.d_log.error("behaviorLoadXml %s is not behavior tree xml", xmlPath)
        return
    end

    self:setName(xmlNodes:getAttrValue(constBaseKeyStrDef.kStrName))
    local agentType = xmlNodes:getAttrValue(constBaseKeyStrDef.kStrAgentType)
    local version = tonumber(xmlNodes:getAttrValue(constBaseKeyStrDef.kStrVersion)) or 0

    if not isLinux() then
        assert(version == constSupportedVersion, "Behavior Tree error version " .. version)
    end

    self:setClassNameString("BehaviorTree");
    self:setId(-1);

    if xmlNodes:getAttrValue("fsm") == "true" then
        self.m_bIsFSM = true
    end

    self:loadPropertiesParsAttachmentsChildren(true, version, agentType, childNodes)
    return true
end

function cBehaviorTree:loadLocal(version, agentType, xmlNode)
    if xmlNode:getNodeName() ~= constBaseKeyStrDef.kStrPar then
        d_ms.d_log.error("cBehaviorTree:loadLocal node name (%s) is different from %s", tostring(xmlNode:getNodeName()), constBaseKeyStrDef.kStrPar)
        return
    end

    local name  = xmlNode:getAttrValue(constBaseKeyStrDef.kStrName)
    local type  = xmlNode:getAttrValue(constBaseKeyStrDef.kStrType)
    local value = xmlNode:getAttrValue(constBaseKeyStrDef.kStrValue)

    self:addLocal(agentType, type, name, value)
end

function cBehaviorTree:addLocal(agentType, typeName, name, valueStr)
    self.m_localProps[name] = getProperty(typeName, valueStr)
end

function cBehaviorTree:addPar(agentType, typeName, name, valueStr)
    self:addLocal(agentType, typeName, name, valueStr)
end

function cBehaviorTree:isBehaviorTree()
    return true
end

function cBehaviorTree:instantiatePars(vars)
    -- TODO: 这块是获取对应的数据吗
    d_ms.d_log.error("cBehaviorTree:instantiatePars is empty")
    if #self.m_localProps > 0 then
        for varName, var in pairs(self.m_localProps) do
            vars[varName]= var
        end
    end
end

function cBehaviorTree:unInstantiatePars(vars)
    -- TODO: 这块是获取对应的数据吗
    d_ms.d_log.error("cBehaviorTree:unInstantiatePars is empty 在调用地方直接置空就行")
end

function cBehaviorTree:loadByProperties(version, agentType, properties)
    d_ms.d_behaviorNode.cBehaviorNode.loadByProperties(version, agentType, properties)

    if #properties > 0 then
        for _, prop in pairs(properties) do
            if prop.name == constBaseKeyStrDef.kStrDomains then
                self.m_domains = prop.value
            elseif prop.name == constBaseKeyStrDef.kStrDescriptorRefs then
                -- do nothing
            else
                -- do nothing
            end
        end
    end
end

function cBehaviorTree:isManagingChildrenAsSubTrees()
    return true
end

function cBehaviorTree:createTask()
    -- REDO: 做了cBehaviorTreeTask
    -- return d_ms.d_behaviorTreeTask.cBehaviorTreeTask.new()
    d_ms.d_log.error("cBehaviorTree:createTask 需要添加")
end