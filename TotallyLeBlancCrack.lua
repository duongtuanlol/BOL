--[[
		-- TO DO
			--> GapClose Q --> R if one enemy nearby
			--> Improve TargetSelector
					Not focus target only reachable by gapclose if other enemies nearby
			--> Auto W back if under turret and no enemies nearby
			--> Auto E in laning phase if jungler nearby
					--> User will be able to check range of leblanc & jungler
			--> Mimic Control
					--> Once I learn how to properly work with packets, meh

		Changelog
			* 1.99
				Improved Smart W
				Added Ignite Checks
				Added Overkill checks
				Fixed the combos
				Better TargetSelecting
				Better combo
				Better GapClosing

			* 2.00
				Script is now paid

			* 2.01
				Switched host
				Forced return W in harass

			* 2.02
				Multiple overkill checks
				Better way of detecting R
				Better gapclosing
				Faster combos
				Better targetselecting
				Message that tells whether you will die or not from ignite
				Auto Level
				Fixed the other killsteal options
				Better KillSteal in general
					Now takes Q buff in according

			* 2.03
				Bug fixes
				Small fix to W casting too fast
				Few more return checks for W


--]]


if myHero.charName:lower() ~= "leblanc" then return end

_G.LeBlanc_Loaded = true
_G.LeBlanc_ScriptVersion = 2.03
_G.LeBlanc_Author = "fourzerotwo"
_G.LeBlanc_PerformAutoUpdate = false

function Say(dba)
  print("<font color=\"#FF0000\"><b>Totally LeBlanc:</b></font> <font color=\"#FFFFFF\">" .. dba .. "</font>")
end
if not VIP_USER then
  return Say("You need to be VIP to use this script. Download cracked BoL at nulled.io")
end

  Say("Auth bypassed boys :^)")

_G.Leblanc_initialized = true
function AutoUpdate()
  local dba = {}
  dba.Version = _G.LeBlanc_ScriptVersion
  dba.UseHttps = true
  dba.Host = "raw.githubusercontent.com"
  dba.VersionPath = "/Nickieboy/BoL/master/version/LeBlanc.version"
  dba.ScriptPath = "/Nickieboy/BoL/master/LeBlanc.lua"
  dba.SavePath = SCRIPT_PATH .. GetCurrentEnv().FILE_NAME
  function dba.CallbackUpdate(_ca, aca)
    Say("Succesfully updated ( " .. aca .. " => " .. _ca .. ").")
  end
  function dba.CallbackNoUpdate(_ca)
    Say("No Updates Found")
  end
  function dba.CallbackNewVersion(_ca)
    Say("New Version found (" .. _ca .. "). Please wait until its downloaded.")
  end
  function dba.CallbackError(_ca)
    Say("Error while Downloading. Please try again.")
  end
  SxScriptUpdate(dba.Version, dba.UseHttps, dba.Host, dba.VersionPath, dba.ScriptPath, dba.SavePath, dba.CallbackUpdate, dba.CallbackNoUpdate, dba.CallbackNewVersion, dba.CallbackError)
end
local _aa, aaa, baa, caa, daa, _ba, aba = false, nil, nil, nil, nil, nil, nil
local bba, cba = false, nil
if FileExist(LIB_PATH .. "VPrediction.lua") then
  bba = true
  require("VPrediction")
end
if VIP_USER and FileExist(LIB_PATH .. "DivinePred.lua") and FileExist(LIB_PATH .. "DivinePred.luac") then
  caa = true
  require("DivinePred")
end
if FileExist(LIB_PATH .. "HPrediction.lua") then
  daa = true
  require("HPrediction")
end
function DeclareVariables()
  Qready, Wready, Eready, Rready = false, false, false, false
  Spells = {
    P = {
      name = "LeBlanc_Base_P_poof.troy"
    },
    AA = {
      range = 525,
      name = "BasicAttack"
    },
    Q = {
      name = "Sigil of Malice",
      spellname = "LeblancChaosOrb",
      range = 700,
      speed = 2000,
      markTimer = 3.5,
      delay = 0,
      activated = 0,
      buffQ = "LeblancChaosOrb",
      buffR = "LeblancChaosOrbM"
    },
    W = {
      name = "Distortion",
      spellname = "LeblancSlide",
      range = 650,
      radius = 250,
      speed = 2000,
      delay = 0.25,
      duration = 4,
      timeActivated = 0,
      isActivated = false,
      startPos = myHero.pos
    },
    E = {
      name = "Ethereal Chains",
      spellname = "LeblancSoulShackle",
      range = 950,
      speed = 1600,
      delay = 0.25,
      radius = 95
    },
    R = {
      name = "Mimic",
      spellname = "LeblancMimic",
      Qname = "LeblancChaosOrbM",
      Wname = "LeblancSlideM",
      Wreturnname = "leblancslidereturnm",
      Ename = "LeblancSoulShackleM"
    },
    WR = {
      duration = 4,
      spellname = "LeblancSlideM",
      timeActivated = 0,
      isActivated = false,
      startPos = myHero.pos
    }
  }
  rSpellName = {
    LeblancChaosOrbM = true,
    LeblancSlideM = true,
    LeblancSoulShackleM = true
  }
  Items = {
    BRK = {
      id = 3153,
      range = 450,
      reqTarget = true,
      slot = nil
    },
    BWC = {
      id = 3144,
      range = 400,
      reqTarget = true,
      slot = nil
    },
    HGB = {
      id = 3146,
      range = 400,
      reqTarget = true,
      slot = nil
    },
    RSH = {
      id = 3074,
      range = 350,
      reqTarget = false,
      slot = nil
    },
    STD = {
      id = 3131,
      range = 350,
      reqTarget = false,
      slot = nil
    },
    TMT = {
      id = 3077,
      range = 350,
      reqTarget = false,
      slot = nil
    },
    YGB = {
      id = 3142,
      range = 350,
      reqTarget = false,
      slot = nil
    },
    BFT = {
      id = 3188,
      range = 750,
      reqTarget = true,
      slot = nil
    },
    RND = {
      id = 3143,
      range = 275,
      reqTarget = false,
      slot = nil
    }
  }
  AAdisabled = false
  lastActivated = nil
  castedThroughHarass = false
  KillText = {}
  cba, DP = nil, nil
  ProdW, ProdE = nil, nil
  eSS, wSS = nil, nil
  ignite, heal, barrier, Iready, Hready, Bready = false, nil, nil, nil, nil, nil
  igniteTick = {}
  enemiesBuffs = {}
  isKilled = {}
  for dba, _ca in pairs(GetEnemyHeroes()) do
    if _ca then
      igniteTick[_ca.networkID] = {
        startT = os.clock(),
        health = _ca.health,
        isIgnited = false
      }
      enemiesBuffs[_ca.networkID] = {
        received = false,
        endTime = os.clock()
      }
      isKilled[_ca.networkID] = false
    end
  end
  lastQCast = {
    target = nil,
    endT = os.clock()
  }
  ignitedTable = {
    ignited = true,
    source = nil,
    time = os.clock(),
    hasSaid = false,
    willKillMe = false
  }
  autoLevelTables = {
    {
      _Q,
      _W,
      _E,
      _Q,
      _Q,
      _R,
      _Q,
      _W,
      _Q,
      _W,
      _R,
      _W,
      _W,
      _E,
      _E,
      _R,
      _E,
      _E
    },
    {
      _W,
      _Q,
      _E,
      _W,
      _W,
      _R,
      _W,
      _Q,
      _W,
      _Q,
      _R,
      _Q,
      _Q,
      _E,
      _E,
      _R,
      _E,
      _E
    }
  }
  lastLevel = myHero.level - 1
  ZhonyasSot = nil
  ZhyonasReady = false
  clone = nil
  cloneActive = false
  target = nil
  ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 700)
  ts.name = "TS"
  tsLong = TargetSelector(TARGET_LOW_HP_PRIORITY, 1500)
  tsLong.name = "GapClose"
  exampleTarget = nil
  forcedTarget = nil
  forcedTargetTime = os.clock()
  enemyMinions = minionManager(MINION_ENEMY, 600, myHero, MINION_SORT_HEALTH_DEC)
  _G.oldDrawCircle = rawget(_G, "DrawCircle")
  _G.DrawCircle = DrawCircle2
  BaseAnimationTime = {}
  BaseWindUpTime = {}
  hasPotionActive = false
  priorityTable = {
    AP = {
      "Annie",
      "Ahri",
      "Akali",
      "Anivia",
      "Annie",
      "Brand",
      "Cassiopeia",
      "Diana",
      "Evelynn",
      "FiddleSticks",
      "Fizz",
      "Gragas",
      "Heimerdinger",
      "Karthus",
      "Kassadin",
      "Katarina",
      "Kayle",
      "Kennen",
      "Leblanc",
      "Lissandra",
      "Lux",
      "Malzahar",
      "Mordekaiser",
      "Morgana",
      "Nidalee",
      "Orianna",
      "Ryze",
      "Sion",
      "Swain",
      "Syndra",
      "Teemo",
      "TwistedFate",
      "Veigar",
      "Viktor",
      "Vladimir",
      "Xerath",
      "Ziggs",
      "Zyra",
      "Velkoz"
    },
    Support = {
      "Alistar",
      "Blitzcrank",
      "Janna",
      "Karma",
      "Leona",
      "Lulu",
      "Nami",
      "Nunu",
      "Sona",
      "Soraka",
      "Taric",
      "Thresh",
      "Zilean",
      "Braum"
    },
    Tank = {
      "Amumu",
      "Chogath",
      "DrMundo",
      "Galio",
      "Hecarim",
      "Malphite",
      "Maokai",
      "Nasus",
      "Rammus",
      "Sejuani",
      "Nautilus",
      "Shen",
      "Singed",
      "Skarner",
      "Volibear",
      "Warwick",
      "Yorick",
      "Zac"
    },
    AD_Carry = {
      "Ashe",
      "Caitlyn",
      "Corki",
      "Draven",
      "Ezreal",
      "Graves",
      "Jayce",
      "Jinx",
      "KogMaw",
      "Lucian",
      "MasterYi",
      "MissFortune",
      "Pantheon",
      "Quinn",
      "Shaco",
      "Sivir",
      "Talon",
      "Tryndamere",
      "Tristana",
      "Twitch",
      "Urgot",
      "Varus",
      "Vayne",
      "Yasuo",
      "Zed",
      "Kalista"
    },
    Bruiser = {
      "Aatrox",
      "Darius",
      "Elise",
      "Fiora",
      "Gangplank",
      "Garen",
      "Irelia",
      "JarvanIV",
      "Jax",
      "Khazix",
      "LeeSin",
      "Nocturne",
      "Olaf",
      "Poppy",
      "Renekton",
      "Rengar",
      "Riven",
      "Rumble",
      "Shyvana",
      "Trundle",
      "Udyr",
      "Vi",
      "MonkeyKing",
      "XinZhao"
    }
  }
  canCastSpells = true
  RSkill = nil
  RSkillTime = os.clock()
  castedE = false
  castedETime = os.clock()
  if caa then
    eSS = LineSS(Spells.E.speed, Spells.E.range, Spells.E.radius, Spells.E.delay * 1000, 0)
    wSS = CircleSS(Spells.W.speed, Spells.W.range + 50, Spells.W.radius, Spells.W.delay * 1000, math.huge)
    LoadDivinePrediction()
  end
  if bba then
    cba = VPrediction()
  end
  if caa then
    DP = DivinePred()
  end
  if daa then
    HP_W, HP_E = nil, nil
    aba = HPrediction()
    LoadHPrediction()
  end
end
function RState(dba)
  local _ca = myHero:GetSpellData(_R).name
  return dba and (dba == "Q" and _ca == Spells.R.Qname or dba == "W" and _ca == Spells.R.Wname or dba == "E" and _ca == Spells.R.Ename)
end
function LoadHPrediction()
  HP_E = HPSkillshot({
    type = "DelayLine",
    delay = 0.25,
    range = 950,
    speed = 1600,
    collisionM = true,
    collisionH = true,
    width = 140
  })
  HP_W = HPSkillshot({
    type = "DelayCircle",
    delay = Spells.W.delay,
    range = Spells.W.range + 50,
    speed = Spells.W.speed,
    radius = Spells.W.radius
  })
end
function LoadDivinePrediction()
  if caa then
    divinePredictionTargetTable = {}
    for dba, _ca in pairs(GetEnemyHeroes()) do
      if _ca and _ca.type and _ca.type == myHero.type then
        divinePredictionTargetTable[_ca.networkID] = DPTarget(_ca)
      end
    end
  end
end
function CheckOrbWalker()
  if _G.Reborn_Initialised then
    SACLoaded = true
    Menu.orbwalker:addParam("info", "Detected SAC", SCRIPT_PARAM_INFO, "")
    _G.AutoCarry.Skills:DisableAll()
    Say("SAC Detected.")
  elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
    require("SxOrbWalk")
    _aa = false
    _G.SxOrb:LoadToMenu(Menu.orbwalker)
    Say("SxOrb detected.")
  end
  if SACLoaded or _aa then
    _ba = true
  end
  if not _ba then
    Say("You need either SAC or SxOrbWalk for this script. Please download one of them.")
  elseif b_a then
    Say("Welcome " .. GetUser() .. ": Trial user")
  elseif c_a then
    Say("Welcome " .. GetUser() .. ": Paid user")
  end
end
function OnLoad()
  if _G.LeBlanc_PerformAutoUpdate then
    AutoUpdate()
  end
  DeclareVariables()
  Summoners()
  DelayAction(function()
    CheckOrbWalker()
  end, 10)
  DrawMenu()
  if heroManager.iCount == 10 then
    arrangePrioritys()
  elseif heroManager.iCount == 6 then
    arrangePrioritysTT()
  end
end
function OnDraw()
  if myHero.dead then
    return
  end
  if Menu.drawings.draw then
    if Menu.drawings.drawQ and CanDrawSpell(_Q) then
      DrawCircle(myHero.x, myHero.y, myHero.z, Spells.Q.range, RGB(255, 102, 102))
    end
    if Menu.drawings.drawW and CanDrawSpell(_W) then
      DrawCircle(myHero.x, myHero.y, myHero.z, Spells.W.range, RGB(255, 51, 153))
    end
    if Menu.drawings.drawTarget and target and ValidTarget(target) then
      local dba = WorldToScreen(D3DXVECTOR3(target.x, target.y, target.z))
      local _ca = dba.x - 35
      local aca = dba.y - 40
      if forcedTarget and forcedTarget.networkID == target.networkID then
        DrawText("Forced: " .. target.charName .. " - " .. "Distance : " .. math.ceil(GetDistance(target)), 12, _ca, aca, ARGB(255, 255, 204, 0))
      else
        DrawText(target.charName .. " - " .. "Distance : " .. math.ceil(GetDistance(target)), 12, _ca, aca, ARGB(255, 255, 204, 0))
      end
    end
    if Menu.drawings.drawE and CanDrawSpell(_E) then
      DrawCircle(myHero.x, myHero.y, myHero.z, Spells.E.range, RGB(255, 153, 153))
    end
    if Menu.drawings.drawKillable then
      for dba, _ca in pairs(GetEnemyHeroes()) do
        if _ca and ValidTarget(_ca) then
          local aca = WorldToScreen(D3DXVECTOR3(_ca.x, _ca.y, _ca.z))
          local bca = aca.x - 35
          local cca = aca.y - 50
          DrawText(KillText[_ca.networkID], Menu.drawings.drawKillableWidth, bca, cca, ARGB(255, 255, 204, 0))
        end
      end
    end
  end
end
function CanDrawSpell(dba)
  if Menu.drawings.drawSpellReady then
    if dba == _Q then
      if not Qready then
        return false
      end
    elseif dba == _W then
      if not IsWReady() then
        return false
      end
    elseif dba == _E and not Eready then
      return false
    end
  end
  return true
end
function CheckForcedTarget()
  if forcedTarget then
    if forcedTarget.dead then
      forcedTarget = nil
      return
    end
    if forcedTargetTime + 10 < os.clock() then
      Say("Time expired. Deselected: " .. forcedTarget.charName)
      forcedTarget = nil
    end
  end
end
function AutoLevel()
  if myHero.level > lastLevel then
    LevelSpell(autoLevelTables[Menu.misc.autolevel.sequence][myHero.level])
    lastLevel = myHero.level
  end
end
function OnTick()
  if myHero.dead then
    return
  end
  Checks()
  CheckIgnite()
  IgniteWillKillMe()
  YOLO()
  if Menu.misc.autolevel.useAutoLevel then
    AutoLevel()
  end
  if Menu.keysettings.useCombo then
    Combo()
  end
  if Menu.settingsW.useOptional then
    LeBlancSpecificSpellChecks()
  end
  if not _ba then
    return
  end
  if Menu.combo.comboAA and (_aa and _G.SxOrb:GetMode() == 1 or SACLoaded and _G.AutoCarry.Keys.AutoCarry) and AAdisabled then
    if _aa then
      _G.SxOrb:EnableAttacks()
    elseif SACLoaded then
      _G.AutoCarry.MyHero:AttacksEnabled(true)
    end
    AAdisabled = false
  end
  if (_aa and _G.SxOrb:GetMode() == 1 or SACLoaded and _G.AutoCarry.Keys.AutoCarry) and not Menu.combo.comboAA and not AAdisabled then
    if _aa then
      _G.SxOrb:DisableAttacks()
    elseif SACLoaded then
      _G.AutoCarry.MyHero:AttacksEnabled(false)
    end
    AAdisabled = true
  end
  if Menu.keysettings.useHarass then
    Harass()
  end
  if Menu.keysettings.useFarm and (_aa and not _G.SxOrb:GetMode() == 1 and not _G.SxOrb:GetMode() == 2 and not _G.SxOrb:GetMode() == 3 or SACLoaded and not _G.AutoCarry.Keys.AutoCarry and not _G.AutoCarry.Keys.MixedMode and not _G.AutoCarry.Keys.LaneClear) then
    Farm()
  end
  if Menu.keysettings.useLaneClear then
    LaneClear()
  end
  if CanPermformKillSteal() then
    KillSteal()
  end
  if Menu.misc.zhonyas.zhonyas and not InFountain() then
    Zhonyas()
  end
  if ignite ~= nil and Menu.misc.autoignite.useIgnite then
    UseIgnite()
  end
end
function TooDangerous(dba)
  local _ca = {}
  local aca = 0
  local bca = {}
  for cca, dca in pairs(GetEnemyHeroes()) do
    if dca and GetDistanceSqr(dca) <= 1000000 then
      for _da, ada in pairs({
        _Q,
        _W,
        _E,
        _R
      }) do
        if ada and dca:CanUseSpell(ada) == READY then
          local bda = dca:GetSpellData(ada).range and dca:GetSpellData(ada).range or 500
          if bda and type(bda) == "number" and bda >= GetDistance(dba, dca) then
            table.insert(_ca[dca], ada)
          end
        end
      end
    end
  end
  if #_ca < 2 and CheckADCTarget(dba) then
    return 3
  end
  for cca, dca in pairs(bca) do
    for _da, ada in pairs(_ca[dca]) do
      if ada and dca then
        aca = aca + getDmg(SpellToString(ada), myHero, dca)
      end
    end
  end
  if aca then
    if aca == 0 then
      return 0
    elseif aca <= myHero.health / 2 then
      return 0
    elseif aca <= myHero.health * 0.7 then
      return 1
    elseif aca <= myHero.health then
      return 2
    elseif aca >= myHero.health then
      return 3
    elseif aca >= myHero.health * 1.5 then
      return 4
    elseif aca >= myHero.health * 2 then
      return 5
    elseif aca >= myHero.health * 3 then
      return 6
    elseif aca >= myHero.health * 4 then
      return 7
    elseif aca >= myHero.health * 5 then
      return 8
    elseif aca >= myHero.health * 6 then
      return 9
    elseif aca >= myHero.health * 7 then
      return 10
    end
  end
  return 0
end
function isKillable(dba)
  local _ca = 0
  local aca = dba.health
  for bca, cca in pairs({
    _Q,
    _W,
    _E,
    _R
  }) do
    if cca then
      if cca == _R and myHero:CanUseSpell(cca) == READY then
        _ca = _ca + SpellDmgCalculations("RQ", dba)
      elseif cca == _R or myHero:CanUseSpell(cca) ~= READY or cca == _W and wUsed() then
      else
        _ca = _ca + SpellDmgCalculations(SpellToString(cca), dba)
      end
    end
  end
  _ca = myHero:CalcMagicDamage(dba, _ca)
  if not damge or not _ca then
    _ca = 0
  end
  return _ca and type(_ca) == "number" and aca and type(aca) == "number" and aca <= _ca or false
end
function OnetoOne()
  local dba = tsLong.target
  if dba and CountEnemyHeroInRange(1000) == 1 and myOppenentLaner[dba.charName] == true then
    local _ca = CheckMinions()
    local aca = CheckTurretDamage()
    local bca = DamageToTarget(dba)
    local cca = DamageToMe(dba)
    if _ca >= 5 and not isKillable(dba) then
      return
    elseif isKillable(dba) then
      SmartCombo(dba)
    end
    if aca and (not SACLoaded or not _G.AutoCarry.OrbWalker:CanShoot() or not SxOrbLoad or not _G.SxOrb:CanAttack()) then
      if not isKillable(dba) then
        if getDmg("Q", aca, dba) and Qready and GetDistanceSqr(aca) <= Spells.Q.range * Spells.Q.range then
          CastQ(aca)
        end
      else
        SmartCombo(dba)
      end
    end
    local dca, _da = MinionCount(dba)
    cca = _da + cca
    if bca >= cca and not UnderTurret(dba.pos, true) then
      SmartCombo(dba)
    end
  end
end
function CheckMinions()
  local dba = 0
  for _ca, aca in pairs(enemyMinions.objects) do
    if aca and GetDistanceSqr(minions) <= (myHero.range + myHero.boundingRadius) * (myHero.range + myHero.boundingRadius) and getDmg("AA", aca, myHero) >= aca.health then
      dba = dba + 1
    end
  end
  return dba
end
function MinionCount(dba)
  local _ca = 0
  local aca = 0
  for bca, cca in pairs(enemyMinions.objects) do
    if cca and GetDistanceSqr(minions, dba.pos) <= cca.range * cca.range and getDmg("AA", cca, myHero) >= cca.health then
      _ca = _ca + 1
      aca = aca + getDmg("AA", myHero, cca)
    end
  end
  return _ca, aca
end
function CheckTurretDamage(dba, _ca)
end
function DamageToTarget(dba)
  local _ca = 0
  for aca, bca in pairs({
    _Q,
    _W,
    _E,
    _R
  }) do
    if bca and myHero:CanUseSpell(bca) == READY then
      if bca == _R then
        _ca = _ca + SpellDmgCalculations("RQ", dba)
      elseif bca == _W and wUsed() then
      else
        _ca = _ca + SpellDmgCalculations(SpellToString(bca), dba)
      end
    end
  end
  _ca = myHero:CalcMagicDamage(dba, _ca)
  if not damge or not _ca then
    _ca = 0
  end
  return _ca and type(_ca) == "number" and health and type(health) == "number" and _ca or 0
end
function DamageToMe(dba)
  local _ca = 0
  for aca, bca in pairs({
    _Q,
    _W,
    _E,
    _R
  }) do
    if bca and dba:CanUseSpell(bca) == READY then
      _ca = _ca + getDmg(SpellToString(bca), myHero, dba)
    end
  end
  _ca = dba:CalcMagicDamage(myHero, _ca)
  if not damge or not _ca then
    _ca = 0
  end
  return _ca and type(_ca) == "number" and health and type(health) == "number" and _ca or 0
end
function CheckADCTarget(dba)
  local _ca = false
  local aca
  for bca, cca in pairs(GetEnemyHeroes()) do
    if cca and cca.type and cca.type == myHero.type and GetDistanceSqr(cca) <= cca.range * cca.range and table.contains(priorityTable.AD_Carry, cca.charName) then
      _ca = true
      aca = cca
      break
    end
  end
  if _ca then
    local bca = {}
    local cca = GetLatency()
    for bda, cda in pairs({
      _Q,
      _W,
      _E,
      _R
    }) do
      if cda and myHero:CanUseSpell(cda) == READY then
        table.insert(bca, cda)
      end
    end
    local dca = 0
    for bda, cda in pairs(bca) do
      local dda = Spells[SpellToString(cda)].delay
      local __b = Spells[SpellToString(cda)].speed
      if dda == nil then
        dda = 0.2
      end
      if __b == nil then
        __b = 1800
      end
      dca = dca + dda + cca / 2000 + GetDistance(aca) / __b
    end
    local _da = math.ceil(myHero.health / getDmg("AD", myHero, aca))
    local ada = 0
    if BaseWindUpTime[aca.networkID] and BaseAnimationTime[aca.networkID] then
      ada = (1 / (aca.attackSpeed * BaseWindUpTime[aca.networkID]) + 1 / (aca.attackSpeed * BaseAnimationTime[aca.networkID]) + cca / 2000) * _da
    else
      ada = _da / aca.attackSpeed
    end
    if dca <= ada then
      return false
    end
  end
  return true
end
function SpellToString(dba)
  return dba == _Q and "Q" or dba == _W and "W" or dba == _E and "E" or dba == _R and "R"
end
function OnApplyBuff(dba, _ca, aca)
  if dba and dba.isMe and _ca and _ca.team and _ca.team ~= myHero.team and _ca.type and _ca.type == myHero.type and not _ca.dead and aca and aca.valid and aca.name then
    if aca.name:find("LeblancSoulShackle") then
      chainTarget = _ca
      castedETime = os.clock()
    end
    if aca.name:find(Spells.Q.buffQ) or aca.name:find(Spells.Q.buffR) then
      enemiesBuffs[_ca.networkID].received = true
      enemiesBuffs[_ca.networkID].endTime = os.clock() * 3500
    end
    if aca.name:lower():find("summonerdot") then
      igniteTick[_ca.networkID].isIgnited = true
      igniteTick[_ca.networkID].startT = os.clock()
    end
  end
  if _ca and _ca.isMe and aca and aca.name == "RegenerationPotion" then
    hasPotionActive = true
  end
end
function OnRemoveBuff(dba, _ca)
  if dba and dba.type and dba.type == myHero.type and _ca and _ca.name then
    if chainTarget and _ca.name:find("LeblancSoulShackle") and dba.networkID == chainTarget.networkID then
      chainTarget = nil
    end
    if ignitedTable.ignited and dba.isMe and _ca.name == "summonerdot" then
      ignitedTable.ignited = false
      ignitedTable.source = nil
      ignitedTable.hasSaid = false
      ignitedTable.willKillMe = false
    end
    if dba.team and dba.team ~= myHero.team and igniteTick[dba.networkID].isIgnited == true and _ca.name:find("summonerdot") then
      igniteTick[dba.networkID].isIgnited = false
    end
    if dba.isMe and _ca.name == "RegenerationPotion" and hasPotionActive then
      hasPotionActive = false
    end
    if dba.team and dba.team ~= myHero.team and enemiesBuffs[dba.networkID].received == true and (_ca.name:find(Spells.Q.buffQ) or _ca.name:find(Spells.Q.buffR)) then
      enemiesBuffs[dba.networkID].received = false
    end
  end
end
function SpellAvailable()
  return Qready or IsWReady() or Rready
end
function IsOverkill(dba)
  if dba and dba.type and dba.type == myHero.type and dba.networkID then
    if ignite == nil then
      return false
    end
    if igniteTick[dba.networkID].isIgnited and igniteTick[dba.networkID].isIgnited ~= true then
      return false
    end
    local _ca = 5 + igniteTick[dba.networkID].startT - os.clock()
    if _ca <= 0 then
      igniteTick[dba.networkID].isIgnited = false
      return false
    end
    local aca = 10 + myHero.level * 4
    local bca = _ca * aca
    if bca > dba.health then
      return true
    end
  end
  return false
end
function OnProcessSpell(dba, _ca)
  if dba and dba.type and dba.type == myHero.type and dba.team and dba.team ~= myHero.team and _ca and _ca.name and _ca.name:lower():find("attack") then
    BaseAnimationTime[dba.networkID] = 1 / (_ca.animationTime * dba.attackSpeed)
    BaseWindUpTime[dba.networkID] = _ca.windUpTime
  end
  if dba and dba.type and dba.type == myHero.type and dba.team and dba.team ~= myHero.team and _ca and _ca.name and _ca.target and _ca.target.isMe and _ca.name == "summonerdot" then
    if getDmg("IGNITE", myHero, dba) >= myHero.health then
      Say(dba.charName .. " ignited me. Ignite WILL kill me.")
      ignitedTable.hasSaid = true
      ignitedTable.willKillMe = true
    else
      Say(dba.charName .. " ignited me. I will survive.")
    end
    ignitedTable.ignited = true
    ignitedTable.source = dba
    ignitedTable.time = os.clock()
  end
  if dba and dba.isMe and _ca and _ca.name and not _ca.name:lower():find("attack") then
    if (canCastSpells == false or RSkill ~= nil or canCastSpells == false and RSkill ~= nil) and rSpellName[_ca.name] ~= nil then
      canCastSpells = true
      RSkill = nil
    end
    if _ca.target and _ca.target.type and _ca.target.type == myHero.type and _ca.target.team ~= myHero.team and _ca.target.health then
      if _ca.name == Spells.Q.spellname and SpellDmgCalculations("Q", _ca.target) >= _ca.target.health then
        isKilled[_ca.target.networkID] = true
      elseif _ca.name == Spells.Q.spellname and enemiesBuffs[_ca.target.networkID].received == true and SpellDmgCalculations("Q", _ca.target) + SpellDmgCalculations("QProc", _ca.target) >= _ca.target.health then
        isKilled[_ca.target.networkID] = true
      elseif _ca.name == Spells.R.Qname and SpellDmgCalculations("RQ", _ca.target) >= _ca.target.health then
        isKilled[_ca.target.networkID] = true
      elseif _ca.name == Spells.R.Qname and enemiesBuffs[_ca.target.networkID].received == true and SpellDmgCalculations("RQ", _ca.target) + SpellDmgCalculations("QProc", _ca.target) >= _ca.target.health then
        isKilled[_ca.target.networkID] = true
      end
    end
    if target and _ca.name == Spells.W.spellname and _ca.endPos and GetDistance(target, _ca.endPos) <= Spells.W.radius - 50 and SpellDmgCalculations("W", _ca.target) >= target.health then
      isKilled[target.networkID] = true
    end
    if _ca.name == Spells.Q.spellname and Wready and target and _ca.target and _ca.target.networkID and _ca.target.networkID == target.networkID then
      local aca = GetWPrediction(target)
      if aca ~= nil then
        local bca = os.clock()
        local cca = Spells.Q.delay
        local dca = GetDistance(target)
        local _da = Spells.Q.speed
        local ada = dca / _da + cca
        local bda = bca + ada
        lastQCast = {
          target = _ca.target,
          endT = bda
        }
      end
    end
    if _ca.name == Spells.W.spellname then
      Spells.W.startPos = _ca.startPos
    elseif _ca.name == Spells.WR.spellname then
      Spells.WR.startPos = _ca.startPos
    end
    if _ca.name == Spells.Q.spellname or _ca.name == Spells.W.spellname or _ca.name == Spells.E.spellname then
      lastActivated = _ca.name
    end
  end
end
function Combo()
  if myHero.dead then
    return
  end
  if target ~= nil and ValidTarget(target, 1500) then
    if isKilled[target.networkID] ~= nil and isKilled[target.networkID] == true then
      return
    end
    if Menu.combo.comboItems then
      UseItems(target)
    end
    if (canCastSpells == false or RSkill ~= nil) and RSkillTime + 1.5 < os.clock() then
      canCastSpells = true
      RSkill = nil
    end
    if not Rready and (canCastSpells == false or RSkill ~= nil) then
      RSkill = nil
      canCastSpells = true
    end
    if Rready and not canCastSpells and RSkill ~= nil then
      if RSkill == "Q" then
        if RState("Q") then
          CastRQ(target)
        elseif Qready and CastQ(target) then
          CastRQ(target)
        end
      elseif RSkill == "W" then
        if RState("W") then
          CastRW(target)
        elseif IsWReady() and CastW(target) then
          CastRW(target)
        end
      elseif RSkill == "E" then
        if RState("E") then
          CastRE(target)
        elseif Eready and CastE(target) then
          CastRE(target)
        end
      end
      return
    end
    if not canCastSpells and RSkill ~= nil then
      return
    end
    if Menu.combo.comboWay == 1 then
      SmartCombo(target)
    elseif Menu.combo.comboWay == 2 then
      ComboQRWE(target)
    elseif Menu.combo.comboWay == 3 then
      ComboQWRE(target)
    elseif Menu.combo.comboWay == 4 then
      ComboWQRE(target)
    elseif Menu.combo.comboWay == 5 then
      ComboWRQE(target)
    end
  end
end
function ComboQRWE(dba)
  if Qready and Rready and GetDistance(dba) <= Spells.Q.range then
    if CastQ(dba) then
      canCastSpells = false
      RSkill = "Q"
      RSkillTime = os.clock()
      return
    end
  elseif Qready and not Rready then
    CastQ(dba)
  elseif Rready and not Qready and RState("Q") then
    CastRQ(dba)
  end
  if not Qready and (not Rready or not RState("Q")) then
    if not wUsed() then
      CastW(dba)
    end
    CastE(dba)
  end
end
function ComboQWRE(dba)
  if Qready then
    CastQ(dba)
  end
  if IsWReady() and Rready and not wrUsed() and GetDistance(dba) <= Spells.W.range then
    if CastW(dba) then
      canCastSpells = false
      RSkill = "W"
      RSkillTime = os.clock()
      return
    end
  elseif IsWReady() and not Rready and not wUsed() then
    CastW(dba)
  elseif Rready and RState("W") and GetDistance(dba) <= Spells.W.range and not wrUsed() then
    canCastSpells = false
    RSkill = "W"
    RSkillTime = os.clock()
    return
  end
  if not Qready and not IsWReady() then
    CastE(dba)
  end
end
function ComboWQRE(dba)
  if IsWReady() then
    CastW(dba)
  end
  if Qready and Rready and GetDistance(dba) <= Spells.Q.range and not IsWReady() then
    if CastQ(dba) then
      canCastSpells = false
      RSkill = "Q"
      RSkillTime = os.clock()
      return
    end
  elseif Qready and not Rready and not IsWReady() then
    CastQ(dba)
  elseif Rready and not Qready and RState("Q") then
    CastRQ(dba)
  end
  if not IsWReady() and not Qready and (not Rready or not RState("Q")) then
    CastE(dba)
  end
end
function ComboWRQE(dba)
  if not wrUsed() and IsWReady() and Rready then
    if CastW(dba) then
      canCastSpells = false
      RSkill = "W"
      RSkillTime = os.clock()
      return
    end
  elseif not Rready and IsWReady() then
    CastW(dba)
  elseif not wrUsed() and Rready and not IsWReady() and RState("W") then
    canCastSpells = false
    RSkill = "W"
    RSkillTime = os.clock()
    return
  elseif not IsWReady() and (not Rready or wrUsed() or not RState("W")) then
    CastQ(dba)
    CastE(dba)
  end
end
function SmartCombo(dba)
  local _ca, aca, bca = ReturnBestTargetPosition(3, Spells.W.range)
  if _ca ~= nil and aca ~= nil and GetDistanceSqr(_ca) < Spells.W.range * Spells.W.range and not wrUsed() and IsWReady() and Rready and bca >= 3 and CastW(_ca.x, _ca.z) then
    canCastSpells = false
    RSkill = "W"
    RSkillTime = os.clock()
    return
  end
  local cca = SpellDmgCalculations("Q", dba)
  local dca = SpellDmgCalculations("QProc", dba)
  local _da = SpellDmgCalculations("W", dba)
  local ada = SpellDmgCalculations("E", dba)
  local bda = SpellDmgCalculations("RQ", dba)
  local cda = SpellDmgCalculations("RW", dba)
  local dda = GetDistanceSqr(dba)
  if Qready and IsWReady() and Rready and cca + bda + dca + dca + _da >= _da + cda + cca and dda < Spells.Q.range * Spells.Q.range then
    if CastQ(dba) then
      canCastSpells = false
      RSkill = "Q"
      RSkillTime = os.clock()
    end
  elseif Qready and Rready and IsWReady() and not wrUsed() and dda < Spells.Q.range * Spells.Q.range and cca + bda + dca + dca + _da < _da + cda + cca then
    CastQ(dba)
    if CastW(dba) then
      canCastSpells = false
      RSkill = "W"
      RSkillTime = os.clock()
    end
  elseif dda < Spells.E.range * Spells.E.range and dda > Spells.Q.range * Spells.Q.range then
    CastE(dba)
  elseif Qready and Rready and GetDistanceSqr(dba) < Spells.Q.range * Spells.Q.range then
    if CastQ(dba) then
      canCastSpells = false
      RSkill = "Q"
      RSkillTime = os.clock()
    end
  elseif Menu.combo.comboGap and GetDistance(dba) > Spells.Q.range and GetDistance(dba) < Spells.Q.range + Spells.W.range - 100 and Qready and IsWReady() and Rready and HasManaToGapClose() and GapClose(dba) then
    if CastQ(dba) and Rready then
      canCastSpells = false
      RSkill = "Q"
      RSkillTime = os.clock()
    end
  elseif Menu.combo.comboGap and GetDistance(dba) > Spells.Q.range and GetDistance(dba) < Spells.Q.range + Spells.W.range - 100 and Qready and IsWReady() and Eready and HasManaToGapClose() and GapClose(dba) then
    if CastQ(dba) and Rready then
      canCastSpells = false
      RSkill = "Q"
      RSkillTime = os.clock()
    end
  elseif IsWReady() and not Eready and not Qready and myHero:GetSpellData(_Q).level and myHero:GetSpellData(_Q).level >= 1 and myHero:GetSpellData(_Q).currentCd and myHero:GetSpellData(_Q).currentCd <= 2 and (not myHero:GetSpellData(_E).level or not (1 <= myHero:GetSpellData(_E).level) or not myHero:GetSpellData(_E).currentCd or not (2 >= myHero:GetSpellData(_E).currentCd)) and not isKillable(dba) then
    return
  else
    if CastQ(dba) and SpellDmgCalculations("Q", dba) > dba.health then
      isKilled[dba.networkID] = true
      return
    end
    if CastRQ(dba) and SpellDmgCalculations("RQ", dba) > dba.health then
      isKilled[dba.networkID] = true
      return
    end
    if CastW(dba) and SpellDmgCalculations("W", dba) > dba.health then
      isKilled[dba.networkID] = true
      return
    end
    CastE(dba)
  end
end
function CastRQ(dba)
  if dba and Rready and GetDistanceSqr(dba) <= Spells.Q.range * Spells.Q.range and RState("Q") then
    CastSpell(_R, dba)
  end
end
function CastRW(dba)
  if RState("W") then
    local _ca = GetWPrediction(dba)
    if dba and Rready and GetDistance(dba) <= Spells.W.range + 100 and _ca ~= nil and not wrUsed() then
      CastSpell(_R, _ca.x, _ca.z)
    end
  end
end
function CastRE(dba)
  if RState("E") then
    local _ca = GetEPrediction(dba)
    if dba and Rready and GetDistance(dba) <= Spells.E.range and _ca ~= nil then
      CastSpell(_R, _ca.x, _ca.Z)
    end
  end
end
function Harass()
  local dba = false
  if target ~= nil and ValidTarget(target) and ManaManager() then
    if Menu.harass.harassQ then
      CastQ(target)
    end
    if Menu.harass.harassW and CastW(target) then
      dba = true
    end
    if Menu.harass.harassE then
      CastE(target)
    end
  end
  if dba and wUsed() then
    CastSpell(_W)
  end
end
function LeBlancSpecificSpellChecks()
  if castedETime + 1.2 > os.clock() then
    return
  end
  if chainTarget and castedETime + 2 < os.clock() then
    chainTarget = nil
  end
  if wUsed() and chainTarget ~= nil and GetDistance(Spells.W.startPos, chainTarget) >= Spells.E.range then
    return
  end
  if wrUsed() and not wUsed() and chainTarget ~= nil and GetDistance(Spells.WR.startPos, chainTarget) >= Spells.E.range then
    return
  end
  if wUsed() and wrUsed() and GetDistance(Spells.W.startPos, chainTarget) >= Spells.E.range and GetDistance(Spells.WR.startPos, chainTarget) >= Spells.E.range and TooDangerous(myHero.pos) <= 5 then
    return
  end
  local dba = TooDangerous(myHero.pos)
  if wUsed() and Wready then
    if CountEnemyHeroInRange(1500) == 0 and UnderTurret(myHero, true) then
      CastSpell(_W)
    end
    local _ca = myHero.health / myHero.maxHealth
    if _ca >= 0.6 and target and isKillable(target) and GetDistance(target) <= 800 and dba <= 4 then
      return
    end
    if _ca <= 0.2 and 2 <= CountEnemyHeroInRange(600) then
      return
    end
    if _ca <= 0.3 and target and isKillable(target) and GetDistance(target) <= 500 and dba <= 4 then
      return
    end
    if CheckADCTarget(Spells.W.startPos) and not CheckADCTarget(myHero.pos) and dba <= 4 then
      return
    elseif CheckADCTarget(myHero.pos) and not CheckADCTarget(Spells.W.startPos) and TooDangerous(Spells.W.startPos) <= 4 then
      CastSpell(_W)
    end
    if dba >= TooDangerous(Spells.W.startPos) and dba >= 4 then
      CastSpell(_W)
    end
  end
  if wrUsed() and not wUsed() then
    if CheckADCTarget(myHero.pos) and not CheckADCTarget(Spells.WR.startPos) then
      CastSpell(_R)
    end
    if dba >= TooDangerous(Spells.WR.startPos) and dba >= 4 then
      CastSpell(_R)
    end
  end
  if wUsed() and CountEnemyHeroInRange(600) == 1 and dba >= 4 then
    CastSpell(_W)
  end
  if Menu.settingsW.useOptionalW == 1 then
    if wUsed() and wrUsed() then
      if CountEnemyHeroInRange(400, Spells.WR.startPos) < CountEnemyHeroInRange(400, Spells.W.startPos) and CountEnemyHeroInRange(400, Spells.WR.startPos) < CountEnemyHeroInRange(400) then
        if not Qready and not Eready then
          CastSpell(_R)
        end
      elseif CountEnemyHeroInRange(400, Spells.W.startPos) > CountEnemyHeroInRange(400, Spells.WR.startPos) and CountEnemyHeroInRange(400, Spells.W.startPos) < CountEnemyHeroInRange(400) and not Qready and not Eready then
        CastSpell(_W)
      end
    elseif wUsed() then
      if CountEnemyHeroInRange(400, Spells.W.startPos) < CountEnemyHeroInRange(400) and (not Qready and not Eready or dba > TooDangerous(Spells.W.startPos)) then
        CastSpell(_W)
      end
    elseif wrUsed() and CountEnemyHeroInRange(400, Spells.WR.startPos) < CountEnemyHeroInRange(400) and not Qready and not Eready then
      CastSpell(_W)
    end
  elseif Menu.settingsW.useOptionalW == 3 or Menu.settingsW.useOptionalW == 4 then
    if wUsed() and wrUsed() then
      if not Qready and not Eready then
        CastSpell(_W)
      end
    elseif wUsed() then
      if not Qready and not Eready then
        CastSpell(_W)
      end
    elseif wrUsed() and not Qready and not Eready then
      CastSpell(_W)
    end
  end
end
function Farm()
  local dba = false
  if Menu.farm.farmAA and (_aa and _G.SxOrb:CanAttack() == true or SACLoaded and _G.AutoCarry.Orbwalker:CanShoot()) then
    return
  end
  if Menu.farm.farmQ then
    for _ca, aca in pairs(enemyMinions.objects) do
      if aca and Menu.farm.farmRange and GetDistanceSqr(aca) < Spells.AA.range * Spells.AA.range and GetDistanceSqr(aca) < Spells.Q.range * Spells.Q.range then
        if getDmg("Q", aca, myHero) > aca.health and CastQ(aca, false) then
          dba = true
        end
      end
      if dba ~= true then
        if not Menu.farm.farmRange and GetDistanceSqr(aca) < Spells.Q.range * Spells.Q.range then
          if getDmg("Q", aca, myHero) > aca.health then
            if CastQ(aca, false) then
              dba = true
            end
            if dba then
              CastSpell(_W)
            end
          end
        end
      end
      if dba ~= true then
      end
    end
  end
  if dba then
    Qready = false
    return
  end
  if Menu.farm.farmW then
    for _ca, aca in pairs(enemyMinions.objects) do
      if aca and Menu.farm.farmRange and GetDistanceSqr(aca) < Spells.AA.range * Spells.AA.range and GetDistanceSqr(aca) < Spells.W.range * Spells.W.range and IsWReady() and getDmg("W", aca, myHero) > aca.health and CastW(aca) then
        CastSpell(_W)
        dba = true
        do break end
        return
      end
      if not Menu.farm.farmRange and GetDistanceSqr(aca) < Spells.W.range * Spells.W.range and IsWReady() and getDmg("W", aca, myHero) > aca.health and CastW(aca) then
        CastSpell(_W)
        dba = true
        break
      end
    end
  end
  if dba then
    Wready = false
    return
  end
end
function LaneClear()
  if Menu.laneclear.laneclearQ then
    for dba, _ca in ipairs(enemyMinions.objects) do
      if GetDistanceSqr(_ca) < Spells.Q.range * Spells.Q.range then
        CastSpell(_Q, _ca)
        break
      end
    end
  end
  if Menu.laneclear.laneclearW and Menu.laneclear.laneclearR and Rready and Wready then
    if not wUsed() and not wrUsed() then
      local dba, _ca = GetBestAOEPosition(enemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
      if _ca and _ca >= Menu.laneclear.laneclearWRAmount then
        if dba ~= nil then
          CastSpell(_W, dba.x, dba.z)
        end
        dba, _ca = GetBestAOEPosition(enemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
        if dba ~= nil then
          CastSpell(_R, dba.x, dba.z)
        end
      end
    end
    if wUsed() then
      CastSpell(_W)
    end
  elseif Menu.laneclear.laneclearW and IsWReady() then
    local dba, _ca = GetBestAOEPosition(enemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
    if dba ~= nil and _ca >= Menu.laneclear.laneclearWAmount then
      CastSpell(_W, dba.x, dba.z)
      CastSpell(_W)
    end
  elseif Menu.laneclear.laneclearR and Rready and RState("W") and not wrUsed() then
    local dba, _ca = GetBestAOEPosition(enemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
    if dba ~= nil and _ca >= Menu.laneclear.laneclearRAmount then
      CastSpell(_R, dba.x, dba.z)
      CastSpell(_R)
    end
  end
end
function KillSteal()
  if not canCastSpells then
    return
  end
  for dba, _ca in pairs(GetEnemyHeroes()) do
    if ValidTarget(_ca) and not _ca.dead and _ca.visible and Menu.killsteal.enemies[_ca.charName] then
      local aca, bca, cca, dca, _da, ada = 0, nil, nil, nil, nil, nil
      if GetDistance(_ca) <= Spells.Q.range + Spells.W.range then
        aca = Qready and Menu.killsteal.killstealQ and SpellDmgCalculations("Q", _ca) or 0
        bca = Rready and RState("Q") and SpellDmgCalculations("RQ", _ca) or 0
        cca = SpellDmgCalculations("QProc", _ca)
        dca = IsWReady() and Menu.killsteal.killstealW and SpellDmgCalculations("W", _ca) or 0
        _da = Rready and Menu.killsteal.killstealR and not wrUsed() and RState("W") and SpellDmgCalculations("RW", _ca) or 0
      end
      if not IsOverkill(_ca) then
        if GetDistanceSqr(_ca) <= 422500 then
          if aca > dca and dca > _ca.health then
            CastW(_ca)
          elseif aca > _ca.health then
            CastQ(_ca)
          elseif enemiesBuffs[_ca.networkID].received and aca + cca > _ca.health then
            CastQ(_ca)
          elseif enemiesBuffs[_ca.networkID].received and dca + cca > _ca.health then
            CastW(_ca)
          elseif bca > _da and _da > _ca.health and RState("W") then
            CastRW(_ca)
          elseif bca > _ca.health and RState("Q") then
            CastRQ(_ca)
          elseif enemiesBuffs[_ca.networkID].received and cca + bca > _ca.health and RState("Q") then
            CastRQ(_ca)
          elseif bca + cca + aca > _ca.health and Qready and Rready then
            CastQ(_ca)
            CastRQ(_ca)
          end
        elseif Menu.killsteal.killstealGap and GetDistanceSqr(_ca) >= 360000 and GetDistance(_ca) <= Spells.Q.range + Spells.W.range - 100 and IsWReady() and HasManaToGapClose() then
          if aca > _ca.health then
            if GapClose(_ca) then
              CastQ(_ca)
            end
          elseif GetDistance(_ca) < Spells.W.range + Spells.W.range - 100 and bca > _da and _da > _ca.health and Rready then
            if GapClose(_ca) and RState("W") then
              CastRW(_ca)
            end
          elseif Menu.killsteal.killstealQR and bca + cca + aca > _ca.health and Qready and Rready then
            if GetDistanceSqr(_ca) >= Spells.Q.range * Spells.Q.range and GetDistanceSqr(_ca) <= (Spells.Q.range + Spells.W.range - 200) * (Spells.Q.range + Spells.W.range - 200) then
              GapClose(_ca)
              CastQ(_ca)
              CastRQ(_ca)
            elseif GetDistanceSqr(_ca) <= Spells.Q.range * Spells.Q.range then
              CastQ(_ca)
              CastRQ(_ca)
            end
          end
        end
      end
    end
  end
end
function GetOrbTarget()
  local dba, _ca
  if forcedTarget and GetDistanceSqr(forcedTarget) <= Spells.E.range * Spells.E.range then
    return forcedTarget
  end
  ts:update()
  tsLong:update()
  dba = tsLong.target
  _ca = dba
  if dba then
    if GetDistance(dba) > 700 and CountEnemyHeroInRange(600) >= 3 and not table.contains(priorityTable.AP, dba.charName) and not table.contains(priorityTable.Support, dba.charName) and not table.contains(priorityTable.AD_Carry, dba.charName) then
      dba = nil
    else
      local aca = Qready and SpellDmgCalculations("Q", dba) or 0
      local bca = Qready and RState("Q") and SpellDmgCalculations("RQ", dba) or 0
      local cca = (Qready or Rready) and SpellDmgCalculations("QProc", dba) or 0
      local dca = Rready and Qready and aca + bca + cca or 0
      if GetDistance(dba) > 700 and 3 <= CountEnemyHeroInRange(300, dba) and dca < dba.health then
        dba = nil
      end
    end
    if not HasManaToGapClose() or dba == nil then
      dba = ts.target
    end
    if dba and GetDistanceSqr(dba) >= 490000 and ts.target ~= nil and (table.contains(priorityTable.AP, ts.target.charName) or table.contains(priorityTable.Support, ts.target.charName) or table.contains(priorityTable.AD_Carry, ts.target.charName)) then
      dba = ts.target
    end
    if dba == nil and _ca ~= nil then
      dba = _ca
    end
    if dba and IsOverkill(dba) then
      dba = nil
    end
    if dba and (dba.type and dba.type ~= myHero.type or not dba.type) then
      dba = nil
    end
  end
  if Menu.combo.forceADC then
    local aca = false
    for bca, cca in pairs(GetEnemyHeroes()) do
      if cca and cca.type and ValidTarget(cca, Spells.E.range) and cca.visible and not cca.dead and (table.contains(priorityTable.AP, cca.charName) or table.contains(priorityTable.AD_Carry, cca.charName)) then
        if dba and isKillable(dba) and not isKillable(cca) then
          break
        end
        dba = cca
        aca = true
        break
      end
    end
  end
  return dba
end
function Zhonyas()
  local dba = GetInventorySlotItem(3157)
  if dba ~= nil and myHero:CanUseSpell(dba) == READY and myHero.health / myHero.maxHealth <= Menu.misc.zhonyas.zhonyasunder then
    CastSpell(dba)
  end
end
function UseIgnite()
  local dba = 50 + 20 * myHero.level
  for _ca, aca in pairs(GetEnemyHeroes()) do
    if aca and GetDistance(aca, myHero) < 600 and ValidTarget(aca, 600) and Menu.misc.autoignite[aca.charName] and Iready and dba > aca.health then
      CastSpell(ignite, aca)
    end
  end
end
function ManaManager()
  if myHero.mana / myHero.maxMana <= Menu.harass.harassMana then
    return false
  end
  return true
end
function CheckIgnite()
  if Menu.misc.counterLogic.usePotion and ignitedTable.ignited and ignitedTable.source then
    local dba = ignitedTable.time + 5 - os.clock()
    local _ca = dba * (10 + ignitedTable.source.level * 4)
    if _ca > myHero.health and _ca - 37 <= myHero.health or _ca >= myHero.health * 0.3 then
      local aca = GetInventorySlotItem(2003)
      if aca ~= nil and not hasPotionActive then
        CastSpell(aca)
      end
    end
  end
end
function IgniteWillKillMe()
  if ignitedTable.ignited and ignitedTable.source and ignitedTable.source.level then
    local dba = ignitedTable.time + 5 - os.clock()
    local _ca = dba * (10 + ignitedTable.source.level * 4)
    if _ca > myHero.health then
      if ignitedTable.hasSaid == false then
        Say(ignitedTable.source.charName .. "'s ignite will kill me.")
        ignitedTable.hasSaid = true
      end
      if ignitedTable.willKillMe ~= true then
        ignitedTable.willKillMe = true
      end
    else
      if ignitedTable.hasSaid == true then
        Say(ignitedTable.source.charName .. "'s ignite will NO LONGER kill me.")
        ignitedTable.hasSaid = false
      end
      if ignitedTable.willKillMe == true then
        ignitedTable.willKillMe = false
      end
    end
  elseif ignitedTable.willKillMe == true then
    ignitedTable.willKillMe = false
  end
end
function YOLO()
  if Menu.yolo.useYolo and ignitedTable.willKillMe == true then
    SmartCombo()
  end
end
function SetPriority(dba, _ca, aca)
  for i = 1, #dba do
    if _ca.charName:find(dba[i]) ~= nil then
      TS_SetHeroPriority(aca, _ca.charName)
    end
  end
end
function arrangePrioritys()
  for dba, _ca in ipairs(GetEnemyHeroes()) do
    SetPriority(priorityTable.AD_Carry, _ca, 1)
    SetPriority(priorityTable.AP, _ca, 2)
    SetPriority(priorityTable.Support, _ca, 3)
    SetPriority(priorityTable.Bruiser, _ca, 4)
    SetPriority(priorityTable.Tank, _ca, 5)
  end
end
function arrangePrioritysTT()
  for dba, _ca in ipairs(GetEnemyHeroes()) do
    SetPriority(priorityTable.AD_Carry, _ca, 1)
    SetPriority(priorityTable.AP, _ca, 1)
    SetPriority(priorityTable.Support, _ca, 2)
    SetPriority(priorityTable.Bruiser, _ca, 2)
    SetPriority(priorityTable.Tank, _ca, 3)
  end
end
function UseItems(dba)
  if dba ~= nil then
    for _ca, aca in pairs(Items) do
      aca.slot = GetInventorySlotItem(aca.id)
      if aca.slot ~= nil and myHero:CanUseSpell(aca.slot) == READY then
        if aca.reqTarget and GetDistance(dba) < aca.range then
          CastSpell(aca.slot, dba)
        elseif not aca.reqTarget and GetDistance(dba) - getHitBoxRadius(myHero) - getHitBoxRadius(dba) < 50 then
          CastSpell(aca.slot)
        end
      end
    end
  end
end
function CalcDamage()
  for dba, _ca in pairs(GetEnemyHeroes()) do
    if _ca and isKilled[_ca.networkID] and isKilled[_ca.networkID] == true then
      if _ca.dead then
        isKilled[_ca.networkID] = false
      elseif target and _ca.networkID ~= target.networkID then
        isKilled[_ca.networkID] = false
      end
    end
    if enemiesBuffs[_ca.networkID].received and enemiesBuffs[_ca.networkID].received == true and enemiesBuffs[_ca.networkID].endTime and enemiesBuffs[_ca.networkID].endTime < os.clock() then
      enemiesBuffs[_ca.networkID].received = false
    end
    if _ca and ValidTarget(_ca) then
      local aca = SpellDmgCalculations("Q", _ca) or 0
      local bca = RState("Q") and SpellDmgCalculations("RQ", _ca) or 0
      local cca = (Qready or Rready and RState("Q")) and SpellDmgCalculations("QProc", _ca) or 0
      local dca = IsWReady() and SpellDmgCalculations("W", _ca) or 0
      local _da = not wrUsed() and RState("W") and SpellDmgCalculations("RW", _ca) or 0
      local ada = SpellDmgCalculations("E", _ca) or 0
      local bda = 50 + 20 * myHero.level or 0
      if myHero.damage > _ca.health then
        KillText[_ca.networkID] = "MURDER HIM"
      elseif Qready and aca < dca and aca > _ca.health then
        KillText[_ca.networkID] = "Q = kill"
      elseif IsWReady() and dca > _ca.health then
        KillText[_ca.networkID] = "W = kill"
      elseif Eready and ada > _ca.health then
        KillText[_ca.networkID] = "E = kill"
      elseif Qready and Iready and aca + bda > _ca.health then
        KillText[_ca.networkID] = "Q + Ignite = kill"
      elseif IsWReady() and Iready and dca + bda > _ca.health then
        KillText[_ca.networkID] = "W + Ignite = kill"
      elseif IsWReady() and Qready and aca + cca + dca > _ca.health then
        KillText[_ca.networkID] = "Q + W = kill"
      elseif Qready and Eready and dca + ada > _ca.health then
        KillText[_ca.networkID] = "Q + E = kill"
      elseif Qready and Rready and aca + bca + cca > _ca.health then
        KillText[_ca.networkID] = "Q + R = kill"
      elseif IsWReady() and Rready and dca + _da > _ca.health then
        KillText[_ca.networkID] = "W + R = kill"
      elseif Qready and Rready and Iready and aca + bca + cca + bda > _ca.health then
        KillText[_ca.networkID] = "Q + R + Ignite = kill"
      elseif Qready and IsWReady() and Rready and aca + cca + dca + _da > _ca.health then
        KillText[_ca.networkID] = "Q + W + R = kill"
      elseif Qready and Rready and IsWReady() and aca + bca + cca + cca + dca > _ca.health then
        KillText[_ca.networkID] = "Q + R + W = kill"
      elseif Qready and IsWReady() and Rready and Iready and aca + cca + dca + _da + bda > _ca.health then
        KillText[_ca.networkID] = "Q + W + R + Ignite = kill"
      elseif Qready and IsWReady() and Iready and aca + bca + cca + cca + dca + bda > _ca.health then
        KillText[_ca.networkID] = "Q + R + W + Ignite = kill"
      elseif Qready and Rready and IsWReady() and Eready and aca + bca + cca + cca + dca + ada > _ca.health then
        KillText[_ca.networkID] = "Q + R + W + E = kill"
      elseif IsWReady() and Qready and Rready and Eready and aca + cca + dca + _da + ada > _ca.health then
        KillText[_ca.networkID] = "Q + W + R + E = kill"
      elseif Qready and Rready and Eready and IsWReady() and Iready and aca + bca + cca + cca + dca + ada + bda > _ca.health then
        KillText[_ca.networkID] = "Q + R + W + E + Ignite = kill"
      elseif Qready and Rready and Eready and IsWReady() and Iready and aca + cca + dca + _da + ada + bda > _ca.health then
        KillText[_ca.networkID] = "Q + W + R + E + Ignite = kill"
      elseif Qready or IsWReady() or Eready then
        KillText[_ca.networkID] = "Harass him!"
      else
        KillText[_ca.networkID] = "Spells on CD"
      end
    end
  end
end
function getHitBoxRadius(dba)
  return GetDistance(dba.minBBox, dba.maxBBox) / 2
end
function CanPermformKillSteal()
  return Menu.killsteal.killsteal and (Menu.killsteal.killStealExcecute == 1 or Menu.killsteal.killStealExcecute == 2 and not Menu.keysettings.useCombo) or Menu.killsteal.killStealExcecute == 3 and not Menu.keysettings.useCombo and not Menu.keysettings.useLaneClear and not Menu.keysettings.useFarm and not Menu.keysettings.useHarass
end
function DrawMenu()
  Menu = scriptConfig("Totally LeBlanc - Totally Legit", "TotallyLeBlanc.cfg")
  local dba = "Totally LeBlanc  -  "
  Menu:addSubMenu(dba .. "Key Settings", "keysettings")
  Menu.keysettings:addParam("useCombo", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
  Menu.keysettings:addParam("useHarass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
  Menu.keysettings:addParam("useLaneClear", "LaneClear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
  Menu.keysettings:addParam("useFarm", "Farm Key", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
  Menu:addSubMenu(dba .. "Combo", "combo")
  Menu.combo:addParam("comboWay", "Perform Combo:", SCRIPT_PARAM_LIST, 1, {
    "Smart",
    "QRWE",
    "QWRE",
    "WQRE",
    "WRQE"
  })
  Menu.combo:addParam("comboItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
  Menu.combo:addParam("comboAA", "Use AAs", SCRIPT_PARAM_ONOFF, true)
  Menu.combo:addParam("comboGap", "Use W to GapClose", SCRIPT_PARAM_ONOFF, true)
  Menu.combo:addParam("selectedTarget", "Focus Selected Target", SCRIPT_PARAM_ONOFF, true)
  Menu.combo:addParam("forceADC", "Force ADC/APC", SCRIPT_PARAM_ONOFF, false)
  Menu:addSubMenu(dba .. "Settings: W", "settingsW")
  Menu.settingsW:addParam("useOptional", "Use Optional W Settings", SCRIPT_PARAM_ONOFF, true)
  Menu.settingsW:addParam("useOptionalW", "Return: ", SCRIPT_PARAM_LIST, 1, {
    "Smart",
    "Target dead",
    "Skills used",
    "Both"
  })
  Menu:addSubMenu(dba .. "Harass", "harass")
  Menu.harass:addParam("harassQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
  Menu.harass:addParam("harassW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, false)
  Menu.harass:addParam("harassE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
  Menu.harass:addParam("harassMana", "Mana Manager %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)
  Menu:addSubMenu(dba .. "Farming", "farm")
  Menu.farm:addParam("farmQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
  Menu.farm:addParam("farmW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
  Menu.farm:addParam("farmRange", "Minions outside AA range only", SCRIPT_PARAM_ONOFF, false)
  Menu.farm:addParam("farmAA", "Farm if AA is on CD", SCRIPT_PARAM_ONOFF, false)
  Menu:addSubMenu(dba .. "Laneclear", "laneclear")
  Menu.laneclear:addParam("laneclearQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
  Menu.laneclear:addParam("laneclearW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
  Menu.laneclear:addParam("laneclearR", "Use " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, false)
  Menu.laneclear:addParam("laneclearWAmount", "Min minions to WR", SCRIPT_PARAM_SLICE, 5, 0, 30, 0)
  Menu.laneclear:addParam("laneclearRAmount", "Min minions to WR", SCRIPT_PARAM_SLICE, 5, 0, 30, 0)
  Menu.laneclear:addParam("laneclearWRAmount", "Min minions to W and WR", SCRIPT_PARAM_SLICE, 5, 0, 30, 0)
  Menu:addSubMenu(dba .. "KillSteal", "killsteal")
  Menu.killsteal:addParam("killsteal", "Use KillSteal", SCRIPT_PARAM_ONOFF, true)
  Menu.killsteal:addParam("killStealExcecute", "Excecute", SCRIPT_PARAM_LIST, 1, {
    "Always",
    "Not in Combo",
    "No other mode active"
  })
  Menu.killsteal:addParam("killstealGap", "GapClose to kill enemy", SCRIPT_PARAM_ONOFF, false)
  Menu.killsteal:addParam("killstealQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
  Menu.killsteal:addParam("killstealW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
  Menu.killsteal:addParam("killstealR", "Use " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, false)
  Menu.killsteal:addParam("killstealQR", "Gapclose > Q + R", SCRIPT_PARAM_ONOFF, true)
  Menu.killsteal:addSubMenu("KillSteal Enemy", "enemies")
  for _ca, aca in pairs(GetEnemyHeroes()) do
    if aca and table.contains(priorityTable.Support, aca.charName) or table.contains(priorityTable.AD_Carry, aca.charName) or table.contains(priorityTable.AP, aca.charName) then
      Menu.killsteal.enemies:addParam(aca.charName, aca.charName, SCRIPT_PARAM_ONOFF, true)
    else
      Menu.killsteal.enemies:addParam(aca.charName, aca.charName, SCRIPT_PARAM_ONOFF, false)
    end
  end
  Menu:addSubMenu(dba .. "YOLO", "yolo")
  Menu.yolo:addParam("useYolo", "Use Yolo", SCRIPT_PARAM_ONOFF, true)
  Menu.yolo:addParam("info52", "Info", SCRIPT_PARAM_INFO, "All-in when ignited")
  Menu.yolo:addParam("info53", "Info:", SCRIPT_PARAM_INFO, "and will kill me")
  Menu:addSubMenu(dba .. "Drawings", "drawings")
  Menu.drawings:addSubMenu("Lag-Free Circles", "lfc")
  Menu.drawings.lfc:addParam("useLFC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, false)
  Menu.drawings.lfc:addParam("CL", "Length before Snapping", SCRIPT_PARAM_SLICE, 300, 75, 2000, 0)
  Menu.drawings:addParam("draw", "Use Drawings", SCRIPT_PARAM_ONOFF, true)
  Menu.drawings:addParam("drawQ", "Draw " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
  Menu.drawings:addParam("drawW", "Draw " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
  Menu.drawings:addParam("drawE", "Draw " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
  Menu.drawings:addParam("drawKillable", "Draw Killable Text", SCRIPT_PARAM_ONOFF, true)
  Menu.drawings:addParam("drawKillableWidth", "Draw Killable Width", SCRIPT_PARAM_SLICE, 10, 5, 20, 0)
  Menu.drawings:addParam("drawTarget", "Draw Target", SCRIPT_PARAM_ONOFF, true)
  Menu.drawings:addParam("drawSpellReady", "Don't draw if spell is CD", SCRIPT_PARAM_ONOFF, false)
  Menu:addSubMenu(dba .. "Prediction", "prediction")
  if caa and daa and bba then
    Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 2, {
      "VPrediction",
      "DivinePrediction",
      "HPrediction"
    })
    Menu.prediction:addParam("usePredictionVPred", "VPrediction HitChance", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
    Menu.prediction:addParam("usePredictionHPred", "HPrediction HitChance", SCRIPT_PARAM_SLICE, 1, 1, 3, 2)
    Menu.prediction:addParam("usePredictionDPred", "DivinePred HitChance", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
  elseif caa and not daa and bba then
    Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 2, {
      "VPrediction",
      "DivinePrediction"
    })
    Menu.prediction:addParam("usePredictionVPred", "VPrediction HitChance", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
    Menu.prediction:addParam("usePredictionDPred", "DivinePred HitChance", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
  elseif daa and not caa and bba then
    Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 2, {
      "VPrediction",
      "HPrediction"
    })
    Menu.prediction:addParam("usePredictionVPred", "VPrediction HitChance", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
    Menu.prediction:addParam("usePredictionHPred", "HPrediction HitChance", SCRIPT_PARAM_SLICE, 1, 1, 3, 2)
  elseif daa and caa and not bba then
    Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 2, {
      "DivinePrediction",
      "HPrediction"
    })
    Menu.prediction:addParam("usePredictionDPred", "DivinePred HitChance", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
    Menu.prediction:addParam("usePredictionHPred", "HPrediction HitChance", SCRIPT_PARAM_SLICE, 1, 1, 3, 2)
  elseif bba and not caa and not daa then
    Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 1, {
      "VPrediction"
    })
    Menu.prediction:addParam("usePredictionVPred", "VPrediction HitChance", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
  elseif not bba and caa and not daa then
    Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 1, {
      "DivinePrediction"
    })
    Menu.prediction:addParam("usePredictionDPred", "DivinePred HitChance", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
  elseif not bba and not caa and daa then
    Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 1, {
      "HPrediction"
    })
    Menu.prediction:addParam("usePredictionHPred", "HPrediction HitChance", SCRIPT_PARAM_SLICE, 1, 1, 3, 2)
  elseif not bba and not caa and not daa then
    Menu.prediction:addParam("usePrediction", "Prediction Type", SCRIPT_PARAM_LIST, 1, {
      "No Predictions found"
    })
  end
  Menu:addSubMenu(dba .. "Misc", "misc")
  Menu.misc:addSubMenu("Auto Level", "autolevel")
  Menu.misc.autolevel:addParam("useAutoLevel", "Use Auto Level", SCRIPT_PARAM_ONOFF, false)
  Menu.misc.autolevel:addParam("sequence", "What to max?", SCRIPT_PARAM_LIST, 1, {"Q-W-R-E", "W-Q-R-E"})
  if ignite ~= nil then
    Menu.misc:addSubMenu("Auto Ignite", "autoignite")
    Menu.misc.autoignite:addParam("useIgnite", "Use Summoner Ignite", SCRIPT_PARAM_ONOFF, true)
    for _ca, aca in ipairs(GetEnemyHeroes()) do
      Menu.misc.autoignite:addParam(aca.charName, "Use Ignite On " .. aca.charName, SCRIPT_PARAM_ONOFF, true)
    end
  end
  Menu.misc:addSubMenu("Zhyonas", "zhonyas")
  Menu.misc.zhonyas:addParam("zhonyas", "Auto Zhonyas", SCRIPT_PARAM_ONOFF, true)
  Menu.misc.zhonyas:addParam("zhonyasunder", "Use Zhonyas under % health", SCRIPT_PARAM_SLICE, 0.2, 0, 1, 2)
  Menu.misc:addSubMenu("Auto Ignite Potion", "counterLogic")
  Menu.misc.counterLogic:addParam("usePotion", "Drink Health Pot when Ignited", SCRIPT_PARAM_ONOFF, true)
  Menu:addSubMenu(dba .. "OrbWalker", "orbwalker")
  Menu:addSubMenu(dba .. "TargetSelector Modes", "tsmodes")
  Menu.tsmodes:addTS(ts)
  Menu.tsmodes:addTS(tsLong)
  Menu:addParam("info2", "Author", SCRIPT_PARAM_INFO, _G.LeBlanc_Author)
  Menu:addParam("info", "Version", SCRIPT_PARAM_INFO, _G.LeBlanc_ScriptVersion)
  Menu.keysettings:permaShow("useCombo")
  Menu.keysettings:permaShow("useHarass")
  Menu.keysettings:permaShow("useLaneClear")
  Menu.keysettings:permaShow("useFarm")
  Menu.killsteal:permaShow("killsteal")
  Menu.drawings:permaShow("draw")
end
function Summoners()
  heal = (not myHero:GetSpellData(SUMMONER_1).name:find("summonerheal") or not SUMMONER_1) and myHero:GetSpellData(SUMMONER_2).name:find("summonerheal") and SUMMONER_2
  ignite = (not myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") or not SUMMONER_1) and myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2
end
function Checks()
  Qready = myHero:CanUseSpell(_Q) == READY
  Wready = myHero:CanUseSpell(_W) == READY
  Eready = myHero:CanUseSpell(_E) == READY
  Rready = myHero:CanUseSpell(_R) == READY
  Hready = heal ~= nil and myHero:CanUseSpell(heal) == READY
  Iready = ignite ~= nil and myHero:CanUseSpell(ignite) == READY
  if Menu.drawings.lfc.useLFC then
    _G.DrawCircle = DrawCircle2
  else
    _G.DrawCircle = _G.oldDrawCircle
  end
  if not Rready and (canCastSpells == false or RSkill ~= nil) then
    canCastSpells = true
    RSkill = nil
  end
  enemyMinions:update()
  target = GetOrbTarget()
  CalcDamage()
  CheckForcedTarget()
end
function ReturnBestTargetPosition(dba, _ca)
  local aca, bca, cca = 0, {}, nil
  local dca = _ca and _ca * _ca or myHero.range * myHero.range
  for _da, ada in ipairs(GetEnemyHeroes()) do
    if dca >= GetDistanceSqr(ada, myHero) then
      bca = {}
      table.insert(bca, ada.charName)
      aca = 0
      for bda, cda in ipairs(GetEnemyHeroes()) do
        if ada ~= cda and GetDistance(cda, ada) < Spells.W.radius then
          aca = aca + 1
          table.insert(bca, cda.charName)
        end
      end
      if dba <= aca then
        cca = ada.pos
        break
      end
    end
  end
  return cca, bca, aca
end
function GetBestAOEPosition(dba, _ca, aca, bca)
  assert(dba and type(dba) == "table", "Totally LeBlanc: Invalid Objects in function GetBestAOEPosition")
  local cca
  local dca = 0
  local _da = bca or myHero
  local ada = _ca and _ca * _ca or myHero
  for bda, cda in ipairs(dba) do
    if ada > GetDistanceSqr(cda, _da) then
      local dda = 0
      for __b, a_b in ipairs(dba) do
        if GetDistanceSqr(a_b, cda) <= aca * aca then
          dda = dda + 1
        end
      end
      if dca < dda then
        dca = dda
        cca = cda.pos
      end
    end
  end
  return cca, dca
end
function GetKillableMinions(dba, _ca, aca, bca)
  assert(aca == _Q or aca == _W or aca == _E, "Totally LeBlanc: Correct spell not detected")
  assert(dba and type(dba) == "table", "Totally LeBlanc: Invalid table in: minionTable, first parameter")
  local cca = _ca and _ca * _ca or myHero.range * myHero.range
  local dca = {}
  local _da = bca or myHero
  local ada = 0
  for bda, cda in ipairs(dba) do
    if cca > GetDistanceSqr(cda) then
      if aca == _Q then
        ada = getDmg("Q", cda, _da)
      end
      if aca == _W then
        ada = getDmg("W", cda, _da)
      end
      if aca == _E then
        ada = getDmg("E", cda, _da)
      end
      if ada > cda.health then
        table.insert(dca, cda)
      end
    end
  end
  return dca
end
function AllyHeroInRange(dba, _ca)
  _ca = _ca or myHero
  dba = dba and dba * dba or myHero.range * myHero.range
  local aca = 0
  for i = 1, heroManager.iCount do
    local bca = heroManager:getHero(i)
    if bca.team == _ca.team and dba >= GetDistanceSqr(_ca, bca) then
      aca = aca + 1
    end
  end
  return aca
end
function GetWPrediction(dba)
  local _ca
  if VPredictionLoaded() then
    local aca, bca, cca = cba:IsDashing(dba, Spells.W.delay, Spells.W.radius, Spells.W.speed, myHero)
    if aca and bca then
      _ca = cca
    else
      _ca = cba:GetCircularCastPosition(dba, Spells.W.delay, Spells.W.radius, Spells.W.range, Spells.W.speed)
    end
  elseif DivinePredLoaded() then
    local aca
    if divinePredictionTargetTable[dba.networkID] ~= nil then
      aca = divinePredictionTargetTable[dba.networkID]
    end
    if aca then
      local bca, cca, dca = DP:predict(aca, wSS)
      if bca and bca == SkillShot.STATUS.SUCCESS_HIT and cca ~= nil then
        _ca = cca
      end
    end
  elseif HPredMenuLoaded() then
    _ca = aba:GetPredict(HP_W, dba, myHero)
  end
  return _ca
end
function GetEPrediction(dba)
  local _ca
  if VPredictionLoaded() then
    local aca, bca, cca = cba:IsDashing(dba, Spells.E.delay, Spells.E.radius, Spells.E.speed, myHero)
    if aca and bca then
      _ca = cca
    else
      local dca, _da = cba:GetLineCastPosition(dba, Spells.E.delay, Spells.E.radius, Spells.E.range + 150, Spells.E.speed, myHero, true)
      if _da >= Menu.prediction.usePredictionVPred then
        _ca = dca
      end
    end
  elseif DivinePredLoaded() then
    local aca
    if divinePredictionTargetTable[dba.networkID] ~= nil then
      aca = divinePredictionTargetTable[dba.networkID]
    end
    if aca then
      local bca, cca, dca = DP:predict(aca, eSS)
      if bca and bca == SkillShot.STATUS.SUCCESS_HIT and cca ~= nil and dca >= Menu.prediction.usePredictionDPred then
        _ca = cca
      end
    end
  elseif HPredMenuLoaded() then
    local aca, bca = aba:GetPredict(HP_E, dba, myHero)
    if aca and bca >= Menu.prediction.usePredictionHPred then
      _ca = aca
    end
  end
  return _ca
end
function VPredictionLoaded()
  return bba and Menu.prediction.usePrediction == 1
end
function DivinePredLoaded()
  return bba and caa and Menu.prediction.usePrediction == 2 or not bba and not daa and caa and Menu.prediction.usePrediction == 1
end
function HPredMenuLoaded()
  return daa and caa and bba and Menu.prediction.usePrediction == 3 or daa and caa and not bba and Menu.prediction.usePrediction == 1 or bba and daa and not caa and Menu.prediction.usePrediction == 2
end
function CastQ(dba)
  if dba ~= nil and not dba.dead and dba.visible and GetDistanceSqr(dba) <= Spells.Q.range * Spells.Q.range and dba.type and (dba.type == myHero.type or dba.type == "obj_AI_Minion") and Qready then
    CastSpell(_Q, dba)
    return true
  end
  return false
end
function CastW(dba, _ca)
  local aca = Spells.W.range + 175
  local bca = aca * aca
  if not _ca then
    if dba and bca >= GetDistanceSqr(dba) then
      if dba.type and dba.type == myHero.type then
        if IsWReady() then
          if lastQCast.target and lastQCast.target.networkID == dba.networkID then
            local _da = os.clock()
            local ada = Spells.W.speed
            local bda = Spells.W.delay
            local cda = GetDistance(dba)
            local dda = cda / Spells.W.speed + bda
            local __b = _da + dda
            if lastQCast.endT and __b < lastQCast.endT then
              return false
            end
          end
          local cca, dca = GetWPrediction(dba)
          if cca ~= nil and (not _G.Evadeee_Loaded or not _G.Evadeee_IsDangerous(Point(cca.x, cca.z)) or getDmg("W", dba, myHero) >= dba.health) then
            CastSpell(_W, cca.x, cca.z)
            return true
          end
        end
      elseif dba.type == "obj_AI_Minion" then
        CastSpell(_W, dba.pos.x, dba.pos.z)
        return true
      end
    end
  elseif IsWReady() and (not _G.Evadeee_Loaded or not _G.Evadeee_IsDangerous(Point(dba, _ca))) and GetDistance(Point(dba, _ca)) <= Spells.W.range then
    CastSpell(_W, dba, _ca)
    return true
  end
  return false
end
function GapClose(dba)
  if IsWReady() and dba and dba.type and dba.type == myHero.type and HasManaToGapClose() then
    local _ca = Vector(myHero) + (Vector(dba) - myHero):normalized() * Spells.W.range
    if not UnderTurret(_ca, true) and (not _G.Evadeee_Loaded or not _G.Evadeee_IsDangerous(Point(_ca.x, _ca.z))) then
      CastSpell(_W, _ca.x, _ca.z)
      return true
    end
  end
  return false
end
function IsWReady()
  return Wready and not wUsed()
end
function HasManaToGapClose()
  local dba = myHero:GetSpellData(_Q).level * 10 + 40
  local _ca = myHero:GetSpellData(_W).level * 5 + 75
  local aca = 80
  return Qready and dba + _ca < myHero.mana or Eready and aca + _ca < myHero.mana
end
function CastE(dba)
  if dba and not dba.dead and GetDistanceSqr(dba) <= Spells.E.range * Spells.E.range and dba.type and (dba.type == myHero.type or dba.type == "obj_AI_Minion") and Eready then
    local _ca = GetEPrediction(dba)
    if _ca ~= nil then
      CastSpell(_E, _ca.x, _ca.z)
      return true
    end
  end
  return false
end
function wUsed()
  return myHero:GetSpellData(_W).name and myHero:GetSpellData(_W).name == "leblancslidereturn"
end
function wrUsed()
  return myHero:GetSpellData(_W).name and myHero:GetSpellData(_R).name == "leblancslidereturnm"
end
function SpellDmgCalculations(dba, _ca)
  local aca = 0
  if dba == "Q" and myHero:GetSpellData(_Q).level >= 1 then
    aca = 25 * myHero:GetSpellData(_Q).level + 30 + 0.4 * myHero.ap
  elseif dba == "W" and 1 <= myHero:GetSpellData(_W).level then
    aca = 40 * myHero:GetSpellData(_W).level + 45 + 0.6 * myHero.ap
  elseif dba == "E" and 1 <= myHero:GetSpellData(_E).level then
    aca = 25 * myHero:GetSpellData(_E).level + 15 + 0.5 * myHero.ap
  elseif dba == "RQ" and 1 <= myHero:GetSpellData(_R).level then
    aca = 100 * myHero:GetSpellData(_R).level + 0.65 * myHero.ap
  elseif dba == "RW" and 1 <= myHero:GetSpellData(_R).level then
    aca = 150 * myHero:GetSpellData(_R).level + 0.975 * myHero.ap
  elseif dba == "RE" and 1 <= myHero:GetSpellData(_R).level then
    aca = 100 * myHero:GetSpellData(_W).level + 0.65 * myHero.ap
  elseif dba == "QProc" then
    aca = 25 * myHero:GetSpellData(_Q).level + 30 + 0.4 * myHero.ap
  end
  aca = myHero:CalcMagicDamage(_ca, aca)
  return aca and aca or 0
end
function DrawCircleNextLvl(dba, _ca, aca, bca, cca, dca, _da)
  bca = bca or 300
  quality = math.max(8, round(180 / math.deg((math.asin(_da / (2 * bca))))))
  quality = 2 * math.pi / quality
  bca = bca * 0.92
  local ada = {}
  for theta = 0, 2 * math.pi + quality, quality do
    local bda = WorldToScreen(D3DXVECTOR3(dba + bca * math.cos(theta), _ca, aca - bca * math.sin(theta)))
    ada[#ada + 1] = D3DXVECTOR2(bda.x, bda.y)
  end
  DrawLines2(ada, cca or 1, 4294967295)
end
function round(dba)
  if dba >= 0 then
    return math.floor(dba + 0.5)
  else
    return math.ceil(dba - 0.5)
  end
end
function DrawCircle2(dba, _ca, aca, bca, cca)
  local dca = Vector(dba, _ca, aca)
  local _da = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local ada = dca - (dca - _da):normalized() * bca
  local bda = WorldToScreen(D3DXVECTOR3(ada.x, ada.y, ada.z))
  if OnScreen({
    x = bda.x,
    y = bda.y
  }, {
    x = bda.x,
    y = bda.y
  }) then
    DrawCircleNextLvl(dba, _ca, aca, bca, 1, cca, Menu.drawings.lfc.CL)
  end
end
function OnWndMsg(dba, _ca)
  if dba == WM_LBUTTONDOWN and Menu.combo.selectedTarget then
    local aca
    for bca, cca in pairs(GetEnemyHeroes()) do
      if cca and cca.visible and not cca.dead and ValidTarget(cca) and GetDistanceSqr(cca, mousePos) <= 40000 then
        aca = cca
      end
    end
    if aca and GetDistanceSqr(aca, mousePos) < 40000 then
      if forcedTarget and aca.networkID == forcedTarget.networkID then
        forcedTarget = nil
        Say("Deselected target: " .. aca.charName)
      else
        forcedTarget = aca
        Say("Selected target: " .. aca.charName)
        forcedTargetTime = os.clock()
      end
    end
  end
end
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQINAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBBkBAAB2AgAAIAACCHwCAAAUAAAAEBgAAAGNsYXNzAAQIAAAAVHJhY2tlcgAEBwAAAF9faW5pdAAECgAAAFVwZGF0ZVdlYgAEGgAAAGNvdW50aW5nSG93TXVjaFVzZXJzSWhhdmUAAgAAAAEAAAADAAAAAQAFCAAAAEwAQADDAIAAAUEAAF1AAAJGgEAApQAAAF1AAAEfAIAAAwAAAAQKAAAAVXBkYXRlV2ViAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAAAgAAAAMAAAAAAAQGAAAABQAAAAwAQACDAAAAwUAAAB1AAAIfAIAAAgAAAAQKAAAAVXBkYXRlV2ViAAMAAAAAAADwPwAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAYAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAAAAAAAAQAAAAUAAABzZWxmAAEAAAAAABAAAABAb2JmdXNjYXRlZC5sdWEACAAAAAEAAAABAAAAAQAAAAEAAAACAAAAAwAAAAIAAAADAAAAAQAAAAUAAABzZWxmAAAAAAAIAAAAAQAAAAUAAABfRU5WAAQAAAALAAAAAwAKIwAAAMYAQAABQQAA3YAAAQaBQABHwcABXQGAAB2BAABMAUECwUEBAAGCAQBdQQACWwAAABeAAYBMwUECwQECAAACAAFBQgIA1kGCA11BgAEXQAGATMFBAsGBAgAAAgABQUICANZBggNdQYABTIFDAsHBAwBdAYEBCMCBhgiAAYYIQIGFTAFEAl1BAAEfAIAAEQAAAAQIAAAAcmVxdWlyZQAEBwAAAHNvY2tldAAEBwAAAGFzc2VydAAEBAAAAHRjcAAECAAAAGNvbm5lY3QABBQAAABtYWlraWU2MS5zaW5uZXJzLmJlAAMAAAAAAABUQAQFAAAAc2VuZAAEKwAAAEdFVCAvdHJhY2tlci9pbmRleC5waHAvdXBkYXRlL2luY3JlYXNlP2lkPQAEKQAAACBIVFRQLzEuMA0KSG9zdDogbWFpa2llNjEuc2lubmVycy5iZQ0KDQoABCsAAABHRVQgL3RyYWNrZXIvaW5kZXgucGhwL3VwZGF0ZS9kZWNyZWFzZT9pZD0ABAIAAABzAAQHAAAAc3RhdHVzAAQIAAAAcGFydGlhbAAECAAAAHJlY2VpdmUABAMAAAAqYQAEBgAAAGNsb3NlAAAAAAABAAAAAAAQAAAAQG9iZnVzY2F0ZWQubHVhACMAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAcAAAAHAAAACAAAAAgAAAAJAAAACQAAAAkAAAAIAAAACQAAAAoAAAAKAAAACwAAAAsAAAALAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAUAAAAFAAAAc2VsZgAAAAAAIwAAAAIAAABhAAAAAAAjAAAAAgAAAGIAAAAAACMAAAACAAAAYwADAAAAIwAAAAIAAABkAAcAAAAjAAAAAQAAAAUAAABfRU5WAAEAAAABABAAAABAb2JmdXNjYXRlZC5sdWEADQAAAAEAAAABAAAAAQAAAAEAAAADAAAAAQAAAAQAAAALAAAABAAAAAsAAAALAAAACwAAAAsAAAAAAAAAAQAAAAUAAABfRU5WAA=="), nil, "bt", _ENV))()
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()
ScriptStatus("XKNLLQLPRMN")
class("SxScriptUpdate")
function SxScriptUpdate:__init(dba, _ca, aca, bca, cca, dca, _da, ada, bda, cda)
  self.LocalVersion = dba
  self.Host = aca
  self.VersionPath = "/BoL/TCPUpdater/GetScript" .. (_ca and "5" or "6") .. ".php?script=" .. self:Base64Encode(self.Host .. bca) .. "&rand=" .. math.random(99999999)
  self.ScriptPath = "/BoL/TCPUpdater/GetScript" .. (_ca and "5" or "6") .. ".php?script=" .. self:Base64Encode(self.Host .. cca) .. "&rand=" .. math.random(99999999)
  self.SavePath = dca
  self.CallbackUpdate = _da
  self.CallbackNoUpdate = ada
  self.CallbackNewVersion = bda
  self.CallbackError = cda
  AddDrawCallback(function()
    self:OnDraw()
  end)
  self:CreateSocket(self.VersionPath)
  self.DownloadStatus = "Connect to Server for VersionInfo"
  AddTickCallback(function()
    self:GetOnlineVersion()
  end)
end
function SxScriptUpdate:print(dba)
  print("<font color=\"#FFFFFF\">" .. os.clock() .. ": " .. dba)
end
function SxScriptUpdate:OnDraw()
  if self.DownloadStatus ~= "Downloading Script (100%)" and self.DownloadStatus ~= "Downloading VersionInfo (100%)" then
    DrawText("Download Status: " .. (self.DownloadStatus or "Unknown"), 50, 10, 50, ARGB(255, 255, 255, 255))
  end
end
function SxScriptUpdate:CreateSocket(dba)
  if not self.LuaSocket then
    self.LuaSocket = require("socket")
  else
    self.Socket:close()
    self.Socket = nil
    self.Size = nil
    self.RecvStarted = false
  end
  self.Socket = self.LuaSocket.tcp()
  self.Socket:settimeout(0, "b")
  self.Socket:settimeout(99999999, "t")
  self.Socket:connect("sx-bol.eu", 80)
  self.Url = dba
  self.Started = false
  self.LastPrint = ""
  self.File = ""
end
function SxScriptUpdate:Base64Encode(dba)
  local _ca = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  return (dba:gsub(".", function(aca)
    local bca, cca = "", aca:byte()
    for i = 8, 1, -1 do
      bca = bca .. (cca % 2 ^ i - cca % 2 ^ (i - 1) > 0 and "1" or "0")
    end
    return bca
  end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(aca)
    if #aca < 6 then
      return ""
    end
    local bca = 0
    for i = 1, 6 do
      bca = bca + (aca:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
    end
    return _ca:sub(bca + 1, bca + 1)
  end) .. ({
    "",
    "==",
    "="
  })[#dba % 3 + 1]
end
function SxScriptUpdate:GetOnlineVersion()
  if self.GotScriptVersion then
    return
  end
  self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
  if self.Status == "timeout" and not self.Started then
    self.Started = true
    self.Socket:send("GET " .. self.Url .. " HTTP/1.0\r\nHost: sx-bol.eu\r\nUser-Agent: hDownload\r\n\r\n")
  end
  self.File = self.File .. (self.Receive or self.Snipped)
  if self.File:find("</s" .. "ize>") then
    if not self.Size then
      self.Size = tonumber(self.File:sub(self.File:find("<si" .. "ze>") + 6, self.File:find("</si" .. "ze>") - 1))
    end
    if self.File:find("<scr" .. "ipt>") then
      local dba, _ca = self.File:find("<scr" .. "ipt>")
      local aca = self.File:find("</scr" .. "ipt>")
      aca = aca and aca - 1
      local bca = self.File:sub(_ca + 1, aca or -1):len()
      self.DownloadStatus = "Downloading VersionInfo (" .. math.round(100 / self.Size * bca, 2) .. "%)"
    end
  end
  if self.File:find("</scr" .. "ipt>") or self.Status == "closed" then
    local dba, _ca = self.File:find("<scr" .. "ipt>")
    local aca, bca = self.File:find("</sc" .. "ript>")
    if not _ca or not aca then
      if self.CallbackError and type(self.CallbackError) == "function" then
        self.CallbackError()
      end
    else
      self.OnlineVersion = Base64Decode(self.File:sub(_ca + 1, aca - 1))
      self.OnlineVersion = tonumber(self.OnlineVersion)
      if not self.OnlineVersion then
        if self.CallbackError and type(self.CallbackError) == "function" then
          self.CallbackError()
        end
      elseif self.OnlineVersion > self.LocalVersion then
        if self.CallbackNewVersion and type(self.CallbackNewVersion) == "function" then
          self.CallbackNewVersion(self.OnlineVersion, self.LocalVersion)
        end
        self:CreateSocket(self.ScriptPath)
        self.DownloadStatus = "Connect to Server for ScriptDownload"
        AddTickCallback(function()
          self:DownloadUpdate()
        end)
      elseif self.CallbackNoUpdate and type(self.CallbackNoUpdate) == "function" then
        self.CallbackNoUpdate(self.LocalVersion)
      end
    end
    self.GotScriptVersion = true
  end
end
function SxScriptUpdate:DownloadUpdate()
  if self.GotSxScriptUpdate then
    return
  end
  self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
  if self.Status == "timeout" and not self.Started then
    self.Started = true
    self.Socket:send("GET " .. self.Url .. " HTTP/1.0\r\nHost: sx-bol.eu\r\n\r\n")
  end
  if (self.Receive or #self.Snipped > 0) and not self.RecvStarted then
    self.RecvStarted = true
    self.DownloadStatus = "Downloading Script (0%)"
  end
  self.File = self.File .. (self.Receive or self.Snipped)
  if self.File:find("</si" .. "ze>") then
    if not self.Size then
      self.Size = tonumber(self.File:sub(self.File:find("<si" .. "ze>") + 6, self.File:find("</si" .. "ze>") - 1))
    end
    if self.File:find("<scr" .. "ipt>") then
      local dba, _ca = self.File:find("<scr" .. "ipt>")
      local aca = self.File:find("</scr" .. "ipt>")
      aca = aca and aca - 1
      local bca = self.File:sub(_ca + 1, aca or -1):len()
      self.DownloadStatus = "Downloading Script (" .. math.round(100 / self.Size * bca, 2) .. "%)"
    end
  end
  if self.File:find("</scr" .. "ipt>") or self.Status == "closed" then
    local dba, _ca = self.File:find("<sc" .. "ript>")
    local aca, bca = self.File:find("</scr" .. "ipt>")
    if not _ca or not aca then
      if self.CallbackError and type(self.CallbackError) == "function" then
        self.CallbackError()
      end
    else
      local cca = self.File:sub(_ca + 1, aca - 1)
      local dca = cca:gsub("\r", "")
      if dca:len() ~= self.Size then
        if self.CallbackError and type(self.CallbackError) == "function" then
          self.CallbackError()
        end
        self.GotSxScriptUpdate = true
        return
      end
      local _da = Base64Decode(dca)
      if type(load(_da)) ~= "function" then
        if self.CallbackError and type(self.CallbackError) == "function" then
          self.CallbackError()
        end
      else
        local ada = io.open(self.SavePath, "w+b")
        ada:write(_da)
        ada:close()
        if self.CallbackUpdate and type(self.CallbackUpdate) == "function" then
          self.CallbackUpdate(self.OnlineVersion, self.LocalVersion)
        end
      end
    end
    self.GotSxScriptUpdate = true
  end
end
