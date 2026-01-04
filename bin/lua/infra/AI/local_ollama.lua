-- ollama.lua
local http   = require("infra.HTTP.HTTP")
local json   = require("infra.HTTP.json")
local log    = require("framework.logger")
local config = require("interface.config")

local ollama = {}

-- ollama models
local DEEPSEEK_FAST = "deepseek-r1:1.5b"
local DEEPSEEK_MID = "deepseek-r1:7b"
local DEEPSEEK_SMART = "deepseek-r1:32b"

local NEMO = "nemotron-mini:4b"

local LLAMA = "llama3.2"
local LLAMA_small="llama3.2:1b"

-- model registry
-- managed dynamically via config

-- sampling presets
local PRESET = {
  creative = {temperature=0.9 ,max_tokens=150,top_p=1,frequency_penalty=0,presence_penalty=0},
  strict   = {temperature=0.0 ,max_tokens=150,top_p=1,frequency_penalty=0,presence_penalty=0},
}

-- helpers --------------------------------------------------------------

-- helpers --------------------------------------------------------------
local function get_api_url(opts)
    opts = opts or {}
    if opts.use_fast and config.use_fast_model() then
        return config.local_url_fast()
    end
    return config.local_url()
end

local function build_body(messages, opts)
  opts = opts or PRESET.creative

  -- force all roles to "user"
  local user_msgs = {}
  for _, msg in ipairs(messages) do
    table.insert(user_msgs, {role = "user", content = msg.content})
  end

  return {
    model    = opts.model or config.local_model_name(),
    messages = user_msgs,
    stream   = false,
  }
end
local function send(messages, callback, opts)
  assert(type(callback)=="function","callback required")

  local headers = {["Content-Type"] = "application/json"}
  local body_tbl = build_body(messages, opts)
  log.http("Ollama request: %s", json.encode(body_tbl))


  -- Pass opts to get_api_url to decide which URL to use
  return http.send_async_request(get_api_url(opts), "POST", headers, body_tbl, function(resp, err)
    if err or (resp and resp.error) then
      local err_str = type(err)=="table" and json.encode(err) or tostring(err)
      log.error("ollama error: error:" .. err_str .. " body:" .. json.encode(resp))
      if callback then callback(nil) end
      return
    end
    
    -- Universal Response Parsing (Matches OpenAI/LMStudio AND Ollama)
    local answer = nil
    if resp.choices and resp.choices[1] and resp.choices[1].message then
        answer = resp.choices[1].message.content
    elseif resp.message then
        answer = resp.message.content
    end

    -- Reasoning Model Support (Strip <think> blocks)
    if answer then
        local found_think = false
        local function strip_think(str)
            local s, e = string.find(str, "<think>", 1, true)
            local s2, e2 = string.find(str, "</think>", 1, true)
            if s and e2 and e2 > s then
                found_think = true
                -- cut out the block
                return strip_think(string.sub(str, 1, s-1) .. string.sub(str, e2+1))
            end
            return str
        end
        
        local clean_answer = strip_think(answer)
        if found_think then
            log.warn("Performance Warning: Detected 'Regioning Model' (<think> tags). This adds massive latency (5s+). Recommend using a standard Instruct model for speed.")
            log.debug("Stripped <think> block. Original Length: " .. #answer .. " Clean Length: " .. #clean_answer)
            answer = clean_answer
        end
    end

    log.debug("Ollama response: %s", answer)
    callback(answer)
  end)

end

-- public shortcuts -----------------------------------------------------
function ollama.generate_dialogue(msgs, callback)
  -- Always uses Main (Smart) model
  return send(msgs, callback, PRESET.creative)
end

function ollama.pick_speaker(msgs, callback)
    local use_fast = config.use_fast_model()
    local model_name = use_fast and config.local_model_name_fast() or config.local_model_name()
    
    return send(msgs, callback, {
        model = model_name, 
        temperature = 0.0, 
        max_tokens = 30,
        use_fast = use_fast -- flag for get_api_url
    })
end

function ollama.summarize_story(msgs, callback)
    local use_fast = config.use_fast_model()
    local model_name = use_fast and config.local_model_name_fast() or config.local_model_name()

    return send(msgs, callback, {
        model = model_name, 
        temperature = 0.2, 
        max_tokens = 100,
        use_fast = use_fast -- flag for get_api_url
    })
end


function ollama.test_connection(callback)
    local msgs = {{content="State only the word 'OK'."}}
    
    log.info("Testing Main Connection...")
    -- Test Main Model
    send(msgs, function(response) 
        if not response then 
            callback("Main Model Connection FAILED")
            return 
        end
        
        -- If Fast Model is disabled, we are done
        if not config.use_fast_model() then
            callback("Main Model Connection OK!")
            return
        end
        
        -- Test Fast Model
        log.info("Testing Fast Connection...")
        send(msgs, function(response_fast)
            if not response_fast then
                callback("Main Model OK. Fast Model FAILED.")
            else
                callback("Both Models Connection OK!")
            end
        end, {use_fast = true, model = config.local_model_name_fast(), temperature=0.0, max_tokens=10})
        
    end, {use_fast = false, model = config.local_model_name(), temperature=0.0, max_tokens=10})
end

return ollama
