-- dynamic_config.lua – values that depend on talker_mcm are now getters
local game_config = talker_mcm
local language = require("infra.language")




-- helper
local function cfg(key, default)
    return (game_config and game_config.get and game_config.get(key)) or default
end


local function is_valid_key(key)
    return key and key:match("^sk%-[%w%-_]+") and #key >= 20
end

local function try_load(path)
    local f = io.open(path, "r")
    if f then
        local key = f:read("*a")
        f:close()
        if is_valid_key(key) then return key end
    end
    return nil
end

local function load_api_key(FileName, env_var_name)
    local paths = {
        string.lower(FileName)..".txt",
        FileName..".key",
        "..\\"..string.lower(FileName)..".txt",
        "..\\"..FileName..".key"
    }

    local temp_path = os.getenv("TEMP") or os.getenv("TMP")
    if temp_path then
        table.insert(paths, temp_path.."\\"..FileName..".key")
        table.insert(paths, temp_path.."\\"..string.lower(FileName)..".txt")
    end

    for _, path in ipairs(paths) do
        local key = try_load(path)
        if key then return key end
    end

    if env_var_name then
        local key = os.getenv(env_var_name)
        if is_valid_key(key) then return key end
    end

    return nil
end


local c = {}

-- static values
c.EVENT_WITNESS_RANGE  = 25
c.NPC_SPEAK_DISTANCE   = 30
c.EVENT_WITNESS_RANGE  = 25
c.NPC_SPEAK_DISTANCE   = 30
c.player_speaks        = false


function c.base_chance()
    return 0.25 -- Fixed 25% chance for ambient/flavor events
end

function c.clear_memory_on_load()
    return cfg("clear_memory_on_load", false)
end

function c.memory_threshold()
    local profile = cfg("context_profile", 2) -- Default to 2 (Medium)
    
    -- Map integer to profile logic (1=Low, 2=Medium, 3=High)
    if profile == 1 then return 4 -- Low
    elseif profile == 3 then return 16 -- High
    end
    return 8 -- Medium/Default (2)
end



function c.speak_key()
    return cfg("speak_key", "x")
end


-- dynamic getters


function c.local_url()
    return cfg("local_url", "http://localhost:11434/api/chat")
end

function c.local_model_name()
    return cfg("local_model_name", "llama3.2")
end


function c.local_model_name_fast()
    return cfg("local_model_name_fast", "llama3.2:1b")
end

function c.local_url_fast()
    return cfg("local_url_fast", "http://localhost:11434/api/chat")
end

function c.use_fast_model()
    return cfg("use_fast_model", true)
end

function c.debug_enabled()
    return cfg("debug_enabled", false)
end

function c.language()
    return cfg("language", DEFAULT_LANGUAGE)
end

function c.language_short()
    return language.to_short(c.language())
end



function c.dialogue_prompt()
    return ("You are a dialogue generator for the harsh setting of STALKER. Swear if appropriate. " ..
            "Limit your reply to one sentence of dialogue. " ..
            "Write ONLY dialogue and make it without quotations or leading with the character name. Avoid cliche and corny dialogue " ..
            "Write dialogue that is realistic and appropriate for the tone of the STALKER setting. " ..
            "Don't be overly antagonistic if not provoked. " ..
            "Speak %s"
        ):format(c.language())
end

return c
