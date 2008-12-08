﻿------------------------------
--      Are you local?      --
------------------------------

local boss = BB["Sartharion"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local db = nil
local started = nil
local enrage_warned = nil
local drakes = nil
local fmt = string.format

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Sartharion",

	tsunami = "Flame Tsunami",
	tsunami_desc = "Warn for churning lava and show a bar.",
	tsunami_warning = "Flame Tsunami in ~5sec!",
	tsunami_message = "Flame Tsunami!",
	tsunami_cooldown = "Flame Tsunami Cooldown",
	tsunami_trigger = "The lava surrounding %s churns!",

	breath = "Flame Breath",
	breath_desc = "Warn for Flame Breath casting.",
	breath_warning = "Flame Breath in ~5sec!",
	breath_message = "Flame Breath!",
	breath_cooldown = "Flame Breath Cooldown",

	drakes = "Drake Adds",
	drakes_desc = "Warn when each drake add will join the fight.",
	drakes_incomingbar = "%s incoming",
	drakes_incomingsoon = "%s incoming in ~5sec!",
	drakes_incoming = "%s incoming!",
	drakes_activebar = "%s active",
	drakes_active = "%s is active!",

	vesperon = "Vesperon",
	vesperon_trigger = "Vesperon, the clutch is in danger! Assist me!",

	shadron = "Shadron",
	shadron_trigger = "Shadron! Come to me! All is at risk!",

	tenebron = "Tenebron",
	tenebron_trigger = "Tenebron! The eggs are yours to protect as well!",

	drakedeath = "Drake Death",
	drakedeath_desc = "Warn when one of the drake adds die.",
	drakedeath_message = "%s died!",

	enrage = "Enrage",
	enrage_warning = "Enrage soon!",
	enrage_message = "Enraged!",

	log = "|cffff0000"..boss.."|r:\n This boss needs data, please consider turning on your /combatlog or transcriptor and submit the logs.",
} end )

L:RegisterTranslations("koKR", function() return {
	tsunami = "용암 파도",
	tsunami_desc = "용암파도에 바와 알림입니다.",
	tsunami_warning = "약 5초 후 용암 파도!",
	tsunami_message = "용암 파도!",
	tsunami_cooldown = "용암 파도 대기시간",
	tsunami_trigger = "%s을 둘러싼 용암이 끓어오릅니다!",

	breath = "화염 숨결",
	breath_desc = "화염 숨결 시전을 알립니다.",
	breath_warning = "약 5초 후 화염 숨결!",
	breath_message = "화염 숨결!",
	breath_cooldown = "화염 숨결 대기시간",

	drakes = "비룡 추가",
	drakes_desc = "각 비룡이 전투에 추가되는 것을 알립니다.",
	drakes_incomingbar = "잠시 후 %s 출현",
	drakes_incomingsoon = "약 5초 후 %s 출현!",
	drakes_incoming = "%s 출현!",
	drakes_activebar = "%s 활동",
	drakes_active = "%s 활동!",

	vesperon = "베스페론",
	vesperon_trigger = "베스페론, 알이 위험하다! 날 도와라!",

	shadron = "샤드론",
	shadron_trigger = "샤드론! 이리 와라! 위험한 상황이다!",

	tenebron = "테네브론",
	tenebron_trigger = "테네브론! 너도 알을 지킬 책임이 있어!",

	drakedeath = "비룡 죽음",
	drakedeath_desc = "비룡의 죽음에 대해 알립니다.",
	drakedeath_message = "%s 죽음!",

	enrage = "격노",
	enrage_warning = "잠시 후 격노!",
	enrage_message = "격노!",

	log = "|cffff0000"..boss.."|r:\n 해당 보스에 대한 대화 멘트, 전투로그등을 필요로 합니다. 섬게이트,인벤의 BigWigs Bossmods 안건에 /대화기록, /전투기록을 한 로그나 기타 스샷, 잘못된 타이머등 오류를 제보 부탁드립니다. 윈드러너 서버:백서향으로 바로 문의 주시면 조금 빠른 수정 업데이트가 됩니다 @_@;",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

local mod = BigWigs:NewModule(boss)
mod.zonename = BZ["The Obsidian Sanctum"]
mod.otherMenu = "Northrend"
mod.enabletrigger = boss
mod.guid = 28860
mod.toggleoptions = {"tsunami", "breath", -1, "drakes", -1, "enrage", "bosskill"}
mod.revision = tonumber(("$Revision$"):sub(12, -3))

------------------------------
--      Initialization      --
------------------------------

function mod:OnEnable()
	self:AddCombatListener("SPELL_AURA_APPLIED", "DrakeCheck", 58105, 61248, 61251)
	self:AddCombatListener("SPELL_AURA_APPLIED", "Enraged", 61632)
	self:AddCombatListener("SPELL_CAST_START", "Breath", 58956)
	self:AddCombatListener("UNIT_DIED", "Deaths")
--	self:AddCombatListener("UNIT_DIED", "BossDeath")

	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("UNIT_HEALTH")
	
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("BigWigs_RecvSync")

--	BigWigs:Print(L["log"])
	started = nil
	db = self.db.profile
	enrage_warned = false
	drakes = {
		[30449] = {["name"] = L["vesperon"], ["alive"] = true,},
		[30451] = {["name"] = L["shadron"], ["alive"] = true,},
		[30452] = {["name"] = L["tenebron"], ["alive"] = true,},
	}
end

------------------------------
--      Event Handlers      --
------------------------------

function mod:DrakeCheck(_, spellID)
--	58105 = Shadron
--	61248 = Tenebron
--	61251 = Vesperon

--	Tenebron called in roughly 15s after engage
--	Shadron called in roughly 60s after engage
--	Vesperon called in roughly 105s after engage
	if not db.drakes then return end
	if spellID == 58105 then
		self:CancelScheduledEvent("ShadronWarn")
		self:TriggerEvent("BigWigs_StopBar", self, fmt(L["drakes_incomingbar"], L["shadron"]))
		self:Bar(fmt(L["drakes_incomingbar"], L["shadron"]), 15, 58105)
		self:ScheduleEvent("ShadronWarn", "BigWigs_Message", 10, fmt(L["drakes_incomingsoon"], L["shadron"]), "Attention")
	elseif spellID == 61248 then
		self:CancelScheduledEvent("TenebronWarn")
		self:TriggerEvent("BigWigs_StopBar", self, fmt(L["drakes_incomingbar"], L["tenebron"]))
		self:Bar(fmt(L["drakes_incomingbar"], L["tenebron"]), 60, 61248)
		self:ScheduleEvent("TenebronWarn", "BigWigs_Message", 55, fmt(L["drakes_incomingsoon"], L["tenebron"]), "Attention")
	elseif spellID == 61251 then
		self:CancelScheduledEvent("VesperonWarn")
		self:TriggerEvent("BigWigs_StopBar", self, fmt(L["drakes_incomingbar"], L["vesperon"]))
		self:Bar(fmt(L["drakes_incomingbar"], L["vesperon"]), 105, 61251)
		self:ScheduleEvent("VesperonWarn", "BigWigs_Message", 100, fmt(L["drakes_incomingsoon"], L["vesperon"]), "Attention")
	end
end

function mod:Enraged(_, spellID)
	if db.enrage then
		self:IfMessage(L["enrage_message"], "Attention", spellID, "Alarm")
	end
end

function mod:Breath(_, spellID)
	if db.breath then
		self:CancelScheduledEvent("BreathWarn")
		self:TriggerEvent("BigWigs_StopBar", self, L["breath_cooldown"])
		self:Bar(L["breath_cooldown"], 12, 57491)
--		A warning message seems more annoying than helpful
--		self:ScheduleEvent("BreathWarn", "BigWigs_Message", 7, L["breath_warning"], "Attention")
	end
end

function mod:Deaths(_, guid)
--	This is pretty ugly, and probably not needed.  The alternative is to check for yells, or SPELL_CAST_SUCCESS for Twilight Revenge (60639)
	guid = tonumber((guid):sub(-12,-7),16)
	if guid == self.guid then
		self:BossDeath(nil, self.guid, true)
	elseif guid == 30449 or guid == 30451 or guid == 30452 then
		if not started then
			-- The drake died before engaging Sartharion, so it will not add during the fight.
			drakes[guid]["alive"] = false
		else
			-- The drake died while fighting Sartharion, so warn about the death, but don't mark as dead incase of a wipe.
			self:Message(fmt(L["drakedeath_message"], drakes[guid]["name"]), "Attention")
		end
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L["tsunami_trigger"] and db.tsunami then
		self:CancelScheduledEvent("TsunamiWarn")
		self:TriggerEvent("BigWigs_StopBar", self, L["tsunami_cooldown"])
		self:Message(L["tsunami_message"], "Important", 57491, "Alert")
		self:Bar(L["tsunami_cooldown"], 30, 57491)
		self:ScheduleEvent("TsunamiWarn", "BigWigs_Message", 25, L["tsunami_warning"], "Attention")
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
--	Roughly 12s after the yell, the drakes actually become active
	if not db.drakes then return end
	if msg:find(L["vesperon_trigger"]) then
		self:Message(fmt(L["drakes_incoming"], L["vesperon"]), "Attention")
		self:CancelScheduledEvent("VesperonWarn")
		self:TriggerEvent("BigWigs_StopBar", self, fmt(L["drakes_activebar"], L["vesperon"]))
		self:Bar(fmt(L["drakes_activebar"], L["vesperon"]), 12, 61251)
		self:ScheduleEvent("VesperonWarn", "BigWigs_Message", 12, fmt(L["drakes_active"], L["vesperon"]), "Attention")
	elseif msg:find(L["shadron_trigger"]) then
		self:Message(fmt(L["drakes_incoming"], L["shadron"]), "Attention")
		self:CancelScheduledEvent("ShadronWarn")
		self:TriggerEvent("BigWigs_StopBar", self, fmt(L["drakes_activebar"], L["shadron"]))
		self:Bar(fmt(L["drakes_activebar"], L["shadron"]), 12, 58105)
		self:ScheduleEvent("ShadronWarn", "BigWigs_Message", 12, fmt(L["drakes_active"], L["shadron"]), "Attention")
	elseif msg:find(L["tenebron_trigger"]) then
		self:Message(fmt(L["drakes_incoming"], L["tenebron"]), "Attention")
		self:CancelScheduledEvent("TenebronWarn")
		self:TriggerEvent("BigWigs_StopBar", self, fmt(L["drakes_activebar"], L["tenebron"]))
		self:Bar(fmt(L["drakes_activebar"], L["tenebron"]), 12, 61248)
		self:ScheduleEvent("TenebronWarn", "BigWigs_Message", 12, fmt(L["drakes_active"], L["tenebron"]), "Attention")
	end
end

function mod:UNIT_HEALTH(msg)
	if not db.enrage then return end
	if UnitName(msg) == boss then
		local hp = UnitHealth(msg)
		if hp > 11 and hp <= 14 and not enrage_warned then
			self:Message(L["enrage_warning"], "Attention")
			enrage_warned = true
		end
	end
end	

function mod:BigWigs_RecvSync(sync, rest, nick)
	if self:ValidateEngageSync(sync, rest) and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if db.tsunami then
			self:CancelScheduledEvent("TsunamiWarn")
			self:TriggerEvent("BigWigs_StopBar", self, L["tsunami_cooldown"])
			self:Bar(L["tsunami_cooldown"], 30, 57491)
			self:ScheduleEvent("TsunamiWarn", "BigWigs_Message", 25, L["tsunami_warning"], "Attention")
		end
--[[
		if db.breath then
			self:CancelScheduledEvent("BreathWarn")
			self:TriggerEvent("BigWigs_StopBar", self, L["breath_cooldown"])
			self:Bar(L["breath_cooldown"], 12, 57491)
			self:ScheduleEvent("BreathWarn", "BigWigs_Message", 7, L["breath_warning"], "Attention")
		end
]]
	end
end
