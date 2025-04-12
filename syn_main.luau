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

local syn = {
	is_Beta = true,
	Cached = {},
	insert = function(a, b, c, d)
		table.insert(a,b)
		table.insert(c,d)
	end,
}

local identity

if getidentity then identity = getidentity else identity = nil end

syn.__index = syn;
local NULL = nil
local env = getfenv()

function PROTOSMASHER_LOADED() return syn.is_Beta end -- or return true;

function is_syn_function(func) -- needed for whatever
	return type(func) == 'function' or syn.is_Beta
end
is_synapse_function = is_syn_function
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
	local hwid
	if gethwid then hwid = gethwid() else hwid = string.char(math.random(32, 64)) end
	local user = tostring(game:GetService("Players").LocalPlayer.Name) or tostring(game:GetService("Players").LocalPlayer.DisplayName)
	if env.request or request then
		options['Syn-Fingerprint'] = hwid
		options['Syn-User-Identifier'] = user
		options['User-Agent'] = 'user-agent: synx/v2.1.3b'
		return (env.request or request)(options)
	end
	return NULL
end

if type(crypt) == 'table' or type(env.crypt) == 'table' then syn.crypt = env.crypt or crypt end-- i am not completing the rest.

function syn.secure_call(target_func, fake_script, ...)
	local new_game = newproxy(true) -- create a sandboxed proxy (for the skids: userdata = newproxy(true))
	local env = getfenv(target_func)
	local game_mt = getmetatable(new_game)

	game_mt.__index = function(_, key)
		if key == 'GetService' then
			return function(_, ...)
				return game.GetService(game, ...)
			end
		elseif key == 'HttpGet' or key == 'HttpPost' or key == 'HttpGetAsync' or key == 'HttpPostAsync' then
			return function() return nil end -- game proxy with no httpget or http requesting related stuff
		else
			return game[key]
		end
	end

	env.getgenv = nil

	env.getfenv = function()
		return getfenv(0)
	end

	env.script = fake_script -- make the called script a fake one 
	env.game = new_game -- change the caller's environment to the proxied game

	setfenv(target_func, env)

	return target_func(...) -- my work here is done
end

function syn.create_secure_vm(fake_script)
	local new_game = newproxy(true)
	local game_mt = getmetatable(new_game)

	game_mt.__index = function(_, key)
		if key == 'GetService' then
			return function(_, ...)
				return game:GetService(...)
			end
		elseif key == 'HttpGet' or key == 'HttpPost' or key == 'HttpGetAsync' or key == 'HttpPostAsync' then
			return function() return nil end
		else
			return game[key]
		end
	end

	local env = {}
	local base_env = getfenv(0)

	for k, v in pairs(base_env) do
		env[k] = v
	end

	env.game = new_game
	env.script = fake_script
	env.getgenv = nil
	env.getfenv = function()
		return base_env
	end
	env.setfenv = setfenv
	env.setmetatable = setmetatable
	env.getmetatable = getmetatable

	return env
end



function syn.run_secure_function(func, ...)
	return coroutine.wrap(func)(...)
end

function syn.create_secure_function(arg)
	assert(type(arg) == 'function', 'expected a function, got ' .. type(arg))
	table.insert(syn, {func = arg})

	local proxied_game = newproxy(true)
	local proxiedMt = getmetatable(proxied_game)

	proxiedMt.__index = function(_, key)
		if key == 'GetService' then
			return function(_, ...)
				return game.GetService(game, ...)
			end
		elseif key == 'HttpGet' or key == 'HttpPost' or key == 'HttpGetAsync' or key == 'HttpPostAsync' then
			return function(...) return error("Cannot send http requests while being in a SynapseProtected Sandbox") end
		end
		return game[key]
	end

	local env = getfenv(arg)
	env.game = proxied_game
	env.getfenv = function() return getfenv(0) end

	return arg
end

	function syn.queue_on_teleport(scr)
		local r = getfenv()
		game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
			if State == Enum.TeleportState.Started then
				scr = scr:gsub("%s*([%w_]+)%s*%.%s*([%w_]+)", function(k, n)
					local v = r[k]
					if v then
						return v[n]
					end
					return k .. "." .. n
				end)
				local after_teleport = syn.create_secure_function(function(__)
					return __
				end)

				syn.run_secure_function(after_teleport, scr)
			end
		end)
	end

	function syn.is_luau()
		return _VERSION == 'Luau'
	end

	function syn.secrun(scr)
		local environment = getfenv()
		local newEnv = setmetatable({}, {
			__index = function(t, key)
				if key == "game" then
					return game
				elseif key == "print" then
					return print
				else
					return environment[key]
				end
			end
		})

		if loadstring then setfenv(loadstring(scr), newEnv)() else return NULL end
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
		local a,b = pcall(function() return game:Shutdown() end)
		if not a then return NULL end
	end


	function syn.isreadonly(main: table): boolean
		-- hi
		if env.isreadonly or isreadonly then return isreadonly(main) else return table.isfrozen(main) end
	end

	function syn.setreadonly(tb, option: boolean)
		if env.setreadonly or setreadonly then return env.setreadonly(tb, option) or setreadonly(tb, option) end
		return NULL
	end

	return syn
