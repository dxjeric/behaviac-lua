------------------------------------------------------------------------------------------------------
-- module : behavior
------------------------------------------------------------------------------------------------------
local require = require
------------------------------------------------------------------------------------------------------
module "ms"
------------------------------------------------------------------------------------------------------
d_common    = require "commonFun"

-- base
d_behaviorCommon    = require "base.behaviorCommon"
d_behaviorNode      = require "base.behaviorNode"
d_behaviorTree      = require "base.behaviorTree"
d_decoratorNode     = require "base.decoratorNode"
d_behaviorTask      = require "base.behaviorTask"
d_leafTask          = require "base.leafTask"
d_attachmentTask    = require "base.attachmentTask"
d_branchTask        = require "base.branchTask"
d_compositeTask     = require "base.compositeTask"
d_singeChildTask    = require "base.singeChildTask"
d_decoratorTask     = require "base.decoratorTask"
d_behaviorTreeTask  = require "base.behaviorTreeTask"

-- attachments
d_event     = require "attachments.event"

-- node.actions

-- node.composites
-- node.conditions
-- node.decorators

------------------------------------------------------------------------------------------------------
d_log = {}
function d_log.must(formatStr, ...)
    print(string.format(formatStr, ...))
end

function d_log.error(formatStr, ...)
    print(string.format(formatStr, ...))
end
-------------------------------------------------------------------------------------------------------------
d_str = {}
function d_str.split(str, char)
    local ret = {}
    local e = 1
    local b = string.find(str, char, e)
    while b do
        table.insert(ret, string.sub(str, e, b - 1))
        e = b + 1
        b = string.find(str, char, e)
    end
    table.insert(ret, string.sub(str, e, -1))

    return ret
end