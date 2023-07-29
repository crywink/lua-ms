--[[
    ms-lua
    Author(s): Sam Kalish
    Date: 06/20/2022
--]]

local s = 1000
local m = s * 60
local h = m * 60
local d = h * 24
local w = d * 7
local y = d * 365.25

local Units = {
    year = {
        "years",
        "yrs",
        "yr",
        "y"
    },
    week = {
        "weeks",
        "week",
        "w"
    },
    day = {
        "days",
        "day",
        "d"
    },
    hour = {
        "hours",
        "hour",
        "hrs",
        "hr",
        "h"
    },
    minute = {
        "minutes",
        "minute",
        "mins",
        "min",
        "m"
    },
    second = {
        "seconds",
        "second",
        "secs",
        "sec",
        "s"
    },
    millisecond = {
        "milliseconds",
        "millisecond",
        "msecs",
        "msec",
        "ms"
    }
}

local STRING_PATTERN = "(%d+)(%a+)"

type Options = {
    long: boolean?
}

local function round(num: number)
    return math.floor(num + 0.5)
end

local function plural(ms: number, n: number, name: string)
    return name .. (ms >= n * 1.5 and "s" or "")
end

local function parse(value: string)
    local totalMs = 0

    for stringGroup in value:gmatch("(%d+%a+)") do
        local record = { stringGroup:match(STRING_PATTERN) } 
        local num, unit = tonumber(record[1]), record[2]

        assert(num, "Invalid number")
        assert(unit, "Invalid unit")

        local realUnit
        for groupName, group in Units do
            for _, unitName in group do
                if string.lower(unit) == unitName then
                    realUnit = groupName
                    break
                end
            end
        end

        assert(realUnit, "Invalid unit")

        if realUnit == "year" then
            totalMs += num * y
        elseif realUnit == "week" then
            totalMs += num * w
        elseif realUnit == "day" then
            totalMs += num * d
        elseif realUnit == "hour" then
            totalMs += num * h
        elseif realUnit == "minute" then
            totalMs += num * m
        elseif realUnit == "second" then
            totalMs += num * s
        elseif realUnit == "millisecond" then
            totalMs += num
        else
            error(`Cannot find unit for ${stringGroup}. Unit: ${realUnit}`)
        end
    end

    return totalMs
end

local function formatShort(value: number): string
    local ms = math.abs(value)

    if ms >= d then
        return `{round(ms / d)}d`
    elseif ms >= h then
        return `{round(ms / h)}h`
    elseif ms >= m then
        return `{round(ms / m)}m`
    elseif ms >= s then
        return `{round(ms / s)}s`
    else
        return `{ms}ms`
    end
end

local function formatLong(value: number): string
    local ms = math.abs(value)

    if ms >= d then
        return `{round(ms / d)} {plural(ms, d, "day")}`
    elseif ms >= h then
        return `{round(ms / h)} {plural(ms, h, "hour")}`
    elseif ms >= m then
        return `{round(ms / m)} {plural(ms, m, "minute")}`
    elseif ms >= s then
        return `{round(ms / s)} {plural(ms, s, "second")}`
    else
        return `{ms} milliseconds`
    end
end

--[=[
    @param value<string|number> The value to convert
    @param options<Options> The options to use

    Convert a string to milliseconds
    ```lua
    ms("1d") -- 86400000
    ```

    Convert milliseconds to a formatted string
    ```lua
    ms(86400000) -- 1d
    ```

    Convert milliseconds to a formatted string with long format
    ```lua
    ms(86400000, { long = true }) -- 1 day
    ```
]=]
return function(value: string | number, options: Options)
    local valueType = type(value)
    local valueNum = tonumber(value)

    if valueType == "number" or valueNum then
        local formatter = options and options.long and formatLong or formatShort
        return formatter(valueNum)
    elseif valueType == "string" then
        return parse(value :: string)
    else
        error("Invalid value type")
    end
end