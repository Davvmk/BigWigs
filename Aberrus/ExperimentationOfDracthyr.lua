if not IsTestBuild() then return end
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Experimentation of Dracthyr", 2569, 2530)
if not mod then return end
mod:RegisterEnableMob(200912, 200913, 200918) -- Neldris, Thadrion, Rionthus
mod:SetEncounterID(2693)
mod:SetRespawnTime(30)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local thadrionEngaged = false
local rionthusEngaged = false

local rendingChargeCount = 1
local massiveSlamCount = 1
local bellowingRoarCount = 1

local unstableEssenceCount = 1
local essenceMarksUsed = {}
local volatileSpewCount = 1
local violentEruptionCount = 1

local deepBreathCount = 1
local temporalAnomalyCount = 1
local disintergrateCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
end

--------------------------------------------------------------------------------
-- Initialization
--

local unstableEssenceMarker = mod:AddMarkerOption(true, "player", 1, 407327, 1, 2, 3) -- Unstable Essence
function mod:GetOptions()
	return {
		-- General
		"stages",
		{406311, "TANK"}, -- Infused Strikes
		407302, -- Infused Explosion
		-- Neldris
		406358, -- Rending Charge
		404472, -- Massive Slam
		404713, -- Bellowing Roar
		-- Thadrion
		{407327, "SAY"}, -- Unstable Essence
		unstableEssenceMarker,
		405492, -- Volatile Spew
		405375, -- Violent Eruption
		-- Rionthus
		406227, -- Deep Breath
		407552, -- Temporal Anomaly
		{405392, "SAY"}, -- Disintegrate
	}, {
		[406358] = -26316, -- Neldris
		[407327] = -26322, -- Thadrion
		[406227] = -26329, -- Rionthus
	}
end

function mod:OnBossEnable()
	-- General
	self:Death("Deaths", 200912, 200913, 200918)

	self:Log("SPELL_AURA_APPLIED", "InfusedStrikesApplied", 406311)
	self:Log("SPELL_AURA_APPLIED_DOSE", "InfusedStrikesApplied", 406311)
	self:Log("SPELL_AURA_APPLIED", "InfusedExplosionApplied", 407302)
	self:Log("SPELL_AURA_APPLIED_DOSE", "InfusedExplosionApplied", 407302)

	-- Neldris
	self:Log("SPELL_CAST_START", "RendingCharge", 406358)
	self:Log("SPELL_CAST_START", "MassiveSlam", 404472)
	self:Log("SPELL_CAST_START", "BellowingRoar", 404713)

	-- Thadrion
	self:Log("SPELL_CAST_START", "UnstableEssence", 405042)
	self:Log("SPELL_AURA_APPLIED", "UnstableEssenceApplied", 407327)
	self:Log("SPELL_AURA_REMOVED", "UnstableEssenceRemoved", 407327)
	self:Log("SPELL_CAST_START", "VolatileSpew", 405492)
	self:Log("SPELL_CAST_START", "ViolentEruption", 405375)

	-- Rionthus
	self:Log("SPELL_CAST_START", "DeepBreath", 406227)
	self:Log("SPELL_CAST_START", "TemporalAnomaly", 407552)
	self:Log("SPELL_CAST_START", "Disintegrate", 405391)
	self:Log("SPELL_AURA_APPLIED", "DisintegrateApplied", 405392)
end

function mod:OnEngage()
	self:SetStage(1)
	thadrionEngaged = false
	rionthusEngaged = false
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")

	rendingChargeCount = 1
	massiveSlamCount = 1
	bellowingRoarCount = 1

	unstableEssenceCount = 1
	essenceMarksUsed = {}
	volatileSpewCount = 1
	violentEruptionCount = 1

	deepBreathCount = 1
	temporalAnomalyCount = 1
	disintergrateCount = 1

	self:Bar(404713, 5, CL.count:format(self:SpellName(404713), bellowingRoarCount)) -- Forceful Roar
	self:Bar(406358, 14.5, CL.count:format(self:SpellName(406358), rendingChargeCount)) -- Rending Charge
	self:Bar(404472, 30, CL.count:format(self:SpellName(404472), massiveSlamCount)) -- Massive Slam
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	-- XXX better event? initial timers have quite a bit of variance
	if not thadrionEngaged then
		if self:GetBossId(200913) then -- Thadrion
			thadrionEngaged = true
			self:Message("stages", "cyan", -26322, false)
			self:PlaySound("stages", "long")

			self:CDBar(405492, 5, CL.count:format(self:SpellName(405492), volatileSpewCount)) -- Volatile Spew
			self:CDBar(407327, 18, CL.count:format(self:SpellName(407327), unstableEssenceCount)) -- Unstable Essence
			self:CDBar(405375, 46, CL.count:format(self:SpellName(405375), violentEruptionCount)) -- Violent Eruption
		end
	elseif not rionthusEngaged then
		if self:GetBossId(200918) then -- Rionthus
			rionthusEngaged = true
			self:Message("stages", "cyan", -26329, false)
			self:PlaySound("stages", "long")

			self:CDBar(405392, 7.8, CL.count:format(self:SpellName(405392), disintergrateCount)) -- Disintegrate
			self:CDBar(407552, 18.0, CL.count:format(self:SpellName(407552), temporalAnomalyCount)) -- Temporal Anomaly
			self:CDBar(406227, 33.8, CL.count:format(self:SpellName(406227), deepBreathCount)) -- Deep Breath
		end
	end
end

function mod:Deaths(args)
	if args.mobId == 200912 then -- Neldris
		self:StopBar(CL.count:format(self:SpellName(406358), rendingChargeCount)) -- Rending Charge
		self:StopBar(CL.count:format(self:SpellName(404472), massiveSlamCount)) -- Massive Slam
		self:StopBar(CL.count:format(self:SpellName(404713), bellowingRoarCount)) -- Forceful Roar
	elseif args.mobId == 200913 then -- Thadrion
		self:StopBar(CL.count:format(self:SpellName(407327), unstableEssenceCount)) -- Unstable Essence
		self:StopBar(CL.count:format(self:SpellName(405492), volatileSpewCount)) -- Volatile Spew
		self:StopBar(CL.count:format(self:SpellName(405375), violentEruptionCount)) -- Violent Eruption
	elseif args.mobId == 200918 then -- Rionthus
		self:StopBar(CL.count:format(self:SpellName(406227), deepBreathCount)) -- Deep Breath
		self:StopBar(CL.count:format(self:SpellName(407552), temporalAnomalyCount)) -- Temporal Anomaly
		self:StopBar(CL.count:format(self:SpellName(405392), disintergrateCount)) -- Disintegrate
	end
end

-- General
function mod:InfusedStrikesApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		if amount % 3 or amount > 15 then
			self:StackMessage(args.spellId, "purple", args.destName, args.amount, 1)
			if amount > 15 then -- Reset Maybe?
				self:PlaySound(args.spellId, "warning")
			else
				self:PlaySound(args.spellId, "info")
			end
		end
	end
end

function mod:InfusedExplosionApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 1)
		if amount > 1 then -- Tank Oops
			self:PlaySound(args.spellId, "warning")
		else
			self:PlaySound(args.spellId, "info")
		end
	end
end

-- Neldris
function mod:RendingCharge(args)
	self:StopBar(CL.count:format(args.spellName, rendingChargeCount))
	self:Message(406358, "red", CL.count:format(args.spellName, rendingChargeCount))
	self:PlaySound(406358, "warning")
	rendingChargeCount = rendingChargeCount + 1
	self:Bar(args.spellId, 34, CL.count:format(args.spellName, rendingChargeCount))
end

function mod:MassiveSlam(args)
	self:StopBar(CL.count:format(args.spellName, massiveSlamCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, massiveSlamCount))
	self:PlaySound(args.spellId, "alert")
	massiveSlamCount = massiveSlamCount + 1
	-- self:Bar(args.spellId, 30, CL.count:format(args.spellName, massiveSlamCount))
end

function mod:BellowingRoar(args)
	self:StopBar(CL.count:format(args.spellName, bellowingRoarCount))
	self:Message(args.spellId, "orange", CL.count:format(args.spellName, bellowingRoarCount))
	self:PlaySound(args.spellId, "alarm")
	bellowingRoarCount = bellowingRoarCount + 1
	self:Bar(args.spellId, 36, CL.count:format(args.spellName, bellowingRoarCount))
end

-- Thadrion
function mod:UnstableEssence(args)
	self:StopBar(CL.count:format(args.spellName, unstableEssenceCount))
	self:Message(407327, "cyan", CL.casting:format(args.spellName))
	unstableEssenceCount = unstableEssenceCount + 1
	self:CDBar(407327, 53, CL.count:format(args.spellName, unstableEssenceCount))
end

function mod:UnstableEssenceApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
		self:Say(args.spellId)
	end
	for i = 1, 3, 1 do -- 1, 2, 3
		if not essenceMarksUsed[i] then
			essenceMarksUsed[i] = args.destGUID
			self:CustomIcon(unstableEssenceMarker, args.destName, i)
			return
		end
	end
end

function mod:UnstableEssenceRemoved(args)
	self:CustomIcon(unstableEssenceMarker, args.destName)
	for i = 1, 3, 1 do -- 1, 2, 3
		if essenceMarksUsed[i] == args.destGUID then
			essenceMarksUsed[i] = nil
			return
		end
	end
end

function mod:VolatileSpew(args)
	self:StopBar(CL.count:format(args.spellName, volatileSpewCount))
	self:Message(args.spellId, "orange", CL.count:format(args.spellName, volatileSpewCount))
	self:PlaySound(args.spellId, "alarm")
	volatileSpewCount = volatileSpewCount + 1
	self:CDBar(args.spellId, volatileSpewCount % 2 == 26 or 30, CL.count:format(args.spellName, volatileSpewCount))
end

function mod:ViolentEruption(args)
	self:StopBar(CL.count:format(args.spellName, violentEruptionCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, violentEruptionCount))
	self:PlaySound(args.spellId, "long")
	violentEruptionCount = violentEruptionCount + 1
	-- self:Bar(args.spellId, 60, CL.count:format(args.spellName, violentEruptionCount)) -- XXX longer than 52s >.>
end

-- Rionthus
function mod:DeepBreath(args)
	self:StopBar(CL.count:format(args.spellName, deepBreathCount))
	self:Message(args.spellId, "red", CL.count:format(args.spellName, deepBreathCount))
	self:PlaySound(args.spellId, "alert")
	deepBreathCount = deepBreathCount + 1
	self:Bar(args.spellId, 43.8, CL.count:format(args.spellName, deepBreathCount))
end

function mod:TemporalAnomaly(args)
	self:StopBar(CL.count:format(args.spellName, temporalAnomalyCount))
	self:Message(args.spellId, "yellow", CL.count:format(args.spellName, temporalAnomalyCount))
	self:PlaySound(args.spellId, "info")
	temporalAnomalyCount = temporalAnomalyCount + 1
	self:Bar(args.spellId, 43.8, CL.count:format(args.spellName, temporalAnomalyCount))
end

function mod:Disintegrate(args)
	self:StopBar(CL.count:format(args.spellName, disintergrateCount))
	self:Message(405392, "orange", CL.count:format(args.spellName, disintergrateCount))
	disintergrateCount = disintergrateCount + 1
	self:Bar(405392, 43.8, CL.count:format(args.spellName, disintergrateCount))
end

function mod:DisintegrateApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "warning")
		self:Say(args.spellId)
	end
end
