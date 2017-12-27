------------------------------------------------------------------------------------------------------
-- module : behavior
------------------------------------------------------------------------------------------------------
local require = require
local print   = print
------------------------------------------------------------------------------------------------------
module "ms"
------------------------------------------------------------------------------------------------------
d_LuaXML                        = require "LuaXML"
d_commonFun                     = require "commonFun"

-- base
d_behaviorCommon                = require "behavior.base.behaviorCommon"
d_behaviorNode                  = require "behavior.base.behaviorNode"
d_behaviorTask                  = require "behavior.base.behaviorTask"
d_attachmentTask                = require "behavior.base.attachmentTask"
d_branchTask                    = require "behavior.base.branchTask"
d_compositeTask                 = require "behavior.base.compositeTask"
d_decoratorNode                 = require "behavior.base.decoratorNode"
d_leafTask                      = require "behavior.base.leafTask"
d_singeChildTask                = require "behavior.base.singeChildTask"
d_decoratorTask                 = require "behavior.base.decoratorTask"
d_behaviorTree                  = require "behavior.base.behaviorTree"
d_behaviorTreeTask              = require "behavior.base.behaviorTreeTask"

d_action                        = require "behavior.node.actions.action"
d_actionTask                    = require "behavior.node.actions.actionTask"
d_conditionBase                 = require "behavior.node.conditions.conditionBase"
d_conditionBaseTask             = require "behavior.node.conditions.conditionBaseTask"

-- attachments
d_attachAction                  = require "behavior.attachments.attachAction"
d_effector                      = require "behavior.attachments.effector"
d_event                         = require "behavior.attachments.event"
d_eventTask                     = require "behavior.attachments.eventTask"
d_precondition                  = require "behavior.attachments.precondition"

-- node.actions
d_assignment                    = require "behavior.node.actions.assignment"
d_assignmentTask                = require "behavior.node.actions.assignmentTask"
d_compute                       = require "behavior.node.actions.compute"
d_computeTask                   = require "behavior.node.actions.computeTask"
d_end                           = require "behavior.node.actions.end"
d_endTask                       = require "behavior.node.actions.endTask"
d_noop                          = require "behavior.node.actions.noop"
d_noopTask                      = require "behavior.node.actions.noopTask"
d_wait                          = require "behavior.node.actions.wait"
d_waitForSignal                 = require "behavior.node.actions.waitForSignal"
d_waitForSignalTask             = require "behavior.node.actions.waitForSignalTask"
d_waitFrames                    = require "behavior.node.actions.waitFrames"
d_waitFramesTask                = require "behavior.node.actions.waitFramesTask"
d_waitTask                      = require "behavior.node.actions.waitTask"

-- node.composites
d_compositeStochastic           = require "behavior.node.composites.compositeStochastic"
d_compositeStochasticTask       = require "behavior.node.composites.compositeStochasticTask"
d_ifElse                        = require "behavior.node.composites.ifElse"
d_ifElseTask                    = require "behavior.node.composites.ifElseTask"
d_parallel                      = require "behavior.node.composites.parallel"
d_parallelTask                  = require "behavior.node.composites.parallelTask"
d_referencedBehavior            = require "behavior.node.composites.referencedBehavior"
d_referencedBehaviorTask        = require "behavior.node.composites.referencedBehaviorTask"
d_selector                      = require "behavior.node.composites.selector"
d_selectorLoop                  = require "behavior.node.composites.selectorLoop"
d_selectorLoopTask              = require "behavior.node.composites.selectorLoopTask"
d_selectorProbability           = require "behavior.node.composites.selectorProbability"
d_selectorProbabilityTask       = require "behavior.node.composites.selectorProbabilityTask"
d_selectorStochastic            = require "behavior.node.composites.selectorStochastic"
d_selectorStochasticTask        = require "behavior.node.composites.selectorStochasticTask"
d_selectorTask                  = require "behavior.node.composites.selectorTask"
d_sequence                      = require "behavior.node.composites.sequence"
d_sequenceStochastic            = require "behavior.node.composites.sequenceStochastic"
d_sequenceStochasticTask        = require "behavior.node.composites.sequenceStochasticTask"
d_sequenceTask                  = require "behavior.node.composites.sequenceTask"
d_withPrecondition              = require "behavior.node.composites.withPrecondition"
d_withPreconditionTask          = require "behavior.node.composites.withPreconditionTask"

-- node.conditions
d_and                           = require "behavior.node.conditions.and"
d_andTask                       = require "behavior.node.conditions.andTask"
d_condition                     = require "behavior.node.conditions.condition"
d_conditionTask                 = require "behavior.node.conditions.conditionTask"
d_false                         = require "behavior.node.conditions.false"
d_falseTask                     = require "behavior.node.conditions.falseTask"
d_or                            = require "behavior.node.conditions.or"
d_orTask                        = require "behavior.node.conditions.orTask"
d_true                          = require "behavior.node.conditions.true"
d_trueTask                      = require "behavior.node.conditions.trueTask"

-- node.decorators
d_decoratorAlwaysFailure        = require "behavior.node.decorators.decoratorAlwaysFailure"
d_decoratorAlwaysFailureTask    = require "behavior.node.decorators.decoratorAlwaysFailureTask"
d_decoratorAlwaysRunning        = require "behavior.node.decorators.decoratorAlwaysRunning"
d_decoratorAlwaysRunningTask    = require "behavior.node.decorators.decoratorAlwaysRunningTask"
d_decoratorAlwaysSuccess        = require "behavior.node.decorators.decoratorAlwaysSuccess"
d_decoratorAlwaysSuccessTask    = require "behavior.node.decorators.decoratorAlwaysSuccessTask"
d_decoratorCount                = require "behavior.node.decorators.decoratorCount"
d_decoratorCountTask            = require "behavior.node.decorators.decoratorCountTask"
d_decoratorCountLimit           = require "behavior.node.decorators.decoratorCountLimit"
d_decoratorCountLimitTask       = require "behavior.node.decorators.decoratorCountLimitTask"
d_decoratorFailureUntil         = require "behavior.node.decorators.decoratorFailureUntil"
d_decoratorFailureUntilTask     = require "behavior.node.decorators.decoratorFailureUntilTask"
d_decoratorFrames               = require "behavior.node.decorators.decoratorFrames"
d_decoratorFramesTask           = require "behavior.node.decorators.decoratorFramesTask"
d_decoratorIterator             = require "behavior.node.decorators.decoratorIterator"
d_decoratorLog                  = require "behavior.node.decorators.decoratorLog"
d_decoratorLogTask              = require "behavior.node.decorators.decoratorLogTask"
d_decoratorLoop                 = require "behavior.node.decorators.decoratorLoop"
d_decoratorLoopTask             = require "behavior.node.decorators.decoratorLoopTask"
d_decoratorLoopUntil            = require "behavior.node.decorators.decoratorLoopUntil"
d_decoratorLoopUntilTask        = require "behavior.node.decorators.decoratorLoopUntilTask"
d_decoratorNot                  = require "behavior.node.decorators.decoratorNot"
d_decoratorNotTask              = require "behavior.node.decorators.decoratorNotTask"
d_decoratorRepeat               = require "behavior.node.decorators.decoratorRepeat"
d_decoratorRepeatTask           = require "behavior.node.decorators.decoratorRepeatTask"
d_decoratorSuccessUntil         = require "behavior.node.decorators.decoratorSuccessUntil"
d_decoratorSuccessUntilTask     = require "behavior.node.decorators.decoratorSuccessUntilTask"
d_decoratorTime                 = require "behavior.node.decorators.decoratorTime"
d_decoratorTimeTask             = require "behavior.node.decorators.decoratorTimeTask"
d_decoratorWeight               = require "behavior.node.decorators.decoratorWeight"
d_decoratorWeightTask           = require "behavior.node.decorators.decoratorWeightTask"

-- mgr
d_behaviorTreeMgr               = require "behavior.behaviorTreeMgr"
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

p = d_commonFun.printValue