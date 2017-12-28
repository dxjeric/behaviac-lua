package.path = package.path .. ";./?.lua;../?.lua;./lua/?.lua"
local d_ms = require "ms"
-- d_ms.p("test", d_ms.d_commonFun.loadXml("./player.xml"))

local bt = d_ms.d_behaviorTree.cBehaviorTree.new()

bt:behaviorLoadXml("./player.xml")


function main_entrance(con, id, data, len, ses, cid, time)
    return 1
end

function error_handler(con, id, data, time, errCode)
end
