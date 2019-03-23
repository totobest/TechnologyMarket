require("config")
local table = require('__stdlib__/stdlib/utils/table')
-- ANOTHER MOD - lite mode --> Keep the pack science recipe

data:extend({
	  {
		name = "use_k_m_notation",
		type = "bool-setting",
		localised_name = "Use Ku and Mu notation for cost resp. over 1000u and 100000u",
		setting_type = "startup",
		default_value = false,
		order = "ccc"
	  }

})

local science_pack_index = 1
local function create_default_science_pack_setting(localised_name, name, cost, enabled)
	local science_pack_index_str = "zaa" .. string.format("%02d", science_pack_index)
	local result = {
	  {
		name = "science-pack-" .. name .. "-enabled",
		type = "bool-setting",
		localised_name = "Replace " .. localised_name,
		setting_type = "startup",
		default_value = enabled == nil and true or enabled,
		order = science_pack_index_str .. "a"
	  },
	  {
		name = "science-pack-" .. name .. "-cost",
		type = "int-setting",
		localised_name = localised_name .. " cost",
		setting_type = "startup",
		default_value = cost,
		minimum_value = 0,
		order = science_pack_index_str .. "b"
	  },
	}
	science_pack_index = science_pack_index + 1
	return result
end


local extra_science_pack_index = 1
local function create_extra_science_pack_setting()
	local science_pack_index_str = "zbb" .. string.format("%02d", extra_science_pack_index)
	local result = {
	  {
		name = "science-pack-" .. extra_science_pack_index .. "-name",
		type = "string-setting",
		localised_name = "Custom science pack #" .. extra_science_pack_index .. " name",
		setting_type = "startup",
		default_value = "",
		allow_blank = true,
--		allowed_values = all_items,
		order = science_pack_index_str .. "a"
	  },
	  {
		name = "science-pack-" .. extra_science_pack_index .. "-cost",
		type = "int-setting",
		localised_name = "Custom science pack #" .. extra_science_pack_index .. " cost",
		setting_type = "startup",
		default_value = 0,
		minimum_value = 0,
		order = science_pack_index_str .. "b"
	  },

	}
	extra_science_pack_index = extra_science_pack_index + 1
	return result
end

local science_pack_settings = {}

table.each(known_science_packs_set, function(v)
	table.insert(science_pack_settings, create_default_science_pack_setting(v.localised_name, v.name, v.cost, v.enabled))
end)

for i = 1, num_extra_science_pack_settings do
	table.insert(science_pack_settings, create_extra_science_pack_setting())
end

data:extend(table.flatten(science_pack_settings))
