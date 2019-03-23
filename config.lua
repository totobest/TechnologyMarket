local table = require('__stdlib__/stdlib/utils/table')

-- some default values for popular science packs.
-- costs are taken from the in-game market before activating the mod.

known_science_packs = {
	{
		localised_name = "Automation science pack",
		name = "automation-science-pack",
     	cost = 470,
		enabled = true
	},
	{
		localised_name = "Logistic science pack",
		name = "logistic-science-pack",
     	cost = 1128,
		enabled = true
	},
	{
		localised_name = "Chemical science pack",
		name = "chemical-science-pack",
     	cost = 12140,
		enabled = true
	},
	{
		localised_name = "Production science pack",
		name = "production-science-pack",
     	cost = 26010,
		enabled = true
	},
	{
		localised_name = "Military science pack",
		name = "military-science-pack",
     	cost = 5186,
		enabled = true
	},
	{
		localised_name = "Utility science pack",
		name = "utility-science-pack",
     	cost = 54585,
		enabled = true
	},
	{
		localised_name = "Space science pack",
		name = "space-science-pack",
     	cost = 54585 * 2, --space science is not present in any recipe so cost is hardly estimate-able. Use double high-tech-science-pack cost for now.
		enabled = false
	},
	-- bobs
	{
		localised_name = "Bob's: Logistic science pack",
		name = "logistic-science-pack",
     	cost = 31983,
		enabled = true
	},
	-- omni
	{
		localised_name = "Omniscience: Omni pack",
		name = "omni-pack",
     	cost = 16406,
		enabled = true
	},
	-- FI
	{
		localised_name = "Food Industry: Food science pack",
		name = "food-science-pack",
     	cost = 613,
		enabled = true
	}
	-- ["science-pack-gold"] = 256, -- bobs
	-- ["alien-science-pack"] = 500, -- bobs
	--	{ partial = true, name = "alien-science-pack-" },	-- bobs - leaving them under alien research
	-- ["sct-science-pack-bio"] = 128, -- angels
}

known_science_packs_set = {}
table.each(known_science_packs, function(v, k) known_science_packs_set[k] = v end)

-- add some empty extra settings for user defined science packs
num_extra_science_pack_settings = 4
