--------------------------------------------------------------------------------------------------------------
-- 行为树 共用定义文件
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

-- keep this version equal to designers' NewVersion
constSupportedVersion = 5

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
function log(...)
    print(...)
end
--------------------------------------------------------------------------------------------------------------
nodeFactory = {}
--------------------------------------------------------------------------------------------------------------
function registNodeCreateFun(nodeName, fun)
    assert(type(nodeName) == "string", string.format("registNodeCreateFun param nodeName is not string (%s)", type(nodeName)))
    assert(type(fun) == "function", string.format("registNodeCreateFun param fun is not function (%s)", type(fun)))

    if nodeFactory[nodeName] then
        log("registNodeCreateFun has regist key = %s", nodeName)
        return
    end

    nodeFactory[nodeName] = fun
end

function registNodeClass(nodeName, nodeClass)
    assert(type(nodeName) == "string", string.format("registNodeClass param nodeName is not string (%s)", type(nodeName)))
    assert(type(nodeClass) == "table", string.format("registNodeClass param nodeClass is not table (%s)", type(nodeClass)))
    assert(type(nodeClass.new) == "function", string.format("registNodeClass param nodeClass has not new function"))

    if nodeFactory[nodeName] then
        log("registNodeCreateFun has regist key = %s", nodeName)
        return
    end

    nodeFactory[nodeName] = nodeClass.new
end

function factoryCreateNode(nodeName)
    if not nodeFactory[nodeName] then
        log("registNodeCreateFun has regist key = %s", nodeName)
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

function ADD_BEHAVIAC_DYNAMIC_TYPE(className, classDeclare)
    if BEHAVIAC_DYNAMIC_TYPES[className] and BEHAVIAC_DYNAMIC_TYPES[className] ~= classDeclare then
        assert(false, "ADD_BEHAVIAC_DYNAMIC_TYPE had add different TYPE" .. className)
        return
    end

    BEHAVIAC_DYNAMIC_TYPES[className] = classDeclare
end
-- 同C++ 
-- 在调用BEHAVIAC_DECLARE_DYNAMIC_TYPE这个之前必须先调用 ADD_BEHAVIAC_DYNAMIC_TYPE
function BEHAVIAC_DECLARE_DYNAMIC_TYPE(nodeClassName, fatherClassName)
    FATHER_CLASS_INFO[nodeClassName] = fatherClassName
    BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_TYPE_COMPOSER(nodeClassName)
    BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_PUBLIC_METHODES(nodeClassName, fatherClassName)
end

function BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_TYPE_COMPOSER(className)
    assert(BEHAVIAC_DYNAMIC_TYPES[className], string.format("BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_TYPE_COMPOSER %s must be call ADD_BEHAVIAC_DYNAMIC_TYPE", className))

    BEHAVIAC_DYNAMIC_TYPES[className].sm_HierarchyLevel = 0
    BEHAVIAC_DYNAMIC_TYPES[className].getClassTypeName = function (self)
        return className
    end
end

function BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_PUBLIC_METHODES(nodeClassName, fatherClassName)
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
        print("getClassHierarchyInfoDecl 这个到底是做什么的")
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
        print("getClassTypeId", nodeClassName)
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
--------------------------------------------------------------------------------------------------------------
stringUtils = {}
function stringUtils.isNullOrEmpty(str)
    if not str or str == "" then
        return true
    end
    return false
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







