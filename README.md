# **代码还不完善，使用需谨慎**
-----------------
# behavior for lua

## Lua支持版本
仅支持Lua5.1


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
	和c++版同目录级别，基础类(behaviortree.h, behaviortree_task.h)按照类名分文件

## 测试代码
	测试xml为bin\player.xml
	测试命令： 在cmd中运行 lua.exe main.lua

## 第三方插件 [LuaXml](https://github.com/LuaDist/luaxml.git)
	源码： LuaXML_lib.c
