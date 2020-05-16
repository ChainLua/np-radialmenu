ESX           = nil
local isJudge = false
local isPolice = false
local isMedic = false
local isDoctor = false
local isNews = false
local isDead = false
local isInstructorMode = false
local myJob = "unemployed"
local isHandcuffed = false
local isHandcuffedAndWalking = false
local hasOxygenTankOn = false
local gangNum = 0
local cuffStates = {}
local PlayerData = {}

--[[RegisterNetEvent("np-jobmanager:playerBecameJob")
AddEventHandler("np-jobmanager:playerBecameJob", function(job, name, notify)
    if isMedic and job ~= "ems" then isMedic = false end
    if isPolice and job ~= "police" then isPolice = false end
    if isDoctor and job ~= "doctor" then isDoctor = false end
    if isNews and job ~= "news" then isNews = false end
    if job == "police" then isPolice = true end
    if job == "ems" then isMedic = true end
    if job == "news" then isNews = true end
    if job == "doctor" then isDoctor = true end
    myJob = job
end)--]]

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    local job = PlayerData.job.name
    myJob = job
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
    local job = PlayerData.job.name
    myJob = job
end)

rootMenuConfig =  {
    {
        id = "keys",
        displayName = "מפתחות",
        icon = "#keysmenu",
        functionName = "cl-keys:menu",
        enableMenu = function()
            return not isDead
        end
    },
    {
        id = "taxi-bill",
        displayName = "שלח-חשבונית",
        icon = "#taxi-logo",
        functionName = "esx_taxijob:bill_menu",
        enableMenu = function()
            return ESX.GetPlayerData().job.name == 'taxi' and not isDead
        end
    },
    {
        id = "clothes",
        displayName = "אביזרים",
        icon = "#mask",
        enableMenu = function()
            return not isDead
        end,
        subMenus = {"clothes:mask", "clothes:hat", "clothes:glasses", "clothes:shoes"}
    },
    {
        id = "walking",
        displayName = "הליכות",
        icon = "#walking",
        enableMenu = function()
            return not isDead
        end,
        subMenus = { "animations:brave", "animations:hurry", "animations:business", "animations:tipsy", "animations:injured","animations:tough", "animations:default", "animations:hobo", "animations:money", "animations:swagger", "animations:shady", "animations:maneater", "animations:chichi", "animations:sassy", "animations:sad", "animations:posh", "animations:alien" }
    },
    {
        id = "emotes",
        displayName = "אנימציות",
        icon = "#dance",
        enableMenu = function()
            return not isDead
        end,
        subMenus = { "anim:id", "anim:getup", "anim:search", "anim:boxing", "anim:bark", "anim:shower", "anim:desk", "anim:look", "anim:taxi", "anim:sit"}
    },
    {
        id = "expressions",
        displayName = "הבעות-פנים",
        icon = "#expressions",
        enableMenu = function()
            return not isDead
        end,
        subMenus = { "expressions:normal", "expressions:drunk", "expressions:angry", "expressions:dumb", "expressions:electrocuted", "expressions:grumpy", "expressions:happy", "expressions:injured", "expressions:joyful", "expressions:mouthbreather", "expressions:oneeye", "expressions:shocked", "expressions:sleeping", "expressions:smug", "expressions:speculative", "expressions:stressed", "expressions:sulking", "expressions:weird", "expressions:weird2"}
    },
    {
        id = "mdt",
        displayName = "מאגר-משטרתי",
        icon = "#mdt",
        functionName = "mdt:Open",
        enableMenu = function()
            return (ESX.GetPlayerData().job.name == 'police' and not isDead)
        end
    },
    {
        id = "trunk",
        displayName = "באגז",
        icon = "#vehicle-options-vehicle",
        enableMenu = function()
            local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
            local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 6.0, 0, 71)
            return not IsPedInAnyVehicle(PlayerPedId(), true) and DoesEntityExist(vehicle) and not isDead
        end,
        subMenus = {"trunk:stash","trunk:enter","trunk:leave"}
    },
    {
        id = "medic",
        displayName = "מדא",
        icon = "#medic",
        enableMenu = function()
            return (ESX.GetPlayerData().job.name == 'ambulance' and not isDead)
        end,
        subMenus = {"medic:revive", "medic:heal", "general:putinvehicle", "general:unseatnearest"}
    },
    {
        id = "police-action",
        displayName = "משטרה",
        icon = "#police-action",
        enableMenu = function()
            return (ESX.GetPlayerData().job.name == 'police' and not isDead)
        end,
        subMenus = {"police:cuff", "cuffs:uncuff", "cuffs:checkinventory", "general:escort",  "general:unseatnearest", "general:putinvehicle", "police:bill", "police:impound", "general:flipvehicle"}
    },
    {
        id = "bloods-action",
        displayName = "בלאדס",
        icon = "#animation-business",
        enableMenu = function()
            return (ESX.GetPlayerData().job.name == 'bloods' and not isDead)
        end,
        subMenus = {"gang:cuff", "gang:uncuff", "cuffs:checkinventory", "general:escort", "general:unseatnearest", "general:putinvehicle"}
    },
    {
        id = "crips-action",
        displayName = "קריפס",
        icon = "#animation-business",
        enableMenu = function()
            return (ESX.GetPlayerData().job.name == 'crips' and not isDead)
        end,
        subMenus = {"gang:cuff", "gang:uncuff", "cuffs:checkinventory", "general:escort", "general:unseatnearest", "general:putinvehicle"}
    },
    {
        id = "vagos-action",
        displayName = "וואגוס",
        icon = "#animation-business",
        enableMenu = function()
            return (ESX.GetPlayerData().job.name == 'vagos' and not isDead)
        end,
        subMenus = {"gang:cuff", "gang:uncuff", "cuffs:checkinventory", "general:escort", "general:unseatnearest", "general:putinvehicle"}
    },
    {
        id = "steal",
        displayName = "שדידות",
        icon = "#cuffs",
        enableMenu = function()
            local target, distance = ESX.Game.GetClosestPlayer()
            return IsPlayerFreeAiming(PlayerId()) and not IsPedInAnyVehicle(PlayerPedId(), false) and not isDead and ESX.GetPlayerData().job.name ~= 'police' and ESX.GetPlayerData().job.name ~= 'ambulance' and target ~= -1 and distance <= 3.0
        end,
        subMenus = {"police:cuff", "cuffs:uncuff", "cuffs:checkinventory", "general:escort", "general:unseatnearest", "general:putinvehicle"}
    },
    {
        id = "news",
        displayName = "חדשות",
        icon = "#news",
        enableMenu = function()
            return ESX.GetPlayerData().job.name == 'reporter' and not isDead
        end,
        subMenus = { "news:setCamera", "news:setMicrophone", "news:setBoom" }
    },
    {
        id = "vehicle",
        displayName = "שליטה-ברכב",
        icon = "#vehicle-options-vehicle",
        functionName = "veh:options",
        enableMenu = function()
            return (not isDead and IsPedInAnyVehicle(PlayerPedId(), false))
        end
    },
    {
        id = "glov",
        displayName = "תא-כפפות",
        icon = "#cuffs",
        functionName = "gloveBox:open",
        enableMenu = function()
            return (not isDead and IsPedInAnyVehicle(PlayerPedId(), false))
        end
    },
}

newSubMenus = {
    ['anim:id'] = {
        title = "שם-בכיס",
        icon = "#pocket",
        functionName = "anim:id"
    }, 
    ['anim:getup'] = {
        title = "קם-מהמיטה",
        icon="#expressions-sleeping",
        functionName = "anim:getup"
    }, 
    ['anim:search'] = {
        title = "חיפוש",
        icon="#search-anim",
        functionName = "anim:search"
    }, 
    ['anim:boxing'] = {
        title = "מכות",
        icon="#boxing",
        functionName = "anim:boxing"
    },
    ['anim:bark'] = {
        title = "כלב",
        icon="#dog",
        functionName = "anim:bark"
    },
    ['anim:shower'] = {
        title = "מתקלח",
        icon="#shower",
        functionName = "anim:shower"
    },
    ['anim:desk'] = {
        title = "מסדר-שולחן",
        icon="#desk",
        functionName = "anim:desk"
    },
    ['anim:look'] = {
        title = "מסתכל-למטה",
        icon="#eye",
        functionName = "anim:look"
    },
    ['anim:taxi'] = {
        title = "קורא-למונית",
        icon="#finger",
        functionName = "anim:taxi"
    },
    ['anim:sit'] = {
        title = "ישיבה",
        icon="#chair",
        functionName = "e sitchair"
    },
    ['clothes:mask'] = {
        title = "מסכה",
        icon = "#mask",
        functionName = "mask"
    }, 
    ['clothes:hat'] = {
        title = "כובע",
        icon = "#hat",
        functionName = "hat"
    }, 
    ['clothes:glasses'] = {
    title = "משקפיים",
    icon = "#glasses",
    functionName = "glasses"
}, 
['clothes:shoes'] = {
    title = "אוזניות",
    icon = "#ear",
    functionName = "ear"
}, 
    ['showbank'] = {
        title = "בנק",
        icon = "#animation-money",
        functionName = "showbank"
    },  
    ['showcash'] = {
        title = "מזומן",
        icon = "#animation-money",
        functionName = "showcash"
    },  
    ['showdirty'] = {
        title = "מלוכלך",
        icon = "#animation-money",
        functionName = "showdirty"
    },  
    ['showjob'] = {
        title = "עבודה",
        icon = "#animation-money",
        functionName = "showjob"
    },  
    ['showsociety'] = {
        title = "חברה",
        icon = "#animation-money",
        functionName = "showsociety"
    },  
    ['general:emotes'] = {
        title = "Emotes",
        icon = "#general-emotes",
        functionName = "dp:RecieveMenu"
    },    
    ['general:keysgive'] = {
        title = "Give Key",
        icon = "#general-keys-give",
        functionName = "keys:give"
    },
    ['general:apartgivekey'] = {
        title = "Give Key",
        icon = "#general-apart-givekey",
        functionName = "apart:giveKey"
    },
    ['general:askfortrain'] = {
        title = "Request Train",
        icon = "#general-ask-for-train",
        functionName = "AskForTrain",
        -- enableMenu = function()
        --     for _,d in ipairs(trainstations) do
        --         if #(vector3(d[1],d[2],d[3]) - GetEntityCoords(PlayerPedId())) < 25 then
        --             return true
        --         else
        --             return false
        --         end
        --     end
        -- end
    },
    ['general:checkoverself'] = {
        title = "Examine Self",
        icon = "#general-check-over-self",
        functionName = "Evidence:CurrentDamageList"
    },
    ['general:checktargetstates'] = {
        title = "Examine Target",
        icon = "#general-check-over-target",
        functionName = "requestWounds"
    },
    ['general:checkvehicle'] = {
        title = "Examine Vehicle",
        icon = "#general-check-vehicle",
        functionName = "esx_mechanicjob:startCraft2"
    },
    ['general:escort'] = {
        title = "ליווי",
        icon = "#general-escort",
        functionName = "escortPlayer"
    },
    ['general:putinvehicle'] = {
        title = "הכנס-לרכב",
        icon = "#general-put-in-veh",
        functionName = "police:forceEnter"
    },
    ['general:unseatnearest'] = {
        title = "גרור-מהרכב",
        icon = "#general-unseat-nearest",
        functionName = "unseatPlayer"
    },    
    ['general:flipvehicle'] = {
        title = "Flip Vehicle",
        icon = "#general-flip-vehicle",
        functionName = "FlipVehicle"
    },
    ['animations:brave'] = {
        title = "אמיץ",
        icon = "#animation-brave",
        functionName = "AnimSet:Brave"
    },
    ['animations:hurry'] = {
        title = "ממהר",
        icon = "#animation-hurry",
        functionName = "AnimSet:Hurry"
    },
    ['animations:business'] = {
        title = "איש-עסקים",
        icon = "#animation-business",
        functionName = "AnimSet:Business"
    },
    ['animations:tipsy'] = {
        title = "שיכור",
        icon = "#animation-tipsy",
        functionName = "AnimSet:Tipsy"
    },
    ['animations:injured'] = {
        title = "מדמם",
        icon = "#animation-injured",
        functionName = "AnimSet:Injured"
    },
    ['animations:tough'] = {
        title = "שרירי",
        icon = "#animation-tough",
        functionName = "AnimSet:ToughGuy"
    },
    ['animations:sassy'] = {
        title = "חצוף",
        icon = "#animation-sassy",
        functionName = "AnimSet:Sassy"
    },
    ['animations:sad'] = {
        title = "עצוב",
        icon = "#animation-sad",
        functionName = "AnimSet:Sad"
    },
    ['animations:posh'] = {
        title = "מלך",
        icon = "#animation-posh",
        functionName = "AnimSet:Posh"
    },
    ['animations:alien'] = {
        title = "חייזר",
        icon = "#animation-alien",
        functionName = "AnimSet:Alien"
    },
    ['animations:nonchalant'] =
    {
        title = "קר רוח",
        icon = "#animation-nonchalant",
        functionName = "AnimSet:NonChalant"
    },
    ['animations:hobo'] = {
        title = "חושב",
        icon = "#animation-hobo",
        functionName = "AnimSet:Hobo"
    },
    ['animations:money'] = {
        title = "כסף",
        icon = "#animation-money",
        functionName = "AnimSet:Money"
    },
    ['animations:swagger'] = {
        title = "משוויץ",
        icon = "#animation-swagger",
        functionName = "AnimSet:Swagger"
    },
    ['animations:shady'] = {
        title = "גאנגסטר",
        icon = "#animation-shady",
        functionName = "AnimSet:Shady"
    },
    ['animations:maneater'] = {
        title = "קוקסינל",
        icon = "#animation-maneater",
        functionName = "AnimSet:ManEater"
    },
    ['animations:chichi'] = {
        title = "צ'י-צ'י",
        icon = "#animation-chichi",
        functionName = "AnimSet:ChiChi"
    },
    ['animations:default'] = {
        title = "רגיל",
        icon = "#animation-default",
        functionName = "AnimSet:default"
    },
    ['k9:spawn'] = {
        title = "Summon",
        icon = "#k9-spawn",
        functionName = "K9:Create"
    },
    ['k9:delete'] = {
        title = "Dismiss",
        icon = "#k9-dismiss",
        functionName = "K9:Delete"
    },
    ['k9:follow'] = {
        title = "Follow",
        icon = "#k9-follow",
        functionName = "K9:Follow"
    },
    ['k9:vehicle'] = {
        title = "Get in/out",
        icon = "#k9-vehicle",
        functionName = "K9:Vehicle"
    },
    ['k9:sit'] = {
        title = "Sit",
        icon = "#k9-sit",
        functionName = "K9:Sit"
    },
    ['k9:lay'] = {
        title = "Lay",
        icon = "#k9-lay",
        functionName = "K9:Lay"
    },
    ['k9:stand'] = {
        title = "Stand",
        icon = "#k9-stand",
        functionName = "K9:Stand"
    },
    ['k9:sniff'] = {
        title = "Sniff Person",
        icon = "#k9-sniff",
        functionName = "K9:Sniff"
    },
    ['k9:sniffvehicle'] = {
        title = "Sniff Vehicle",
        icon = "#k9-sniff-vehicle",
        functionName = "sniffVehicle"
    },
    ['k9:huntfind'] = {
        title = "Hunt nearest",
        icon = "#k9-huntfind",
        functionName = "K9:Huntfind"
    },
    ['blips:gasstations'] = {
        title = "Gas Stations",
        icon = "#blips-gasstations",
        functionName = "CarPlayerHud:ToggleGas"
    },    
    ['blips:trainstations'] = {
        title = "Train Stations",
        icon = "#blips-trainstations",
        functionName = "Trains:ToggleTainsBlip"
    },
    ['blips:garages'] = {
        title = "Garages",
        icon = "#blips-garages",
        functionName = "Garages:ToggleGarageBlip"
    },
    ['blips:barbershop'] = {
        title = "Barber Shop",
        icon = "#blips-barbershop",
        functionName = "hairDresser:ToggleHair"
    },    
    ['blips:tattooshop'] = {
        title = "Tattoo Shop",
        icon = "#blips-tattooshop",
        functionName = "tattoo:ToggleTattoo"
    },
    ['drivinginstructor:drivingtest'] = {
        title = "Driving Test",
        icon = "#drivinginstructor-drivingtest",
        functionName = "drivingInstructor:testToggle"
    },
    ['drivinginstructor:submittest'] = {
        title = "Submit Test",
        icon = "#drivinginstructor-submittest",
        functionName = "drivingInstructor:submitTest"
    },
    ['judge-raid:checkowner'] = {
        title = "Check Owner",
        icon = "#judge-raid-check-owner",
        functionName = "appartment:CheckOwner"
    },
    ['judge-raid:seizeall'] = {
        title = "Seize All Content",
        icon = "#judge-raid-seize-all",
        functionName = "appartment:SeizeAll"
    },
    ['judge-raid:takecash'] = {
        title = "Take Cash",
        icon = "#judge-raid-take-cash",
        functionName = "appartment:TakeCash"
    },
    ['judge-raid:takedm'] = {
        title = "Take Marked Bills",
        icon = "#judge-raid-take-dm",
        functionName = "appartment:TakeDM"
    },
    ['cuffs:cuff'] = {
        title = "Cuff",
        icon = "#cuffs-cuff",
        functionName = "civ:cuffFromMenu"
    },
    ['police:impound'] = {
        title = "עקל-רכב",
        icon = "#impound-vehicle",
        functionName = "policemenu:impound"
    },
    ['cuffs:uncuff'] = {
        title = "אזיקה שחרור",
        icon = "#cuffs-uncuff",
        functionName = "police:uncuffMenu"
    },
    ['gang:uncuff'] = {
        title = "אזיקה שחרור",
        icon = "#cuffs-uncuff",
        functionName = "police:uncuffMenu"
    },

    ['trunk:stash'] = {
        title = "פתח-באגז",
        icon = "#vehicle-options-vehicle",
        functionName = "trunk:open"
    },
    ['trunk:enter'] = {
        title = "כנס-לבגאז",
        icon = "#general-put-in-veh",
        functionName = "entertrunk"
    },
    ['trunk:leave'] = {
        title = "צא-מהבגאז",
        icon = "#general-unseat-nearest",
        functionName = "leavetrunk"
    },
    ['cuffs:remmask'] = {
        title = "Remove Mask Hat",
        icon = "#cuffs-remove-mask",
        functionName = "police:remmask"
    },
    ['cuffs:checkinventory'] = {
        title = "חיפוש",
        icon = "#cuffs-check-inventory",
        functionName = "disc-inventoryhud:search"
    },
    ['cuffs:unseat'] = {
        title = "Unseat",
        icon = "#cuffs-unseat-player",
        functionName = "unseatPlayerCiv"
    },
    ['cuffs:checkphone'] = {
        title = "Read Phone",
        icon = "#cuffs-check-phone",
        functionName = "police:checkPhone"
    },
    ['medic:revive'] = {
        title = "החייאה",
        icon = "#medic-revive",
        functionName = "medic:revive"
    },
    ['medic:heal'] = {
        title = "חבישה",
        icon = "#medic-heal",
        functionName = "medic:heal'"
    },
    ['police:cuff'] = {
        title = "אזיקה",
        icon = "#cuffs-cuff",
        functionName = "esx_policejob:usecuff"
    },
    ['gang:cuff'] = {
        title = "אזיקה",
        icon = "#cuffs-cuff",
        functionName = "esx_policejob:usecuff"
    },
    ['police:checkbank'] = {
        title = "Check Bank",
        icon = "#police-check-bank",
        functionName = "police:checkBank"
    },
    ['police:checklicenses'] = {
        title = "רשיונות",
        icon = "#police-check-licenses",
        functionName = "policemenu:license"
    },
    ['police:removeweapons'] = {
        title = "Remove Weapons License",
        icon = "#police-action-remove-weapons",
        functionName = "police:removeWeapon"
    },
    ['police:gsr'] = {
        title = "GSR Test",
        icon = "#police-action-gsr",
        functionName = "police:gsr"
    },
    ['police:dnaswab'] = {
        title = "DNA Swab",
        icon = "#police-action-dna-swab",
        functionName = "evidence:dnaSwab"
    },
    ['police:toggleradar'] = {
        title = "Toggle Radar",
        icon = "#police-vehicle-radar",
        functionName = "startSpeedo"
    },
    ['police:runplate'] = {
        title = "חיפוש-רכב-במאגר",
        icon = "#police-vehicle-plate",
        functionName = "policemenu:searchVehicle"
    },
    ['police:frisk'] = {
        title = "Frisk",
        icon = "#police-action-frisk",
        functionName = "police:frisk"
    },

    ['police:impound'] = {
        title = "עיקול-רכב",
        icon = "#impound-vehicle",
        functionName = "policemenu:impound"
    },
    ['judge:grantDriver'] = {
        title = "Grant Drivers",
        icon = "#judge-licenses-grant-drivers",
        functionName = "police:grantDriver"
    }, 
    ['judge:grantBusiness'] = {
        title = "Grant Business",
        icon = "#judge-licenses-grant-business",
        functionName = "police:grantBusiness"
    },  
    ['judge:grantWeapon'] = {
        title = "Grant Weapon",
        icon = "#judge-licenses-grant-weapon",
        functionName = "police:grantWeapon"
    },
    ['judge:grantHouse'] = {
        title = "Grant House",
        icon = "#judge-licenses-grant-house",
        functionName = "police:grantHouse"
    },
    ['judge:grantBar'] = {
        title = "Grant BAR",
        icon = "#judge-licenses-grant-bar",
        functionName = "police:grantBar"
    },
    ['judge:grantDA'] = {
        title = "Grant DA",
        icon = "#judge-licenses-grant-da",
        functionName = "police:grantDA"
    },
    ['judge:removeDriver'] = {
        title = "Remove Drivers",
        icon = "#judge-licenses-remove-drivers",
        functionName = "police:removeDriver"
    },
    ['judge:removeBusiness'] = {
        title = "Remove Business",
        icon = "#judge-licenses-remove-business",
        functionName = "police:removeBusiness"
    },
    ['judge:removeWeapon'] = {
        title = "Remove Weapon",
        icon = "#judge-licenses-remove-weapon",
        functionName = "police:removeWeapon"
    },
    ['judge:removeHouse'] = {
        title = "Remove House",
        icon = "#judge-licenses-remove-house",
        functionName = "police:removeHouse"
    },
    ['judge:removeBar'] = {
        title = "Remove BAR",
        icon = "#judge-licenses-remove-bar",
        functionName = "police:removeBar"
    },
    ['judge:removeDA'] = {
        title = "Remove DA",
        icon = "#judge-licenses-remove-da",
        functionName = "police:removeDA"
    },
    ['judge:denyWeapon'] = {
        title = "Deny Weapon",
        icon = "#judge-licenses-deny-weapon",
        functionName = "police:denyWeapon"
    },
    ['police:bill'] = {
        title = "הענק-דוח",
        icon = "#police-check-bank",
        functionName = "police:billmenu"
    },
    ['judge:denyDriver'] = {
        title = "Deny Drivers",
        icon = "#judge-licenses-deny-drivers",
        functionName = "police:denyDriver"
    },
    ['judge:denyBusiness'] = {
        title = "Deny Business",
        icon = "#judge-licenses-deny-business",
        functionName = "police:denyBusiness"
    },
    ['judge:denyHouse'] = {
        title = "Deny House",
        icon = "#judge-licenses-deny-house",
        functionName = "police:denyHouse"
    },
    ['news:setCamera'] = {
        title = "מצלמה",
        icon = "#news-job-news-camera",
        functionName = "Cam:ToggleCam"
    },
    ['news:setMicrophone'] = {
        title = "מיקרופון",
        icon = "#news-job-news-microphone",
        functionName = "Mic:ToggleMic"
    },
    ['news:setBoom'] = {
        title = "בום",
        icon = "#news-job-news-boom",
        functionName = "Mic:ToggleBMic"
    },
    ['weed:currentStatusServer'] = {
        title = "Request Status",
        icon = "#weed-cultivation-request-status",
        functionName = "weed:currentStatusServer"
    },   
    ['weed:weedCrate'] = {
        title = "Remove A Crate",
        icon = "#weed-cultivation-remove-a-crate",
        functionName = "weed:weedCrate"
    },
    ['cocaine:currentStatusServer'] = {
        title = "Request Status",
        icon = "#meth-manufacturing-request-status",
        functionName = "cocaine:currentStatusServer"
    },
    ['cocaine:methCrate'] = {
        title = "Remove A Crate",
        icon = "#meth-manufacturing-remove-a-crate",
        functionName = "cocaine:methCrate"
    },
    ["expressions:angry"] = {
        title="כועס",
        icon="#expressions-angry",
        functionName = "expressions",
        functionParameters =  { "mood_angry_1" }
    },
    ["expressions:drunk"] = {
        title="שיכור",
        icon="#expressions-drunk",
        functionName = "expressions",
        functionParameters =  { "mood_drunk_1" }
    },
    ["expressions:dumb"] = {
        title="טיפש",
        icon="#expressions-dumb",
        functionName = "expressions",
        functionParameters =  { "pose_injured_1"}
    },
    ["expressions:electrocuted"] = {
        title="מחשמל",
        icon="#expressions-electrocuted",
        functionName = "expressions",
        functionParameters =  { "electrocuted_1" }
    },
    ["expressions:grumpy"] = {
        title="מצמרר",
        icon="#expressions-grumpy",
        functionName = "expressions", 
        functionParameters =  { "mood_drivefast_1" }
    },
    ["expressions:happy"] = {
        title="שמח",
        icon="#expressions-happy",
        functionName = "expressions",
        functionParameters =  { "mood_happy_1" }
    },
    ["expressions:injured"] = {
        title="נפגע",
        icon="#expressions-injured",
        functionName = "expressions",
        functionParameters =  { "mood_injured_1" }
    },
    ["expressions:joyful"] = {
        title="מאושר",
        icon="#expressions-joyful",
        functionName = "expressions",
        functionParameters =  { "mood_dancing_low_1" }
    },
    ["expressions:mouthbreather"] = {
        title="פה-עקום",
        icon="#expressions-mouthbreather",
        functionName = "expressions",
        functionParameters = { "smoking_hold_1" }
    },
    ["expressions:normal"]  = {
        title="רגיל",
        icon="#expressions-normal",
        functionName = "expressions:clear"
    },
    ["expressions:oneeye"]  = {
        title="עין-אחת",
        icon="#expressions-oneeye",
        functionName = "expressions",
        functionParameters = { "pose_aiming_1" }
    },
    ["expressions:shocked"]  = {
        title="מופתע",
        icon="#expressions-shocked",
        functionName = "expressions",
        functionParameters = { "shocked_1" }
    },
    ["expressions:sleeping"]  = {
        title="יושן",
        icon="#expressions-sleeping",
        functionName = "expressions",
        functionParameters = { "dead_1" }
    },
    ["expressions:smug"]  = {
        title="זחוח",
        icon="#expressions-smug",
        functionName = "expressions",
        functionParameters = { "mood_smug_1" }
    },
    ["expressions:speculative"]  = {
        title="חושב",
        icon="#expressions-speculative",
        functionName = "expressions",
        functionParameters = { "mood_aiming_1" }
    },
    ["expressions:stressed"]  = {
        title="לחוץ",
        icon="#expressions-stressed",
        functionName = "expressions",
        functionParameters = { "mood_stressed_1" }
    },
    ["expressions:sulking"]  = {
        title="זועף",
        icon="#expressions-sulking",
        functionName = "expressions",
        functionParameters = { "mood_sulk_1" },
    },
    ["expressions:weird"]  = {
        title="מוזר",
        icon="#expressions-weird",
        functionName = "expressions",
        functionParameters = { "effort_2" }
    },
    ["expressions:weird2"]  = {
        title="מוזר-2",
        icon="#expressions-weird2",
        functionName = "expressions",
        functionParameters = { "effort_3" }
    }
}

RegisterNetEvent("menu:setCuffState")
AddEventHandler("menu:setCuffState", function(pTargetId, pState)
    cuffStates[pTargetId] = pState
end)


RegisterNetEvent("isJudge")
AddEventHandler("isJudge", function()
    isJudge = true
end)

RegisterNetEvent("isJudgeOff")
AddEventHandler("isJudgeOff", function()
    isJudge = false
end)



RegisterNetEvent("drivingInstructor:instructorToggle")
AddEventHandler("drivingInstructor:instructorToggle", function(mode)
    if myJob == "driving instructor" then
        isInstructorMode = mode
    end
end)

RegisterNetEvent("police:currentHandCuffedState")
AddEventHandler("police:currentHandCuffedState", function(pIsHandcuffed, pIsHandcuffedAndWalking)
    isHandcuffedAndWalking = pIsHandcuffedAndWalking
    isHandcuffed = pIsHandcuffed
end)

RegisterNetEvent("menu:hasOxygenTank")
AddEventHandler("menu:hasOxygenTank", function(pHasOxygenTank)
    hasOxygenTankOn = pHasOxygenTank
end)

RegisterNetEvent('enablegangmember')
AddEventHandler('enablegangmember', function(pGangNum)
    gangNum = pGangNum
end)

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local closestPed = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        for index,value in ipairs(players) do
            local target = GetPlayerPed(value)
            if(target ~= ply) then
                local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
                local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
                if(closestDistance == -1 or closestDistance > distance) and not IsPedInAnyVehicle(target, false) then
                    closestPlayer = value
                    closestPed = target
                    closestDistance = distance
                end
            end
        end
        return closestPlayer, closestDistance, closestPed
    end
end

trainstations = {
    {-547.34057617188,-1286.1752929688,25.3059978411511},
    {-892.66284179688,-2322.5168457031,-13.246466636658},
    {-1100.2299804688,-2724.037109375,-8.3086919784546},
    {-1071.4924316406,-2713.189453125,-8.9240007400513},
    {-875.61907958984,-2319.8686523438,-13.241264343262},
    {-536.62890625,-1285.0009765625,25.301458358765},
    {270.09558105469,-1209.9177246094,37.465930938721},
    {-287.13568115234,-327.40936279297,8.5491418838501},
    {-821.34295654297,-132.45257568359,18.436864852905},
    {-1359.9794921875,-465.32354736328,13.531299591064},
    {-498.96591186523,-680.65930175781,10.295949935913},
    {-217.97073364258,-1032.1605224609,28.724565505981},
    {113.90325164795,-1729.9976806641,28.453630447388},
    {117.33223724365,-1721.9318847656,28.527353286743},
    {-209.84713745117,-1037.2414550781,28.722997665405},
    {-499.3971862793,-665.58514404297,10.295639038086},
    {-1344.5224609375,-462.10494995117,13.531820297241},
    {-806.85192871094,-141.39852905273,18.436403274536},
    {-302.21514892578,-327.28854370117,8.5495929718018},
    {262.01733398438,-1198.6135253906,37.448017120361},
--  {2072.4086914063,1569.0856933594,76.712524414063},
    {664.93090820313,-997.59942626953,22.261747360229},
    {190.62687683105,-1956.8131103516,19.520135879517},
--  {2611.0278320313,1675.3806152344,26.578210830688},
    {2615.3901367188,2934.8666992188,39.312232971191},
    {2885.5346679688,4862.0146484375,62.551517486572},
    {47.061096191406,6280.8969726563,31.580261230469},
    {2002.3624267578,3619.8029785156,38.568252563477},
    {2609.7016601563,2937.11328125,39.418235778809}
}
