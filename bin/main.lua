package.path = package.path .. ";./?.lua;../?.lua;./lua/?.lua"
local d_ms = require "ms"
--------------------------------------------------------------------------------------

local bt = d_ms.d_behaviorTreeMgr.loadBehaviorTree("test")
local loopCount = 10
local runTime   = 100
local EBTStatus = d_ms.d_behaviorCommon.EBTStatus
--------------------------------------------------------------------------------------

class("cPlayer")

function cPlayer:__init()
    local task = bt:createAndInitTask()
    print("task", task)
    self.m_frames = 0
    self.m_bActive = true
   
    --------------------------------------------------------------------------------------
    -- obj需要包含的接口
    self.m_btStack              = {}
    self.m_currentBT            = task             -- obj base
    self.m_referencetree        = false
    self.m_excutingTreeTask     = false
    self.m_behaviorTreeTasks    = {task}   -- {BehaviorTreeTask, BehaviorTreeTask}
    --------------------------------------------------------------------------------------

    self.MoveSpeed = 4
    self.CastRight = 0
    self.TestInt = 0
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
    print("cPlayer:MoveAhead speed = " .. speed)
    self.MoveSpeed = 4
end

function cPlayer:MoveBack(speed)
    print("cPlayer:MoveBack speed = " .. speed)
    self.MoveSpeed = 3
    return true
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

function cPlayer:TestState(state)
    self.MoveSpeed = self.MoveSpeed + 1

    if self.MoveSpeed > 4 then
        print('BT_SUCCESS --------------' .. self.MoveSpeed, d_ms.d_behaviorCommon.EBTStatus.BT_SUCCESS)
        return d_ms.d_behaviorCommon.EBTStatus.BT_SUCCESS
    else
        print('BT_RUNNING --------------' .. self.MoveSpeed, d_ms.d_behaviorCommon.EBTStatus.BT_RUNNING)
        return d_ms.d_behaviorCommon.EBTStatus.BT_RUNNING
    end
end

function cPlayer:EnumM(e)
    print('-------------------- TestState e = ' .. e)
end

math.random(os.time())
local a = 0
function cPlayer:Select1(str)
    -- a = a + 1
    -- if a == 2 then
    --     assert(false)
    -- end
    print("cPlayer:Select1", str, os.time())
    return d_ms.d_behaviorCommon.EBTStatus.BT_SUCCESS
end

function cPlayer:Select2(str)
    print("cPlayer:Select2", str)
end

function cPlayer:TestRetInt()
    return 2
end

--------------------------------------------------------------------------------------
-- obj需要包含的接口
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
    if self.m_currentBT ~= nil then
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


-- 这个可以优化下
function cPlayer:_btsetcurrent(relativePath, triggerMode, bByEvent)

    if self.m_currentBT then
        if triggerMode == d_ms.d_behaviorCommon.triggerMode.TM_Return then
            local item = {
                bt              = self.m_currentBT,  -- BehaviorTreeTask
                triggerMode     = triggerMode, -- TriggerMode
                triggerByEvent  = bByEvent,
            }
            table.insert(self.m_btStack, item)
        elseif triggerMode == d_ms.d_behaviorCommon.triggerMode.TM_Transfer then
            self.m_currentBT:abort(self)
            self.m_currentBT:reset(self)
        end
    end

    local pTask = false -- BehaviorTreeTask* pTask
    for _, bt in ipairs(self.m_behaviorTreeTasks) do
        BEHAVIAC_ASSERT(bt)
        if bt:getName() == relativePath then
            pTask = bt
            break
        end
    end

    local bRecursive = false
    if pTask then
        for _, item in ipairas(self.m_btStack) do
            if item.bt:getName() == relativePath then
                bRecursive = true
                break
            end
        end

        if pTask:getStatus() ~= EBTStatus.BT_INVALID then
            pTask:reset(self)
        end
    end

    if pTask == false or bRecursive then
        pTask = d_ms.d_behaviorTreeMgr.createBehaviorTreeTask(path)
        if not pTask then
            d_ms.d_log.error("cPlayer:_btSetCurrent %s bt is not exist", tostring(path))
            return
        end
        table.insert(self.m_behaviorTreeTasks, pTask)
    end

    self:_setCurrentTreeTask(pTask)

    print("_btsetcurrent  _btsetcurrent")
end

function cPlayer:btsetcurrent(relativePath)
    self:_btsetcurrent(relativePath, d_ms.d_behaviorCommon.triggerMode.TM_Transfer, false)
end

function cPlayer:btReferenceTree(relativePath)
    self.m_referencetree = true
    self:_btsetcurrent(relativePath, d_ms.d_behaviorCommon.TM_Return, false);
end

function cPlayer:btEventTree(relativePath, triggerMode)
    self:_btsetcurrent(relativePath, triggerMode, true)
end

function cPlayer:btgetcurrent()
    return self.m_currentBT
end
--------------------------------------------------------------------------------------
function cPlayer:attackTarget(skillID)
    print("cPlayer:attackTarget", skillID)
    return EBTStatus.BT_SUCCESS
end
function cPlayer:getBeAttackedCount()
    print("cPlayer:getBeAttackedCount")
    return 1
end
function cPlayer:getBeAttackedTime()
    print("cPlayer:getBeAttackedTime")
    return 100
end
-- int
function cPlayer:getCurrentHpPercent()
    print("cPlayer:getCurrentHpPercent")
    return math.random(10000)/10000
end
-- behaviac::EBTStatus
function cPlayer:moveToPos(posX, posY, posZ)
    local t = math.random(100)
    print("cPlayer:moveToPos", posX, posY, posZ, t)
    if t < 30 then
        return EBTStatus.BT_SUCCESS
    elseif t < 80 then
        return EBTStatus.BT_RUNNING
    else
        return EBTStatus.BT_FAILURE
    end 
end
function cPlayer:moveToTarget(isRandom, distanceX, distanceY)
    local t = math.random(100)
    if t < 30 then
        print("cPlayer:moveToTarget", isRandom, distanceX, distanceY, "EBTStatus.BT_SUCCESS")
        return EBTStatus.BT_SUCCESS
    elseif t < 80 then
        print("cPlayer:moveToTarget", isRandom, distanceX, distanceY, "EBTStatus.BT_RUNNING")
        return EBTStatus.BT_RUNNING
    else
        print("cPlayer:moveToTarget", isRandom, distanceX, distanceY, "EBTStatus.BT_FAILURE")
        return EBTStatus.BT_FAILURE
    end 
end
function cPlayer:randomSearchTargetsFromHateList(targetCount)
    local t = math.random(100)
    if math.random(100) < 50 then
        print("cPlayer:randomSearchTargetsFromHateList", targetCount, "EBTStatus.BT_FAILURE")
        return EBTStatus.BT_FAILURE
    else
        print("cPlayer:randomSearchTargetsFromHateList", targetCount, "EBTStatus.BT_SUCCESS")
        return EBTStatus.BT_SUCCESS
    end
end
function cPlayer:searchTargetFromHateList(distance, isFirst)
    local t = math.random(100)
    if math.random(100) < 50 then
        print("cPlayer:searchTargetFromHateList", distance, isFirst, "EBTStatus.BT_FAILURE")
        return EBTStatus.BT_FAILURE
    else
        print("cPlayer:searchTargetFromHateList", distance, isFirst, "EBTStatus.BT_SUCCESS")
        return EBTStatus.BT_SUCCESS
    end
end
function cPlayer:randomSearchTargetsByDistance(distance, targetType, targetCount, isFriend)
    local t = math.random(100)
    if math.random(100) < 50 then
        print("cPlayer:searchTargetFromHateList", distance, targetType, targetCount, isFriend, "EBTStatus.BT_FAILURE")
        return EBTStatus.BT_FAILURE
    else
        print("cPlayer:searchTargetFromHateList", distance, targetType, targetCount, isFriend, "EBTStatus.BT_SUCCESS")
        return EBTStatus.BT_SUCCESS
    end
end
function cPlayer:searchTargetByDistance(distance, targetType, isNearest, isFriend)
    local t = math.random(100)
    if math.random(100) < 50 then
        print("cPlayer:searchTargetByDistance", distance, targetType, isNearest, isFriend, "EBTStatus.BT_FAILURE")
        return EBTStatus.BT_FAILURE
    else
        print("cPlayer:searchTargetByDistance", distance, targetType, isNearest, isFriend, "EBTStatus.BT_SUCCESS")
        return EBTStatus.BT_SUCCESS
    end
end
function cPlayer:searchTargetByHpInterval(distance, targetType, isMax, isFriend)
    local t = math.random(100)
    if math.random(100) < 50 then
        print("cPlayer:searchTargetByHpInterval", distance, targetType, isMax, isFriend, "EBTStatus.BT_FAILURE")
        return EBTStatus.BT_FAILURE
    else
        print("cPlayer:searchTargetByHpInterval", distance, targetType, isMax, isFriend, "EBTStatus.BT_SUCCESS")
        return EBTStatus.BT_SUCCESS
    end
end
function cPlayer:searchTargetsByHpInterval(distance, targetType, maxPercent, minPercent, targetCount, isFriend)
    local t = math.random(100)
    if math.random(100) < 50 then
        print("cPlayer:searchTargetsByHpInterval", distance, targetType, maxPercent, minPercent, targetCount, isFriend, "EBTStatus.BT_FAILURE")
        return EBTStatus.BT_FAILURE
    else
        print("cPlayer:searchTargetsByHpInterval", distance, targetType, maxPercent, minPercent, targetCount, isFriend, "EBTStatus.BT_SUCCESS")
        return EBTStatus.BT_SUCCESS
    end
end
--------------------------------------------------------------------------------------
function cPlayer:isActive()
    return self.m_bActive
end

math.randomseed(os.time())
local player = cPlayer.new()

local beginTime = os.time()
while os.time() - beginTime <= runTime do
    player:btexec()
end

-- for i= 1, 50 do
--     print('-----------------------start-----------------------', i)
--     player:btExec()
--     print('end', '----------------------------------------------', i)
-- end
function main_entrance(con, id, data, len, ses, cid, time)
    return 1
end

function error_handler(con, id, data, time, errCode)
end
