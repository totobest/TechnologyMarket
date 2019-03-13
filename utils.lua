require("config")
require("stdlib/string")
require("stdlib/table")
require("stdlib/log/logger")

IS_DEBUG = false
 
LOGGER = Logger.new('TechnologyMarket', nil, IS_DEBUG, {
		log_ticks = false,
})

LOG = function(msg)
	if _G.game then
		LOGGER.log(msg)
	else
		print("TechnologyMarket: " .. msg)
	end
end
LOG("Hello!")

if _G.game then
	assert(LOGGER.write(), "Logger.write() did not work!")
end

local thousands_separator = ","

function format_money( n )
	if n == nil then return( "0u" ) end
	
	local neg, mega
	local unit
	
	if settings.startup.use_k_m_notation.value then
		if n >= 100000 then
			n = math.floor(n/100000)
			unit = "million"
		elseif n >= 1000 then
			n = math.floor(n/1000)
			unit = "thousand"
		end
	end
	
	if n < 0 then
		n = -n
		neg = true
	else
		neg = false
	end
	
	local s = tostring(math.floor(n+0.5))
	local s2 = ""
	local l = string.len(s)
	local i = l+1
	
	while i > 4 do
		i = i-3	
		s2 =  thousands_separator .. string.sub(s,i,i+2) .. s2
	end
	
	if i > 1 then
		s2 =  string.sub(s,1,i-1) .. s2
	end
	
	if not settings.startup.use_k_m_notation.value or unit == nil then
		s2 = s2 .. "u"
	elseif unit == "million" then
			s2 = s2 .. "Mu"
	elseif unit == "thousand" then
			s2 = s2 .. "Ku"
	end
	
	if neg then
		return( "-" .. s2 )
	else
		return( s2 )
	end
end

science_pack_cost_table = {}

local function add_science_pack(science_pack_name, science_pack_cost)
	assert (not string.is_empty(science_pack_name))
	LOGGER.log("Loaded science pack " .. science_pack_name .. " with cost " .. science_pack_cost)
	science_pack_cost_table[science_pack_name] = science_pack_cost
end

table.each(known_science_packs_set, function(v)
	if v.enabled then
		add_science_pack(v.name, v.cost)
	end
end)

for i = 1, num_extra_science_pack_settings do
	local key = "science-pack-" .. i
	local science_pack_name = settings.startup[key .."-name"].value
	if not string.is_empty(science_pack_name) then
		local science_pack_cost = settings.startup[key .."-cost"].value
		add_science_pack(science_pack_name, science_pack_cost)
	end
end  

function get_technology_cost(unit_count, ingredients)
	local c = 0
	if not unit_count then
		error("unit_count cannot be nil")
	end
	table.each(ingredients, function(ingredient)
		if science_pack_cost_table[ingredient] then
			c = c + science_pack_cost_table[ingredient]
		end
	end)
	return c * unit_count
end


