require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/chattynode"

local BrainCommon = require "brains/braincommon"

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST = 9

local START_RUN_DIST = 3
local STOP_RUN_DIST = 5
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30
local SEE_TREE_DIST = 30

local KEEP_CHOPPING_DIST = 15

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8


local function IsDeciduousTreeMonster(guy)
    return guy.monster and guy.prefab == "deciduoustree"
end

local CHOP_MUST_TAGS = { "CHOP_workable" }
local function FindDeciduousTreeMonster(inst)
    return FindEntity(inst, SEE_TREE_DIST / 3, IsDeciduousTreeMonster, CHOP_MUST_TAGS)
end

local function KeepChoppingAction(inst)
    return inst.tree_target ~= nil
        or (inst.components.follower.leader ~= nil and
            inst:IsNear(inst.components.follower.leader, KEEP_CHOPPING_DIST))
        or FindDeciduousTreeMonster(inst) ~= nil
end

local function StartChoppingCondition(inst)
    return inst.tree_target ~= nil
        or (inst.components.follower.leader ~= nil and
            inst.components.follower.leader.sg ~= nil and
            inst.components.follower.leader.sg:HasStateTag("chopping"))
        or FindDeciduousTreeMonster(inst) ~= nil
end

local function FindTreeToChopAction(inst)
    local target = FindEntity(inst, SEE_TREE_DIST, nil, CHOP_MUST_TAGS)
    if target ~= nil then
        if inst.tree_target ~= nil then
            target = inst.tree_target
            inst.tree_target = nil
        else
            target = FindDeciduousTreeMonster(inst) or target
        end
        return BufferedAction(inst, target, ACTIONS.CHOP)
    end
end

local MINE_MUST_TAGS = { "MINE_workable" }
local MINE_CANT_TAGS = { "carnivalgame_part", "event_trigger", "waxedplant" }
local function KeepMiningAction(inst)
    return inst.components.follower.leader ~= nil and
        inst:IsNear(inst.components.follower.leader, KEEP_CHOPPING_DIST)
end

local function StartMiningCondition(inst)
    return inst.components.follower.leader ~= nil and
            inst.components.follower.leader.sg ~= nil and
            inst.components.follower.leader.sg:HasStateTag("mining")
end

local function FindRockToMineAction(inst)
    local target = FindEntity(inst, SEE_TREE_DIST, nil, MINE_MUST_TAGS, MINE_CANT_TAGS)
    if target == nil and inst.components.follower.leader ~= nil then
        target = FindEntity(inst.components.follower.leader, SEE_TREE_DIST, nil, MINE_MUST_TAGS, MINE_CANT_TAGS)
    end
    if target ~= nil then
        return BufferedAction(inst, target, ACTIONS.MINE)
    end
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function RescueLeaderAction(inst)
    return BufferedAction(inst, GetLeader(inst), ACTIONS.UNPIN)
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function GetFaceTargetNearestPlayerFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    return FindClosestPlayerInRange(x, y, z, START_RUN_DIST + 1, true)
end

local function KeepFaceTargetNearestPlayerFn(inst, target)
    return GetFaceTargetNearestPlayerFn(inst) == target
end


local WarlyPigBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function WarlyPigBrain:OnStart()
    local root =
        PriorityNode(
            {
                ChattyNode(self.inst, "PIG_TALK_FIGHT",
                    WhileNode(
                        function()
                            return self.inst.components.combat.target == nil or
                                not self.inst.components.combat:InCooldown()
                        end, "AttackMomentarily",
                        ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST))),
                ChattyNode(self.inst, "PIG_TALK_RESCUE",
                    WhileNode(
                        function()
                            return GetLeader(self.inst) and GetLeader(self.inst).components.pinnable and
                                GetLeader(self.inst).components.pinnable:IsStuck()
                        end, "Leader Phlegmed",
                        DoAction(self.inst, RescueLeaderAction, "Rescue Leader", true))),
                ChattyNode(self.inst, "PIG_TALK_FIGHT",
                    WhileNode(
                        function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end,
                        "Dodge",
                        RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST,
                            STOP_RUN_AWAY_DIST))),
                RunAway(self.inst,
                    function(guy)
                        return guy:HasTag("pig") and guy.components.combat and
                            guy.components.combat.target == self.inst
                    end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST),
                WhileNode(function() return true end, "IsDay",
                    PriorityNode {
                        IfThenDoWhileNode(function() return StartChoppingCondition(self.inst) end, function()
                                return
                                    KeepChoppingAction(self.inst)
                            end, "chop",
                            LoopNode {
                                ChattyNode(self.inst, "PIG_TALK_HELP_CHOP_WOOD",
                                    DoAction(self.inst, FindTreeToChopAction, nil, true)) }),
                        IfThenDoWhileNode(function() return StartMiningCondition(self.inst) end, function()
                                return
                                    KeepMiningAction(self.inst)
                            end, "chop",
                            LoopNode {
                                ChattyNode(self.inst, "PIG_TALK_HELP_CHOP_WOOD",
                                    DoAction(self.inst, FindRockToMineAction, nil, true)) }),
                        ChattyNode(self.inst, "PIG_TALK_FOLLOWWILSON",
                            Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST)),
                        IfNode(function() return GetLeader(self.inst) end, "has leader",
                            ChattyNode(self.inst, "PIG_TALK_FOLLOWWILSON",
                                FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn))),

                        ChattyNode(self.inst, "PIG_TALK_RUNAWAY_WILSON",
                            RunAway(self.inst, "player", START_RUN_DIST, STOP_RUN_DIST)),
                        ChattyNode(self.inst, "PIG_TALK_LOOKATWILSON",
                            FaceEntity(self.inst, GetFaceTargetNearestPlayerFn, KeepFaceTargetNearestPlayerFn)),
                    }, .5),
            }, .5)

    self.bt = BT(self.inst, root)
end

return WarlyPigBrain
