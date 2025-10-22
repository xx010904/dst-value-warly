local function OnPigCoinPostInit(inst)
    -- 保存原始的 spell 方法
    if inst and inst.components.spellcaster then
        local original_spell = inst.components.spellcaster.spell
        -- Hook 新的 spell 方法
        inst.components.spellcaster.spell = function(inst, target, pos, caster)
            -- 召唤 60 只精英
            for i = 1, 2 do
                -- 召唤精英的方法
                local function custom_spellfn(inst, target, pos, caster)
                    if caster ~= nil then
                        local pos = caster:GetPosition()

                        -- 创建精英
                        local elite = SpawnPrefab("pigelitefighter" .. math.random(4))
                        elite.Transform:SetPosition(pos.x,
                            (caster.components.rider ~= nil and caster.components.rider:IsRiding()) and 3 or 0, pos.z)
                        elite.components.follower:SetLeader(caster)
                        elite.components.health:SetInvincible(true)

                        -- 设置精英位置
                        local theta = math.random() * PI2
                        local offset = FindWalkableOffset(pos, theta, 2.5, 16, true, true, nil, false, true)
                            or FindWalkableOffset(pos, theta, 2.5, 16, false, false, nil, false, true)
                            or Vector3(0, 0, 0)
                        pos.x, pos.y, pos.z = pos.x + offset.x, 0, pos.z + offset.z
                        elite.sg:GoToState("spawnin", { dest = pos })

                        -- 设置精英存在时间（例如：60秒）
                        elite.components.timer:SetTimeLeft("despawn_timer", 180)
                    end
                end

                custom_spellfn(inst, target, pos, caster)
            end
            -- 调用原始的 spell 方法
            if original_spell then
                original_spell(inst, target, pos, caster)
            end
        end
    end
end

AddPrefabPostInit("pig_coin", OnPigCoinPostInit)
