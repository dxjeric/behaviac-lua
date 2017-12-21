--------------------------------------------------------------------------------------------------------------
-- 行为树 共用定义文件
--------------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------------
module "behavior.base.behaviorCommon"
--------------------------------------------------------------------------------------------------------------
-- 执行返回
EBTStatus = {
    BT_INVALID = 0,     -- 无效
    BT_SUCCESS = 1,     -- 成功
    BT_FAILURE = 2,     -- 失败
    BT_RUNNING = 3,     -- 运行中
}

ENodePhase = {
    E_SUCCESS   = 0,    -- 成功
    E_FAILURE   = 1,    -- 失败
    E_BOTH      = 2,    -- 两者皆可？？？？？
}

EPreconditionPhase = {
    E_ENTER     = 0,
    E_UPDATE    = 1,
    E_BOTH      = 2,
}

triggerMode = {
    TM_Transfer = 1,
    TM_Return   = 2,
}

EOperatorType = {
    E_INVALID       = 0,
    E_ASSIGN        = 1,    -- =
    E_ADD           = 2,    -- +
    E_SUB           = 3,    -- -
    E_MUL           = 4,    -- *
    E_DIV           = 5,    -- /
    E_EQUAL         = 6,    -- ==
    E_NOTEQUAL      = 7,    -- !=
    E_GREATER       = 8,    -- >
    E_LESS          = 9,    -- <
    E_GREATEREQUAL  = 10,   -- >=
    E_LESSEQUAL     = 11,   -- <=
}

-- keep this version equal to designers' NewVersion
constSupportedVersion   = 5
-- cCompositeTask 中的任务无效值
constInvalidChildIndex  = -1

constBaseKeyStrDef = {
    kStrNodeName        = "node",
    kStrBehavior        = "behavior",
    kStrAgentType       = "agenttype",
    kStrId              = "id",
    kStrPars            = "pars",
    kStrPar             = "par",
    kStrNode            = "node",
    kStrCustom          = "custom",
    kStrProperty        = "property",
    kStrAttachment      = "attachment",
    kStrClass           = "class",
    kStrName            = "name",
    kStrType            = "type",
    kStrValue           = "value",
    kStrVersion         = "version",
    kStrFlag            = "flag",
    kStrPrecondition    = "precondition",
    kStrEffector        = "effector",
    kStrTransition      = "transition",
    kStrDomains         = "Domains",
    kStrDescriptorRefs  = "DescriptorRefs",
}
--------------------------------------------------------------------------------------------------------------
nodeFactory = {}
--------------------------------------------------------------------------------------------------------------
function registNodeCreateFun(nodeName, fun)
    assert(type(nodeName) == "string", string.format("registNodeCreateFun param nodeName is not string (%s)", type(nodeName)))
    assert(type(fun) == "function", string.format("registNodeCreateFun param fun is not function (%s)", type(fun)))

    if nodeFactory[nodeName] then
        d_ms.d_log.error("registNodeCreateFun has regist key = %s", nodeName)
        return
    end

    nodeFactory[nodeName] = fun
end

function registNodeClass(nodeName, nodeClass)
    assert(type(nodeName) == "string", string.format("registNodeClass param nodeName is not string (%s)", type(nodeName)))
    assert(type(nodeClass) == "table", string.format("registNodeClass param nodeClass is not table (%s)", type(nodeClass)))
    assert(type(nodeClass.new) == "function", string.format("registNodeClass param nodeClass has not new function"))

    if nodeFactory[nodeName] then
        d_ms.d_log.error("registNodeCreateFun has regist key = %s", nodeName)
        return
    end

    nodeFactory[nodeName] = nodeClass.new
end

function factoryCreateNode(nodeName)
    if not nodeFactory[nodeName] then
        d_ms.d_log.error("registNodeCreateFun has regist key = %s", nodeName)
        return nil
    else
        return nodeFactory[nodeName]()
    end
end
--------------------------------------------------------------------------------------------------------------
-- lua 使用
FATHER_CLASS_INFO = {}
BEHAVIAC_DYNAMIC_TYPES = {}
STATIC_BEHAVIAC_HierarchyLevels = setmetatable({}, {__index = function() return 0 end})

function _G.ADD_BEHAVIAC_DYNAMIC_TYPE(className, classDeclare)
    if BEHAVIAC_DYNAMIC_TYPES[className] and BEHAVIAC_DYNAMIC_TYPES[className] ~= classDeclare then
        assert(false, "ADD_BEHAVIAC_DYNAMIC_TYPE had add different TYPE" .. className)
        return
    end

    BEHAVIAC_DYNAMIC_TYPES[className] = classDeclare
end
-- 同C++ 
-- 在调用BEHAVIAC_DECLARE_DYNAMIC_TYPE这个之前必须先调用 ADD_BEHAVIAC_DYNAMIC_TYPE
function _G.BEHAVIAC_DECLARE_DYNAMIC_TYPE(nodeClassName, fatherClassName)
    FATHER_CLASS_INFO[nodeClassName] = fatherClassName
    BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_TYPE_COMPOSER(nodeClassName)
    BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_PUBLIC_METHODES(nodeClassName, fatherClassName)
end

function _G.BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_TYPE_COMPOSER(className)
    assert(BEHAVIAC_DYNAMIC_TYPES[className], string.format("BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_TYPE_COMPOSER %s must be call ADD_BEHAVIAC_DYNAMIC_TYPE", className))

    BEHAVIAC_DYNAMIC_TYPES[className].sm_HierarchyLevel = 0
    BEHAVIAC_DYNAMIC_TYPES[className].getClassTypeName = function (self)
        return className
    end
end

function _G.BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_PUBLIC_METHODES(nodeClassName, fatherClassName)
    assert(BEHAVIAC_DYNAMIC_TYPES[nodeClassName], string.format("BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_PUBLIC_METHODES %s must be call ADD_BEHAVIAC_DYNAMIC_TYPE", nodeClassName))
    assert(BEHAVIAC_DYNAMIC_TYPES[fatherClassName], string.format("BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_PUBLIC_METHODES %s must be call ADD_BEHAVIAC_DYNAMIC_TYPE", fatherClassName))

    STATIC_BEHAVIAC_HierarchyLevels[nodeClassName] = STATIC_BEHAVIAC_HierarchyLevels[fatherClassName] + 1 
    BEHAVIAC_DYNAMIC_TYPES[nodeClassName].sm_HierarchyLevel = STATIC_BEHAVIAC_HierarchyLevels[nodeClassName]

    local checkFunName = string.format("is%s", string.sub(className, 2, -1))
    BEHAVIAC_DYNAMIC_TYPES[nodeClassName][checkFunName] = function() return true end
    local rootFatherName = fatherClassName
    local fName = fatherClassName
    while fName then
        fName = FATHER_CLASS_INFO[fName]
        if fName then
            rootFatherName = fName
        end
    end
    if rootFatherName then
        if not BEHAVIAC_DYNAMIC_TYPES[rootFatherName][checkFunName] then
            BEHAVIAC_DYNAMIC_TYPES[rootFatherName][checkFunName] = function() return false end
        end
    end


    BEHAVIAC_DYNAMIC_TYPES[nodeClassName].getClassHierarchyInfoDecl = function(self)
        d_ms.d_log.error("getClassHierarchyInfoDecl 这个到底是做什么的")
        return "getClassHierarchyInfoDecl"
    end

    BEHAVIAC_DYNAMIC_TYPES[nodeClassName].getHierarchyInfo = function(self)
        local decl = self:getClassHierarchyInfoDecl()
        if not decl.m_szCassTypeName then
            decl:InitClassLayerInfo(self:getClassTypeName(), BEHAVIAC_DYNAMIC_TYPES[fatherClassName]:getHierarchyInfo())
        end
        return decl
    end

    BEHAVIAC_DYNAMIC_TYPES[nodeClassName].getClassTypeId = function(self)
        d_ms.d_log.error("getClassTypeId = %s", nodeClassName)
        return 1
    end

    BEHAVIAC_DYNAMIC_TYPES[nodeClassName].isClassAKindOf = function(self)
        return true
    end

    BEHAVIAC_DYNAMIC_TYPES[nodeClassName].dynamicCast = function(self, other)
        d_ms.d_log.error("dynamicCast use is%s fun", string.sub(nodeClassName, 2, -1))
        return false
    end
end

function _G.BEHAVIAC_ASSERT(check, msgFormat, ...)
    if not check then
        d_ms.d_log.error("BEHAVIAC_ASSERT" .. msgFormat, ...)
        assert(false)
    end
end
--------------------------------------------------------------------------------------------------------------
local paramMt = {}
function paramMt:run(obj)

end

function paramMt:getIValueFrom(obj, method)
end

function paramMt:getIValue(obj)
end

function paramMt:setValueCast(obj, opr, cast)
end

function paramMt:getValue(obj)
end

function paramMt:getClassTypeNumberId()
end


-- Compute(pAgent, pComputeNode->m_opr1, pComputeNode->m_opr2, pComputeNode->m_operator);
function paramMt:compute(obj, opr1, opr2, operator)
end

function paramMt:getValue(obj)
end

function paramMt:compare(obj, right, comparisonType)
end


BehaviorParseFactory = {}
function BehaviorParseFactory.parseMethod(methodInfo)
    return setmetatable({}, paramMt)
end

function BehaviorParseFactory.parseProperty(propertyStr)
    return setmetatable({}, paramMt)
end

function BehaviorParseFactory.parseMethodOutMethodName(methodInfo)
    return methon, methonName
end

function BehaviorParseFactory.parseOperatorType(operatorTypeStr)
    if operatorTypeStr == "Invalid" then
        return EOperatorType.E_INVALID
    elseif operatorTypeStr == "Assign" then
        return EOperatorType.E_ASSIGN
    elseif operatorTypeStr == "Add" then
        return EOperatorType.E_ADD
    elseif operatorTypeStr == "Sub" then
        return EOperatorType.E_SUB
    elseif operatorTypeStr == "Mul" then
        return EOperatorType.E_MUL
    elseif operatorTypeStr == "Div" then
        return EOperatorType.E_DIV
    elseif operatorTypeStr == "Equal" then
        return EOperatorType.E_EQUAL
    elseif operatorTypeStr == "NotEqual" then
        return EOperatorType.E_NOTEQUAL
    elseif operatorTypeStr == "Greater" then
        return EOperatorType.E_GREATER
    elseif operatorTypeStr == "Less" then
        return EOperatorType.E_LESS
    elseif operatorTypeStr == "GreaterEqual" then
        return EOperatorType.E_GREATEREQUAL
    elseif operatorTypeStr == "LessEqual" then
        return EOperatorType.E_LESSEQUAL
    end
    
    BEHAVIAC_ASSERT(false)
    return EOperatorType.E_INVALID
end
--------------------------------------------------------------------------------------------------------------
stringUtils = {}
function stringUtils.isNullOrEmpty(str)
    if not str or str == "" then
        return true
    end
    return false
end

function stringUtils.isValidString(str)
    if not str or str == "" then
        return false
    end

    return true
end
--------------------------------------------------------------------------------------------------------------
CRC = {}
function CRC.CalcCRC(idStr)
    return 0xfffffff
end
--------------------------------------------------------------------------------------------------------------
function makeVariableId(idStr)
    return CRC.CalcCRC(idStr)
end
--------------------------------------------------------------------------------------------------------------
basicTypesFun = {}
basicTypesFun.bool = function(str)
    if str == "true" then
        return true
    else
        return false
    end
end

basicTypesFun.Boolean = function(str)
    if str == "true" then
        return true
    else
        return false
    end
end

basicTypesFun.byte      = tonumber
basicTypesFun.ubyte     = tonumber
basicTypesFun.Byte      = tonumber
basicTypesFun.char      = tonumber
basicTypesFun.Char      = tonumber
basicTypesFun.SByte     = tonumber
basicTypesFun.decimal   = tonumber
basicTypesFun.Decimal   = tonumber
basicTypesFun.double    = tonumber
basicTypesFun.Double    = tonumber
basicTypesFun.float     = tonumber
basicTypesFun.int       = tonumber
basicTypesFun.Int16     = tonumber
basicTypesFun.Int32     = tonumber
basicTypesFun.Int64     = tonumber
basicTypesFun.long      = tonumber
basicTypesFun.llong     = tonumber
basicTypesFun.sbyte     = tonumber
basicTypesFun.short     = tonumber
basicTypesFun.ushort    = tonumber
basicTypesFun.uint      = tonumber
basicTypesFun.UInt16    = tonumber
basicTypesFun.UInt32    = tonumber
basicTypesFun.UInt64    = tonumber
basicTypesFun.ulong     = tonumber
basicTypesFun.ullong    = tonumber
basicTypesFun.Single    = tonumber

basicTypesFun.string            = function(str) return str end
basicTypesFun.String            = function(str) return str end
basicTypesFun["std::string"]    = function(str) return str end
basicTypesFun["char*"]          = function(str) return str end
basicTypesFun["const char*"]    = function(str) return str end

function getProperty(typeName, valueStr)
    local isArray = false
    if string.find(typeName, "vector<") then
        isArray = true
        typeName = string.gmatch(typeName, "vector<(.+)>")()
    end

    if basicTypesFun[typeName] then
        if isArray then
            d_ms.d_log.error("getProperty need to be implementation")
            return {}
        else
            return basicTypesFun[typeName](valueStr)
        end
    else
        d_ms.d_log.error("getProperty (%s) no funtion", typeName)
    end
end
--------------------------------------------------------------------------------------------------------------
