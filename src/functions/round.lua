---@diagnostic disable-next-line: lowercase-global
function round(num, numDecimalPlaces)
    local multi = 10 ^ (numDecimalPlaces or 0)

    return math.floor(num * multi + 0.5) / multi
end
