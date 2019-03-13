require("stdlib/event/event")
require("utils")

local switching_technology_penalty = 1 - settings.startup.switching_technology_penalty_in_percent.value / 100

function onResearchStarted(event)
	local tech = event.research
    local force = tech.force
	
	LOG("onResearchStarted event.research.name=" .. event.research.name)
	
	if event.last_research ~= nil and global.last_research_cost ~= nil then
		local research_progress = force.get_saved_technology_progress(event.last_research)
		if research_progress ~= nil then
			local credits_to_refund = math.floor(global.last_research_cost * (1 - research_progress) * switching_technology_penalty)
			local credits = remote.call("market", "get_credits", force.name)
			force.print({"", "Refunding " .. format_money(credits_to_refund) .. " from unfinished research ", event.last_research.localised_name})
			remote.call("market", "credits", credits + credits_to_refund)
		end
	end
	local tech_bck = game.technology_prototypes[event.research.name .. "_tm"]
	if tech_bck == nil then
		force.print("TechnologyMarket: Another mod has tweaked the technologies and I cannot get the cost of " .. event.research.name)
		force.print("TechnologyMarket: Please post on the forum this message along with the list of mods you have installed.")
		return
	end
	local ingredients = {}
	local n = 0
	table.each(tech_bck.research_unit_ingredients, function(ingredient)
		n = n + 1
		ingredients[n] = ingredient.name
	end)
	local research_unit_count
	if tech.research_unit_count ~= nil then
		research_unit_count = tech.research_unit_count
	else
	    -- TODO: ask devs for access to the internal math calc. https://www.factorio.com/blog/post/fff-161
		local formula = "return " .. string.gsub(tech.research_unit_count_formula, "L", tech.level)
		formula = string.gsub(formula, "(%d+)%(", "%1*(")
		formula = string.gsub(formula, "%)(%d+)", ")*%1")
		LOG("formula=" .. formula)
		local f = assert(load(formula))
		research_unit_count = f()
	end

	local credits_needed = get_technology_cost(research_unit_count, ingredients)
	local research_progress = force.research_progress
	if research_progress ~= nil and research_progress > 0 then
		credits_needed = math.floor(credits_needed * (1 - research_progress))
	end
	local credits = remote.call("market", "get_credits", force.name)
	if credits < credits_needed then
		force.print("No enought credits to start research. Missing " .. format_money(credits_needed - credits))
		force.current_research = nil
	else
		global.last_research_cost = credits_needed
		force.print({"", "Spending " .. format_money(credits_needed) .. " to start research ", event.research.localised_name})
		remote.call("market", "credits", credits - credits_needed)
	end
end

Event.register(defines.events.on_research_started, onResearchStarted)
