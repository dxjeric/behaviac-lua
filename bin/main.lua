package.path = package.path .. ";./?.lua;../?.lua;./lua/?.lua"
local d_ms = require "ms"
-- d_ms.p("test", d_ms.d_commonFun.loadXml("./player.xml"))

local bt = d_ms.d_behaviorTree.cBehaviorTree.new()

bt:behaviorLoadXml("./player.xml")


class("cPlayer")

function cPlayer:__init()
    local task = bt:createAndInitTask()
    print("task", task)
    self.m_frames = 0
    self.m_bActive = true
    self.m_currentBT = task
    self.m_behaviorTreeTasks = {task}   -- {BehaviorTreeTask, BehaviorTreeTask}
    self.m_btStack = {}
end
-- m_btStack = {BehaviorTreeStackItem_t, BehaviorTreeStackItem_t}
-- BehaviorTreeStackItem_t {
--     BehaviorTreeTask*	bt;
--     TriggerMode			triggerMode;
--     bool				    triggerByEvent
-- }

function cPlayer:GetCurTime()
    return os.time()
end

function cPlayer:MoveAhead(speed)
    print("cPlayer:MoveAhead")
end

function cPlayer:MoveBack(speed)
    print("cPlayer:MoveBack")
end

function cPlayer:Condition()
    print("cPlayer:Condition")
    return true
end
function cPlayer:Action1()
    print("cPlayer:Action1")
    return d_ms.d_behaviorCommon.EBTStatus.BT_SUCCESS
end
function cPlayer:Action3()
    print("cPlayer:Action3")
    self.m_frames = self.m_frames + 1

    if self.m_frames == 5 then
        return d_ms.d_behaviorCommon.EBTStatus.BT_SUCCESS
    else
        return d_ms.d_behaviorCommon.EBTStatus.BT_RUNNING
    end
end

function cPlayer:btexec()
    if self.m_bActive then
        local s = self:btexec_()

        while self.m_referencetree and s == d_ms.d_behaviorCommon.EBTStatus.BT_RUNNING do
            self.m_referencetree = false
            s = self:btexec_()
        end
        return s
    end
        
    return  d_ms.d_behaviorCommon.EBTStatus.BT_INVALID
end

function cPlayer:_setCurrentTreeTask(value)
    self.m_currentBT = value 
end

function cPlayer:btexec_()
    if self.m_currentBT ~= NULL then
        local pCurrent = self.m_currentBT
        local s = self.m_currentBT:exec(self)

        while s ~= d_ms.d_behaviorCommon.BT_RUNNING do
            -- self.m_currentBT->reset(this)
            local len = #self.m_btStack
            if len > 0 then
                -- get the last one
                local lastOne = self.m_btStack[len]
                table.remove(self.m_btStack, len)
                self:_setCurrentTreeTask(lastOne.bt)

                local bExecCurrent = false
                if lastOne.triggerMode == d_ms.d_behaviorCommon.triggerMode.TM_Return then
                    if not lastOne.triggerByEvent then
                        if self.m_currentBT ~= pCurrent then
                            s = self.m_currentBT:resume(self, s)
                        else
                            BEHAVIAC_ASSERT(true)
                        end
                    else
                        bExecCurrent = true
                    end
                else
                    bExecCurrent = true
                end

                if bExecCurrent then
                    pCurrent = self.m_currentBT
                    s = self.m_currentBT:exec(this)
                    break
                end
            else
                -- don't clear it
                -- self.m_currentBT = 0
                break
            end
        end

        if s ~= d_ms.d_behaviorCommon.BT_RUNNING then
            self.m_excutingTreeTask = 0
        end

        return s
    else
        -- BEHAVIAC_LOGWARNING("NO ACTIVE BT!\n")
    end

    return d_ms.d_behaviorCommon.BT_INVALID
end

function cPlayer:isActive()
    return self.m_bActive
end


local player = cPlayer.new()
function main_entrance(con, id, data, len, ses, cid, time)
    return 1
end

function error_handler(con, id, data, time, errCode)
end
