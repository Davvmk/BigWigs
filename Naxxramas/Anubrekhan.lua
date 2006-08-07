------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.0")("Anub'Rekhan")
local L = AceLibrary("AceLocale-2.0"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "anubrekhan",

	locust_cmd = "locust",
	locust_name = "Locust Swarm Alert",
	locust_desc = "Warn for Locust Swarm",

	starttrigger1 = "Just a little taste...",
	starttrigger2 = "Yes, run! It makes the blood pump faster!",
	starttrigger3 = "There is no way out.",
	engagewarn = "Anub'Rekhan engaged. First Locust Swarm in about 90 seconds.",
	
	gaintrigger = "Anub'Rekhan gains Locust Swarm.",
	gainendwarn = "Locust Swarm ended!",
	gainnextwarn = "Next Locust Swarm in about 90 seconds.",
	gainwarn10sec = "10 Seconds until Locust Swarm",
	gainincbar = "Next Locust Swarm",
	gainbar = "Locust Swarm",
	
	casttrigger = "Anub'Rekhan begins to cast Locust Swarm.",
	castwarn = "Incoming Locust Swarm!",

} end )

L:RegisterTranslations("deDE", function() return {
	starttrigger1 = "Nur einmal kosten...",
	starttrigger2 = "Rennt! Das bringt das Blut in Wallung!",
	starttrigger3 = "Es gibt kein Entkommen.",
	engagewarn = "Heuschreckenschwarm in ca. 90 s.",
	
	gaintrigger = "Anub'Rekhan bekommt Heuschreckenschwarm.",
	gainendwarn = "Heuschreckenschwarm beendet!",
	gainnextwarn = "N\195\164chster Schwarm in ca. 90 s.",
	gainwarn10sec = "10 s BIS SCHWARM",
	gainincbar = "Schwarm",
	gainbar = "Heuschreckenschwarm",
	
	casttrigger = "Anub'Rekhan beginnt Heuschreckenschwarm zu wirken.",
	castwarn = "SCHWARM incoming!",
} end )

L:RegisterTranslations("koKR", function() return {
	starttrigger1 = "어디 맛 좀 볼까...",
	starttrigger2 = "그래, 도망쳐! 더 신선한 피가 솟구칠 테니!",
	starttrigger3 = "나가는 길은 없다.",
	engagewarn = "아눕레칸 격노. 대략 90초후 첫번째 메뚜기 떼.",
			
	gaintrigger = "아눕레칸|1이;가; 메뚜기 떼 효과를 얻었습니다.",
	gainendwarn = "메뚜기 떼 종료!",
	gainnextwarn = "다음 메뚜기 떼 대략 95초후.",
	gainwarn10sec = "10초후 메뚜기 떼",
	gainincbar = "다음 메뚜기 떼",
	gainbar = "메뚜기 떼",				
	 
	casttrigger = "아눕레칸|1이;가; 메뚜기 떼|1을;를; 시전합니다.",
	castwarn = "메뚜기 떼 소환!",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsAnubrekhan = BigWigs:NewModule(boss)
BigWigsAnubrekhan.zonename = AceLibrary("Babble-Zone-2.0")("Naxxramas")
BigWigsAnubrekhan.enabletrigger = boss
BigWigsAnubrekhan.toggleoptions = {"locust", "bosskill"}
BigWigsAnubrekhan.revision = tonumber(string.sub("$Revision$", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsAnubrekhan:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "LocustCast")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "LocustCast")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "AnubLocustInc", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "AnubLocustSwarm", 10)

end

function BigWigsAnubrekhan:CHAT_MSG_MONSTER_YELL( msg )
	if self.db.profile.locust and msg == L"starttrigger1" or msg == L"starttrigger2" or msg == L"starttrigger3" then
		self:TriggerEvent("BigWigs_Message", L"engagewarn", "Orange")
		self:ScheduleEvent("BigWigs_Message", 80, L"gainwarn10sec", "Red")
		self:TriggerEvent("BigWigs_StartBar", self, L"gainincbar", 90, 1, "Interface\\Icons\\Spell_Nature_InsectSwarm", "Green", "Yellow", "Orange", "Red")
	end
end

function BigWigsAnubrekhan:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS( msg )
	if msg == L"gaintrigger" then
		self:TriggerEvent("BigWigs_SendSync", "AnubLocustSwarm")
	end
end

function BigWigsAnubrekhan:LocustCast( msg )
	if msg == L"casttrigger" then
		self:TriggerEvent("BigWigs_SendSync", "AnubLocustInc")
	end
end

function BigWigsAnubrekhan:BigWigs_RecvSync( sync )
	if sync == "AnubLocustInc" then
		self:ScheduleEvent("bwanublocustinc", 3.25, self.BigWigs_RecvSync, self, "AnubLocustSwarm")
		self:TriggerEvent("BigWigs_Message", L"castwarn", "Orange")
	elseif sync == "AnubLocustSwarm" then
		self:CancelScheduledEvent("bwanublocustinc")
		self:ScheduleEvent("BigWigs_Message", 20, L"gainendwarn", "Red")
		self:TriggerEvent("BigWigs_StartBar", self, L"gainbar", 20, 2, "Interface\\Icons\\Spell_Nature_InsectSwarm", "Yellow", "Orange", "Red")
		self:TriggerEvent("BigWigs_Message", L"gainnextwarn", "Orange")
		self:ScheduleEvent("BigWigs_Message", 80, L"gainwarn10sec", "Red")
		self:TriggerEvent("BigWigs_StartBar", self, L"gainincbar", 90, 1, "Interface\\Icons\\Spell_Nature_InsectSwarm", "Green", "Yellow", "Orange", "Red")
	end
end
