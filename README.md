# behavior

## 需要包含的lua代码
1. bin\目录
	1. commonFun.lua
	1. LuaXML.lua
	1. ms.lua
	1. LuaXML_lib.dll
2. behavior目录中所有的代码

## 文件说明
### commonFun.lua
	1. 可以删除的接口 : isLinux isTest
	1. 需要替换 :      redoGetIntValueSinceStartup  redoGetDoubleValueSinceStartup redoGetFrameSinceStartup
	1. 需要增加的接口 : table.copy(t)， bits.bitAnd()
	1. 必须保留的接口 : loadXml
### LuaXML.lua 和 LuaXML_lib.dll
	处理lua处理xml文件的底层接口 

### behavior相关代码([C++ 源码](https://github.com/Tencent/behaviac.git))
	和C++版同目录级别，基础类(behaviortree.h, behaviortree_task.h)按照类名分文件

## 测试代码
	测试xml为bin\player.xml
	测试命令： 在cmd中运行 lua.exe main.lua

## 第三方插件 [LuaXml](https://github.com/LuaDist/luaxml.git)
	源码： LuaXML_lib.c

## 原生工具需要修改的地方
	函数引用部分，这个暂时使用的是原是版本，工具修改之后需要同步修改behaviorCommon.lua中的解析接口(parseMethod,parseProperty)
# 新增节点
## DecoratorCountOnce
	节点包含Action需要执行的次数，当次数被执行完成之后，将不再执行该子节点
## ecoratorEveryTime
	每隔多久执行一次节点Action