if myHero.charName ~= "Ahri"  or not VIP_USER then return end
local version = 0.2
local AUTOUPDATE = true
local SCRIPT_NAME = "Ahri - The Charmer"
require 'VPrediction'
require 'SOW'

-- These variables need to be near the top of your script so you can call them in your callbacks.
HWID = Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER")..os.getenv("USERNAME")..os.getenv("COMPUTERNAME")..os.getenv("PROCESSOR_LEVEL")..os.getenv("PROCESSOR_REVISION")))
-- DO NOT CHANGE. This is set to your proper ID.
id = 244

-- CHANGE ME. Make this the exact same name as the script you added into the site!
ScriptName = "Ahri"

-- Thank you to Roach and Bilbao for the support!
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()
-- Constants --
local ignite, igniteReady = nil, nil
local ts = nil
local VP = nil
local qOff, wOff, eOff, rOff = 0,0,0,0
local abilitySequence = {1,3,2,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3}
local Ranges = { AA = 550 }
local skills = {
	SkillQ = { ready = true, name = "Orb of Deception", range = 880, delay = 0.25, speed = 1100.0, width = 100.0 },
	SkillW = { ready = true, name = "Fox-Fire", range = 675, delay = nil, speed = nil, width = nil },
	SkillE = { ready = true, name = "Charm", range = 800, delay = 0.25, speed = 1200.0, width = 60.0 },
	SkillR = { ready = true, name = "Mantra", range = 450, delay = nil, speed = nil, width = nil },
}
--[[ Slots Items standaard]]--
local tiamatSlot, hydraSlot, youmuuSlot, bilgeSlot, bladeSlot, dfgSlot, divineSlot = nil, nil, nil, nil, nil, nil, nil
local tiamatReady, hydraReady, youmuuReady, bilgeReady, bladeReady, dfgReady, divineReady = nil, nil, nil, nil, nil, nil, nil

--[[Basic attacks]]--
local lastBasicAttack = 0
local swingDelay = 0.25
local swing = false


--[[Misc]]--
local lastSkin = 0
local isSAC = false
local isMMA = false
local target = nil
--Credit Trees
function GetCustomTarget()
	ts:update()
	if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
	if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
  if _G.MMA_Loaded then
                return _G.MMA_ConsideredTarget(MaxRange())
                
  end
            ts.range = MaxRange()    
	return ts.target
  
end
function OnLoad()
	if _G.ScriptLoaded then	return end
	_G.ScriptLoaded = true
	initComponents()
  UpdateWeb(true, ScriptName, id, HWID)
end
function initComponents()
    -- VPrediction Start
 VP = VPrediction()
   -- SOW Declare
   Orbwalker = SOW(VP)
  -- Target Selector
   ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 900)
  
 Menu = scriptConfig("Ahri - The Charmer by SyraX", "AhriMA")

   if _G.MMA_Loaded ~= nil then
     PrintChat("<font color = \"#33CCCC\">MMA Status:</font> <font color = \"#fff8e7\"> Loaded</font>")
     isMMA = true
 elseif _G.AutoCarry ~= nil then
      PrintChat("<font color = \"#33CCCC\">SAC Status:</font> <font color = \"#fff8e7\"> Loaded</font>")
     isSAC = true
 else
     PrintChat("<font color = \"#33CCCC\">OrbWalker not found:</font> <font color = \"#fff8e7\"> Loading SOW</font>")
       Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
       Orbwalker:LoadToMenu(Menu.SOWorb)
    end
  
 Menu:addSubMenu("["..myHero.charName.." - Combo]", "AhriCombo")
    Menu.AhriCombo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.AhriCombo:addSubMenu("Q Settings", "qSet")
  Menu.AhriCombo.qSet:addParam("useQ", "Use Q in combo", SCRIPT_PARAM_ONOFF, true)
 Menu.AhriCombo:addSubMenu("W Settings", "wSet")
  Menu.AhriCombo.wSet:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, false)
 Menu.AhriCombo:addSubMenu("E Settings", "eSet")
  Menu.AhriCombo.eSet:addParam("useE", "Use E in combo", SCRIPT_PARAM_ONOFF, true)
 Menu.AhriCombo:addSubMenu("R Settings", "rSet")
  Menu.AhriCombo.rSet:addParam("useR", "Use Smart Ultimate", SCRIPT_PARAM_ONOFF, true)
 
 Menu:addSubMenu("["..myHero.charName.." - Harass]", "Harass")
  Menu.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
  Menu.Harass:addParam("useQ", "Use Q in Harass", SCRIPT_PARAM_ONOFF, true)
    Menu.Harass:addParam("useW", "Use W in Harass", SCRIPT_PARAM_ONOFF, false)
   Menu.Harass:addParam("useE", "Use E in Harass", SCRIPT_PARAM_ONOFF, true)
    
 Menu:addSubMenu("["..myHero.charName.." - Laneclear]", "Laneclear")
    Menu.Laneclear:addParam("lclr", "Laneclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
  Menu.Laneclear:addParam("useClearQ", "Use Q in Laneclear", SCRIPT_PARAM_ONOFF, true)
 Menu.Laneclear:addParam("useClearW", "Use W in Laneclear", SCRIPT_PARAM_ONOFF, false)
    Menu.Laneclear:addParam("useClearE", "Use E in Laneclear", SCRIPT_PARAM_ONOFF, true)
 
 Menu:addSubMenu("["..myHero.charName.." - Jungleclear]", "Jungleclear")
    Menu.Jungleclear:addParam("jclr", "Jungleclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
  Menu.Jungleclear:addParam("useClearQ", "Use Q in Jungleclear", SCRIPT_PARAM_ONOFF, true)
 Menu.Jungleclear:addParam("useClearW", "Use W in Jungleclear", SCRIPT_PARAM_ONOFF, false)
    Menu.Jungleclear:addParam("useClearE", "Use E in Jungleclear", SCRIPT_PARAM_ONOFF, true)
 
 Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
 Menu.Ads:addParam("Escp", "Escape Key Use with spacebar", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
    Menu.Ads:addParam("autoLevel", "Auto-Level Spells", SCRIPT_PARAM_ONOFF, false)
   Menu.Ads:addSubMenu("Killsteal", "KS")
   Menu.Ads.KS:addParam("ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, false)
   Menu.Ads.KS:addParam("CAP", "Smart capclose", SCRIPT_PARAM_ONOFF, false)
   Menu.Ads.KS:addParam("KSQ", "Smart Q Steal", SCRIPT_PARAM_ONOFF, false)
   Menu.Ads.KS:addParam("KSW", "W Steal", SCRIPT_PARAM_ONOFF, false)
   Menu.Ads.KS:addParam("VERA", "Charm him under tower", SCRIPT_PARAM_ONOFF, false)
   Menu.Ads.KS:addParam("BOSS", "SyraX Carry me!", SCRIPT_PARAM_ONOFF, false)
  Menu.Ads.KS:addParam("igniteRange", "Minimum range to cast Ignite", SCRIPT_PARAM_SLICE, 470, 0, 600, 0)
  Menu.Ads:addSubMenu("VIP", "VIP")
    Menu.Ads.VIP:addParam("skin", "Use custom skin", SCRIPT_PARAM_ONOFF, false)
  Menu.Ads.VIP:addParam("skin1", "Skin changer", SCRIPT_PARAM_SLICE, 1, 1, 5)
    
 Menu:addSubMenu("["..myHero.charName.." - Target Selector]", "targetSelector")
 Menu.targetSelector:addTS(ts)
    ts.name = "Focus"
  
 Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
  Menu.drawings:addParam("drawAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
  Menu.drawings:addParam("drawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("drawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("drawE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("drawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("KillText", "Draw KillText", SCRIPT_PARAM_ONOFF, true)
    
 targetMinions = minionManager(MINION_ENEMY, 360, myHero, MINION_SORT_MAXHEALTH_DEC)
  allyMinions = minionManager(MINION_ALLY, 360, myHero, MINION_SORT_MAXHEALTH_DEC)
 jungleMinions = minionManager(MINION_JUNGLE, 360, myHero, MINION_SORT_MAXHEALTH_DEC)
 
 if Menu.Ads.VIP.skin and VIP_USER then
       GenModelPacket("Ahri", Menu.Ads.VIP.skin1)
     lastSkin = Menu.Ads.VIP.skin1
    end
  
 PrintChat("<font color = \"#33CCCC\">Ahri - The Charmer by</font> <font color = \"#fff8e7\">SyraX V"..version.."</font>")
end
function OnTick()
	target = GetCustomTarget()
	targetMinions:update()
	allyMinions:update()
	jungleMinions:update()
	CDHandler()
	KillSteal()
  

	if Menu.Ads.VIP.skin and VIP_USER and skinChanged() then
		GenModelPacket("Ahri", Menu.Ads.VIP.skin1)
		lastSkin = Menu.Ads.VIP.skin1
	end

	if Menu.Ads.autoLevel then
		AutoLevel()
	end
	
	if Menu.AhriCombo.combo then
		Combo()
	end
	
	if Menu.Harass.harass then
		Harass()
	end
	
	if Menu.Laneclear.lclr then
		LaneClear()
	end
	
	if Menu.Jungleclear.jclr then
		JungleClear()
	end


if GetGame().isOver then
	UpdateWeb(false, ScriptName, id, HWID)
	-- This is a var where I stop executing what is in my OnTick()
	startUp = false;
end
end

function CDHandler()
	-- Spells of die ready zijn of niet
	skills.SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
	skills.SkillW.ready = (myHero:CanUseSpell(_W) == READY)
	skills.SkillE.ready = (myHero:CanUseSpell(_E) == READY)
	skills.SkillR.ready = (myHero:CanUseSpell(_R) == READY)

	-- Items meer enmeer
	tiamatSlot = GetInventorySlotItem(3077)
	hydraSlot = GetInventorySlotItem(3074)
	youmuuSlot = GetInventorySlotItem(3142) 
	bilgeSlot = GetInventorySlotItem(3144)
	bladeSlot = GetInventorySlotItem(3153)
	dfgSlot = GetInventorySlotItem(3128)
	divineSlot = GetInventorySlotItem(3131)
	
	tiamatReady = (tiamatSlot ~= nil and myHero:CanUseSpell(tiamatSlot) == READY)
	hydraReady = (hydraSlot ~= nil and myHero:CanUseSpell(hydraSlot) == READY)
	youmuuReady = (youmuuSlot ~= nil and myHero:CanUseSpell(youmuuSlot) == READY)
	bilgeReady = (bilgeSlot ~= nil and myHero:CanUseSpell(bilgeSlot) == READY)
	bladeReady = (bladeSlot ~= nil and myHero:CanUseSpell(bladeSlot) == READY)
	dfgReady = (dfgSlot ~= nil and myHero:CanUseSpell(dfgSlot) == READY)
	divineReady = (divineSlot ~= nil and myHero:CanUseSpell(divineSlot) == READY)

	-- Summoners ignite bullshit
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		ignite = SUMMONER_2
	end
	igniteReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
DamageCalculation()
end-- Harass --


-- Harras function whit VP will later update whit Prodiction from klokje
function Harass()	
	if target ~= nil and ValidTarget(target) then
		if Menu.Harass.useQ and ValidTarget(target, skills.SkillQ.range) and skills.SkillQ.ready then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, skills.SkillQ.delay, skills.SkillQ.width, skills.SkillQ.range, skills.SkillQ.speed, myHero, false)
        if HitChance >= 2 and GetDistance(CastPosition) < 880 then
				 CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
		if Menu.Harass.useW and ValidTarget(target, skills.SkillW.range) and skills.SkillW.ready then
			CastSpell(_W, target)
		end
		if Menu.Harass.useE and ValidTarget(target, skills.SkillE.range) and skills.SkillE.ready then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, skills.SkillE.delay, skills.SkillE.width, skills.SkillE.range, skills.SkillE.speed, myHero, true)
        if HitChance >= 2 and GetDistance(CastPosition) < 800 then
				 CastSpell(_E, CastPosition.x, CastPosition.z)
         
		end
	end
	
end
end
end

-- End Harass --


-- Combo Selector  standaard--

function Combo()
	local typeCombo = 0
	if target ~= nil then
		AllInCombo(target, 0)
	end
	
end

-- Dynamic KS Q --
function GekkeKSQ()
  for i, target in ipairs(GetEnemyHeroes()) do
  qDmg = getDmg("Q", target, myHero)
  if ValidTarget(target, skills.SkillQ.range) and skills.SkillQ.ready and target.health < qDmg + qDmg then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, skills.SkillQ.delay, skills.SkillQ.width, skills.SkillQ.range, skills.SkillQ.speed, myHero, false)
        if HitChance >= 2 and GetDistance(CastPosition) < 880 then
				 CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
  end
end
end

-- W when killable
function GekkeKSW()
  for i, target in ipairs(GetEnemyHeroes()) do
  wDmg = getDmg("W", target, myHero)
  if ValidTarget(target, skills.SkillW.range) and skills.SkillW.ready and target.health < wDmg * 3 then
				 CastSpell(_W)
		end
  end
end

-- q Functie voor mijn combo wat beter te maken
function CastQ()
    for i, target in ipairs(GetEnemyHeroes()) do
      if ValidTarget(target, skills.SkillQ.range) and skills.SkillQ.ready then
        local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, skills.SkillQ.delay, skills.SkillQ.width, skills.SkillQ.range, skills.SkillQ.speed, myHero, false)
          if HitChance >= 2 and GetDistance(CastPosition) < 880 then
				 CastSpell(_Q, CastPosition.x, CastPosition.z)
          end
      end
    end
end
 --e functie ook voor combo wat beter te maken
 function CastE()
   for i, target in ipairs(GetEnemyHeroes()) do
      if ValidTarget(target, skills.SkillE.range) and skills.SkillE.ready then
        local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, skills.SkillE.delay, skills.SkillE.width, skills.SkillE.range, skills.SkillE.speed, myHero, true)
          if HitChance >= 2 and GetDistance(CastPosition) < 800 then
				 CastSpell(_E, CastPosition.x, CastPosition.z)
          end
      end
    end
end



--Dynamic capclose If he come to close he will charm f charm hit he will do his Q 2
local Charm = false

function OnGapclose2(target)
    if target ~= nil and Charm then
      local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(target, skills.SkillQ.delay, skills.SkillQ.width, skills.SkillQ.range, skills.SkillQ.speed, myHero, true)
      if skills.SkillQ.ready and  HitChance >= 2 and GetDistance(CastPosition) < 500 then
            CastSpell(_Q, CastPosition.x, CastPosition.z)
      end
    end
end
  
function OnGapclose(target)
  if target ~= nil then
    
    local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(target, skills.SkillQ.delay, skills.SkillQ.width, skills.SkillQ.range, skills.SkillQ.speed, myHero, true)
          if skills.SkillQ.ready and  HitChance >= 2 and GetDistance(CastPosition) < 500 then
            CastSpell(_E, CastPosition.x, CastPosition.z)
            Charm = true
            end
          end
         
            
		
	end

-- Nice R cast

function CastR()
  local Mouse = Vector(myHero) + 800 * (Vector(mousePos) - Vector(myHero)):normalized()
          CastSpell(_R, Mouse.x, Mouse.z)
end


-- W for combo
function CastW()
  if ValidTarget(target, skills.SkillW.range)  then
				 CastSpell(_W)
  end
end
  
  
  -- Harass Mana Function by Kain--

 
 
--{ Enemy in range of myHero

  
-- The shuit
function GekkeAutoCarryTepper()
  for i, target in ipairs(GetEnemyHeroes()) do
    qDmg = getDmg("Q", target, myHero)
    rDmg = getDmg("R", target, myHero)
    wDmg = getDmg("W", target, myHero)
    eDmg = getDmg("E", target, myHero)
    local count = CountEnemyInRange(target,range)
    if ValidTarget(target, skills.SkillQ.range) then   
      if target.health < eDmg then
        CastE()
      elseif target.health < eDmg + qDmg + qDmg then
        CastE()
        CastQ()
      elseif target.health < eDmg + wDmg + wDmg + wDmg then
        CastE()
        CastW()
      elseif target.health < eDmg + wDmg + wDmg + wDmg + qDmg + qDmg then
        CastE()
        CastW()
        CastQ()
      elseif target.health < rDmg + rDmg + rDmg + qDmg + qDmg + wDmg + wDmg + wDmg + eDmg and count < 3 and not IsMyManaLow() then
        CastR()
        CastE()
        CastW()
        CastQ()
      
      
      
  
      end
    
      
       
        
    end
                   
  end
end


-- All In Combo -- 

function AllInCombo(target, typeCombo)
	if target ~= nil and typeCombo == 0 then
		ItemUsage(target)
		if skills.SkillR.ready and Menu.AhriCombo.rSet.useR and ValidTarget(target, Ranges.AA) then
			local Mouse = Vector(myHero) + 400 * (Vector(mousePos) - Vector(myHero)):normalized()
        CastSpell(_R, Mouse.x, Mouse.z)
		end

		if Menu.AhriCombo.qSet.useQ and ValidTarget(target, skills.SkillQ.range) and skills.SkillQ.ready then
			local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, skills.SkillQ.delay, skills.SkillQ.width, skills.SkillQ.range, skills.SkillQ.speed, myHero, false)
        if HitChance >= 2 and GetDistance(CastPosition) < 880 then
				 CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
    end

		if Menu.AhriCombo.wSet.useW and ValidTarget(target, skills.SkillW.range) and skills.SkillW.ready then
		    CastSpell(_W)
		end

		if Menu.AhriCombo.eSet.useE and ValidTarget(target, skills.SkillE.range) and skills.SkillE.ready then
		    local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, skills.SkillE.delay, skills.SkillE.width, skills.SkillE.range, skills.SkillE.speed, myHero, true)
        if HitChance >= 2 and GetDistance(CastPosition) < 800 then
				 CastSpell(_E, CastPosition.x, CastPosition.z)
		end
	end
end
end


-- All In Combo --

--laneclear
function LaneClear()
	for i, minion in pairs(targetMinions.objects) do
		if minion ~= nil then
			if Menu.Laneclear.useClearQ and skills.SkillQ.ready and ValidTarget(minion, skills.SkillQ.range)then
				local qPosition, qChance = VP:GetCircularCastPosition(minion, skills.SkillQ.delay, skills.SkillQ.width, skills.SkillQ.range, skills.SkillQ.speed, myHero, false)
			    if qPosition ~= nil and qChance >= 1 then
			      CastSpell(_Q, qPosition.x, qPosition.z)
			    end
      end
      if Menu.Laneclear.useClearW and skills.SkillW.ready and ValidTarget(targetMinion, skills.SkillW.range) then
				CastSpell(_W)
			end
		
      if Menu.Laneclear.useClearE and skills.SkillE.ready and ValidTarget(minion, skills.SkillE.range)then
				local ePosition, eChance = VP:GetCircularCastPosition(minion, skills.SkillE.delay, skills.SkillE.width, skills.SkillE.range, skills.SkillE.speed, myHero, false)
			    if ePosition ~= nil and eChance >= 2 then
			      CastSpell(_E, ePosition.x, ePosition.z)
          end
      end
    end
  end
end
			
		




-- Jungle Clear will update soon!

function JungleClear()
	for i, jungleMinion in pairs(jungleMinions.objects) do
		if jungleMinion ~= nil then
			if Menu.Jungleclear.useClearQ and skills.SkillQ.ready and ValidTarget(jungleMinion, skills.SkillQ.range) then
				CastSpell(_Q, jungleMinion.x, jungleMinion.z)
			end
			if Menu.Jungleclear.useClearW and skills.SkillW.ready and ValidTarget(jungleMinion, skills.SkillW.range) then
				CastSpell(_W, jungleMinion)
			end
			if Menu.Jungleclear.useClearE and skills.SkillE.ready and ValidTarget(jungleMinion, skills.SkillE.range) then
				CastSpell(_E, jungleMinion.x, jungleMinion.z)
			end
		end
	end
end
-- Auto lvl from the best ahri build out here now i will change this once in the 3 moands
function AutoLevel()
	local qL, wL, eL, rL = player:GetSpellData(_Q).level + qOff, player:GetSpellData(_W).level + wOff, player:GetSpellData(_E).level + eOff, player:GetSpellData(_R).level + rOff
	if qL + wL + eL + rL < player.level then
		local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
		local level = { 0, 0, 0, 0 }
		for i = 1, player.level, 1 do
			level[abilitySequence[i]] = level[abilitySequence[i]] + 1
		end
		for i, v in ipairs({ qL, wL, eL, rL }) do
			if v < level[i] then LevelSpell(spellSlot[i]) end
		end
	end
end


-- SHortcuts 
function KillSteal()
	if Menu.Ads.KS.ignite then
		IgniteKS()
	end
  if Menu.Ads.KS.KSQ then
    GekkeKSQ()
  end
  if Menu.Ads.KS.KSW then
    GekkeKSW()
  end
  if Menu.Ads.KS.BOSS then
    GekkeAutoCarryTepper()
  end
  if Menu.Ads.KS.CAP then
    OnGapclose(target)
    OnGapclose2(target)
  end
  if Menu.Ads.Escp then
    EscapeMode()
  end
  if Menu.Ads.KS.VERA then
    Vera()
  end
end

-- Auto Ignite get the maximum range to avoid over kill --

function IgniteKS()
	if igniteReady then
		local Enemies = GetEnemyHeroes()
		for i, val in ipairs(Enemies) do
			if ValidTarget(val, 600) then
				if getDmg("IGNITE", val, myHero) > val.health and GetDistance(val) >= Menu.Ads.KS.igniteRange then
					CastSpell(ignite, val)
				end
			end
		end
	end
end

-- Auto Ignite --

function HealthCheck(unit, HealthValue)
	if unit.health > (unit.maxHealth * (HealthValue/100)) then 
		return true
	else
		return false
	end
end

function ItemUsage(target)

	if dfgReady then CastSpell(dfgSlot, target) end
	if youmuuReady then CastSpell(youmuuSlot, target) end
	if bilgeReady then CastSpell(bilgeSlot, target) end
	if bladeReady then CastSpell(bladeSlot, target) end
	if divineReady then CastSpell(divineSlot, target) end

end

-- Change skin function, made by Shalzuth
function GenModelPacket(champ, skinId)
	p = CLoLPacket(0x97)
	p:EncodeF(myHero.networkID)
	p.pos = 1
	t1 = p:Decode1()
	t2 = p:Decode1()
	t3 = p:Decode1()
	t4 = p:Decode1()
	p:Encode1(t1)
	p:Encode1(t2)
	p:Encode1(t3)
	p:Encode1(bit32.band(t4,0xB))
	p:Encode1(1)--hardcode 1 bitfield
	p:Encode4(skinId)
	for i = 1, #champ do
		p:Encode1(string.byte(champ:sub(i,i)))
	end
	for i = #champ + 1, 64 do
		p:Encode1(0)
	end
	p:Hide()
	RecvPacket(p)
end

function skinChanged()
	return Menu.Ads.VIP.skin1 ~= lastSkin
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
 radius = radius or 300
 quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
 quality = 2 * math.pi / quality
 radius = radius*.92
 local points = {}
 for theta = 0, 2 * math.pi + quality, quality do
  local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
  points[#points + 1] = D3DXVECTOR2(c.x, c.y)
 end
 DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
 local vPos1 = Vector(x, y, z)
 local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
 local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
 local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
 if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
  self:DrawCircleNextLvl(x, y, z, radius, 1, color, 75)
 end
end

function CircleDraw(x,y,z,radius, color)
	self:DrawCircle2(x, y, z, radius, color)
end--[[ Kill Text ]]--
TextList = {"Harass him", "Q", "W", "E", "ULT HIM !", "Items", "All In", "Skills Not Ready"}
KillText = {}
colorText = ARGB(229,229,229,0)
_G.ShowTextDraw = true

-- Damage Calculation Thanks Skeem for the base --


-- Need to be updated
function DamageCalculation()
  for i=1, heroManager.iCount do
    local target = heroManager:GetHero(i)
    if ValidTarget(target) and target ~= nil then
      qDmg = getDmg("Q", target,myHero)
      wDmg = getDmg("W", target,myHero)
      eDmg = getDmg("E", target,myHero)
      rDmg = getDmg("R", target,myHero)
      dfgDmg = getDmg("DFG", target, myHero)

      if not skills.SkillQ.ready and not skills.SkillW.ready and not skills.SkillE.ready and not skills.SkillR.ready then
        KillText[i] = TextList[8]
        return
      end

      if target.health <= qDmg then
        KillText[i] = TextList[2]
      elseif target.health <= wDmg then
        KillText[i] = TextList[3]
      elseif target.health <= eDmg then
        KillText[i] = TextList[4]
      elseif target.health <= rDmg then
        KillText[i] = TextList[5]
      elseif target.health <= qDmg + wDmg then
        KillText[i] = TextList[2] .."+".. TextList[3]
      elseif target.health <= qDmg + eDmg then
        KillText[i] = TextList[2] .."+".. TextList[4]
      elseif target.health <= qDmg + rDmg then
        KillText[i] = TextList[2] .."+".. TextList[5]
      elseif target.health <= wDmg + eDmg then
        KillText[i] = TextList[3] .."+".. TextList[4]
      elseif target.health <= wDmg + rDmg then
        KillText[i] = TextList[3] .."+".. TextList[5]
      elseif target.health <= eDmg + rDmg then
        KillText[i] = TextList[4] .."+".. TextList[5]
      elseif target.health <= qDmg + wDmg + eDmg then
        KillText[i] = TextList[2] .."+".. TextList[3] .."+".. TextList[4]
      elseif target.health <= qDmg + wDmg + eDmg + rDmg then
        KillText[i] = TextList[2] .."+".. TextList[3] .."+".. TextList[4] .."+".. TextList[5]
      elseif target.health <= dfgDmg + ((qDmg + wDmg + eDmg + rDmg) + (0.2 * (qDmg + wDmg + eDmg + rDmg))) then
        KillText[i] = TextList[7]
      else
        KillText[i] = TextList[1]
      end
    end
  end
end

function OnDraw()    if not myHero.dead then
        if Menu.drawings.drawAA then DrawCircle(myHero.x, myHero.y, myHero.z, Ranges.AA, ARGB(25 , 125, 125, 125)) end
        if Menu.drawings.drawQ then DrawCircle(myHero.x, myHero.y, myHero.z, skills.SkillQ.range, ARGB(25 , 125, 125, 125)) end
        if Menu.drawings.drawW then DrawCircle(myHero.x, myHero.y, myHero.z, skills.SkillW.range, ARGB(25 , 125, 125, 125)) end
        if Menu.drawings.drawE then DrawCircle(myHero.x, myHero.y, myHero.z, skills.SkillE.range, ARGB(25 , 125, 125, 125)) end
        if Menu.drawings.drawR then DrawCircle(myHero.x, myHero.y, myHero.z, skills.SkillR.range, ARGB(25 , 125, 125, 125)) end
    end
if _G.ShowTextDraw and Menu.drawings.KillText then
    for i = 1, heroManager.iCount do
	    local target = heroManager:GetHero(i)
	    if ValidTarget(target) and target ~= nil then
	      local barPos = WorldToScreen(D3DXVECTOR3(target.x, target.y, target.z)) --(Credit to Zikkah)
	      local PosX = barPos.x - 35
	      local PosY = barPos.y - 10
	      if KillText[i] ~= 10 then
	        DrawText(TextList[KillText[i]], 16, PosX, PosY, colorText)
	      else
	        DrawText(TextList[KillText[i]] .. string.format("%4.1f", ((target.health - (qDmg + pDmg + eDmg + itemsDmg)) * (1/rDmg)) * 2.5) .. "s = Kill", 16, PosX, PosY, colorText)
	      end
	    end
	end
  end
end



-- when a motrherfocker will be on my tower i will charm him
local kip = false


function OnTowerFocus(tower, unit)
  unit = GetTarget()
  if unit ~= nil then
       if tower.team == myHero.team then
         if unit.team ~= myHero.team then
           Kip = true
       end
     end
  end
 

 end

-- Vera<3

function Vera()
 for i, target in ipairs(GetEnemyHeroes()) do
  if target ~= nil then
    if Kip then
			CastE()
		end
  end
end
end

    


--function DiveOrNot(unit, offset)
 -- for i, turret ~= in pairs(GetTurrets()) do
   -- if turret ~= nil then
     -- if turret.team == isAI.team then
     --   if GetDitance(unit, turret) <= turret.range+offset then 
       --   return true
       -- end
    --end
  --  end
 --   return false
--d  end
-- Maxtnage
function MaxRange()
        if skills.SkillQ.ready then
                return skills.SkillQ.range
        elseif skills.SkillE.ready then
                return skills.SkillE.range
        else
                return myHero.range + 50
        end
end
  
        
    -- team fight ? i will not be the first one that his ulti cast
    --{ Enemy in range of myHero
function CountEnemyInRange(target, range)
        local count = 0 
        for i = 1, heroManager.iCount do
                local hero = heroManager:GetHero(i)
                if hero.team ~= myHero.team and hero.visible and not hero.dead and GetDistanceSqr(target,hero) <= 700 then
                        count = count + 1
                end
        end
        return count
end
--}

-- helpme
function EscapeMode()
  if skills.SkillR.ready then
			local Mouse = Vector(myHero) + 400 * (Vector(mousePos) - Vector(myHero)):normalized()
        CastSpell(_R, Mouse.x, Mouse.z)
		end
end


  
  -- don't fuck whit me if my mana low
  function IsMyManaLow()
        if myHero.mana < (myHero.maxMana * 20 / 100) then
                return true
        else
                return false
        end
end

function OnBugsplat()
	UpdateWeb(false, ScriptName, id, HWID)
end

function OnUnload()
	UpdateWeb(false, ScriptName, id, HWID)
end
