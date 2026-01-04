-- debug_tracker.lua
local log = require("framework.logger")

local Tracker = {}
Tracker.__index = Tracker

-- State storage
local state = {
    current_stage = "Idle",
    stages = {
        { name = "Triggered", duration = nil, status = "pending", info = nil },
        { name = "Choosing Actor", duration = nil, status = "pending", info = nil },
        { name = "Memory Store", duration = nil, status = "pending", info = nil },
        { name = "Sent to LLM", duration = nil, status = "pending", info = nil },
        { name = "Response", duration = nil, status = "pending", info = nil }
    },
    start_times = {},
    fail_reason = nil
}

function Tracker.reset()
    state.current_stage = "Idle"
    state.fail_reason = nil
    state.start_times = {}
    for _, stage in ipairs(state.stages) do
        stage.duration = nil
        stage.status = "pending"
        stage.info = nil
    end
end

function Tracker.set_stage_info(stage_name, info_text)
    for _, stage in ipairs(state.stages) do
        if stage.name == stage_name then
            stage.info = info_text
            break
        end
    end
end

function Tracker.set_fail_reason(reason)
    state.fail_reason = reason
    state.current_stage = "Failed: " .. reason
    
    -- Close any running stage
    for _, stage in ipairs(state.stages) do
        if stage.status == "running" then
            stage.status = "failed"
            local start_time = state.start_times[stage.name] or os.clock()
            stage.duration = os.clock() - start_time
        end
    end
end

function Tracker.start_stage(stage_name)
    state.current_stage = stage_name
    state.start_times[stage_name] = os.clock()
    
    -- update status in list
    for _, stage in ipairs(state.stages) do
        if stage.name == stage_name then
            stage.status = "running"
        elseif stage.status == "running" then
             -- previous stage finished?
             stage.status = "done"
        end
    end
end

function Tracker.end_stage(stage_name)
    local start_time = state.start_times[stage_name]
    if start_time then
        local duration = os.clock() - start_time
        
        for _, stage in ipairs(state.stages) do
            if stage.name == stage_name then
                stage.duration = duration
                stage.status = "done"
                break
            end
        end
    end
end

function Tracker.get_state()
    return state
end

return Tracker
