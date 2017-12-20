package.path = package.path .. ";./?.lua;../?.lua;./lua/?.lua"
require "ms"
printValue("test", d_ms.d_commonFun.loadXml("./player.xml"))

function main_entrance(con, id, data, len, ses, cid, time)

    return 1
end

function error_handler(con, id, data, time, errCode)
end
