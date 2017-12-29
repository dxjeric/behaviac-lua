------------------------------------------------------------------------------------------------------
-- 行为树 节点基础类
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
local tonumber      = tonumber
local setmetatable  = setmetatable
local getmetatable  = getmetatable
------------------------------------------------------------------------------------------------------
local d_ms = require "ms"
------------------------------------------------------------------------------------------------------
module "behavior.base.behaviorNode"
------------------------------------------------------------------------------------------------------
local constBaseKeyStrDef    = d_ms.d_behaviorCommon.constBaseKeyStrDef
local EBTStatus             = d_ms.d_behaviorCommon.EBTStatus
local stringUtils           = d_ms.d_behaviorCommon.stringUtils
------------------------------------------------------------------------------------------------------
class("cBehaviorNode")
_G.ADD_BEHAVIAC_DYNAMIC_TYPE("cBehaviorNode", cBehaviorNode)
------------------------------------------------------------------------------------------------------
function cBehaviorNode:__init()
    self.m_node             = false -- 节点数据
    self.m_id               = 0     -- 编辑器生成的ID
    self.m_children         = false -- 子节点 没有子节点为false 存在子节点时为table
    self.m_preconditions    = {}    -- 前置处理
    self.m_effectors        = {}    -- TODO: 什么鬼
    self.m_events           = {}    -- TODO: 什么鬼
    self.m_agentType        = ""    -- TODO: 这个应该是对象的类型之类的？暂时还没明白有什么作用
    self.m_nodeClassName    = ""    -- 节点名字
    self.m_bHasEvents       = false -- TODO: 是否是事件的标志吗?
    self.m_customCondition  = false -- 自定义条件
    self.m_parent           = false
    self.m_loadAttachment   = false -- 是否在加载attachment
    self.m_enterPrecond     = 0     -- 前置处理
    self.m_updatePrecond    = 0     -- 循环处理
    self.m_bothPrecond      = 0     -- 两者都有
    self.m_successEffectors = 0     -- 成功处理
    self.m_failureEffectors = 0     -- 失败处理
    self.m_bothEffectors    = 0     -- 两者都处理
end
------------------------------------------------------------------------------------------------------
-- 设置
------------------------------------------------------------------------------------------------------
function cBehaviorNode:setClassNameString(nodeClassName)
    self.m_nodeClassName = nodeClassName
end

function cBehaviorNode:getClassNameString()
    return self.m_nodeClassName
end

function cBehaviorNode:setId(id)
    self.m_id = id
end

function cBehaviorNode:getId(id)
    return self.m_id
end


function cBehaviorNode:setAgentType(agentType)
    if _G.isLinux() then
        return
    end
    self.m_agentType = agentType
end

function cBehaviorNode:getHierarchyInfo()
    print("getHierarchyInfo")
end

function cBehaviorNode:getObjectTypeName()
    return self:getClassTypeName()
end

function cBehaviorNode:release()
    self:clear()
end

function cBehaviorNode:clear()
    if self.m_children then
        for _, child in ipairs(self.m_children) do
            child:release()
        end
        self.m_children = false
    end

    if self.m_customCondition then
        self.m_customCondition:release()
        self.m_customCondition = false
    end
end
------------------------------------------------------------------------------------------------------
-- 节点加载部分
------------------------------------------------------------------------------------------------------
-- 创建节点 根据node类型
function cBehaviorNode:create(nodeClass)
    return d_ms.d_behaviorCommon.factoryCreateNode(nodeClass)
end
-- 数据记载
-- 参数1: 对象类型
-- 参数2: xml数据节点
-- 参数3: 版本号
-- 返回：加载数据的根节点
-- 同 load(const char* agentType, rapidxml::xml_node<>* node, int version)
function cBehaviorNode:loadNode(agentType, xmlNode, version)
    assert(xmlNode:getNodeName() == constBaseKeyStrDef.kStrNodeName)

    local nodeClassName = xmlNode:getAttrValue(constBaseKeyStrDef.kStrClass)
    -- print("nodeClassName", nodeClassName)
    if nodeClassName then
        local newNode = self:create(nodeClassName)
        if newNode then
            newNode:setClassNameString(nodeClassName)
            local idStr = xmlNode:getAttrValue(constBaseKeyStrDef.kStrId)
            assert(idStr, string.format("node = %s no id", agentType))
            self:setId(tonumber(idStr))
            newNode:loadPropertiesParsAttachmentsChildren(true, version, agentType, xmlNode)
        end
        return newNode
    end

    return nil
end
-- Parse the property of node
-- Parse the node's property or properties, and store it/them in prperties
-- return return true if successfully loaded
function cBehaviorNode:loadPropertyPars(outProperties, xmlNode, version, agentType)
    if xmlNode:getNodeName() == constBaseKeyStrDef.kStrProperty then
        local name, value = xmlNode:getFirstAttr()
        table.insert(outProperties, {name = name, value = value})
        return true
    elseif xmlNode:getNodeName() == constBaseKeyStrDef.kStrPars then
        local children = xmlNode:getNodeData()
        if children then
            for _, child in ipairs(children) do
                if child:getNodeName() == constBaseKeyStrDef.kStrPar then
                    self:loadLocal(version, agentType, child)
                end
            end
        end
        return true
    end
    return false
end

-- 加载具体数据 同 load_properties_pars_attachments_children
function cBehaviorNode:loadPropertiesParsAttachmentsChildren(isNode, version, agentType, xmlNode)
    self:setAgentType(agentType)

    local hasEvents = self:hasEvents()
    local childs = xmlNode:getNodeData()
    if not childs then
        return
    end

    local properties = {}
    for _, oneChild in ipairs(childs) do
        if not self:loadPropertyPars(properties, oneChild, version, agentType) then
            local nodeName = oneChild:getNodeName()
            if isNode then
                if nodeName == constBaseKeyStrDef.kStrAttachment then
                    hasEvents = self:loadAttachment(version, agentType, hasEvents, oneChild);
                elseif nodeName == constBaseKeyStrDef.kStrCustom then
                    assert(oneChild:getFirstNodeData(), "kStrCustom 数据不存在")
                    -- TODO: 这个地方是否需要直接使用 cBehaviorNode.loadNode()
                    local newNode = self:loadNode(agentType, oneChild:getFirstNodeData(), version)
                    self:setCustomCondition(newNode)
                elseif nodeName == constBaseKeyStrDef.kStrNode then
                    local newNode = self:loadNode(agentType, oneChild, version)
                    assert(newNode, "加载节点失败")
                    hasEvents = hasEvents or newNode.m_bHasEvents;
                    self:addChild(newNode)
                end
            else
                if nodeName == constBaseKeyStrDef.kStrAttachment then
                    hasEvents = self:loadAttachment(version, agentType, hasEvents, oneChild);
                end
            end
        end
    end

    if #properties > 0 then
        self:loadByProperties(version, agentType, properties)
    end

    self.m_bHasEvents = self.m_bHasEvents or hasEvents
end

-- return boolean
function cBehaviorNode:loadAttachment(version, agentType, hasEvents, xmlNode)
    local attachClassName = xmlNode:getAttrValue(constBaseKeyStrDef.kStrClass)
    if not attachClassName then
        self:loadAttachmentTransitionEffectors(version, agentType, xmlNode);
        return true
    end

    local attachmentNode = self:create(attachClassName)
    if attachmentNode then
        attachmentNode:setClassNameString(attachClassName)
        local id = xmlNode:getAttrValue(constBaseKeyStrDef.kStrId)
        attachmentNode:setId(tonumber(id))
        
        local bIsPrecondition   = false
        local bIsEffector       = false
        local bIsTransition     = false
        local flagStr = xmlNode:getAttrValue(constBaseKeyStrDef.kStrFlag)
        if flagStr == constBaseKeyStrDef.precondition then
            bIsPrecondition = true
        elseif flagStr == constBaseKeyStrDef.kStrEffector then
            bIsEffector = true
        elseif flagStr == constBaseKeyStrDef.kStrTransition then
            bIsTransition = true
        end

        attachmentNode:loadPropertiesParsAttachmentsChildren(false, version, agentType, xmlNode)
        self:attach(attachmentNode, bIsPrecondition, bIsEffector, bIsTransition)
        hasEvents = hasEvents or attachmentNode:isEvent()
    else
        assert(attachmentNode, "attachment node is nil")
    end

    return hasEvents
end

-- 属性加载
-- 同load(int version, const char* agentType, const properties_t& properties)
function cBehaviorNode:loadByProperties(version, agentType, properties)
    local nodeType = self:getClassTypeName()
    print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", nodeType)
    -- REDO: 增加 默认BehaviorNodeLoaded 这个放在behavior tree的管理中
end

-- 加载附件 transition effectors
function cBehaviorNode:loadAttachmentTransitionEffectors(version, agentType, xmlNode)
    self.m_loadAttachment = true
    self:loadPropertiesParsAttachmentsChildren(false, version, agentType, xmlNode)
    self.m_loadAttachment = false
end

-- 
function cBehaviorNode:attach(attachmentNode, isPrecondition, isEffector, isTransition)
    assert(isTransition == false, "isTransition must be false") -- TODO: 为什么？
    
    if isPrecondition then
        assert(not isEffector)
        assert(attachmentNode)  -- TODO: 检测是否是附件
        table.insert(self.m_preconditions, attachmentNode)

        local phase = attachmentNode:getPhase()
        if phase == EPreconditionPhase.E_ENTER then
            self.m_enterPrecond = self.m_enterPrecond + 1
        elseif phase == EPreconditionPhase.E_UPDATE then
            self.m_updatePrecond = self.m_updatePrecond + 1
        elseif phase == EPreconditionPhase.E_BOTH then
            self.m_bothPrecond = self.m_bothPrecond + 1
        else
            assert(false, string.format("cBehaviorNode:Attach isPrecondition error EPreconditionPhase = %d", phase))
        end
    elseif isEffector then
        assert(not isPrecondition)
        assert(attachmentNode)  -- TODO: 检测是否是Effector
        table.insert(self.m_effectors, attachmentNode)

        local phase = attachmentNode:getPhase()
        if phase == ENodePhase.E_SUCCESS then
            self.m_successEffectors = self.m_successEffectors + 1
        elseif phase == ENodePhase.E_FAILURE then
            self.m_failureEffectors = self.m_failureEffectors + 1
        elseif phase == ENodePhase.E_BOTH then
            self.m_bothEffectors = self.m_bothEffectors + 1
        else
            assert(false, string.format("cBehaviorNode:Attach isEffector error ENodePhase = %d", phase))
        end
    else
        table.insert(self.m_events, attachmentNode)
    end
end

function cBehaviorNode:createAndInitTask()
    local task = self:createTask()
    -- print("cBehaviorNode:createAndInitTask", task.__name)
    task:init(self)
    return task
end

function cBehaviorNode:attachNoTranstion(attachmentNode, isPrecondition, isEffector)
    self:attach(attachmentNode, isPrecondition, isEffector, false)
end

function cBehaviorNode:loadLocal(version, agentType, xmlNode)
    d_ms.d_log.error("cBehaviorNode:loadLocal must inheritance")
end

function cBehaviorNode:loadProperties(version, agentType, xmlNode)
    self:setAgentType(agentType)

    local xmlData = xmlNode:getChildeByName(constBaseKeyStrDef.kStrProperty)
    if not xmlData then
        return
    end
    local properties = {}
    for _, oneData in ipairs(xmlData) do
        local name, value = oneData:getFirstAttr()
        table.insert(properties, {name = name, value = value})
    end

    if #properties > 0 then
        self:loadByProperties(version, agentType, properties)
    end
end

function cBehaviorNode:loadPropertiesPars(version, agentType, xmlNode)
    self:loadProperties(version, agentType, xmlNode)

    -- pars
    local parsNodes = xmlNode:getChildeByName(constBaseKeyStrDef.kStrPars)
    if parsNodes then
        local parNodes = parsNodes:getChildeByName(constBaseKeyStrDef.kStrPar)
        for _, parNode in ipairs(parNodes:getNodeData()) do
            self:loadLocal(version, agentType, parNode)
        end
    end
end
------------------------------------------------------------------------------------------------------
-- 子节点
function cBehaviorNode:addChild(childNode)
    childNode.m_parent = self
    if not self.m_children then
        self.m_children = {}
    end
    table.insert(self.m_children, childNode)
end

function cBehaviorNode:getChildrenCount()
    if self.m_children then
        return #self.m_children
    else
        return 0
    end
end

function cBehaviorNode:getChild(index)
    if self.m_children then
        return self.m_children[index]
    else
        return false
    end
end

function cBehaviorNode:getChildById(nodeid)
    if not self.m_children then
        return false
    end

    for _, child in ipairs(self.m_children) do
        if child:getId() == nodeid then
            return child
        end
    end

    return false
end

function cBehaviorNode:getParent()
    return self.m_parent
end
------------------------------------------------------------------------------------------------------
function cBehaviorNode:hasEvents()
    return self.m_bHasEvents
end

function cBehaviorNode:setEvents(hasEvents)
    self.m_bHasEvents = hasEvents
end
------------------------------------------------------------------------------------------------------
-- 更新
-- 返回执行结果 EBTStatus
function cBehaviorNode:updataImpl(obj, childStatus)
    return EBTStatus.BT_FAILURE
end
------------------------------------------------------------------------------------------------------
function cBehaviorNode:combineResults(firstValidPrecond, lastCombineValue, precond, taskBoolean)
    if firstValidPrecond then
        firstValidPrecond = false
        lastCombineValue = taskBoolean
    else
        local andOp = precond:IsAnd()
        if andOp then
            lastCombineValue = lastCombineValue and taskBoolean
        else
            lastCombineValue = lastCombineValue or taskBoolean
        end
    end

    return firstValidPrecond, lastCombineValue
end

function cBehaviorNode:checkPreconditions(obj, isAlive)
    local phase = isAlive and EPreconditionPhase.E_UPDATE or EPreconditionPhase.E_ENTER

    if #self.m_preconditions == 0 then
        return true
    end

    if self.m_bothPrecond == 0 then
        if phase == EPreconditionPhase.E_ENTER and self.m_enterPrecond == 0 then
            return true
        end

        if phase == EPreconditionPhase.E_UPDATE and self.m_updatePrecond == 0 then
            return true
        end
    end

    
    local firstValidPrecond = true
    local lastCombineValue  = false
    for _, precond in ipairs(self.m_preconditions) do
        local ph = precond:getPhase()
        if ph == EPreconditionPhase.E_BOTH or ph == phase then
            local taskBoolean = precond:evaluate(obj)

            firstValidPrecond, lastCombineValue = self:combineResults(firstValidPrecond, lastCombineValue, precond, taskBoolean)
        end
    end

    return lastCombineValue
end

function cBehaviorNode:applyEffects(obj, phase)
    if #self.m_effectors == 0 then
        return
    end

    if self.m_bothEffectors == 0 then
        if phase == ENodePhase.E_SUCCESS and self.m_successEffectors == 0 then
            return
        end

        if phase == ENodePhase.E_FAILURE and self.m_failureEffectors == 0 then
            return
        end
    end

    for _, effector in ipairs(self.m_effectors) do
        local ph = effector:getPhase()
        if phase == ENodePhase.E_BOTH or ph == ENodePhase.E_BOTH or ph == phase then
            effector:evaluate(obj)
        end
    end
end

function cBehaviorNode:checkEvents(eventName, obj, eventParams)
    if #self.m_events > 0 then
        for _, event in ipairs(self.m_events) do
            if event:isEvent() and stringUtils.isNullOrEmpty(eventName) then
                local en = event:getEventName()
                if stringUtils.isNullOrEmpty(en) and en == eventName then
                    event:switchTo(obj, eventParams)
                    if event:triggeredOnce() then
                        return false
                    end
                end
            end
        end
    end

    return true
end

function cBehaviorNode:evaluate(obj)
    d_ms.d_log.error("cBehaviorNode:evaluate must be inheritance, Only Condition/Sequence/And/Or allowed")
    return false
end

-- return true for Parallel, SelectorLoop, etc., which is responsible to update all its children just like sub trees
-- so that they are treated as a return-running node and the next update will continue them.
function cBehaviorNode:isManagingChildrenAsSubTrees()
    return false
end


------------------------------------------------------------------------------------------------------------------
-- 节点类型检测
-- 这个后后面通过 BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_PUBLIC_METHODES 做初始化处理
function cBehaviorNode:isEvent()
    return false
end

function cBehaviorNode:isPrecondition()
    return false
end

function cBehaviorNode:isPrecondition()
    return false
end

function cBehaviorNode:isEffector()
    return false
end

function cBehaviorNode:isAttachaction()
    return false
end

function cBehaviorNode:isBehaviorTree()
    return false
end

function cBehaviorNode:isDecoratorNode()
    return false
end
------------------------------------------------------------------------------------------------------------------
function cBehaviorNode:isValid(obj, behaviorTask)
    d_ms.d_log.info("cBehaviorNode:isValid")
    return true
end

function cBehaviorNode:evaluteCustomCondition(obj)
    if self.m_customCondition then
        return self.m_customCondition:evaluate(obj)
    end

    return false
end

function cBehaviorNode:setCustomCondition(node)
    self.m_customCondition = node
end
------------------------------------------------------------------------------------------------------------------