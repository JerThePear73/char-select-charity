function clamp_soft(num, min, max, rate)
    if num < min then
        num = num + rate
        num = math.min(num, max)
    elseif num > max then
        num = num - rate
        num = math.max(num, min)
    end
    return num
end

function convert_s16(num)
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

function mario_update_forward_vel_to_x_y(m)
    velAngle = convert_s16(m.faceAngle.y - atan2s(m.vel.z, m.vel.x))
    m.forwardVel = math.sqrt(m.vel.x^2 + m.vel.z^2);

    if (velAngle < -0x4000 or velAngle > 0x4000) then
        m.forwardVel = m.forwardVel * -1.0;
    end

    return m.forwardVel
end