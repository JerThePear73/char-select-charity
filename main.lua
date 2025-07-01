-- name: [CS] CHARITY
-- description: its me :)

local E_MODEL_CHARITY = smlua_model_util_get_id("charity_geo")

local TEX_CHARITY = get_texture_info("charity-icon")

local TEXT_MOD_NAME = "CHARITY"

local VOICETABLE_CHARITY = {
	[CHAR_SOUND_UH] = 'bonk.ogg',
	[CHAR_SOUND_DOH] = 'bonk.ogg',
	[CHAR_SOUND_OOOF] = 'bonk.ogg',
	[CHAR_SOUND_OOOF2] = {'hurt1.ogg', 'hurt2.ogg', 'hurt3.ogg', 'hurt4.ogg', 'hurt5.ogg', 'hurt6.ogg', 'hurt7.ogg', 'hurt8.ogg'},
	[CHAR_SOUND_ATTACKED] = {'hurt1.ogg', 'hurt2.ogg', 'hurt3.ogg', 'hurt4.ogg', 'hurt5.ogg', 'hurt6.ogg', 'hurt7.ogg', 'hurt8.ogg'},
	[CHAR_SOUND_ON_FIRE] = {'hurt1.ogg', 'hurt2.ogg', 'hurt3.ogg', 'hurt4.ogg', 'hurt5.ogg', 'hurt6.ogg', 'hurt7.ogg', 'hurt8.ogg'},
	[CHAR_SOUND_WAAAOOOW] = 'die.ogg',
	[CHAR_SOUND_DYING] = 'die.ogg',
	[CHAR_SOUND_DROWNING] = 'diedrown.ogg',
	[CHAR_SOUND_PANTING] = 'silence.ogg',
	[CHAR_SOUND_PUNCH_YAH] = 'punch1.ogg',
	[CHAR_SOUND_PUNCH_WAH] = 'punch2.ogg',
	[CHAR_SOUND_PUNCH_HOO] = 'punch3.ogg',
	[CHAR_SOUND_HRMM] = {'grab1.ogg', 'grab2.ogg', 'grab3.ogg'},
	[CHAR_SOUND_WAH2] = {'wah1.ogg', 'wah2.ogg', 'wah3.ogg'},
	[CHAR_SOUND_WHOA] = {'ledgegrab1.ogg', 'ledgegrab2.ogg', 'ledgegrab3.ogg'},
	[CHAR_SOUND_EEUH] = 'ledgeup.ogg',
	[CHAR_SOUND_UH2] = {'quickup1.ogg', 'quickup2.ogg', 'quickup3.ogg'},
	[CHAR_SOUND_GROUND_POUND_WAH] = {'wah1.ogg', 'wah2.ogg', 'wah3.ogg'},
	[CHAR_SOUND_YAH_WAH_HOO] = {'jump1.ogg', 'jump2.ogg', 'jump3.ogg'},
	[CHAR_SOUND_HOOHOO] = {'silence.ogg'},
	[CHAR_SOUND_HAHA] = 'squeaker.ogg',
	[CHAR_SOUND_HAHA_2] = 'silence.ogg',
}


local CAPTABLE_CHARITY = {
    normal = smlua_model_util_get_id("charity_cap_geo"),
    wing = smlua_model_util_get_id("charity_cap_wing_geo"),
    metal = smlua_model_util_get_id("charity_cap_metal_geo"),
    metalWing = smlua_model_util_get_id("charity_cap_metal_wing_geo"),
}

local PALETTE_CHARITY = {
    [GLOVES] = {r = 87, g = 71, b = 75},
    [PANTS] = {r = 77, g = 11, b = 22},
    [CAP] = {r = 90, g = 21, b = 30},
    [SKIN] = {r = 255, g = 224, b = 224},
    [SHOES] = {r = 203, g = 174, b = 174},
    [HAIR] = {r = 255, g = 152, b = 162},
    [SHIRT] = {r = 151, g = 34, b = 42},
    [EMBLEM] = {r = 0, g = 0, b = 0}
}

CT_CHARITY = 0
if _G.charSelectExists then
    CT_CHARITY = _G.charSelect.character_add("CHARITY", {"strange cat...bat...bunny thing...", "freakshow central"}, "modeled by wibblus", {r = 255, g = 100, b = 100}, E_MODEL_CHARITY, CT_MARIO, TEX_CHARITY)
    _G.charSelect.character_add_caps(E_MODEL_CHARITY, CAPTABLE_CHARITY)
    _G.charSelect.character_add_palette_preset(E_MODEL_CHARITY, PALETTE_CHARITY)
    _G.charSelect.character_set_category(CT_CHARITY, "Squishy Workshop")

    -- the following must be hooked for each character added
    _G.charSelect.character_add_voice(E_MODEL_CHARITY, VOICETABLE_CHARITY)
    _G.charSelect.config_character_sounds()
else
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
end

-- Wavedashing Moveset
gCharityStates = {}
for i = 0, MAX_PLAYERS - 1 do
    gCharityStates[i] = {
        wavedashVelX = 0,
        wavedashVelY = 0,
        wavedashVelZ = 0,
    }
end

local function clamp_soft(num, min, max, rate)
    if num < min then
        num = num + rate
        num = math.min(num, max)
    elseif num > max then
        num = num - rate
        num = math.max(num, min)
    end
    return num
end

local function convert_s16(num)
    local min = -32768
    local max = 32767
    while (num < min) do
        num = max + (num - min)
    end
    while (num > max) do
        num = min + (num - max)
    end
    return num
end

local function mario_update_forward_vel_to_x_y(m)
    velAngle = convert_s16(m.faceAngle.y - atan2s(m.vel.z, m.vel.x))
    m.forwardVel = math.sqrt(m.vel.x^2 + m.vel.z^2);

    if (velAngle < -0x4000 or velAngle > 0x4000) then
        m.forwardVel = m.forwardVel * -1.0;
    end

    return m.forwardVel
end

local ACT_CHARITY_WAVEDASH = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
local ACT_CHARITY_WAVEDASH_SLIDE = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)

local wavedashMaxSpeed = 60
local wavedashDecelGround = 0.7
local wavedashDecelAirMult = 0.85
local wavedashDisableActs = {
    [ACT_CHARITY_WAVEDASH] = true,
    [ACT_DIVE] = true,
    [ACT_BACKWARD_ROLLOUT] = true,
    [ACT_STEEP_JUMP] = true,
}
local wavedashKillActs = {
    [ACT_WALL_KICK_AIR] = true,
    [ACT_SOFT_BONK] = true,
    [ACT_GROUND_BONK] = true
}
local function act_charity_wavedash(m)
    local e = gCharityStates[m.playerIndex]
    if m.actionTimer == 0 then
        local dodgeMultY = -0.7
        if m.controller.buttonDown & A_BUTTON ~= 0 then
            dodgeMultY = 1
        end
        e.wavedashVelX = sins(m.intendedYaw)*wavedashMaxSpeed*(m.intendedMag/32)
        e.wavedashVelY = dodgeMultY*wavedashMaxSpeed
        e.wavedashVelZ = coss(m.intendedYaw)*wavedashMaxSpeed*(m.intendedMag/32)

        set_mario_animation(m, CHAR_ANIM_WING_CAP_FLY)
    end

    e.wavedashVelX = e.wavedashVelX * wavedashDecelAirMult
    e.wavedashVelY = e.wavedashVelY * wavedashDecelAirMult
    e.wavedashVelZ = e.wavedashVelZ * wavedashDecelAirMult

    m.vel.x = 0
    m.vel.y = 0
    m.vel.z = 0
    m.forwardVel = 0
    m.slideVelX = 0
    m.slideVelZ = 0

    m.marioObj.header.gfx.angle.y = m.faceAngle.y + 0x8000
    m.marioObj.header.gfx.angle.x = m.faceAngle.x + 0x8000
    
    if m.actionTimer > 15 then
        set_mario_action(m, ACT_BACKWARD_ROLLOUT, 0)
    end

    local step = perform_air_step(m, AIR_STEP_NONE)
    if step == AIR_STEP_LANDED then
        set_mario_action(m, ACT_CHARITY_WAVEDASH_SLIDE, 0)
    end
    m.actionTimer = m.actionTimer + 1

    if m.pos.y + e.wavedashVelX + m.marioObj.hitboxHeight < m.ceilHeight then
        m.pos.y = m.pos.y + e.wavedashVelY
    else
        m.pos.y = m.ceilHeight - m.marioObj.hitboxHeight
    end

    m.pos.x = m.pos.x + e.wavedashVelX
    m.pos.z = m.pos.z + e.wavedashVelZ
end

local function act_charity_wavedash_slide(m)
    local e = gCharityStates[m.playerIndex]
    if math.sqrt(e.wavedashVelX^2 + e.wavedashVelZ^2) > 1 then
        e.wavedashVelX = clamp_soft(e.wavedashVelX, 0, 0, wavedashDecelGround)
        e.wavedashVelZ = clamp_soft(e.wavedashVelZ, 0, 0, wavedashDecelGround)
        e.wavedashVelY = 0
    else
        set_mario_action(m, ACT_CROUCHING, 0)
    end

    perform_ground_step(m)
    set_mario_animation(m, CHAR_ANIM_CROUCHING)

    if m.controller.buttonPressed & A_BUTTON ~= 0 then
        m.vel.x = e.wavedashVelX
        m.vel.z = e.wavedashVelZ
        mario_update_forward_vel_to_x_y(m)
        set_mario_action(m, ACT_DOUBLE_JUMP, 0)
    end

    if m.controller.buttonPressed & B_BUTTON ~= 0 then
        m.vel.x = e.wavedashVelX
        m.vel.z = e.wavedashVelZ
        mario_update_forward_vel_to_x_y(m)
        set_mario_action(m, ACT_MOVE_PUNCHING, 0)
    end

    m.pos.x = m.pos.x + e.wavedashVelX
    m.pos.y = m.pos.y + e.wavedashVelY
    m.pos.z = m.pos.z + e.wavedashVelZ
end

hook_mario_action(ACT_CHARITY_WAVEDASH, act_charity_wavedash)
hook_mario_action(ACT_CHARITY_WAVEDASH_SLIDE, act_charity_wavedash_slide)

local function charity_update(m)
    local e = gCharityStates[m.playerIndex]
    if m.controller.buttonPressed & L_TRIG ~= 0 and m.action & ACT_FLAG_AIR ~= 0 and not wavedashDisableActs[m.action] then
        set_mario_action(m, ACT_CHARITY_WAVEDASH, 0)
    end

    -- Update Wavedash

    if wavedashKillActs[m.action] then
        e.wavedashVelX = 0
        e.wavedashVelY = 0
        e.wavedashVelZ = 0
    end
end

_G.charSelect.character_hook_moveset(CT_CHARITY, HOOK_MARIO_UPDATE, charity_update)