require("utils")
require("stdlib/table")

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
local function create_technology_ghost(technology)
  local technology_ghost = table.deepcopy(technology)
  technology_ghost.name = technology.name .. "_tm"
  technology_ghost.enabled = false
  technology_ghost.max_level = nil
  technology_ghost.upgrade = false
  data.raw.technology[technology_ghost.name] = technology_ghost
end

local function add_cost_info_to_techonology(technology)
  -- LOG("technology.name=" .. technology.name)

  local cost_text

  if technology.unit.count == nil then
    assert(technology.unit.count_formula ~= nil, "no technology.unit.count and no technology.unit.count_formula!")
    -- infinite technology
	cost_text = "variable"
  else
    local ingredients = {}
	local n = 0
	for _, v in pairs(technology.unit.ingredients) do
		n = n + 1
		ingredients[n] = v[1]
	end

	local cost = get_technology_cost(technology.unit.count or 1, ingredients)
	cost_text = format_money(cost)
  end

  local pattern = string.match(technology.name, "-(%d+)")
  local technology_name_for_localisation =  pattern and string.sub(technology.name, 1, -#pattern - 2) or technology.name

  if settings.startup.cost_in_description.value then
	cost_text = "Cost: " .. cost_text
	local localised_description = technology.localised_description or {"technology-description." .. technology_name_for_localisation}
	localised_description = {"", localised_description, "\n", cost_text}
	technology.localised_description = localised_description
  else
	cost_text = "(" .. cost_text .. ")"
	local localised_name = technology.localised_name or {"technology-name." .. technology_name_for_localisation}
	local localised_name_array = {"", localised_name}
	if pattern and technology.unit.count_formula == nil then
		table.insert(localised_name_array, " " .. pattern)
	end
	table.insert(localised_name_array, " " .. cost_text)
	technology.localised_name = localised_name_array
  end
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

table.each(data.raw.technology, function(technology, name)
	if not string.find(name, "_tm") then
		create_technology_ghost(technology)
		add_cost_info_to_techonology(technology)
		technology_remove_unlock_recipe_of_known_packs(technology, science_pack_cost_table)
		technology_remove_units_of_known_packs(technology, science_pack_cost_table)
	end
end)

table.each(science_pack_cost_table, function(_, pack_name)
	set_pack_settings(pack_name)
end)

table.each(data.raw.lab, function(lab)
	local inputs = lab.inputs
	lab.inputs = table.filter(inputs, function(item) return not science_pack_cost_table[item] end)
end)
