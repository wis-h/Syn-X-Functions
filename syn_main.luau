--[[
 Author: RazAPIx64.dll32 or razapix64.dll32 (on Discord)
 Filename: syn_main.luau

 Syn-X-Functions © 2025 by RazAPI is licensed under Creative Commons Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)

 You are free to use, distribute, and share the Syn-X-Functions project as long as you provide proper attribution to the original creator. 
 However, you may not modify, remix, or fork this project in any way. Redistribution of the work is only allowed in its original, unaltered form. 
 All users must credit the creator when using the project, and no derivative works or adaptations are permitted.
]]


--[[
 REQUIREMENTS:

 - A level 3-8 internal-external (not possible on external since you need getreg which is implemented internally)
 - 1 byte of ram
]]

local syn: table = {
  is_Beta = true,
  Cached: table = {},
  insert = function(a, b, c, d)
     table.insert(a,b)
     table.insert(c,d)
  end,
}
local identity = if getidentity or getthreadidentity then getidentity() else 0 end

syn.__index = syn;
local NULL = nil
local env = getfenv()

function PROTOSMASHER_LOADED() return syn.is_Beta end -- or return true;

function is_syn_function(func) -- needed for whatever
  if syn[func] then
    return true
  else
    return false
  end
  
  return false
end
function syn_isbeta() return syn.is_Beta end

function syn.checkcaller()
 if env.checkcaller or checkcaller then return env.checkcaller or checkcaller else return NULL end
 return NULL
end

function syn.cache_invalidate(invalidated_Cache: Instance)
  if cache and cache.invalidate then return cache.invalidate(invalidated_Cache) end
  table.insert(syn.Cached, invalidated_Cache)
  if env.getreg or getreg then getreg[invalidated_Cache] = nil; else syn.Cached[invalidated_Cache] = true; invalidated_Cache.Parent = nil; invalidated_Cache = nil end
  -- cache.invalidate is supposed to invalidate the instance (or whatever) from the registry/cache
  -- owner of sUNC [senS], 2025.
end

function syn.cache_replace(Cache1: Instance, Cache2: Instance)
 syn.insert(syn.Cached, Cache1, syn.Cached, Cache2);
 if cache and cache.replace then return cache.replace(Cache1, Cache2) end
 if env.getreg or getreg then getreg[Cache1] = getreg[Cache2] else
    local main = getmetatable(syn.Cached[Cache1]) or syn.Cached[Cache1]
    local main2 = getmetatable(syn.Cached[Cache2]) or syn.Cached[Cache2]
    
    syn.Cached[main] = syn.Cached[main2]
  end
end

function syn.cache_iscached(iscached_Cache: Instance)
  -- Murda Musik (feat. Destroy Lonely)
  if cache and cache.iscached then return cache.iscached(iscached_Cached) end
  if env.getreg or getreg then return getreg[iscached_Cached] == nil else
     return syn.Cached[iscached_Cached] == nil
  end

  return syn.Cached[iscached_Cached] == nil
end

function syn.request(options: table)
  local hwid = if gethwid then gethwid() else string.char(math.random(32, 64)) end
  local user = tostring(game:GetService("Players").LocalPlayer.Name) or tostring(game:GetService("Players").LocalPlayer.DisplayName)
  if env.request and request then
    options['Syn-Fingerprint'] = hwid
    options['Syn-User-Identifier'] = user
    options['User-Agent'] = {'user-agent: synx/v2.1.3b'}
    return request(options)
  end
end

if type(env.crypt) == 'table' or type(crypt) == 'table' then syn.crypt = env.crypt or crypt else return NULL end -- i am not completing the rest.

function syn.secure_call(func)
    local new_game = newproxy(true)
    local environment = getfenv(func)
    local game_mt = getmetatable(new_game)

    game_mt.__index = function(_, key)
        if key == 'GetService' then
            return function(_, ...)
                return game.GetService(game, ...)
            end
        elseif key == 'HttpGet' or key == 'HttpPost' or key == 'HttpGetAsync' or key == 'HttpPostAsync' then
            return function() return nil end
        else
            return game[key]
        end
    end

    environment.getgenv = nil
    environment.getfenv = nil
    environment.game = new_game

    setfenv(func, environment)
    return new_game
end



function syn.create_secure_function(arg) -- this is an inaccurate way to do it, these should be done internally.
  return coroutine.wrap(function(...)
       while true do
        return coroutine.yield(arg(...)) -- keep yielding so the coroutine can be called every 1 nanosecond or so
      end
    end)
end

function syn.run_secure_function(func, ...)
    return coroutine.wrap(func)(...)
end


function syn.get_thread_identity()
  return tonumber(identity)
end

function syn.set_thread_identity(new)
  identity = new
end

function syn.toast_notification(T: string, T2: string, image)
  game.GetService(game, 'StarterGui'):SetCore("SendNotification", {
    Title = T,
    Text = T2,
    Icon = image or NULL
 })
  -- Reminder: This is a synapse z function
end

function syn.kill_process()
  -- you cannot do this in lua, so just make them exit the game [some exploits have game:Shutdown() blocked, so just pcall it]
  local a,b = pcall(function() return game:Shutdown() end
  if not a then return NULL else game:Shutdown() end
end

function syn.isreadonly(main: table): boolean
  if env.isreadonly or isreadonly then return env.isreadonly or isreadonly else return table.isfrozen(main) end
  return table.isfrozen(main)
end

function syn.setreadonly(tb, option: boolean)
 if env.setreadonly or setreadonly then return env.setreadonly(tb, option) or setreadonly(tb, option) end
    return NULL
end

return syn
