require("utils")
local table = require('__stdlib__/stdlib/utils/table')

local function filter_out_known_packs(effects_parent, pack_table, technology_name)
	effects_parent.effects = table.filter(effects_parent.effects, function(effect)
		if effect.type == "unlock-recipe" then
			local name = effect.recipe
			if pack_table[name] ~= nil then
				LOG("Removed science pack '" .. name .. "', unlocked by '" .. technology_name .. "' from research tree.")
				return false
			elseif name:find("science-pack",1,true) ~= nil then
				LOG("Found unknown science pack '" .. name .. "', unlocked by '" .. technology_name .. "'")
			end
		end
		return true
	end)
end

local function technology_remove_unlock_recipe_of_known_packs(technology, pack_table)
	assert(technology ~= nil)

	local hasdif = false
	if technology.expensive then
		hasdif = true
		if technology.expensive.effects and table_size(technology.expensive.effects) then
			filter_out_known_packs(technology.expensive, pack_table, technology.name)
		end
	end
	if technology.normal then
		hasdif = true
		if technology.normal.effects and table_size(technology.normal.effects) then
			filter_out_known_packs(technology.normal, pack_table, technology.name)
		end
	end
	if not hasdif and technology.effects and table_size(technology.effects) then
		filter_out_known_packs(technology, pack_table, technology.name)
	end

end

local function technology_remove_units_of_known_packs(technology, pack_table)
	technology.unit.ingredients = table.filter(technology.unit.ingredients, function(item)
		local pack_name = item[1]
		return pack_table[pack_name] == nil
	end)
end


local function set_pack_settings(pack_name)
	local pack_recipe = data.raw.recipe[pack_name]
	if pack_recipe then
		LOG("Disabling recipe " .. pack_name)
		pack_recipe.enabled = false
	end
	local pack_item = data.raw.tool[pack_name]
	if pack_item then
		LOG("Hidding tool " .. pack_name)
		if pack_item.flags == nil then
			pack_item.flags = {}
		end
		table.insert(pack_item.flags, "hidden")
	end

end

local function get_technology_cost(ingredients)
	local c = 0
	table.each(ingredients, function(ingredient)
		if science_pack_cost_table[ingredient] then
			c = c + science_pack_cost_table[ingredient]
		end
	end)
	return c / 20
end


table.each(data.raw.technology, function(technology, name)
	local cost = nil
	if technology.unit.count == nil then
		cost = 1
	else
		cost = get_technology_cost(
			table.map(technology.unit.ingredients, function(v) return v[1] end))
		cost = math.floor(cost / technology.unit.count)
	end

	technology_remove_unlock_recipe_of_known_packs(technology, science_pack_cost_table)
	technology_remove_units_of_known_packs(technology, science_pack_cost_table)

	-- LOG("technology.name=" .. technology.name .. " technology.unit.count=" .. (technology.unit.count == nil and "nil" or technology.unit.count) .. " cost=" .. cost)
	if cost == 0 then
		LOG("calculated cost for technology is 0 " .. name)
		cost = 1
	end
	table.insert(technology.unit.ingredients,
		{"ucoin", cost}
	)
end)

table.each(science_pack_cost_table, function(_, pack_name)
	set_pack_settings(pack_name)
end)

data:extend({
	table.merge(
		table.deep_copy(data.raw.item.ucoin),
		{
			type = "tool",
			durability = 1
		}
	)
})

data.raw.item.ucoin = nil

table.each(data.raw.lab, function(lab)
	local inputs = lab.inputs
	inputs = table.filter(inputs, function(item) return not science_pack_cost_table[item] end)
	table.insert(inputs, "ucoin")
	lab.inputs = inputs
end)
