-- If you are using Roblox Studio to test this, please be reminded to:

-- Create a LocalScript inside of StarterPlayers.StarterCharacterScripts
-- Create a ModuleScript inside of StarterPlayers.StarterCharacterScripts

-- Inside of the ModuleScript, put main.luau's content [raw code] inside of the ModuleScript.
-- After doing that, follow my steps in the LocalScript:

local syn = require(script.Parent.ModuleScriptsName) -- Your modulescript's name, or just make it ModuleScript on default.

-- To test if it works, you do
local tb = {}
table.freeze(tb)
print(syn.isreadonly(tb)) --> true
