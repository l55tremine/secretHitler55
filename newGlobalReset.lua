
function shufflePlayers()
	local shufflePlayers = {}
	local playerColours = {}
	
	for i, value in pairs(Player.getPlayers()) do
		if (value ~= nil and value.color ~= "Grey" and value.color ~= "Black" and (value.host == false or options.shuffleHost)) then
			table.insert(playerColours, value.color)
			table.insert(shufflePlayers, value)
		end
	end
	
	for i, value in pairs(playerColours) do
		if #shufflePlayers > 1 then
			local tempRandInt = math.random(#shufflePlayers)
			if (Player[playerColours[i]] ~= nil and Player[playerColours[i]].seated and shufflePlayers[tempRandInt].steam_id ~= Player[playerColours[i]].steam_id) then
				Player[playerColours[i]].changeColor("Grey")
			end
			shufflePlayers[tempRandInt].changeColor(playerColours[i])
			table.remove(shufflePlayers, tempRandInt)
		else
			shufflePlayers[1].changeColor(playerColours[i])
		end
	end
end

blbButtons = {} 
btMode = 0
stopVoteTouching = true
spawnTimer = false

recordDownvotes = false

--timer variables
freeTalkTimeNT = 7*60
maxAddsNT = 1
newAddTimeNT = 45
presOnlyTNT = 60
pleaseConfirmRestart = false

function refreshBelowLibButtons()
	if (getObjectFromGUID("1943fd") == nil) then
		return false
	end
	libBoard = getObjectFromGUID("1943fd")
	libBoard.clearButtons()
	
	local BLBparameters = {
		label="Stop Vote\nTouching", 
		tooltip = "This stops non-promoted people from\ntouching other people's votes",
		click_function="voteTouchSwitch",
		function_owner=Global,
		position={-7.5, 0,5.5},
		height=400, 
		width=1000, 
		font_size=150, 
		color = getButClr(stopVoteTouching)
	}
	
	blbButtons[BLBparameters.click_function] = 0--numButtons()
	libBoard.createButton(BLBparameters)
	
	BLBparameters.click_function="BTSwitch"
	blbButtons[BLBparameters.click_function] = 1--numButtons()
	BLBparameters.position = {-4.5, 0,5.5}
	
	if btMode == 1 then
		BLBparameters.label="Move\nBrown Teal"
		BLBparameters.tooltip = "Moves anyone who sits in brown or teal to grey\ndoesn't do anything to promoted players"
		BLBparameters.color = stringColorToRGB("Green")
		libBoard.createButton(BLBparameters)
	elseif btMode == 2 then
		BLBparameters.label="Kick\nBrown Teal"
		BLBparameters.tooltip = "Kicks anyone who sits in brown or teal\ndoesn't do anything to promoted players"
		BLBparameters.color = stringColorToRGB("Green")
		libBoard.createButton(BLBparameters)
	else
		BLBparameters.label="Off\nBrown Teal"
		BLBparameters.tooltip = "Doesn't do anything to the people who sit in brown and teal"
		BLBparameters.color = stringColorToRGB("Red")
		libBoard.createButton(BLBparameters)
	end
	
	--non-toggle 
	BLBparameters.color = stringColorToRGB("White")
	
	BLBparameters.label = "Get Notetaker"
	BLBparameters.tooltip = "Gives the player who clicks it a notetaker if promoted/host"
	BLBparameters.click_function="getNotetaker"
	BLBparameters.position = {-1.5, 0,5.5}
	libBoard.createButton(BLBparameters)
	
	BLBparameters.label = "Return Votes"
	BLBparameters.tooltip = "Returns all non-stacked votes to people's hands"
	BLBparameters.click_function="returnVotes"
	BLBparameters.position = {1.5, 0,5.5}
	libBoard.createButton(BLBparameters)
	
	BLBparameters.label = "Recreate Votes"
	BLBparameters.tooltip = "Deletes all votes and remakes them in people's hands"
	BLBparameters.click_function="recreateVotes"
	BLBparameters.position = {4.5, 0,5.5}
	libBoard.createButton(BLBparameters)
	
	BLBparameters.label = "Reset Game"
	BLBparameters.tooltip = "Resets the game. Still a work in progress"
	BLBparameters.click_function="resetGame"
	BLBparameters.position = {7.5, 0,5.5}
	libBoard.createButton(BLBparameters)
	
	if (pleaseConfirmRestart) then
		libBoard.createButton({
			label="Are you sure?", 
			click_function="nullFunction",
			function_owner=Global,
			position={7.5, 0,6.5},
			height=0, 
			width=0, 
			font_size=150,
		})
		
		BLBparameters.width = 400
		
		BLBparameters.label = "Yes"
		BLBparameters.tooltip = "Confirms the reset"
		BLBparameters.click_function="confirmReset"
		BLBparameters.position = {7, 0,7.5}
		libBoard.createButton(BLBparameters)
		
		BLBparameters.label = "No"
		BLBparameters.tooltip = "cancels"
		BLBparameters.click_function="cancelReset"
		BLBparameters.position = {8, 0,7.5}
		libBoard.createButton(BLBparameters)
	end
end

function voteTouchSwitch(o, colour)
	if Player[colour].admin then
		stopVoteTouching = not stopVoteTouching
		local tempParams = {}
		tempParams.index = blbButtons["voteTouchSwitch"]
		tempParams.color = getButClr(stopVoteTouching)
		getObjectFromGUID("1943fd").editButton(tempParams)
		--settingsScreen(o, colour)
	end
end

function BTSwitch(object, colour)
	if Player[colour].admin then
		local tempParams = {}
		tempParams.index = blbButtons["BTSwitch"]
		
		if btMode == 0 then
			btMode = 1
			tempParams.label="Move\nBrown Teal"
			tempParams.tooltip = "Moves anyone who sits in brown or teal to grey\ndoesn't do anything to promoted players"
			tempParams.color = stringColorToRGB("Green")
		elseif btMode == 1 then
			btMode = 2
			tempParams.label="Kick\nBrown Teal"
			tempParams.tooltip = "Kicks anyone who sits in brown or teal\ndoesn't do anything to promoted players"
			tempParams.color = stringColorToRGB("Green")
		else
			btMode = 0
			tempParams.label="Off\nBrown Teal"
			tempParams.tooltip = "Doesn't do anything to the people who sit in brown and teal"
			tempParams.color = stringColorToRGB("Red")
		end
		getObjectFromGUID("1943fd").editButton(tempParams)
	end
end

function getNotetaker(obj, color, alt_click)
	if Player[color].admin and color ~= "Black" then -- and started == true
		--spawn note taker(s)
		local params = {position = {-100, 100, -100}, sound = false}
		if options.noteType == 1 then
			params.type = 'Chess_Board'
			params.scale = {1.55, 1.55, 1.55}
		elseif options.noteType == 2 then
			params.type = 'Go_Board'
			params.scale = {1.45, 1.45, 1.45}
		elseif options.noteType == 3 then
			params.type = 'Checker_Board'
			params.scale = {1.55, 1.55, 1.55}
		elseif options.noteType == 4 then
			params.type = 'reversi_board'
			params.scale = {1.45, 1.45, 1.45}
		elseif options.noteType == 5 then
			params.type = 'Custom_Board'
			params.scale = {1, 1, 1}
		elseif options.noteType == 6 then
			params.type = 'Custom_Model'
			params.scale = {1.05, 1.05, 1.05}
		elseif options.noteType > 6 then
			params.type = 'backgammon_board'
			params.scale = {1.8, 1.8, 1.8}
		end
		
		local notetaker = spawnObject(params)
		if options.noteType < 7 then
			notetaker.setLuaScript(newNoteTakerLuaScript(color, 'true', 'false', 'false', 'false', 'false', 'true'))
		elseif options.noteType == 7 then
			notetaker.setLuaScript(newNoteTakerLuaScript(color, 'false', 'false', 'false', 'false', 'false', 'false'))
		elseif options.noteType == 8 then
			notetaker.setLuaScript(newNoteTakerLuaScript(color, 'false', 'true', 'false', 'false', 'false', 'false'))
		end
		if options.noteType == 5 then
			local custom = {}
			custom.image = 'http://cloud-3.steamusercontent.com/ugc/486766424829587499//FDF54ECD5D1706DE0A590239E84D62CDE757FE46/'
			notetaker.setCustomObject(custom)
		elseif options.noteType == 6 then
			local custom = {}
			custom.diffuse = 'http://cloud-3.steamusercontent.com/ugc/478894184492866532/6639B6E1AB511AB10D53DB91B2A47A0A63410DDF/'
			custom.mesh = 'http://cloud-3.steamusercontent.com/ugc/478894184492865468/51C18F993BBDD5D1B55FE5261A625B2CE0B2FD9F/'
			custom.type = 4
			custom.material = 3
			notetaker.setCustomObject(custom)
		end
	end
end

function returnVotes(obj, color, alt_click)
	local colours = {"White","Brown","Red","Orange","Yellow","Green","Teal","Blue","Purple","Pink","Black"}
	if Player[color].admin then
		for i, value in pairs(getAllObjects()) do
			if (value.tag == "Card") then
				for i2, value2 in pairs(colours) do
					if (value.getDescription() == value2.."'s Nein Card" or value.getDescription() == value2.."'s Ja Card") then
						value.deal(1, value2)
					end
				end
			end
		end
	end
end

function recreateVotes(object, color, alt_click)
	if color == "setup" or (started == true and Player[color].admin) then
		startLuaCoroutine(Global, 'recreateVotesCo')
	end
end

function recreateVotesCo()
	local colours = {"White","Brown","Red","Orange","Yellow","Green","Teal","Blue","Purple","Pink"}
	for i, value in pairs(getAllObjects()) do
		if (value.tag == "Card") then
			for i2, value2 in pairs(colours) do
				if (value.getDescription() == value2.."'s Nein Card" or value.getDescription() == value2.."'s Ja Card") then
					value.destruct()
				end
			end
		end
	end
	
	--local neinCopy 	= getObjectFromGUID("bd31d9")
	--local jaCopy 	= getObjectFromGUID("9532bb")
	
	
	local spawmParams = {
		type = "Deck", 
		sound = false,
		scale = {1.51, 1, 1.51}
	}
	
	for i, value in pairs(colours) do
		if (roles[value] ~= nil) then
			spawmParams.position = getObjectFromGUID(HIDDEN_ZONE_GUIDS[value]).getPosition()
			local newVoteDeck = spawnObject(spawmParams)
			wait(2)
			newVoteDeck.setCustomObject(voteInfo)
			wait(3)
			
			local newNein = newVoteDeck.takeObject()
			local newJa = newVoteDeck.takeObject()
			wait(3)
			
			newNein.setDescription(value .. '\'s Nein Card')
			newNein.interactable = true
			newNein.setLock(false)
			newNein.setLuaScript(neinScript)
			newNein.drag_selectable = false
			
			newJa.setDescription(value .. '\'s Ja Card')
			newJa.interactable = true
			newJa.setLock(false)
			newJa.setLuaScript(jaScript)
			newJa.drag_selectable = false
			wait(3)
		end
	end
	
	return true
end

function onObjectPickedUp(player_color, picked_up_object)
	--it only checks for grey because of an old bug. I realize i dont need it.
	if player_color ~= "Grey" and Player[player_color].admin ~= true then
		if ( 
			stopVoteTouching == true
			and string.len(picked_up_object.getDescription()) > 10 
			and (string.sub(picked_up_object.getDescription(), string.len(picked_up_object.getDescription())-6) == "Ja Card" 
			or string.sub(picked_up_object.getDescription(), string.len(picked_up_object.getDescription())-8) == "Nein Card" ) 
			and string.sub(picked_up_object.getDescription(), 1, string.len(player_color)) ~= player_color
		) then
			
			picked_up_object.setVelocity({0,0,0})
			picked_up_object.drop()
		end
	
	end
end

function numButtons()
	if (self.getButtons() == nil) then
		return 0
	end
	return #self.getButtons()
end

function getButClr(booleanVar)
	returnValue = stringColorToRGB("Red")
	if booleanVar then
		returnValue = stringColorToRGB("Green")
	end
	return returnValue
end

function spawnNikosTimer()
	if (spawnTimer) then
		local params = {
			position = {0.00, 1.2, -15.00}, 
			sound = false,
			type = "Digital_Clock",
			scale = {1.00, 1.00, 0.21},
			rotation = {90.00, 0, 0}
		}
		local spawnedClock = spawnObject(params)
		spawnedClock.setLuaScript(nikosTimerScript)
		spawnedClock.setLock(true)
		spawnedClock.setDescription("This clock is intended to make the game a bit faster.\nthis is still new and basically a prototype, but maybe I won't need to ever update it.")
	end
end

function timerOnSwitch(obj, color)
	if Player[color].admin then
		spawnTimer = not spawnTimer
		settingsPannelMakeButtons()
	end
end

function resetGame(obj, color, alt_click)
	if (not Player[color].admin or started ~= true) then
		return false
	end
	
	pleaseConfirmRestart = true
	refreshBelowLibButtons()
end

function confirmReset(obj, color, alt_click)
	pleaseConfirmRestart = false
	refreshBelowLibButtons()
	startLuaCoroutine(Global, 'resetGameCo')
end

function cancelReset(obj, color, alt_click)
	pleaseConfirmRestart = false
	refreshBelowLibButtons()
end

function resetGameCo()
	local tempObj
	
	local ElectionTrackerTemp = getObjectFromGUID(ELECTION_TRACKER_GUID)
	ElectionTrackerTemp.setPositionSmooth({-3.97, 1.5, -9.39},false,true)
	ElectionTrackerTemp.setRotation({0.00, 0.00, 0.00})
	
	tempObj = getObjectFromGUID(settingsPannel_guid)
	tempObj.setPositionSmooth({32.91, 1.05, 0.00},false,true)
	tempObj.setRotation({0.00, 180.00, 0.00})
	tempObj.setScale({0.88, 0.88, 0.88})
	settingsPannelMakeButtons()
	
	tempObj = getObjectFromGUID(PRESIDENT_GUID)
	tempObj.setPositionSmooth({-16.50, 2.08, 17.00},false,true)
	tempObj.setRotation({0.00, 270.00, 0.00})
	
	tempObj = getObjectFromGUID(PREV_PRESIDENT_GUID)
	if (tempObj) then
		tempObj.setPositionSmooth(PREV_PRESIDENT_POS,false,true)
		tempObj.setRotation(PREV_PRESIDENT_ROT)
	else
		tempObj = getObjectFromGUID("2ab2e8").clone()
		wait(3) -- if you dont wait it just takes the original object
		tempObj.setPositionSmooth(PREV_PRESIDENT_POS,false,true)
		tempObj.setRotation(PREV_PRESIDENT_ROT)
		tempObj.setScale({1.00, 1.00, 1.00})
		tempObj.setLock(false)
		tempObj.interactable = true
		PREV_PRESIDENT_GUID = tempObj.guid
	end
	
	tempObj = getObjectFromGUID(CHANCELOR_GUID)
	tempObj.setPositionSmooth({16.50, 2.08, 17.00},false,true)
	tempObj.setRotation({0.00, 90.00, 0.00})
	
	tempObj = getObjectFromGUID(PREV_CHANCELOR_GUID)
	tempObj.setPositionSmooth(PREV_CHANCELOR_POS,false,true)
	tempObj.setRotation(PREV_CHANCELOR_ROT)
	
	refreshBoardCards()
	refreshHiddenZones()
	
	for i, guidOfButtons in ipairs(playerStatusButtonGuids) do
		tempObj = getObjectFromGUID(guidOfButtons)
		if (tempObj) then
			tempObj.destruct()
		end
	end
	
	if (bulletsToDelete ~= nil) then 
		for i, guidOfBullet in ipairs(bulletsToDelete) do
			tempObj = getObjectFromGUID(guidOfBullet)
			if (tempObj) then
				tempObj.destruct()
			end
		end
	else
		bulletsToDelete = {}
	end
	
	for i, guidOfBanner in ipairs(bannerGuids) do
		tempObj = getObjectFromGUID(guidOfBanner)
		if (tempObj) then
			tempObj.destruct()
		end
	end
	
	local drawZone = getObjectFromGUID(DRAW_ZONE_GUID)
	for i, j in ipairs(drawZone.getObjects()) do
		if j.tag == 'Deck' then
			j.destruct()
		end
	end
	
	local discardZone = getObjectFromGUID(DISCARD_ZONE_GUID)
	for i, j in ipairs(discardZone.getObjects()) do
		if j.tag == 'Deck' then
			j.destruct()
		end
	end
	
	
	
	wait(10)
	
	local colours = {"White","Brown","Red","Orange","Yellow","Green","Teal","Blue","Purple","Pink"}
	for i, obj in ipairs(getAllObjects()) do
		if (obj.tag == "Card" and obj.interactable == true) then
			local desc = obj.getDescription()
			for i2, value2 in pairs(colours) do
				if (desc == value2.."'s Nein Card" or desc == value2.."'s Ja Card") then
					obj.destruct()
				end
			end
			if (desc == "Fascist Role Card" or desc == "Hitler Role Card" or desc == "Liberal Role Card" or desc == "Fascist Party Card" or desc == "Liberal Party Card") then
				obj.destruct()
			end
			if (isPolicyCard(obj)) then
				obj.destruct()
			end
		elseif (obj.tag == "Board" and obj.getDescription() == "Note Taker by Lost Savage\nBased on the work of:\nsmiling Aktheon,\nSwiftPanda,\nThe Blind Dragon\nand Max\n") then
			obj.destruct()
		end
	end
	
	--Variable
	customOnly = nil
	bannerZoneGuid = nil
	topdeck = false
	lastDrawCt = nil
	lastPlayerCt = nil
	hold = false
	votes = {}
	disableVote = false
	votePassed = false
	blockDraw = false

	--Wait timers
	voteWaitId = nil
	policyWaitId = nil
	boardCardWaitId = nil

	--Saved data
	activePowerColor = nil
	bannerGuids = {}
	fascists = {}
	forcePres = nil
	greyAvatarGuids = {}
	greyPlayerSteamIds = {}
	greyPlayerHandGuids = {}
	hitler = {}
	inspected = {}
	jaCardGuids = {}
	lastFascistPlayed = 0
	lastLiberalPlayed = 0
	lastChan = nil
	lastPres = nil
	lastVote = ''
	mainNotes = ''
	neinCardGuids = {}
	notate = {
		line = nil,
		action = ''
	}
	noteTakerNotes = {}
	noteTakerCurrLine = 0
	players = {}
	playerRoleCardGuids = {}
	playerStatusButtonGuids = {}
	playerStatus = { --[1 Board, 2 Not Hitler, 3 Vote Only, 4 Silenced, 5 Dead, 6 Dead not Hitler]
		White = 1,
		Brown = 1,
		Red = 1,
		Orange = 1,
		Yellow = 1,
		Green = 1,
		Teal = 1,
		Blue = 1,
		Purple = 1,
		Pink = 1,
		Tan = 1,
		Maroon = 1
	}
	roles = {}
	started = false
	voteNotes = ''
	voteNotebook = ''
	
	bulletsToDelete = {}
	
	wait(10)
	lockNeededCards()
	wait(10)
	resetNotes()
	refreshUI()
	
	--down here because something above throws it into the void
	--ElectionTrackerTemp.setLock(false)
	local lineDrawer = getObjectFromGUID("beaa34")
	if (lineDrawer) then
		lineDrawer.call("globalCallClear")
	end
	return true
end

function nullFunction()
	return false
end

--add validation to the definition. float only or :::: ?
function setTimerFreeTalkTimeNT(obj, color, input, stillEditing)
	if Player[color].admin == false then
		Player[color].broadcast("[ff0000]NotePad: You don't have permission to do that")
		return tostring(freeTalkTimeNT)
	elseif Player[color].admin and stillEditing == false then
		freeTalkTimeNT = input
	end
end
function setTimerNumAddsNT(obj, color, input, stillEditing)
	if Player[color].admin == false then
		Player[color].broadcast("[ff0000]NotePad: You don't have permission to do that")
		return tostring(maxAddsNT)
	elseif Player[color].admin and stillEditing == false then
		maxAddsNT = input
	end
end
function setTimerPresOnlyNT(obj, color, input, stillEditing)
	if Player[color].admin == false then
		Player[color].broadcast("[ff0000]NotePad: You don't have permission to do that")
		return tostring(newAddTimeNT)
	elseif Player[color].admin and stillEditing == false then
		newAddTimeNT = input
	end
end
function setTimerAddTimeNT(obj, color, input, stillEditing)
	if Player[color].admin == false then
		Player[color].broadcast("[ff0000]NotePad: You don't have permission to do that")
		return tostring(presOnlyTNT)
	elseif Player[color].admin and stillEditing == false then
		presOnlyTNT = input
	end
end


nikosTimerScript = "freeTalkTime = "..freeTalkTimeNT.."\nmax45s = "..maxAddsNT.."\nnew45sTime = "..newAddTimeNT.."\npresOnlyT = "..presOnlyTNT..[[

--nikos's timer script

parameters = {
	function_owner=self,
	rotation={90,180,0},
	height=400, 
	width=1200,
	font_size = 300,
	scale = {0.1, 0.021, 0.1},--{0.2,0,0.33},
	font_color = stringColorToRGB("Black")
}

editParams = {index = 2,label="Currently Off"}
clrnums = {White = "[ffffff]",Brown = "[703A16]",Red = "[DA1917]", Orange = "[F3631C]", Yellow = "[E6E42B]", Green = "[30B22A]", Teal = "[20B09A]", Blue = "[1E87FF]", Purple = "[9F1FEF]", Pink = "[F46FCD]", Black = "[3F3F3F]"}
add45sUsed = {}
--savedTime45 = -1
after45 = -1
currentlyMuted = false
presOnlyTime = false

function toggleMute(obj, color)
	if (Player[color].admin) then
		for i, playerVar in pairs(Player.getPlayers()) do
			playerVar.mute()
		end
	end
end

function onLoad()
	self.clearButtons()
	
	self.createButton({
		label="", click_function="toggleMute", function_owner=self, rotation={90,180,0},
		position={0.385, -0.02, 0}, height=40, width=40, tooltip = "this button toggles mute in case something goes wrong"
	})
	
	parameters.label="Start" --Players
	parameters.click_function="startTurn"
	parameters.position={0.3, -0.1, 0}
	self.createButton(parameters)
	
	parameters.click_function = "nilFunction"
	parameters.label="Currently Error" --Players
	parameters.width=4000
	parameters.position={0, -0.2, 0}
	self.createButton(parameters)
	
	parameters.click_function = "add45"
	parameters.label="add time" --Players
	parameters.width=1200
	parameters.position={-0.3, -0.1, 0}
	self.createButton(parameters)
	
	self.setScale({1.00, 1.00, 0.21})
	--self.setRotation({90.00, 0, 0.00})
	
	local inputParams = {
		label="free\ntalk", input_function="setFreeTalkTime", function_owner=self, scale = {0.1, 0.021, 0.1}, rotation={90,180,0},
		position={-0.1, -0.1, 0}, height=200, width=400, font_size=175
	}
	
	inputParams.label = "free\ntalk"
	inputParams.input_function = "setFreeTalkTime"
	inputParams.position = {-0.1, -0.075, 0}
	inputParams.value = freeTalkTime
	inputParams.tooltip = "the time where people can talk freely"
	self.createInput(inputParams)
	
	inputParams.label = "num\n45s"
	inputParams.input_function = "setNum45s"
	inputParams.position = {0, -0.075, 0}
	inputParams.value = max45s
	inputParams.tooltip = "the number of times people can add seconds"
	self.createInput(inputParams)
	
	inputParams.label = "pres time"
	inputParams.input_function = "setPresOnly"
	inputParams.position = {0, -0.125, 0}
	inputParams.value = presOnlyT
	inputParams.tooltip = "the number of second where it is pres only"
	self.createInput(inputParams)
	
	inputParams.label = "45s\ntime"
	inputParams.input_function = "set45sTime"
	inputParams.position = {0.1, -0.075, 0}
	inputParams.value = new45sTime
	inputParams.tooltip = "how much time is added when they add time"
	self.createInput(inputParams)
	
	setOff()
end

function nilFunction()
	return false
end

function startTurn(obj, color, alt_click)
	if (Player[color].admin) then
		Timer.destroy(self.getGUID().."timerDone")
		if (currentlyMuted == true) then
			for i, playerObj in pairs(Player.getPlayers()) do
				if (playerObj.seated) then
					--playerObj.mute()
				end
			end
			currentlyMuted = false
		end
		
		self.setValue(freeTalkTime*1)
		after45 = -1
		self.Clock.pauseStart()
		self.setColorTint(stringColorToRGB("Black"))
		editParams.label = "current mode: free talk"
		self.editButton(editParams)
		--waitingFor = 0
		checkForDone()
		--doMute = true
	end
end

function presOnly()
	Timer.destroy(self.getGUID().."timerDone")
		
	self.setValue(presOnlyT*1)
	after45 = -1
	self.Clock.pauseStart()
	self.setColorTint(stringColorToRGB("Black"))
	editParams.label = "current mode: pres ONLY"
	presOnlyTime = true
	self.editButton(editParams)
	--waitingFor = 0
	checkForDone()
end

function add45(obj, color, alt_click)
	
	if (add45sUsed[color] == nil) then
		add45sUsed[color] = 1
	elseif (add45sUsed[color] == max45s) then
		return false
	else 
		add45sUsed[color] = 1 + add45sUsed[color]
	end
	--doMute = false
	local currentTime = self.getValue()
	self.Clock.pauseStart()
	--waitingFor = currentTime
	after45 = currentTime
	self.setValue(new45sTime*1)
	self.Clock.pauseStart()
	self.setColorTint(stringColorToRGB(color))
	editParams.label = "current mode: "..clrnums[color]..Player[color].steam_name
	self.editButton(editParams)
	checkForDone()
end

function continueFreeTalk()
	self.setValue(after45)
	self.Clock.pauseStart()
	after45 = -1
	self.setColorTint(stringColorToRGB("Black"))
	editParams.label = "current mode: free talk"
	self.editButton(editParams)
	--waitingFor = 0
	checkForDone()
end

function setOff()
	self.setColorTint(stringColorToRGB("Black"))
	editParams.label = "current mode: Off"
	self.editButton(editParams)
	--waitingFor = 0
end

function checkForDone()
	
	if (self.getValue() == 0) then
		if (after45 == -1 and presOnlyTime) then
			for i, playerObj in pairs(Player.getPlayers()) do
				if (playerObj.seated) then
					--playerObj.mute()
				end
			end
			currentlyMuted = true
			presOnlyTime = false
			setOff()
			return false
		elseif (after45 == -1 and presOnlyTime == false) then
			presOnly()
		else
			continueFreeTalk()
		end
	end
	
	local timerparameters = {}
	timerparameters.identifier = self.getGUID().."timerDone"
	timerparameters.function_name = 'checkForDone'
	timerparameters.delay = 1
	Timer.destroy(self.getGUID().."timerDone")
	Timer.create(timerparameters)
end

function onDestroy()
	Timer.destroy(self.getGUID().."timerDone")
end

function setFreeTalkTime(obj, color, input, stillEditing)
	if Player[color].admin == false then
		Player[color].broadcast("[ff0000]NotePad: You don't have permission to do that")
		return tostring(freeTalkTime)
	elseif Player[color].admin and stillEditing == false then
		freeTalkTime = input
	end
end

function setNum45s(obj, color, input, stillEditing)
	if Player[color].admin == false then
		Player[color].broadcast("[ff0000]NotePad: You don't have permission to do that")
		return tostring(max45s)
	elseif Player[color].admin and stillEditing == false then
		max45s = input
	end
	
end

function set45sTime(obj, color, input, stillEditing)
	if Player[color].admin == false then
		Player[color].broadcast("[ff0000]NotePad: You don't have permission to do that")
		return tostring(new45sTime)
	elseif Player[color].admin and stillEditing == false then
		new45sTime = input
	end
	
end

function setPresOnly(obj, color, input, stillEditing)
	if Player[color].admin == false then
		Player[color].broadcast("[ff0000]NotePad: You don't have permission to do that")
		return tostring(presOnlyT)
	elseif Player[color].admin and stillEditing == false then
		presOnlyT = input
	end
	
end

]]

function resetNotes()
	Notes.setNotes("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n[ffffff]Mod name: "..MOD_NAME.."\nVersion: "..UPDATE_VERSION.."\nLink to workshop: "..linkToWorkshop)
end

-- Created by LostGod on 5/8/2016
-- Heavily modified by Lost Savage
-- Lots of code from Sionar
-- Also used code from smiling Aktheon, SwiftPanda,
-- Rodney, Markimus, Morten G and Hmmmpf
-- original scripts can be found on https://github.com/LostSavage/SecretHitlerCE
-- new edit by 55tremine can be found on https://github.com/l55tremine/secretHitler55
MOD_NAME = "Secret Hitler: 55"
UPDATE_VERSION = 3
ADD_ON_VERSION = 6
linkToWorkshop = "https://steamcommunity.com/sharedfiles/filedetails/?id=2076307698"
----#include \SecretHitlerCE\main.ttslua
--Static

--Boards and Buttons
settingsPannel_guid = '39d283'
fasPannel_guid = 'c09dbd'
drawPileBoard_guid = 'a5b10f'
discardPileBoard_guid = '3e225f'
radio_string = '●'
check_string = '✓'

--Decks/Cards
--extraRole_card_guids = {'675a6f', '16e480', '0a5960', '02b664', '328440', '05df40', '98f4dd', '7b4b46', 'ccb7ed', 'c2309a'}
fakeMembership_card_guid = '55d1c3'
--fascistMembership_card_guid = 'e4d489'
--liberalMembership_card_guid = 'a73564'
GREY_POLICY_RIGHT = -9
GREY_EXPANSION_RIGHT = 9

-- new additions
--[[copyHitlerGuids = {"05df3f"}
copyFasGuids = {"02b663","7b4b45","e3aae3"}
copyLibGuids = {"f4370e","c23099","16e47f","ccb7ec","98f4dc","32843f"}]]--

copyPartyCards = {"7f6315", "e2bd89"} -- fas then lib
bulletsToDelete = {}

--Placards and Tracker
PRESIDENT_GUID = "4d3d8f"
PREV_PRESIDENT_GUID = "4ed685"
PREV_PRESIDENT_POS = {x = -16.5, y = 1.06, z = -17}
PREV_PRESIDENT_ROT = {x = 0, y = 270, z = 0}
CHANCELOR_GUID = "7dba7e"
PREV_CHANCELOR_GUID = "448483"
PREV_CHANCELOR_POS = {x = 16.5, y = 1.06, z = -17}
PREV_CHANCELOR_ROT = {x = 0, y = 90, z = 0}
ELECTION_TRACKER_GUID = "dd57c4"

--Scripting Zones
DRAW_ZONE_GUID = '6463d3'
DISCARD_ZONE_GUID = 'b9bd6e'
ABILITIESPILE_ZONE_GUID = 'eea120'
EFFECTSPILE_ZONE_GUID = '374a16'
fascist_zone_guids = {'1f0149', '390247', '6c3840', '13e460', '441bbf', '6a906e', '488053'}
liberal_zone_guids = {'12b8ce', '3cabfa', '6f02b7', '939e6d', '3f80ba', 'a6b76f'}
topdeck_zone_guid = 'c0b577'
policySafety_zone_guids = {White = 'e99663', Brown = '13b335', Red = 'd7774a', Orange = 'f601b1', Yellow = '620e09', Green = 'b7c2d8', Teal = '162d55', Blue = '0aa61b', Purple = 'fdc17a', Pink = 'c4d8e8'}

--Other
HIDDEN_ZONE_GUIDS = {White = "f13d0b", Brown = "90049b", Red = "134297", Orange = "344002", Yellow = "9b5558", Green = "7a8301", Teal = "568a75", Blue = "dbd95e", Purple = "cc1b94", Pink = "d954ee"}
boardGreen_rgb = {14/255, 45/255, 18/255}
boardBrown_rgb = {53/255, 27/255, 17/255}
lastVote_guids = {'0d8b0c', 'cd55ea', '06e71d', '2923c6'}
-- @{100, 100, 100+} hidden zones
-- @{-100, 100, -100} is used to delete/spawn objects

--Variable
customOnly = nil
bannerZoneGuid = nil
topdeck = false
lastDrawCt = nil
lastPlayerCt = nil
hold = false
votes = {}
disableVote = false
votePassed = false
blockDraw = false

--Wait timers
voteWaitId = nil
policyWaitId = nil
boardCardWaitId = nil

--Saved data
activePowerColor = nil
bannerGuids = {}
bulletInfo = {
	type = 'Custom_Model',
	mesh = 'http://cloud-3.steamusercontent.com/ugc/487893695357489958/2749FC201350D558AC9DF373861E4323C8B354BB/',
	diffuse = '',
	assetbundle = nil,
	assetbundle_secondary = nil,
	convex = true,
	image = nil,
	material = 2,
	specular_color = {1, 1, 0.5882353},
	specular_intensity = 1.7,
	specular_sharpness = 8.0,
	fresnel_strength = 0,
	use_grid = false,
	colorTint = {0, 0, 0.0382530019},
	scale = {0.75, 0.75, 0.75},
	action = 'Shoots',
	status = 'Dead',
	shooterColor = nil
}
fascists = {}
forcePres = nil
greyAvatarGuids = {}
greyPlayerSteamIds = {}
greyPlayerHandGuids = {}
hitler = {}
voteInfo = {
	type = 'Deck',
	face = "http://cloud-3.steamusercontent.com/ugc/487893695357363209/86078D3725CDE2B860059AF6ADEC9C0DF2B9D786/",
	back = "http://cloud-3.steamusercontent.com/ugc/487893695357363653/E92709D8795B0637D18C6910013EEDF96A1480A3/",
	width = 2,
	height = 2,
	number = 2
}
roleInfo = {
	type = "Deck",
	face = "http://cloud-3.steamusercontent.com/ugc/486767061412116401/336CAFD99D8CF70D8371094E048AB7B2CDD23DC3/",
	back = "http://cloud-3.steamusercontent.com/ugc/486767061412115929/FBB86CA2DAEF0B27A2643AC720B8212CDF10E0FA/",
	width = 4,
	height = 3,
	number = 10
}
jaScript = 'collision = false -- workaround for rewind error\r\n' ..
					'\r\n' ..
					'function onLoad()\r\n' ..
					'	Global.call(\'callFunction\', {fcn = \'addJaCard\', params = {self}})\r\n' ..
					'end\r\n' ..
					'\r\n' ..
					'function onDrop(playerColor)\r\n' ..
					'	local options = Global.getTable(\'options\')\r\n' ..
					'	if options.scriptedVoting then\r\n' ..
					'		collision = true\r\n' ..
					'		Global.call(\'createVoteWait\')\r\n' ..
					'	end\r\n' ..
					'end\r\n' ..
					'\r\n' ..
					'function onCollisionEnter(collisionInfo)\r\n' ..
					'	local options = Global.getTable(\'options\')\r\n' ..
					'	if collision and options.scriptedVoting then\r\n' ..
					'		Global.call(\'createVoteWait\')\r\n' ..
					'	end\r\n' ..
					'end\r\n'
neinScript = 'collision = false -- workaround for rewind error\r\n' ..
					'\r\n' ..
					'function onLoad()\r\n' ..
					'	Global.call(\'callFunction\', {fcn = \'addNeinCard\', params = {self}})\r\n' ..
					'end\r\n' ..
					'\r\n' ..
					'function onDrop(playerColor)\r\n' ..
					'	local options = Global.getTable(\'options\')\r\n' ..
					'	if options.scriptedVoting then\r\n' ..
					'		collision = true\r\n' ..
					'		Global.call(\'createVoteWait\')\r\n' ..
					'	end\r\n' ..
					'end\r\n' ..
					'\r\n' ..
					'function onCollisionEnter(collisionInfo)\r\n' ..
					'	local options = Global.getTable(\'options\')\r\n' ..
					'	if collision and options.scriptedVoting then\r\n' ..
					'		Global.call(\'createVoteWait\')\r\n' ..
					'	end\r\n' ..
					'end\r\n'

imprisonInfo = {
	type = 'Custom_Model',
	mesh = 'http://cloud-3.steamusercontent.com/ugc/993492686551248783/B83B87475B885192F8F820E381F1D70A2E3F1919/',
	diffuse = 'http://cloud-3.steamusercontent.com/ugc/993492686551247160/63699220060380A49761207FF81A12E1AB00A597/',
	assetbundle = nil,
	assetbundle_secondary = nil,
	convex = true,
	image = nil,
	material = 2,
	specular_color = {0.737, 0.737, 0.737},
	specular_intensity = 0.9,
	specular_sharpness = 7.0,
	fresnel_strength = 0,
	use_grid = false,
	colorTint = {1, 1, 1},
	scale = {4, 4, 4},
	action = 'Imprisons',
	status = 'Imprisoned',
	shooterColor = nil
}
inspected = {}
jaCardGuids = {}
lastFascistPlayed = 0
lastLiberalPlayed = 0
lastChan = nil
lastPres = nil
lastVote = ''
mainNotes = ''
neinCardGuids = {}
notate = {
	line = nil,
	action = ''
}
noteTakerNotes = {}
noteTakerCurrLine = 0
options = {
	autoNotate = false,
	dealPartyCards = false,
	dealRoleCards = false,
	expansionAmount = 2,
	expansionOptionEnabled = 0, -- [1 SwapGov, 2 Reverse, 4 SwapPower, 8 SetupPowerAbilities]
	expansionOptionStatus = 0, -- [1 SwapGov, 2 Reverse]
	expansionOptionText = {'Pres -> Chan', 'Chan -> Pres', 'Clockwise', 'Counterclockwise'},
	fascistCards = 11,
	greyCards = 0,
	gameType = 0, -- [0 Original, 2 Custom]
	liberalCards = 6,
	noteType = 1, -- [1 Dark wood, 2 Light wood, 3 Red wood, 4 Black plastic, 5 Board image, 6 Swiss cheese, 7 Private only, 8 Cooperative]
	policySafety = true,
	scriptedVoting = true,
	shufflePlayers = false,
	shuffleHost = true,
	voteHistory = false,
	zoneType = 4 -- [1 None, 2 Small, 3 Gap (version 1), 4 Gap (version 2), 5 Large, 6 11-12 Players]
}
players = {}
playerRoleCardGuids = {}
playerStatusButtonGuids = {}
playerStatus = { --[1 Board, 2 Not Hitler, 3 Vote Only, 4 Silenced, 5 Dead, 6 Dead not Hitler]
	White = 1,
	Brown = 1,
	Red = 1,
	Orange = 1,
	Yellow = 1,
	Green = 1,
	Teal = 1,
	Blue = 1,
	Purple = 1,
	Pink = 1,
	Tan = 1,
	Maroon = 1
}
roles = {}
started = nil
text = {
	hitler = 'Hitler',
	liberal = 'Liberal',
	liberalAbbr = 'Liberal',
	liberalArticle = 'a',
	liberalLetter = 'L',
	fascist = 'Fascist',
	fascistAbbr = 'Fascist',
	fascistArticle = 'a',
	fascistLetter = 'F',
	grey = 'Grey',
	greyAbbr = 'Grey',
	greyArticle = 'a',
	greyLetter = 'G',
	policy = 'policy'
}
voteNotes = ''
voteNotebook = ''

-- Called when a game finishes loading
function onLoad(saveString)
	if not (saveString == '') then
		local save = JSON.decode(saveString)
		activePowerColor = save['a']
		bannerGuids = save['b']
		bulletInfo = save['bi']
		fascists = save['f']
		forcePres = save['fp']
		greyAvatarGuids = save['gag']
		greyPlayerSteamIds = save['gp']
		greyPlayerHandGuids = save['gphg']
		hitler = save['h']
		imprisonInfo = save['ii']
		inspected = save['in']
		jaCardGuids = save['ja']
		lastFascistPlayed = save['lfp']
		lastLiberalPlayed = save['llp']
		lastChan = save['lc']
		lastPres = save['lp']
		lastVote = save['lv']
		mainNotes = save['mn']
		neinCardGuids = save['nein']
		notate = save['note']
		noteTakerNotes = save['ntn']
		noteTakerCurrLine = save['ntcl']
		options = save['o']
		players = save['p']
		playerRoleCardGuids = save['prcg']
		playerStatus = save['ps']
		playerStatusButtonGuids = save['psbg']
		roles = save['r']
		started = save['s']
		text = save['t']
		voteNotes = save['vn']
		voteNotebook = save['vnb']
		btMode = save['bt']
		stopVoteTouching = save['svt']
		recordDownvotes = save['recd']
		spawnTimer = save['st']
		bulletsToDelete = save['btd']
		--timer values
		freeTalkTimeNT = save['ntft']
		presOnlyTNT = save['ntpa']
		maxAddsNT = save['ntma']
		newAddTimeNT = save['ntat']
	end
	alwaysInit()
	if not started then
		local status, err = pcall(init)
		if not status then
			printToAll('ERROR LOADING: ' .. err, {1,0,0})
		end
		settingsPannelMakeButtons()
		refreshBoardCards()
	end
	if not noteTakerCurrLine or noteTakerCurrLine == 0 then
		noteTakerNotes = {}
		noteTakerCurrLine = 0
		addNewLine()
	end
	
	lockNeededCards()
	resetNotes()
	Physics.play_area = 1
	--reload text for tabletop glitch showing it really tiny
	for _, lastVoteGuid in ipairs(lastVote_guids) do
		local lastVoteObj = getObjectFromGUID(lastVoteGuid)
		if lastVoteObj then 
			lastVoteObj.setScale({3.00, 3.00, 3.00})
			lastVoteObj.TextTool.setValue("   ")
			lastVoteObj.setScale({5.00, 5.00, 5.00})
		end
	end
end

function lockNeededCards()
	local tempObj = getObjectFromGUID("2ab2e8")
	if (tempObj) then
		tempObj.setLock(true)
		tempObj.interactable = false
	end
	tempObj = getObjectFromGUID(copyPartyCards[1])
	if (tempObj) then
		tempObj.setLock(true)
		tempObj.interactable = false
	end
	tempObj = getObjectFromGUID(copyPartyCards[2])
	if (tempObj) then
		tempObj.setLock(true)
		tempObj.interactable = false
	end
	tempObj = getObjectFromGUID(fakeMembership_card_guid)
	if (tempObj) then
		tempObj.setLock(true)
		tempObj.interactable = false
	end
end

function onSave()
	local save = {}
	save['a'] = activePowerColor
	save['b'] = bannerGuids
	save['bi'] = bulletInfo
	save['f'] = fascists
	save['fp'] = forcePres
	save['gag'] = greyAvatarGuids
	save['gp'] = greyPlayerSteamIds
	save['gphg'] = greyPlayerHandGuids
	save['h'] = hitler
	save['ii'] = imprisonInfo
	save['in'] = inspected
	save['ja'] = jaCardGuids
	save['lfp'] = lastFascistPlayed
	save['llp'] = lastLiberalPlayed
	save['lc'] = lastChan
	save['lp'] = lastPres
	save['lv'] = lastVote
	save['mn'] = mainNotes
	save['nein'] = neinCardGuids
	save['note'] = notate
	save['ntn'] = noteTakerNotes
	save['ntcl'] = noteTakerCurrLine
	save['o'] = options
	save['p'] = players
	save['prcg'] = playerRoleCardGuids
	save['ps'] = playerStatus
	save['psbg'] = playerStatusButtonGuids
	save['r'] = roles
	save['s'] = started
	save['t'] = text
	save['vn'] = voteNotes
	save['vnb'] = voteNotebook
	save['bt'] = btMode
	save['svt'] = stopVoteTouching
	save['recd'] = recordDownvotes
	save['st'] = spawnTimer
	save['btd'] = bulletsToDelete
	--timer values
	save['ntft'] = freeTalkTimeNT
	save['ntpa'] = presOnlyTNT
	save['ntma'] = maxAddsNT
	save['ntat'] = newAddTimeNT
	local saveString = JSON.encode(save)

	return saveString
end

function refreshHiddenZones()
	for _, player in pairs(MAIN_PLAYABLE_COLORS) do
		if options.zoneType == 1 then
			--Hide the hidden zone so we can still use it later
			tmpObj = getObjectFromGUID(HIDDEN_ZONE_GUIDS[player])
			tmpObj.setScale({0.01, 0.01, 0.01})
			local colorToNumber = {White = 1, Brown = 2, Red = 3, Orange = 4, Yellow = 5, Green = 6, Teal = 7, Blue = 8, Purple = 9, Pink = 10}
			tmpObj.setPosition({100, 100, 100 + colorToNumber[player] * 2})
		elseif options.zoneType == 2 then
			tmpObj = getObjectFromGUID(HIDDEN_ZONE_GUIDS[player])
			tmpObj.setScale({15.3268776, 5.1, 6.35014629})
			forceObjectToPlayer(tmpObj, player, {forward = 0, right = 0, up = 0, forceHeight = 3.51}, NO_ROT)
		elseif options.zoneType == 3 then
			local pos = {White = {29.65, 3.51, -32.75}, Brown = {0, 3.51, -32.75}, Red = {-29.65, 3.51, -32.75}, Orange = {-50.2, 3.51, -19.25}, Yellow = {-50.2, 3.51, 19.25}, Green = {-29.65, 3.51, 32.75}, Teal = {0, 3.51, 32.75}, Blue = {29.65, 3.51, 32.75}, Purple = {50.2, 3.51, 19.25}, Pink = {50.2, 3.51, -19.25}}
			local scale = {White = {28.4, 5.1, 10.1}, Brown = {28.4, 5.1, 10.1}, Red = {28.4, 5.1, 10.1}, Orange = {9.55, 5.1, 37.25}, Yellow = {9.55, 5.1, 37.25}, Green = {28.4, 5.1, 10.1}, Teal = {28.4, 5.1, 10.1}, Blue = {28.4, 5.1, 10.1}, Purple = {9.55, 5.1, 37.25}, Pink = {9.55, 5.1, 37.25}}

			tmpObj = getObjectFromGUID(HIDDEN_ZONE_GUIDS[player])
			tmpObj.setPosition(pos[player])
			tmpObj.setScale(scale[player])
			tmpObj.setRotation(NO_ROT)
		elseif options.zoneType == 4 then
			local pos = {White = {29.65, 3.51, -31.9}, Brown = {0, 3.51, -31.9}, Red = {-29.65, 3.51, -31.9}, Orange = {-50.2, 3.51, -19.25}, Yellow = {-50.2, 3.51, 19.25}, Green = {-29.65, 3.51, 31.9}, Teal = {0, 3.51, 31.9}, Blue = {29.65, 3.51, 31.9}, Purple = {50.2, 3.51, 19.25}, Pink = {50.2, 3.51, -19.25}}
			local scale = {White = {28.4, 5.1, 11.8}, Brown = {28.4, 5.1, 11.8}, Red = {28.4, 5.1, 11.8}, Orange = {9.55, 5.1, 37.25}, Yellow = {9.55, 5.1, 37.25}, Green = {28.4, 5.1, 11.8}, Teal = {28.4, 5.1, 11.8}, Blue = {28.4, 5.1, 11.8}, Purple = {9.55, 5.1, 37.25}, Pink = {9.55, 5.1, 37.25}}

			tmpObj = getObjectFromGUID(HIDDEN_ZONE_GUIDS[player])
			tmpObj.setPosition(pos[player])
			tmpObj.setScale(scale[player])
			tmpObj.setRotation(NO_ROT)
		elseif options.zoneType == 5 then
			local pos = {White = {29.3, 3.51, -31.9}, Brown = {0, 3.51, -31.9}, Red = {-29.3, 3.51, -31.9}, Orange = {-49.4, 3.51, -19}, Yellow = {-49.4, 3.51, 19}, Green = {-29.3, 3.51, 31.9}, Teal = {0, 3.51, 31.9}, Blue = {29.3, 3.51, 31.9}, Purple = {49.4, 3.51, 19}, Pink = {49.4, 3.51, -19}}
			local scale = {White = {29.3, 5.1, 11.8}, Brown = {29.3, 5.1, 11.8}, Red = {29.3, 5.1, 11.8}, Orange = {10.8, 5.1, 38.0}, Yellow = {10.8, 5.1, 38.0}, Green = {29.3, 5.1, 11.8}, Teal = {29.3, 5.1, 11.8}, Blue = {29.3, 5.1, 11.8}, Purple = {10.8, 5.1, 38.0}, Pink = {10.8, 5.1, 38.0}}

			tmpObj = getObjectFromGUID(HIDDEN_ZONE_GUIDS[player])
			tmpObj.setPosition(pos[player])
			tmpObj.setScale(scale[player])
			tmpObj.setRotation(NO_ROT)
		elseif options.zoneType == 6 then
			local pos = {White = {-29.3, 3.51, -49.4}, Brown = {-49.4, 3.51, -29.3}, Red = {-49.4, 3.51, 0}, Orange = {-49.4, 3.51, 29.3}, Yellow = {-29.3, 3.51, 49.4}, Green = {0, 3.51, 49.4}, Teal = {29.3, 3.51, 49.4}, Blue = {49.4, 3.51, 29.3}, Purple = {49.4, 3.51, 0}, Pink = {49.4, 3.51, -29.3}}
			local scale = {White = {28.4, 5.1, 10.8}, Brown = {10.8, 5.1, 28.4}, Red = {10.8, 5.1, 28.4}, Orange = {10.8, 5.1, 28.4}, Yellow = {28.4, 5.1, 10.8}, Green = {28.4, 5.1, 10.8}, Teal = {28.4, 5.1, 10.8}, Blue = {10.8, 5.1, 28.4}, Purple = {10.8, 5.1, 28.4}, Pink = {10.8, 5.1, 28.4}}

			tmpObj = getObjectFromGUID(HIDDEN_ZONE_GUIDS[player])
			tmpObj.setPosition(pos[player])
			tmpObj.setScale(scale[player])
			tmpObj.setRotation(NO_ROT)

			local handPos = {White = {-29.3, 4.46, -51.66}, Brown = {-51.66, 4.46, -29.3}, Red = {-51.66, 4.46, 0}, Orange = {-51.66, 4.46, 29.3}, Yellow = {-29.3, 4.46, 51.66}, Green = {0, 4.46, 51.66}, Teal = {29.3, 4.46, 51.66}, Blue = {51.66, 4.46, 29.3}, Purple = {51.66, 4.46, 0}, Pink = {51.66, 4.46, -29.3}}
			local handRot = {White = {0, 0, 0}, Brown = {0, 90, 0}, Red = {0, 90, 0}, Orange = {0, 90, 0}, Yellow = {0, 180, 0}, Green = {0, 180, 0}, Teal = {0, 180, 0}, Blue = {0, 270, 0}, Purple = {0, 270, 0}, Pink = {0, 270, 0}}
			local handParams = {
				scale = {11.66, 5.4, 4.87}
			}

			handParams.position = handPos[player]
			handParams.rotation = handRot[player]
			Player[player].setHandTransform(handParams)

			tmpObj = getObjectFromGUID(policySafety_zone_guids[player])
			forceObjectToPlayer(tmpObj, player, {forward = 0, right = 0, up = 0, forceHeight = 3.51}, NO_ROT)
		end
	end
	if options.zoneType == 6 then
		broadcastToAll('Alpha release ... still work in progress.', {1,1,1})
		local params = {type = 'Custom_Model', sound = false}
		local tableExt = {}
		local custom = {
			mesh = 'http://cloud-3.steamusercontent.com/ugc/933812827275737908/4A39E65F99D7809D6055BED44C2B2AF420776850/',
			diffuse = 'http://cloud-3.steamusercontent.com/ugc/933812827275738471/DBC87C418A1CBD45F4EB56EB0F63B65E7F042F1F/',
			type = 4,
			material = 1,
			specular_color = {223/255, 207/255, 190/255},
			specular_intensity = 0.05,
			specular_sharpness = 6.3
		}
		for i = 1, 2 do
			tableExt[i] = spawnObject(params)
			tableExt[i].setCustomObject(custom)
			tableExt[i].setLock(true)
			tableExt[i].setRotation({0, 270, 0})
			tableExt[i].setScale({0.74, 1, 1})
			tableExt[i].setLuaScript(
				'function onLoad()\r\n' ..
				'	self.interactable = false\r\n' ..
				'end\r\n')
		end
		tableExt[1].setPosition({0, 0.1, -46.2})
		tableExt[2].setPosition({0, 0.1, 46.2})
		params = {
			type = 'Custom_Assetbundle',
			scale = {14.2, 2.55, 5.4},
			callback = 'greyPlayerHandCallback',
			sound = false
		}
		custom = {
			assetbundle = 'http://cloud-3.steamusercontent.com/ugc/933813375181578705/3961A9B3B73895140CA5055A8745BEE4A3E39299/'
		}
		local playerHands = {}
		for i, color in ipairs(GREY_PLAYABLE_COLORS) do
			playerHands[i] = spawnObject(params)
			playerHands[i].setCustomObject(custom)
			playerHands[i].setColorTint(GREY_PLAYABLE_COLORS_RGB[color])
			playerHands[i].setDescription(color .. ' Hand')
			playerHands[i].setLock(true)
		end
		playerHands[1].setPosition({29.3, 3.5, -49.4}) -- Tan
		playerHands[2].setPosition({0, 3.5, -49.4}) -- Maroon
		refreshUI()
	end
end

-- check for topdeck
function onObjectEnterScriptingZone(zone, enterObject)
	if enterObject then
		if zone.guid == topdeck_zone_guid and enterObject.guid == ELECTION_TRACKER_GUID then
			editButtonByLabel(drawPileBoard_guid, 'Draw 3', 'Topdeck', 'topdeckCard')
		end
	end
end

--check for topdeck and policy safety
function onObjectLeaveScriptingZone(zone, leaveObject)
	if leaveObject then
		if zone.guid == topdeck_zone_guid and leaveObject.guid == ELECTION_TRACKER_GUID then
			editButtonByLabel(drawPileBoard_guid, 'Topdeck', 'Draw 3', 'drawThree')
		elseif options.policySafety then
			if inTable(policySafety_zone_guids, zone.guid) and leaveObject.tag == 'Card' and
				(leaveObject.getDescription() == FASCISTPOLICY_STRING or
				 leaveObject.getDescription() == LIBERALPOLICY_STRING) then
				if not leaveObject.is_face_down and leaveObject.held_by_color then
					broadcastToColor('Keep your policy cards face down\nwhen removing them from your hand!', leaveObject.held_by_color, {1, 0, 0})
					leaveObject.deal(1, leaveObject.held_by_color)
				end
			end
		end
	end
end

function alwaysInit()
	local tmpObj

	-- Initialize the pseudo random number generator
	math.randomseed(os.time())

	refreshUI()
	refreshStatusButtons()
	refreshExpansionButtons()
	refreshBelowLibButtons()

	local drawPileBoard = getObjectFromGUID(drawPileBoard_guid)
	if drawPileBoard then
		local button = {
			click_function = 'drawThree',
			label = 'Draw 3',
			function_owner = Global,
			position = {0, 0.14, 3.7},
			rotation = {0, 0, 0},
			width = 2700,
			height = 1300,
			font_size = 650
		}
		drawPileBoard.createButton(button)
	end

	tmpObj = getObjectFromGUID(fakeMembership_card_guid)
	if tmpObj then	tmpObj.interactable = false end
end

function refreshStatusButtons()
	local tmpObj
	local buttonGUID

	for _, buttonGUID in ipairs(playerStatusButtonGuids) do
		tmpObj = getObjectFromGUID(buttonGUID)
		if tmpObj then
			tmpObj.clearButtons()
			local ownerColor = tmpObj.getName()
			local button = {
				function_owner = self,
				position = {0, 0.2, 0},
				rotation = {0, 180, 0},
				width = 2900,
				height = 1500,
				font_size = 600,
				click_function = 'changePlayerStatus'
			}
			if _G.playerStatus[ownerColor] == 1 then
				if options.zoneType == 6 then
					local greenColors = {'Brown', 'Red', 'Blue', 'Purple'}
					if inTable(greenColors, ownerColor) then
						button.color = boardGreen_rgb
					else
						button.color = boardBrown_rgb
					end
				else
					button.color = boardGreen_rgb
				end
				button.label = ''
			elseif _G.playerStatus[ownerColor] == 2 then
				button.color = stringColorToRGB('Green')
				button.label = 'Not ' .. text.hitler
			elseif _G.playerStatus[ownerColor] == 3 then
				button.color = stringColorToRGB('Yellow')
				button.label = 'Vote Only'
			elseif _G.playerStatus[ownerColor] == 4 then
				button.color = stringColorToRGB('Blue')
				button.label = 'Silenced'
			elseif _G.playerStatus[ownerColor] == 5 then
				button.color = stringColorToRGB('Red')
				button.label = bulletInfo.status
			elseif _G.playerStatus[ownerColor] == 6 then
				button.color = stringColorToRGB('Red')
				button.label = bulletInfo.status .. '\nNot ' .. text.hitler
			else
				button.color = stringColorToRGB('Red')
				button.label = imprisonInfo.status
				button.font_size = 550
			end
			tmpObj.createButton(button)
		end
	end
end

function refreshExpansionButtons()
	local fasBoard = getObjectFromGUID(fasPannel_guid)
	if fasBoard then
		fasBoard.clearButtons()
		local button = {
			click_function = 'expansionOptionStatusSwapGov',
			function_owner = self,
			position = {12, 0.2, 6},
			rotation = {0, 0, 0},
			width = 2600,
			height = 800,
			font_size = 360
		}
		if bit32.band(options.expansionOptionStatus, 1) == 1 then
			button.font_color = {0, 0, 0}
			button.color =  stringColorToRGB('Orange')
			button.label = options.expansionOptionText[2]
		else
			button.font_color = stringColorToRGB('White')
			button.color =  boardGreen_rgb
			button.label = options.expansionOptionText[1]
		end
		if bit32.band(options.expansionOptionEnabled, 1) == 1 then
			fasBoard.createButton(button)
		end

		button.click_function = 'expansionOptionStatusReverse'
		button.position = {-12, 0.2, 6}
		button.width = 2800
		if bit32.band(options.expansionOptionStatus, 2) == 2 then
			button.font_color = {0, 0, 0}
			button.color =  stringColorToRGB('Orange')
			button.label = options.expansionOptionText[4]
		else
			button.font_color = stringColorToRGB('White')
			button.color =  boardGreen_rgb
			button.label = options.expansionOptionText[3]
		end
		if bit32.band(options.expansionOptionEnabled, 2) == 2 then
			fasBoard.createButton(button)
		end
	end
end

function init()
	local tmpObj

	tmpObj = getObjectFromGUID(PRESIDENT_GUID)
	if tmpObj == nil then error('President') end
	tmpObj.interactable = false
	tmpObj.setLock(true)
	tmpObj = getObjectFromGUID(CHANCELOR_GUID)
	if tmpObj == nil then error('Chancellor') end
	tmpObj.interactable = false
	tmpObj.setLock(true)
	tmpObj = getObjectFromGUID(PREV_PRESIDENT_GUID)
	if tmpObj == nil then error('Prev President') end
	tmpObj.setLock(true)
	tmpObj = getObjectFromGUID(PREV_CHANCELOR_GUID)
	if tmpObj == nil then error('Prev Chancellor') end
	tmpObj.setLock(true)

	tmpObj = getObjectFromGUID(ELECTION_TRACKER_GUID)
	if tmpObj == nil then error('Election Tracker') end
	tmpObj.setLock(true)

	for i, player in ipairs(MAIN_PLAYABLE_COLORS) do
		tmpObj = getObjectFromGUID(HIDDEN_ZONE_GUIDS[player])
		if tmpObj == nil then error(player .. ' Hidden Zone') end
	end

	--Expansion
	tmpObj = getDeckFromZoneByGUID(ABILITIESPILE_ZONE_GUID)
	if tmpObj then	tmpObj.interactable = false end
	tmpObj = getDeckFromZoneByGUID(EFFECTSPILE_ZONE_GUID)
	if tmpObj then	tmpObj.interactable = false end

	if options.gameType ~= 2 then
		--delete board cards
		testActionUsedPolicyZones(
			function(p) return isBoardCard(p) or isPolicyNotUsedCard(p) end,
			function(p) p.destruct() end,
			nil)
	end
end

function onChat(messageIn, player)
	local message = string.gsub(messageIn, '%s+', ' ')
	local messageTable = string.tokenize(message, ' ')
	messageTable[1] = string.lower(messageTable[1])

	if messageTable[1] == 'r' then
		if started then
			player:print(tellRole(player.color))
		else
			player:print('[FF0000]ERROR: Game not started.[-]')
		end
		return false
	elseif messageTable[1] == 'l' then
		player:print(lastVote)
		return false
	elseif messageTable[1] == 'h' then
		if options.voteHistory then
			player:print(string.gsub(voteNotebook, '\n$', ''))
		else
			player:print('[FF0000]ERROR: Full vote history is not enabled.[-]')
		end
		return false
	elseif messageTable[1] == 'n' then
		player:print(string.gsub(noteTakerNotesString(100, false, true), '\n$', ''))
		return false
	elseif messageTable[1] == 'o' then
		player:print(string.gsub(tableToString(options), '\n$', ''))
		return false
	elseif messageTable[1] == 'v' then
		player:print(versionInfo())
		return false
	elseif messageTable[1] == 'c' and (player.admin) then
		if messageTable[2] then
			messageTable[2] = string.titlecase(messageTable[2])
			if inTable(MAIN_PLAYABLE_COLORS, messageTable[2]) or messageTable[2] == 'Black' or messageTable[2] == 'Grey' then
				if messageTable[3] then
					local playerFound = getPlayerByNameSteamID(messageTable[3], Player.getPlayers())
					if playerFound then
						playerFound:changeColor(messageTable[2])
					else
						player:print('ERROR: ' .. messageTable[3] .. ' not found.', {1, 0, 0})
					end
				else
					player:changeColor(messageTable[2])
				end
			else
				player:print('ERROR: Unknown color ' .. messageTable[2] .. '.', {1, 0, 0})
			end
		else
			player:print('ERROR: No color given.', {1, 0, 0})
		end
		return false
	elseif messageTable[1] == 'promote' and (player.admin) then
		if messageTable[2] then
			local playerFound = getPlayerByNameSteamID(messageTable[2], Player.getPlayers())
			if playerFound then
				playerFound.promote()
			else
				player:print(messageTable[2] .. ' not found.', {1, 0, 0})
			end
		else
			player.promote()
		end
		return false
	elseif messageTable[1] == 'kick' and (player.admin) then
		if messageTable[2] then
			local playerFound = getPlayerByNameSteamID(messageTable[2], Player.getPlayers())
			if playerFound then
				playerFound.kick()
			else
				player:print(messageTable[2] .. ' not found.', {1, 0, 0})
			end
		end
		return false
	elseif messageTable[1] == 'list' and (player.admin) then
		for _, p in pairs(Player.getPlayers()) do
			player:print(p.steam_name .. ' ' .. p.steam_id)
		end
		return false
	elseif messageTable[1] == 'help' then
		player:print(chatHelp(player.admin))
		return false
	end

	for _, color in pairs(GREY_PLAYABLE_COLORS) do
		if greyPlayerSteamIds[color] == player.steam_id then
			printToAll("[" .. stringColorToHex(color) .. "]" .. player.steam_name .. ":[-] " .. messageIn)
			return false
		end
	end
end

function chatHelp(admin)
	local msg = 'chat commands:\n' ..
					'   r - All the role information you can know\n' ..
					'   l - Shows the last vote\n' ..
					'   h - Vote history\n' ..
					'   n - All of the notes\n' ..
					'   o - current options\n' ..
					'   v - Version info\n' ..
					'   help - This message'
	if admin then
		msg = msg .. '\nadmin chat commands:\n' ..
					'   c color [name* or steam id] - sets player to color\n' ..
					'   promote [name* or steam id] - promotes/demotes player\n' ..
					'   kick name* or steam id - kicks the player\n' ..
					'   list - lists steam ids\n' ..
					'   * partial name allowed but must be distinct'
	end

	return msg
end

do -- settings panel

function settingsPannelMakeButtons()
	local settingsPannel = getObjectFromGUID(settingsPannel_guid)
	if settingsPannel then
		settingsPannel.clearButtons()
		settingsPannel.clearInputs()
		
		local buttonParam = {
			font_color = {0, 0, 0},
			rotation = {0, 0, 0},
			width = 0,
			height = 0,
			font_size = 480,
			function_owner = self,
			click_function = 'nullFunction'
		}
		local startX = -6.1
		local offsetZ = 1.32

		local startZ = -22.9
		buttonParam.label = '[u]Game Type[/u]'
		buttonParam.position = {0, 0.2, startZ - 1.4}
		settingsPannel.createButton(buttonParam)
		makeSquareButtonLabel(settingsPannel, options.gameType == 0, radio_string, '', 'Original', 'gameTypeZero', {startX, 0.2, startZ}, 2.45, not customOnly)
		makeSquareButtonLabel(settingsPannel, options.gameType == 2, radio_string, '', 'Custom', 'gameTypeTwo', {startX, 0.2, startZ + offsetZ * 1}, 2.3, true)
		makeDecIncButtonsLabel(settingsPannel, options.liberalCards, '-', '+', 'Liberal Cards', 'decLiberalCards', 'incLiberalCards', {startX + 1.3, 0.2, startZ + offsetZ * 2}, 6.1, false, options.gameType == 2)
		makeDecIncButtonsLabel(settingsPannel, options.fascistCards, '-', '+', 'Fascist Cards', 'decFascistCards', 'incFascistCards', {startX + 1.3, 0.2, startZ + offsetZ * 3}, 6.1, false, options.gameType == 2)
		makeDecIncButtonsLabel(settingsPannel, options.greyCards, '-', '+', 'Grey Cards', 'decGreyCards', 'incGreyCards', {startX + 1.3, 0.2, startZ + offsetZ * 4}, 5.65, false, options.gameType == 2)

		startZ = -14.5
		buttonParam.label = '[u]Note Taker[/u]'
		buttonParam.position = {0, 0.2, startZ - 1.4}
		settingsPannel.createButton(buttonParam)
		local labels = {'Dark wood', 'Light wood (tintable)', 'Red wood (tintable)', 'Black plastic', 'Board image', 'Swiss cheese', 'Private only', 'Cooperative'}
		local offsets = {4.4, 6.6, 6.3, 4.7, 4.7, 4.7, 4.6, 4.6}
		makeDecIncButtonsLabel(settingsPannel, options.noteType, '-', '+', labels, 'decNoteType', 'incNoteType', {startX, 0.2, startZ}, offsets, false, true)

		startZ = -11.6
		buttonParam.label = '[u]Hidden Zones[/u]'
		buttonParam.position = {0, 0.2, startZ - 1.4}
		settingsPannel.createButton(buttonParam)
		labels = {'None', 'Small', 'Gap (version 1)', 'Gap (version 2)', 'Large', '11-12 Players'}
		offsets = {3.2, 3.3, 5.3, 5.35, 3.3, 4.8}
		makeDecIncButtonsLabel(settingsPannel, options.zoneType, '-', '+', labels, 'decZoneType', 'incZoneType', {startX, 0.2, startZ}, offsets, false, options.zoneType ~= 6)

		startZ = -8.5
		buttonParam.label = '[u]Other Options[/u]'
		buttonParam.position = {0, 0.2, startZ - 1.4}
		settingsPannel.createButton(buttonParam)
		makeSquareButtonLabel(settingsPannel, options.dealRoleCards, check_string, '', 'Deal role', 'roleCardFlip', {startX, 0.2, startZ}, 2.7, true)
		makeSquareButtonLabel(settingsPannel, options.dealPartyCards, check_string, '', 'Deal party membership', 'partyCardFlip', {startX, 0.2, startZ + offsetZ}, 5.8, true)
		makeSquareButtonLabel(settingsPannel, options.scriptedVoting, check_string, '', 'Scripted voting', 'scriptedVotingFlip', {startX, 0.2, startZ + offsetZ * 2}, 4, true)
		makeSquareButtonLabel(settingsPannel, options.autoNotate, check_string, '', 'Auto notate', 'autoNotateFlip', {startX, 0.2, startZ + offsetZ * 3}, 3.4, true)
		if (options.autoNotate) then
			makeSmallSquareButtonLabel(settingsPannel, recordDownvotes, check_string, '', 'Record Downvotes', 'recdownFlip', {startX+7, 0.2, startZ + offsetZ * 3}, 3.5, true)
		end
		makeSquareButtonLabel(settingsPannel, options.policySafety, check_string, '', 'Policy safety', 'policySafetyFlip', {startX, 0.2, startZ + offsetZ * 4}, 3.5, true)
		makeSquareButtonLabel(settingsPannel, options.voteHistory, check_string, '', 'Vote history', 'voteHistoryFlip', {startX, 0.2, startZ + offsetZ * 5}, 3.4, true)
		makeSquareButtonLabel(settingsPannel, spawnTimer, check_string, '', 'Timer On', 'timerOnSwitch', {startX, 0.2, startZ + offsetZ * 6}, 2.8, true) --new
		if (spawnTimer) then
			local inputParams = { --scale = {0.1, 0.1, 0.1},
				 rotation={0,0,0},
				height=200, width=400, font_size=175, validation=2,
			}
			
			--positions @@@
			inputParams.input_function = "setTimerFreeTalkTimeNT"
			inputParams.position = {0, 0.2, startZ + offsetZ * 6}
			inputParams.value = freeTalkTimeNT
			inputParams.tooltip = "the time where people can talk freely.\n(in seconds)"
			settingsPannel.createInput(inputParams)
			
			inputParams.label = ""
			inputParams.input_function = "setTimerPresOnlyNT"
			inputParams.position = {1, 0.2, startZ + offsetZ * 6}
			inputParams.value = presOnlyTNT
			inputParams.tooltip = "the number of second where it is pres only.\n(in seconds)"
			settingsPannel.createInput(inputParams)
			
			inputParams.label = ""
			inputParams.input_function = "setTimerNumAddsNT"
			inputParams.position = {2, 0.2, startZ + offsetZ * 6}
			inputParams.value = maxAddsNT
			inputParams.tooltip = "the number of times people can add seconds."
			settingsPannel.createInput(inputParams)			
			
			inputParams.label = ""
			inputParams.input_function = "setTimerAddTimeNT"
			inputParams.position = {3, 0.2, startZ + offsetZ * 6}
			inputParams.value = newAddTimeNT
			inputParams.tooltip = "how much time is added when they add time.\n(in seconds)"
			settingsPannel.createInput(inputParams)
		end
		makeSquareButtonLabel(settingsPannel, options.shufflePlayers, check_string, '', 'Shuffle players', 'shufflePlayersFlip', {startX, 0.2, startZ + offsetZ * 7}, 4, true)
		makeSquareButtonLabel(settingsPannel, options.shuffleHost, check_string, '', 'Shuffle host', 'shuffleHostFlip', {startX + 1.3, 0.2, startZ + offsetZ * 8}, 3.3, options.shufflePlayers)

		--Expansion
		local abilitiesDeck = getDeckFromZoneByGUID(ABILITIESPILE_ZONE_GUID)
		if abilitiesDeck then
			startZ = 3.7
			buttonParam.label = '[u]Fan Expansion[/u]'
			buttonParam.position = {0, 0.2, startZ - 1.4}
			settingsPannel.createButton(buttonParam)
			makeDecIncButtonsLabel(settingsPannel, options.expansionAmount, '-', '+', 'Cards', 'decExpansionAmount', 'incExpansionAmount', {startX, 0.2, startZ}, 4.7, false, true)
			makeSquareButtonLabel(settingsPannel, bit32.band(options.expansionOptionEnabled, 1) == 1, check_string, '', 'Swap government', 'expansionOptionEnabledSwapGov', {startX, 0.2, startZ + offsetZ}, 4.7, true)
			makeSquareButtonLabel(settingsPannel, bit32.band(options.expansionOptionEnabled, 4) == 4, check_string, '', 'Swap power', 'expansionOptionEnabledSwapPower', {startX + 1.3, 0.2, startZ + offsetZ * 2}, 3.4, bit32.band(options.expansionOptionEnabled, 1) == 1)
			makeSquareButtonLabel(settingsPannel, bit32.band(options.expansionOptionEnabled, 2) == 2, check_string, '', 'Reverse', 'expansionOptionEnabledReverse', {startX, 0.2, startZ + offsetZ * 3}, 2.4, true)
			makeSquareButtonLabel(settingsPannel, bit32.band(options.expansionOptionEnabled, 8) == 8, check_string, '', 'Setup power abilities', 'expansionOptionEnabledSetupPowerAbilities', {startX, 0.2, startZ + offsetZ * 4}, 5.3, true)
		end

		buttonParam = {
			click_function = 'setupStart',
			label = 'Start',
			function_owner = self,
			position = {0, 0.2, 23.5},
			rotation = {0, 0, 0},
			width = 3300,
			height = 1700,
			font_size = 750
		}
		settingsPannel.createButton(buttonParam)
	else
		printToAll('ERROR: Settings pannel not found.', {1,0,0})
	end
end

function makeSquareButtonLabel(objectIn, valueIn, trueButtonTextIn, falseButtonTextIn, labelTextIn, clickFunctionIn, buttonPositionIn, textOffsetIn, enabledIn)
	local buttonParam = {
		rotation = {0, 0, 0},
		width = 600,
		height = 600,
		font_size = 480,
		function_owner = self,
		click_function = clickFunctionIn,
		position = buttonPositionIn
	}
	local textParam = {
		label = labelTextIn,
		font_color = {0, 0, 0},
		rotation = {0, 0, 0},
		width = 0,
		height = 0,
		font_size = 480,
		function_owner = self,
		click_function = 'nullFunction',
		position = {buttonPositionIn[1] + textOffsetIn, buttonPositionIn[2], buttonPositionIn[3]}
	}
	if valueIn then
		buttonParam.label = trueButtonTextIn
	else
		buttonParam.label = falseButtonTextIn
	end
	if not enabledIn then
		buttonParam.click_function = 'nullFunction'
		buttonParam.color = stringColorToRGB('Grey')
		buttonParam.font_color = {0.3, 0.3, 0.3}
		textParam.font_color = {0.3, 0.3, 0.3}
	end
	objectIn.createButton(buttonParam)
	objectIn.createButton(textParam)
end

--this is only used once because I'm lazy
function makeSmallSquareButtonLabel(objectIn, valueIn, trueButtonTextIn, falseButtonTextIn, labelTextIn, clickFunctionIn, buttonPositionIn, textOffsetIn, enabledIn)
	local buttonParam = {
		rotation = {0, 0, 0},
		width = 500,
		height = 500,
		font_size = 330,
		function_owner = self,
		click_function = clickFunctionIn,
		position = buttonPositionIn
	}
	local textParam = {
		label = labelTextIn,
		font_color = {0, 0, 0},
		rotation = {0, 0, 0},
		width = 0,
		height = 0,
		font_size = 330,
		function_owner = self,
		click_function = 'nullFunction',
		position = {buttonPositionIn[1] + textOffsetIn, buttonPositionIn[2], buttonPositionIn[3]}
	}
	if valueIn then
		buttonParam.label = trueButtonTextIn
	else
		buttonParam.label = falseButtonTextIn
	end
	if not enabledIn then
		buttonParam.click_function = 'nullFunction'
		buttonParam.color = stringColorToRGB('Grey')
		buttonParam.font_color = {0.3, 0.3, 0.3}
		textParam.font_color = {0.3, 0.3, 0.3}
	end
	objectIn.createButton(buttonParam)
	objectIn.createButton(textParam)
end

function makeDecIncButtonsLabel(objectIn, valueIn, decButtonTextIn, incButtonTextIn, labelTextIn, decFunctionIn, incFunctionIn, positionIn, textOffsetIn, showValueIn, enabledIn)
	local buttonParam = {
		font_color = {0, 0, 0},
		rotation = {0, 0, 0},
		width = 0,
		height = 0,
		font_size = 480,
		function_owner = self,
		click_function = 'nullFunction'
	}

	local valueOffset
	if type(labelTextIn) == 'table' then
		valueOffset = 0
		buttonParam.label = labelTextIn[valueIn]
		buttonParam.position = {positionIn[1] + textOffsetIn[valueIn], positionIn[2], positionIn[3]}
	else
		valueOffset = 1.3
		buttonParam.label = labelTextIn
		buttonParam.position = {positionIn[1] + textOffsetIn, positionIn[2], positionIn[3]}
	end
	if not enabledIn then
		buttonParam.font_color = {0.3, 0.3, 0.3}
	end
	objectIn.createButton(buttonParam)

	if not enabledIn then
		buttonParam.color = stringColorToRGB('Grey')
	end
	buttonParam.label = decButtonTextIn
	buttonParam.position = positionIn
	buttonParam.width = 600
	buttonParam.height = 600
	if enabledIn then
		buttonParam.click_function = decFunctionIn
	end
	objectIn.createButton(buttonParam)

	buttonParam.label = incButtonTextIn
	buttonParam.position = {positionIn[1] + 1.3 + valueOffset, positionIn[2], positionIn[3]}
	if enabledIn then
		buttonParam.click_function = incFunctionIn
	end
	objectIn.createButton(buttonParam)

	if valueOffset > 0 then
		buttonParam.label = valueIn
		if enabledIn then
			buttonParam.click_function = incFunctionIn
		end
		buttonParam.position = {positionIn[1] + valueOffset, positionIn[2], positionIn[3]}
		objectIn.createButton(buttonParam)
	end
end

function gameTypeZero(clickedObject, playerColor)
	if Player[playerColor].admin then
		options.gameType = 0
		options.fascistCards = 11
		options.liberalCards = 6
		options.greyCards = 0
		refreshBoardCards()
		settingsPannelMakeButtons()
	end
end

function gameTypeTwo(clickedObject, playerColor)
	if Player[playerColor].admin then
		options.gameType = 2
		refreshBoardCards()
		settingsPannelMakeButtons()
	end
end

function decNoteType(clickedObject, playerColor)
	if Player[playerColor].admin then
		if options.noteType > 1 then
			options.noteType = options.noteType - 1
		end
		settingsPannelMakeButtons()
	end
end

function incNoteType(clickedObject, playerColor)
	if Player[playerColor].admin then
		if options.noteType < 8 then
			options.noteType = options.noteType + 1
		end
		settingsPannelMakeButtons()
	end
end

function decZoneType(clickedObject, playerColor)
	if Player[playerColor].admin then
		if options.zoneType > 1 then
			options.zoneType = options.zoneType - 1
		end
		refreshHiddenZones()
		settingsPannelMakeButtons()
	end
end

function incZoneType(clickedObject, playerColor)
	if Player[playerColor].admin then
		if options.zoneType < 6 then
			options.zoneType = options.zoneType + 1
		end
		refreshHiddenZones()
		settingsPannelMakeButtons()
	end
end

function roleCardFlip(clickedObject, playerColor)
	if Player[playerColor].admin then
		options.dealRoleCards = not options.dealRoleCards
		settingsPannelMakeButtons()
	end
end

function partyCardFlip(clickedObject, playerColor)
	if Player[playerColor].admin then
		options.dealPartyCards = not options.dealPartyCards
		settingsPannelMakeButtons()
	end
end

function scriptedVotingFlip(clickedObject, playerColor)
	if Player[playerColor].admin then
		options.scriptedVoting = not options.scriptedVoting
		settingsPannelMakeButtons()
	end
end

function autoNotateFlip(clickedObject, playerColor)
	if Player[playerColor].admin then
		options.autoNotate = not options.autoNotate
		settingsPannelMakeButtons()
	end
end

function recdownFlip(clickedObject, playerColor)
	if Player[playerColor].admin then
		recordDownvotes = not recordDownvotes
		settingsPannelMakeButtons()
	end
end

function policySafetyFlip(clickedObject, playerColor)
	if Player[playerColor].admin then
		options.policySafety = not options.policySafety
		settingsPannelMakeButtons()
	end
end

function voteHistoryFlip(clickedObject, playerColor)
	if Player[playerColor].admin then
		options.voteHistory = not options.voteHistory
		settingsPannelMakeButtons()
	end
end

function shufflePlayersFlip(clickedObject, playerColor)
	if Player[playerColor].admin then
		options.shufflePlayers = not options.shufflePlayers
		settingsPannelMakeButtons()
	end
end

function shuffleHostFlip(clickedObject, playerColor)
	if Player[playerColor].admin then
		options.shuffleHost = not options.shuffleHost
		settingsPannelMakeButtons()
	end
end

function expansionOptionEnabledSwapGov(clickedObject, playerColor)
	if Player[playerColor].admin then
		if bit32.band(options.expansionOptionEnabled, 1) == 1 then
			options.expansionOptionEnabled = options.expansionOptionEnabled - 1
		else
			options.expansionOptionEnabled = options.expansionOptionEnabled + 1
		end
		refreshExpansionButtons()
		settingsPannelMakeButtons()
	end
end

function expansionOptionEnabledReverse(clickedObject, playerColor)
	if Player[playerColor].admin then
		if bit32.band(options.expansionOptionEnabled, 2) == 2 then
			options.expansionOptionEnabled = options.expansionOptionEnabled - 2
		else
			options.expansionOptionEnabled = options.expansionOptionEnabled + 2
		end
		refreshExpansionButtons()
		settingsPannelMakeButtons()
	end
end

function expansionOptionEnabledSwapPower(clickedObject, playerColor)
	if Player[playerColor].admin then
		if bit32.band(options.expansionOptionEnabled, 4) == 4 then
			options.expansionOptionEnabled = options.expansionOptionEnabled - 4
		else
			options.expansionOptionEnabled = options.expansionOptionEnabled + 4
		end
		settingsPannelMakeButtons()
	end
end

function expansionOptionEnabledSetupPowerAbilities(clickedObject, playerColor)
    if Player[playerColor].admin then
        if bit32.band(options.expansionOptionEnabled, 8) == 8 then
            options.expansionOptionEnabled = options.expansionOptionEnabled - 8
        else
            options.expansionOptionEnabled = options.expansionOptionEnabled + 8
        end
        refreshExpansionButtons()
        settingsPannelMakeButtons()
    end
end

function expansionOptionStatusSwapGov(clickedObject, playerColor)
	if Player[playerColor].admin then
		if bit32.band(options.expansionOptionStatus, 1) == 1 then
			options.expansionOptionStatus = options.expansionOptionStatus - 1
		else
			options.expansionOptionStatus = options.expansionOptionStatus + 1
		end
		refreshExpansionButtons()
	end
end

function expansionOptionStatusReverse(clickedObject, playerColor)
	if Player[playerColor].admin then
		if bit32.band(options.expansionOptionStatus, 2) == 2 then
			options.expansionOptionStatus = options.expansionOptionStatus - 2
		else
			options.expansionOptionStatus = options.expansionOptionStatus + 2
		end
		refreshExpansionButtons()
	end
end

function decLiberalCards(clickedObject, playerColor)
	if Player[playerColor].admin then
		if options.liberalCards > 5 then
			options.liberalCards = options.liberalCards - 1
		end
		settingsPannelMakeButtons()
	end
end

function incLiberalCards(clickedObject, playerColor)
	if Player[playerColor].admin then
		if options.liberalCards < 8 then
			options.liberalCards = options.liberalCards + 1
		end
		settingsPannelMakeButtons()
	end
end

function decFascistCards(clickedObject, playerColor)
	if Player[playerColor].admin then
		if options.fascistCards > 10 then
			options.fascistCards = options.fascistCards - 1
		end
		settingsPannelMakeButtons()
	end
end

function incFascistCards(clickedObject, playerColor)
	if Player[playerColor].admin then
		if options.fascistCards < 15 then
			options.fascistCards = options.fascistCards + 1
		end
		settingsPannelMakeButtons()
	end
end

function decGreyCards(clickedObject, playerColor)
	if Player[playerColor].admin then
		if options.greyCards > 0 then
			options.greyCards = options.greyCards - 1
		end
		settingsPannelMakeButtons()
	end
end

function incGreyCards(clickedObject, playerColor)
	if Player[playerColor].admin then
		if options.greyCards < 2 then
			options.greyCards = options.greyCards + 1
		end
		settingsPannelMakeButtons()
	end
end

function decExpansionAmount(clickedObject, playerColor)
	if Player[playerColor].admin then
		if options.expansionAmount > 0 then
			options.expansionAmount = options.expansionAmount - 1
		end
		settingsPannelMakeButtons()
	end
end

function incExpansionAmount(clickedObject, playerColor)
	if Player[playerColor].admin then
		if options.expansionAmount < 4 then
			options.expansionAmount = options.expansionAmount + 1
		end
		settingsPannelMakeButtons()
	end
end

end

--adds a ja card to the list of ja card guids
function addJaCard(cardIn)
	local player = string.gsub(cardIn.getDescription(), '\'s Ja Card', '')
	jaCardGuids[player] = cardIn.getGUID()
end

--adds a nein card to the list of nein card guids
function addNeinCard(cardIn)
	local player = string.gsub(cardIn.getDescription(), '\'s Nein Card', '')
	neinCardGuids[player] = cardIn.getGUID()
end

function displayBannerCardsCoroutine()
	local tmpZone = getObjectFromGUID(bannerZoneGuid)
	local inZone = tmpZone.getObjects()
	local policyCard = nil
	local boardCard = nil

	-- get the cards
	for _, j in ipairs(inZone) do
		if isPolicyCard(j) then
			policyCard = j
		elseif isBoardCard(j) and not isSubBoardCard(j) then
			boardCard = j
		end
	end

	-- kill old banners
	if bannerGuids then
		for _, j in ipairs(bannerGuids) do
			destroyObjectByGUID(j)
		end
	end
	bannerGuids = {}

	-- display and board card handler
	if policyCard and boardCard and not topdeck then
		displayBannerCard(policyCard, -14.5, 0)
		displayBannerCard(boardCard, 20.5, 4)
		boardCardHandler(boardCard)
	else
		displayBannerCard(policyCard, 0, 0)
		if lastPres and not topdeck then
			movePlacards(nextPres(lastPres), true)
		end
	end

	topdeck = false

	-- Win check
	if lastLiberalPlayed > 5 or lastFascistPlayed > 6 then
		if not options.dealRoleCards then giveRoleCards() end
	end

	return true
end

function displayBannerCard(card, offset, bannerGuidsOffset)
	local bannerCard = {}
	local params = {sound = false}
	params.snap_to_grid = false
	params.position = {offset, 33, 144}
	bannerCard[1] = card.clone(params)
	params.position = {-offset, 33, -144}
	bannerCard[2] = card.clone(params)
	params.position = {144, 33, -offset}
	bannerCard[3] = card.clone(params)
	params.position = {-144, 33, offset}
	bannerCard[4] = card.clone(params)
	wait(5)
	bannerCard[1].setRotation({90, 180, 0})
	bannerCard[2].setRotation({90, 0, 0})
	bannerCard[3].setRotation({90, 270, 0})
	bannerCard[4].setRotation({90, 90, 0})
	for i, j in ipairs(bannerCard) do
		bannerCard[i].setScale({13, 0, 13})
		bannerCard[i].setLock(true)
		bannerCard[i].interactable = false
		bannerGuids[i + bannerGuidsOffset] = bannerCard[i].guid
	end
end

function boardCardHandler(card)
	local powerHolder = lastPres
	if bit32.band(options.expansionOptionEnabled, 4) == 4 and bit32.band(options.expansionOptionStatus, 1) == 1 then
		powerHolder = lastChan
	end
	if powerHolder then
		if isBoardCardInspect(card) then
			--expansion
			local abilitiesDeck = getDeckFromZoneByGUID(ABILITIESPILE_ZONE_GUID)
			if abilitiesDeck then
				broadcastToAll('Delaying inspect 5 seconds...', {1,1,1})
				sleep(5)
			end
			if not options.dealPartyCards then createInspectButtons(powerHolder) end
			if options.autoNotate then
				notateInfo(powerHolder, 'inspects', '', '', true)
			end
		elseif isBoardCardPickPres(card) then
			if options.autoNotate then
				notateInfo(powerHolder, 'gives pres to', '', '', true)
			end
		elseif isBoardCardBullet(card) then
			giveBullet(powerHolder)
			bulletInfo.shooterColor = powerHolder
			if options.autoNotate then
				notateInfo(powerHolder, string.lower(bulletInfo.action), '', '', true)
			end
		elseif isBoardCardImprison(card) then
			giveImprison(powerHolder)
			imprisonInfo.shooterColor = powerHolder
			if options.autoNotate then
				notateInfo(powerHolder, string.lower(imprisonInfo.action), '', '', true)
			end
		elseif isBoardCardTopCard(card) then
			smartBroadcastToColor('Examine the top card from the deck and put it back in the draw pile.', powerHolder, {1, 1, 1})
			drawCards(1, powerHolder)
			if options.autoNotate then
				notateInfo(powerHolder, 'examines deck:', '', '', false)
			end
		elseif isBoardCardTopThree(card) then
			smartBroadcastToColor('Examine the top three cards from the deck and put them back in the draw pile (right to left to keep the order).', powerHolder, {1, 1, 1})
			drawCards(3, powerHolder)
			if options.autoNotate then
				notateInfo(powerHolder, 'examines deck:', '', '', false)
			end
		end
	else
		printToAll('ERROR: Player ' .. powerHolder .. ' not found.', {1,0,0})
	end

	if powerHolder and lastPres then
		if isBoardCardPickPres(card) then
			local saveForcePres = forcePres
			forcePres = nil
			movePlacards(powerHolder, true)
			if saveForcePres then
				forcePres = saveForcePres
			else
				forcePres = nextPres(lastPres)
			end
		else
			movePlacards(nextPres(lastPres), true)
		end
	end
end

function nextPres(playerIn)
	local nextList
	if bit32.band(options.expansionOptionStatus, 2) == 2 then
		nextList = {White = 'Maroon', Brown = 'White', Red = 'Brown', Orange = 'Red', Yellow = 'Orange', Green = 'Yellow', Teal = 'Green', Blue = 'Teal', Purple = 'Blue', Pink = 'Purple', Tan = 'Pink', Maroon = 'Tan'}
	else
		nextList = {White = 'Brown', Brown = 'Red', Red = 'Orange', Orange = 'Yellow', Yellow = 'Green', Green = 'Teal', Teal = 'Blue', Blue = 'Purple', Purple = 'Pink', Pink = 'Tan', Tan = 'Maroon', Maroon = 'White'}
	end
	local checkPres = playerIn
	local returnVal = nextList[checkPres]

	while not inTable(players, returnVal) or (_G.playerStatus[returnVal] == 3) or (_G.playerStatus[returnVal] > 4)  do
		checkPres = returnVal
		returnVal = nextList[checkPres]
	end

	return returnVal
end

function movePlacards(playerIn, returnVoteCards)
	local moveToPlayer = playerIn
	if forcePres then
		moveToPlayer = forcePres
		forcePres = nil
	end

	--Expansion
	expansionCounters()

	if options.scriptedVoting and returnVoteCards then
		returnVoteCardsToHand()
		disableVote = false
		blockDraw = false
		votePassed = false
	end

	local tmpPres = getObjectFromGUID(PRESIDENT_GUID)
	tmpPres.setVar('lastPres', moveToPlayer)
	if tmpPres then giveObjectToPlayer(tmpPres, moveToPlayer, {forward = 11, right = 0, up = 0, forceHeight = 2.2}, NO_ROT, false, false) end
	local tmpChan = getObjectFromGUID(CHANCELOR_GUID)
	if tmpChan then giveObjectToPlayer(tmpChan, moveToPlayer, {forward = 11, right = 0, up = 0, forceHeight = 2.8}, NO_ROT, false, false) end
end

function giveBullet(playerIn)
	giveBulletImprison(playerIn, bulletInfo, "markDead")
end

function markDead(tableIn)
	if type(tableIn) == 'table' then
		local victimColor = closestPlayer(tableIn[1], players, 18)
		if victimColor and victimColor ~= bulletInfo.shooterColor then
			bulletInfo.shooterColor = nil
			_G.playerStatus[victimColor] = 5
			refreshStatusButtons()
			Wait.time(function() tableIn[1].setLock(true) end, 2)
			if options.autoNotate then
				if notate.line and notate.action == string.lower(bulletInfo.action) then
					notateColor2ByObject(tableIn)
				end
			end
		end
	end
end

function giveImprison(playerIn)
	giveBulletImprison(playerIn, imprisonInfo, "markImprisoned")
end

function markImprisoned(tableIn)
	if type(tableIn) == 'table' then
		local victimColor = closestPlayer(tableIn[1], players, 18)
		if victimColor and victimColor ~= imprisonInfo.shooterColor then
			imprisonInfo.shooterColor = nil
			_G.playerStatus[victimColor] = 7
			refreshStatusButtons()
			Wait.time(function() tableIn[1].setLock(true) end, 2)
			if options.autoNotate then
				if notate.line and notate.action == string.lower(imprisonInfo.action) then
					notateColor2ByObject(tableIn)
				end
			end
		end
	end
end

function giveBulletImprison(playerIn, itemInfo, funcName)
	local params = {type = itemInfo.type, sound = false}
	local item = spawnObject(params)
	custom = {
		mesh = itemInfo.mesh,
		diffuse = itemInfo.diffuse,
		assetbundle = itemInfo.assetbundle,
		assetbundle_secondary = itemInfo.assetbundle_secondary,
		image = itemInfo.image,
		convex = itemInfo.convex,
		material = itemInfo.material,
		specular_color = itemInfo.specular_color,
		specular_intensity = itemInfo.specular_intensity,
		specular_sharpness = itemInfo.specular_sharpness,
		fresnel_strength = itemInfo.fresnel_strength
	}
	item.use_grid = itemInfo.use_grid
	item.setCustomObject(custom)
	item.setColorTint(itemInfo.colorTint)
	item.setScale(itemInfo.scale)
	item.setLuaScript(
			'function onDrop(playerColor)\r\n' ..
			'	Global.call(\'' .. funcName .. '\', {self})\r\n' ..
			'end\r\n')
	wait(5)
	if (bulletsToDelete == nil) then
		bulletsToDelete = {}
	end
	table.insert(bulletsToDelete, item.guid)
	item.setPosition({0, 30, 0})
	giveObjectToPlayer(item, playerIn, {forward = 20, right = 0, up = 0, forceHeight = 6}, NO_ROT)
end

function createPolicyCardWait()
	
	if policyWaitId then
		Wait.stop(policyWaitId)
	end
	policyWaitId = Wait.time(function() startPolicyCardCheck() end, 1)
end

function startPolicyCardCheck()
	if (started ~= true) then
		return false
	end
	if not Global.getVar('hold') then
		Global.setVar('hold', true)
		startLuaCoroutine(Global, 'policyCardCoroutine')
	end
end

function policyCardCoroutine()
	local cardLists = {}
	local drawZone = nil
	local discardZone = nil

	local homeTracker = function()
		local tracker = getObjectFromGUID(ELECTION_TRACKER_GUID)
		if tracker then
			tracker.setPositionSmooth(electionTrackerOrgPos)
			tracker.setRotationSmooth({0, 315, 0})
		end
	end

	local movePrevPlacards = function()
		if lastPres and lastChan then
			local tmpPres = getObjectFromGUID(PREV_PRESIDENT_GUID)
			if tmpPres then giveObjectToPlayer(tmpPres, lastPres, {forward = 11, right = 0, up = 0, forceHeight = 1.1}, NO_ROT, false, false) end
			local tmpChan = getObjectFromGUID(PREV_CHANCELOR_GUID)
			if tmpChan then giveObjectToPlayer(tmpChan, lastChan, {forward = 11, right = 0, up = 0, forceHeight = 1.1}, NO_ROT, false, false) end
		end
	end

	local homePrevPlacards = function()
		local tmpPres = getObjectFromGUID(PREV_PRESIDENT_GUID)
		if tmpPres then
			tmpPres.setRotationSmooth(PREV_PRESIDENT_ROT, false, false)
			tmpPres.setPositionSmooth(PREV_PRESIDENT_POS, false, false)
		end
		local tmpChan = getObjectFromGUID(PREV_CHANCELOR_GUID)
		if tmpChan then
			tmpChan.setRotationSmooth(PREV_CHANCELOR_ROT, false, false)
			tmpChan.setPositionSmooth(PREV_CHANCELOR_POS, false, false)
		end
	end

	drawZone = getObjectFromGUID(DRAW_ZONE_GUID)
	discardZone = getObjectFromGUID(DISCARD_ZONE_GUID)

	if drawZone == nil or discardZone == nil then
		return true
	end

	-- Get the status of all cards and decks from the zones
	cardLists = getPolicyCardStatus(true)

	-- protect the cards
	if #cardLists.drawDeckList == 1 and #cardLists.drawList > 1 then
		local tmpDeck = getObjectFromGUID(cardLists.drawDeckList[1])
		if tmpDeck then
			tmpDeck.interactable = false
		end
	end
	if #cardLists.discardDeckList == 1 and #cardLists.discardList > 1 then
		local tmpDeck = getObjectFromGUID(cardLists.discardDeckList[1])
		if tmpDeck then
			tmpDeck.interactable = false
		end
	end

	--Expansion
	tmpObj = getDeckFromZoneByGUID(ABILITIESPILE_ZONE_GUID)
	if tmpObj then tmpObj.interactable = false end
	tmpObj = getDeckFromZoneByGUID(EFFECTSPILE_ZONE_GUID)
	if tmpObj then tmpObj.interactable = false end

	-- Msg if cards are added to the draw deck
	if lastDrawCt and #cardLists.drawList > lastDrawCt and #cardLists.drawDeckList == 1 then
		broadcastToAll('WARNING: One or more cards have been added to the draw deck!', {1,0,0})
	end
	lastDrawCt = #cardLists.drawList

	if started and #cardLists.fascistList > options.fascistCards then
		broadcastToAll('CHEATING DETECTED: Too many ' .. text.fascistAbbr ..  ' ' .. text.policy .. ' cards.', {1,0,0})
	end
	if started and #cardLists.liberalList > options.liberalCards then
		broadcastToAll('CHEATING DETECTED: Too many ' .. text.liberalAbbr ..  ' ' .. text.policy .. ' cards.', {1,0,0})
	end
	if started and #cardLists.greyList > options.greyCards then
		broadcastToAll('CHEATING DETECTED: Too many ' .. text.greyAbbr ..  ' ' .. text.policy .. ' cards.', {1,0,0})
	end

	-- Location of all cards is known
	if started and #cardLists.fascistList == options.fascistCards and #cardLists.liberalList == options.liberalCards and #cardLists.greyList == options.greyCards and (#cardLists.discardDeckList == 0 or #cardLists.discardDeckList == 1) then
		-- Reshuffle
		local autoNotateReshuffle = false
		if #cardLists.drawList < 3 and #cardLists.discardDeckList == 1 and (#cardLists.drawDeckList == 0 or #cardLists.drawDeckList == 1) then
			if cardLists.drawDeckList[1] then
				local tmpDeck = getObjectFromGUID(cardLists.drawDeckList[1])
				pos = tmpDeck.getPosition()
			else
				pos = getPositionByGUID(DRAW_ZONE_GUID)
			end
			broadcastToAll('Starting reshuffle...', {1,1,1})
			local discardDeck = getObjectFromGUID(cardLists.discardDeckList[1])
			discardDeck.setPositionSmooth({pos['x'], 3, pos['z']}, false, true)
			sleep(2)
			local expectedCards = #cardLists.drawList + #cardLists.discardList
			local drawDeck = getDeckFromZoneByGUID(DRAW_ZONE_GUID)
			if drawDeck and #drawDeck.getObjects() == expectedCards then
				lastDrawCt = expectedCards
				drawDeck.shuffle()
				broadcastToAll('reshuffle done.', {1,1,1})
				if options.autoNotate then
					autoNotateReshuffle = true
				end
				local discardPileBoard = getObjectFromGUID(discardPileBoard_guid)
				if discardPileBoard then
					discardPileBoard.setName(0)
				end
			else
				broadcastToAll('ERROR: reshuffle FAILED! Please fix the issue.', {1,0,0})
				startLuaCoroutine(Global, 'disableSecurityCoroutine')
				return true
			end
		end

		-- Banners and board card handler
		if #cardLists.liberalPlayedList > 0 and (#cardLists.liberalPlayedList + #cardLists.liberalNotUsedList) > lastLiberalPlayed then
			lastLiberalPlayed = #cardLists.liberalPlayedList + #cardLists.liberalNotUsedList
			bannerZoneGuid = liberal_zone_guids[lastLiberalPlayed]
			tmpZone = getObjectFromGUID(bannerZoneGuid)
			inZone = tmpZone.getObjects()
			local cardType = nil
			for i, j in ipairs(inZone) do
				if isLiberalPolicyCard(j) and not j.is_face_down then
					cardType = text.liberalLetter
				elseif isGreyPolicyCard(j) and not j.is_face_down then
					cardType = text.greyLetter
				end
			end
			if cardType then
				if options.autoNotate then
					if topdeck then
						notateInfo('', 'Topdeck:', '', '[0080F8]' .. cardType .. '[-]', false)
					elseif bit32.band(options.expansionOptionStatus, 1) == 1 then
						notateInfo(lastChan, '>', lastPres, '[0080F8]' .. cardType .. '[-]', false)
					else
						notateInfo(lastPres, '>', lastChan, '[0080F8]' .. cardType .. '[-]', false)
					end
					homeTracker()
				end
				if topdeck then
					homePrevPlacards()
				else
					movePrevPlacards()
				end
				startLuaCoroutine(Global, 'displayBannerCardsCoroutine')
			else
				lastLiberalPlayed = 0 -- didn't find the card
			end
		elseif #cardLists.fascistPlayedList > 0 and (#cardLists.fascistPlayedList + #cardLists.fascistNotUsedList) > lastFascistPlayed then
			lastFascistPlayed = #cardLists.fascistPlayedList + #cardLists.fascistNotUsedList
			bannerZoneGuid = fascist_zone_guids[lastFascistPlayed]
			tmpZone = getObjectFromGUID(bannerZoneGuid)
			inZone = tmpZone.getObjects()
			local cardType = nil
			for i, j in ipairs(inZone) do
				if isFascistPolicyCard(j) and not j.is_face_down then
					cardType = text.fascistLetter
				elseif isGreyPolicyCard(j) and not j.is_face_down then
					cardType = text.greyLetter
				end
			end
			if cardType then
				if options.autoNotate then
					if topdeck then
						notateInfo('', 'Topdeck:', '', '[FF0000]' .. cardType .. '[-]', false)
					elseif bit32.band(options.expansionOptionStatus, 1) == 1 then
						notateInfo(lastChan, '>', lastPres, '[FF0000]' .. cardType .. '[-]', false)
					else
						notateInfo(lastPres, '>', lastChan, '[FF0000]' .. cardType .. '[-]', false)
					end
					homeTracker()
					if lastFascistPlayed == 4 then notateInfo('', '', '', '[FF0000]' .. text.hitler .. ' territory![-]', false) end
				end
				if topdeck then
					homePrevPlacards()
				else
					movePrevPlacards()
				end
				startLuaCoroutine(Global, 'displayBannerCardsCoroutine')
			else
				lastFascistPlayed = 0 -- didn't find the card
			end
		end
		if autoNotateReshuffle then notateInfo('', '', '', '*Reshuffle*', false) end
		if lastLiberalPlayed or lastFascistPlayed then
			-- Lock placed policy cards
			if boardCardWaitId then
				Wait.stop(boardCardWaitId)
			end
			boardCardWaitId = Wait.time(
				function()
					testReadyToLock(
						function(p)
							return isPolicyCard(p) and not p.is_face_down
						end, boardCardWaitId)
				end, 1, -1)
		end
	end

	Global.setVar('hold', false)

	return true
end

function getPolicyCardStatus(removeCards)
	local returnTable = {}
	returnTable.fascistList = {}
	returnTable.fascistPlayedList = {}
	returnTable.fascistNotUsedList = {}
	returnTable.liberalList = {}
	returnTable.liberalPlayedList = {}
	returnTable.liberalNotUsedList = {}
	returnTable.greyList = {}
	returnTable.drawList = {}
	returnTable.drawDeckList = {}
	returnTable.discardList = {}
	returnTable.discardDeckList = {}
	local removeCt = 0
	local cardError = false
	local drawZone = nil
	local discardZone = nil

	drawZone = getObjectFromGUID(DRAW_ZONE_GUID)
	discardZone = getObjectFromGUID(DISCARD_ZONE_GUID)

	local inZone = drawZone.getObjects()
	for i, j in ipairs(inZone) do
		if isFascistPolicyCard(j) then
			smartTableInsert(returnTable.fascistList, j.guid)
			smartTableInsert(returnTable.drawList, j.guid)
			smartTableInsert(returnTable.drawDeckList, j.guid)
		elseif isLiberalPolicyCard(j) then
			smartTableInsert(returnTable.liberalList, j.guid)
			smartTableInsert(returnTable.drawList, j.guid)
			smartTableInsert(returnTable.drawDeckList, j.guid)
		elseif isGreyPolicyCard(j) then
			smartTableInsert(returnTable.greyList, j.guid)
			smartTableInsert(returnTable.drawList, j.guid)
			smartTableInsert(returnTable.drawDeckList, j.guid)
		elseif j.tag == 'Deck' then
			smartTableInsert(returnTable.drawDeckList, j.guid)
			local inDeck = j.getObjects()
			for k, l in ipairs(inDeck) do
				if l.description == FASCISTPOLICY_STRING then
					smartTableInsert(returnTable.fascistList, l.guid)
					smartTableInsert(returnTable.drawList, l.guid)
				elseif l.description == LIBERALPOLICY_STRING then
					smartTableInsert(returnTable.liberalList, l.guid)
					smartTableInsert(returnTable.drawList, l.guid)
				elseif l.description == GREYPOLICY_STRING then
					smartTableInsert(returnTable.greyList, l.guid)
					smartTableInsert(returnTable.drawList, l.guid)
				elseif removeCards and removeCt < (#inDeck - 1) then
					local params = {}
					params.position = {0,5,0}
					params.guid = l.guid
					local card = j.takeObject(params)
					if not cardError then
						cardError = true
						printToAll('ERROR: That is not a policy card.', {1,0,0})
					end
					removeCt = removeCt + 1
				end
			end
		end
	end
	removeCt = 0
	inZone = discardZone.getObjects()
	for i, j in ipairs(inZone) do
		if j.tag == 'Deck' then
			smartTableInsert(returnTable.discardDeckList, j.guid)
			local inDeck = j.getObjects()
			for k, l in ipairs(inDeck) do
				if l.description == FASCISTPOLICY_STRING then
					smartTableInsert(returnTable.fascistList, l.guid)
					smartTableInsert(returnTable.discardList, l.guid)
				elseif l.description == LIBERALPOLICY_STRING then
					smartTableInsert(returnTable.liberalList, l.guid)
					smartTableInsert(returnTable.discardList, l.guid)
				elseif l.description == GREYPOLICY_STRING then
					smartTableInsert(returnTable.greyList, l.guid)
					smartTableInsert(returnTable.discardList, l.guid)
				elseif removeCards and removeCt < (#inDeck - 1) then
					local params = {}
					params.position = {0,5,0}
					params.guid = l.guid
					local card = j.takeObject(params)
					if not cardError then
						cardError = true
						printToAll('ERROR: That is not a policy card.', {1,0,0})
					end
					removeCt = removeCt + 1
				end
			end
		end
	end
	local tmpZoneGuid
	local tmpZone
	local cardFound = false
	for i = #liberal_zone_guids, 1, -1 do
		tmpZone = getObjectFromGUID(liberal_zone_guids[i])
		if tmpZone then
			inZone = tmpZone.getObjects()
			for _, j in ipairs(inZone) do
				if isLiberalPolicyCard(j) then
					smartTableInsert(returnTable.liberalList, j.guid)
					smartTableInsert(returnTable.liberalPlayedList, j.guid)
					cardFound = true
				elseif isGreyPolicyCard(j) then
					smartTableInsert(returnTable.greyList, j.guid)
					smartTableInsert(returnTable.liberalPlayedList, j.guid)
					cardFound = true
				elseif isPolicyNotUsedCard(j) and cardFound then
					smartTableInsert(returnTable.liberalNotUsedList, j.guid)
				end
			end
		end
	end
	cardFound = false
	for i = #fascist_zone_guids, 1, -1 do
		tmpZone = getObjectFromGUID(fascist_zone_guids[i])
		if tmpZone then
			inZone = tmpZone.getObjects()
			for _, j in ipairs(inZone) do
				if isFascistPolicyCard(j) then
					smartTableInsert(returnTable.fascistList, j.guid)
					smartTableInsert(returnTable.fascistPlayedList, j.guid)
					cardFound = true
				elseif isGreyPolicyCard(j) then
					smartTableInsert(returnTable.greyList, j.guid)
					smartTableInsert(returnTable.fascistPlayedList, j.guid)
					cardFound = true
				elseif isPolicyNotUsedCard(j) and cardFound then
					smartTableInsert(returnTable.fascistNotUsedList, j.guid)
				end
			end
		end
	end

	return returnTable
end

function allPolicyCardsKnown()
	local cardLists = {}

	cardLists = getPolicyCardStatus(false)
	if started and #cardLists.fascistList == options.fascistCards and #cardLists.liberalList == options.liberalCards and #cardLists.greyList == options.greyCards and #cardLists.drawDeckList == 1 and (#cardLists.discardDeckList == 0 or #cardLists.discardDeckList == 1) then
		return true
	end

	return false
end

function createVoteWait()
	if started == true and not disableVote then
		if voteWaitId then
			Wait.stop(voteWaitId)
		end
		voteWaitId = Wait.time(function() startVoteCheck() end, 1)
	end
end

function startVoteCheck()
	if (started == false or started == nil) then
		return false
	end
	local jaVote
	local neinVote
	local voteDone = true
	local pos
	votes = {}

	for i, playerColor in pairs(players) do
		jaVote = 0
		neinVote = 0
		jaCard = getObjectFromGUID(jaCardGuids[playerColor])
		neinCard = getObjectFromGUID(neinCardGuids[playerColor])
		if greyPlayer(playerColor) then
			ph = getObjectFromGUID(greyPlayerHandGuids[playerColor])
			if ph then
				pos = ph.getPosition()
				pos = {x = pos['x'], y = pos['y'], z = pos['z'] - 2.26}
			end
		else
			local ph = Player[playerColor].getPlayerHand()
			if ph then
				pos = {x = ph['pos_x'], y = ph['pos_y'], z = ph['pos_z']}
			end
		end
		if pos and jaCard and neinCard and not (_G.playerStatus[playerColor] > 3) then
			local distance = findDistance(jaCard.getPosition(), pos);
			if distance > 8 then
				if jaCard.is_face_down and not jaCard.held_by_color then
					jaVote = 1
				else
					voteDone = false
				end
			end
			distance = findDistance(neinCard.getPosition(), pos);
			if distance > 8 then
				if neinCard.is_face_down and not neinCard.held_by_color then
					neinVote = -1
				else
					voteDone = false
				end
			end
		end
		votes[playerColor] = jaVote + neinVote
		if (jaVote + neinVote) == 0 and not (_G.playerStatus[playerColor] > 3) then
			voteDone = false
		end
	end

	if voteDone then
		voteNotes = getFinalVoteString()
		setNotes(voteNotes .. '\n\n' .. mainNotes)
		local presColor = getPres()
		local chanColor = getChan()
		local out = '[' .. stringColorToHex(presColor) .. ']' .. presColor .. '[-] > '
		out = out .. '[' .. stringColorToHex(chanColor) .. ']' .. chanColor .. '[-]\n'
		out = out .. voteNotes
		if voteNotebook == '' then
			voteNotebook = out
		else
			voteNotebook = voteNotebook .. '\n\n' .. out
		end
		lastVote = out
		for _, lastVoteGuid in ipairs(lastVote_guids) do
			local lastVoteObj = getObjectFromGUID(lastVoteGuid)
			if lastVoteObj then 
				lastVoteObj.setScale({4.00, 4.00, 5.00})
				lastVoteObj.TextTool.setValue(removeBBCode(out))
				lastVoteObj.setScale({5.00, 5.00, 5.00})
			end
		end
		flipVotes()
		disableVote = true
		if string.find(out, 'Vote passes') then
			votePassed = true
		else
			votePassed = false
		end
	else
		voteNotes = getPrelimVoteString()
		setNotes(voteNotes .. '\n\n' .. mainNotes)
	end
end

function expansionCounters()
	local allObjs = getAllObjects()
	local tmpObj

	for _, tmpObj in ipairs(allObjs) do
		if tmpObj then
			if tmpObj.tag == 'Counter' and (string.match(tmpObj.getName(), 'Turns') or string.match(tmpObj.getName(), 'Rounds')) then
				tmpObj.Counter.decrement()
			end
		end
	end
end

function waitReturnVoteCardsCoroutine()
	if (started == false or started == nil) then
		return false
	end
	
	sleep(2)
	returnVoteCardsToHand()
	disableVote = false
	blockDraw = false
	votePassed = false

	return true
end

function flipVotes()
	for i, playerColor in pairs(players) do
		jaCard = getObjectFromGUID(jaCardGuids[playerColor])
		neinCard = getObjectFromGUID(neinCardGuids[playerColor])
		if greyPlayer(playerColor) then
			ph = getObjectFromGUID(greyPlayerHandGuids[playerColor])
			if ph then
				pos = ph.getPosition()
				pos = {x = pos['x'], y = pos['y'], z = pos['z'] - 2.26}
			end
		else
			local ph = Player[playerColor].getPlayerHand()
			if ph then
				pos = {x = ph['pos_x'], y = ph['pos_y'], z = ph['pos_z']}
			end
		end
		if pos and jaCard and neinCard and not (_G.playerStatus[playerColor] > 3) then
			local distance = findDistance(jaCard.getPosition(), pos);
			if distance > 8 then jaCard.flip() end
			distance = findDistance(neinCard.getPosition(), pos);
			if distance > 8 then neinCard.flip() end
		end
	end
end

function returnVoteCardsToHand()
	for i, playerColor in pairs(players) do
		jaCard = getObjectFromGUID(jaCardGuids[playerColor])
		neinCard = getObjectFromGUID(neinCardGuids[playerColor])
		if jaCard and neinCard then
			if greyPlayer(playerColor) then
				giveObjectToPlayer(jaCard, playerColor, {forward = GREY_FORWARD, right = GREY_RIGHT, up = GREY_UP}, {x = 0, y = 180, z = 180, exactRot = true}, false, true)
				giveObjectToPlayer(neinCard, playerColor, {forward = GREY_FORWARD, right = GREY_RIGHT, up = GREY_UP}, {x = 0, y = 180, z = 180, exactRot = true}, false, true)
			else
				local jaCardRot = jaCard.getRotation()
				local neinCardRot = neinCard.getRotation()
				giveObjectToPlayer(jaCard, playerColor, {forward = 0, right = 0, up = 0}, {x = jaCardRot["x"], y = jaCardRot["y"], z = jaCardRot["z"], exactRot = true}, false, true)
				giveObjectToPlayer(neinCard, playerColor, {forward = 0, right = 0, up = 0}, {x = neinCardRot["x"], y = neinCardRot["y"], z = neinCardRot["z"], exactRot = true}, false, true)
			end
		end
	end
end

function getFinalVoteString()
	local jaCount = 0
	local neinCount = 0
	local out = '[i]Ja votes[/i]: '
	for i, playerColor in pairs(ALL_PLAYABLE_COLORS) do -- used for the order
		if votes[playerColor] == 1 and inTable(players, playerColor) then
			if string.sub(out, -1) == ']' then out = out .. ', ' end
			out = out .. '[' .. stringColorToHex(playerColor) .. ']' .. playerColor .. '[-]'
			jaCount = jaCount + 1
		end
	end
	if jaCount == 0 then out = out .. 'None' end
	out = out .. '[/i]\n[i]Nein votes[/i]:[i] '
	for i, playerColor in pairs(ALL_PLAYABLE_COLORS) do -- used for the order
		if votes[playerColor] == -1 and inTable(players, playerColor) then
			if string.sub(out, -1) == ']' then out = out .. ', ' end
			out = out .. '[' .. stringColorToHex(playerColor) .. ']' .. playerColor .. '[-]'
			neinCount = neinCount + 1
		end
	end
	if neinCount == 0 then out = out .. 'None' end
	out = out .. '[/i]'
	if jaCount > neinCount then
		broadcastToAll('Vote passes', stringColorToRGB('Green'))
		out = '[' .. stringColorToHex('Green') .. ']-<<<<· Vote passes <══¦-•\n' .. '[-]' .. out
	else
		broadcastToAll('Vote fails', stringColorToRGB('Red'))
		out = '[' .. stringColorToHex('Red') .. ']-<<<<· Vote fails <══¦-•\n' .. '[-]' .. out
		if options.autoNotate and recordDownvotes then
			local lineSave = noteTakerCurrLine
			noteTakerCurrLine = #noteTakerNotes
			if not noteTakerBlankLine(noteTakerCurrLine) then
				addNewLine()
				noteTakerCurrLine = #noteTakerNotes
			end
			noteTakerNotes[noteTakerCurrLine].color1 = getPres()
			noteTakerNotes[noteTakerCurrLine].action = '>'
			noteTakerNotes[noteTakerCurrLine].color2 = getChan()
			noteTakerNotes[noteTakerCurrLine].result = '[222222]Downvoted[-]'
			noteTakerCurrLine = lineSave
			refreshNotes(nil)
		end
		local tracker = getObjectFromGUID(ELECTION_TRACKER_GUID)
		if tracker then
			tracker.translate({electionTrackerMoveX, 0, 0})
		end
		movePlacards(nextPres(getPres()), false)
		startLuaCoroutine(Global, 'waitReturnVoteCardsCoroutine')
	end

	return out
end

function getPrelimVoteString()
	local out = '[u]Voted[/u]:[i] '
	for i, playerColor in pairs(ALL_PLAYABLE_COLORS) do -- used for the order
		if votes[playerColor] ~= 0 and inTable(players, playerColor) and not (_G.playerStatus[playerColor] > 3) then
			if string.sub(out, -1) == ']' then out = out .. ', ' end
			out = out .. '[' .. stringColorToHex(playerColor) .. ']' .. playerColor .. '[-]'
		end
	end
	out = out .. '[/i]\n[u]Waiting on[/u]:[i] '
	for i, playerColor in pairs(ALL_PLAYABLE_COLORS) do -- used for the order
		if votes[playerColor] == 0 and inTable(players, playerColor) and not (_G.playerStatus[playerColor] > 3) then
			if string.sub(out, -1) == ']' then out = out .. ', ' end
			out = out .. '[' .. stringColorToHex(playerColor) .. ']' .. playerColor .. '[-]'
		end
	end
	out = out .. '[/i]'

	return out
end

function editButtonByLabel(objectGUIDIn, oldLabelIn, newLabelIn, newFunctionIn)
	local bObject = getObjectFromGUID(objectGUIDIn)
	if bObject then
		local buttonList = bObject.getButtons()
		if buttonList then
			local button
			for _, button in ipairs(buttonList) do
				if button.label == oldLabelIn then
					button.label = newLabelIn
					button.click_function = newFunctionIn
					bObject.editButton(button)
				end
			end
		end
	end
end

function topdeckCard(clickedObject, playerColor)
	if started then
		if playerColor == getPres() then
			drawDeck = getDeckFromZoneByGUID(DRAW_ZONE_GUID)
			if drawDeck then
				lastPres = playerColor
				topdeck = true
				local params = {}
				params.position = {0, 2, 0}
				params.flip = true
				local card = drawDeck.takeObject(params)
				if isLiberalPolicyCard(card) then
					broadcastToAll('The topdeck is '.. text.liberalArticle .. ' ' .. text.liberal .. ' ' .. text.policy .. '!', {0.1, 0.3, 1})
				else
					broadcastToAll('The topdeck is '.. text.fascistArticle .. ' ' .. text.fascist .. ' ' .. text.policy .. '!', {1,0,0})
				end
			else
				broadcastToAll('ERROR: Draw deck not found.', {1, 0, 0})
			end
		else
			printToColor('ERROR: You are not the president.', playerColor, {1, 0, 0})
		end
	else
		printToColor('ERROR: Game not started.', playerColor, {1, 0, 0})
	end
end

function drawThree(clickedObject, playerColor)
	if started then
		local drawPlayer = getPres()
		local drawPlayerText = 'president'
		if bit32.band(options.expansionOptionStatus, 1) == 1 then
			drawPlayer = getChan()
			drawPlayerText = 'chancellor'
		end
		if playerColor == drawPlayer then
			if blockDraw then
				smartBroadcastToColor('ERROR: You can only draw once (move the Chancellor placard to reset).', playerColor, {1, 0, 0})
			else
				if not options.scriptedVoting or votePassed then
					blockDraw = true
					drawCards(3, playerColor)
				else
					smartBroadcastToColor('ERROR: Vote did not pass.', playerColor, {1, 0, 0})
				end
			end
		else
			smartBroadcastToColor('ERROR: You are not the ' .. drawPlayerText .. '.', playerColor, {1, 0, 0})
		end
	else
		smartBroadcastToColor('ERROR: Game not started.', playerColor, {1, 0, 0})
	end
end

function drawCards(amount, playerColor)
	local drawCt = 0
	local drawDeck = nil

	drawDeck = getDeckFromZoneByGUID(DRAW_ZONE_GUID)
	if drawDeck then
		drawCt = #drawDeck.getObjects()
		if drawCt > (amount - 1) then
			lastPres = getPres()
			lastChan = getChan()
			if greyPlayer(playerColor) then
				deal12P(amount, playerColor)
			else
				drawDeck.deal(amount, playerColor)
			end
			if amount == 1 then
				broadcastToAll('Dealing 1 card to ' .. playerColor .. '.', stringColorToRGBExtra(playerColor))
			else
				broadcastToAll('Dealing ' .. amount .. ' cards to ' .. playerColor .. '.', stringColorToRGBExtra(playerColor))
			end
		else
			broadcastToAll('ERROR: Too few cards to deal.', {1, 0, 0})
		end
	else
		broadcastToAll('ERROR: Draw deck not found.', {1, 0, 0})
	end
end

function getPres()
	local tempObj = getObjectFromGUID(PRESIDENT_GUID)
	return closestPlayer(tempObj, players, 1000)
end

function getChan()
	local tempObj = getObjectFromGUID(CHANCELOR_GUID)
	return closestPlayer(tempObj, players, 1000)
end

function onPlayerChangeColor(color)
	
	refreshUI()
	
	if ( color == "Teal" or color == "Brown" ) and Player[color].admin ~= true then
		if (btMode == 1) then
			Player[color].changeColor("Grey")
			return false
		elseif (btMode == 2) then
			Player[color].kick()
			return false
		end
	end
	
	
	if started then
		if color ~= 'Grey' and color ~= 'Black' then
			printToColor('--------------------------------------',color, {1, 1, 1})
			printToColor('Welcome! ' .. Player[color].steam_name,color, {1, 1, 1})
			printToColor('--------------------------------------',color, {1, 1, 1})
			Player[color]:print(tellRole(color))
			printToColor('--------------------------------------',color, {1, 1, 1})
			Player[color]:print(chatHelp(Player[color].admin))
		elseif color == 'Black' then
			printToAll('--------------------------------------', {1, 1, 1})
			local hcol = stringColorToRGBExtra(color)
			printToAll('All hail the omniscient Black player ' .. Player[color].steam_name, {hcol['r'], hcol['g'], hcol['b']})
			printToAll('--------------------------------------', {1, 1, 1})
			Player[color]:print(tellRole(color))
			printToColor('--------------------------------------',color, {1, 1, 1})
			Player[color]:print(chatHelp(Player[color].admin))
		end
	else
		local needRefresh = true
		if lastPlayerCt then
			if lastPlayerCt < 7 and #getSeatedPlayers() < 7 then
				needRefresh = false
			elseif lastPlayerCt > 6 and lastPlayerCt < 9 and
					 #getSeatedPlayers() > 6 and #getSeatedPlayers() < 9 then
				needRefresh = false
			elseif lastPlayerCt > 8 and #getSeatedPlayers() > 8 then
				needRefresh = false
			end
		end
		if needRefresh then
			refreshBoardCards()
		end
	end

	if options.zoneType == 6 and color ~= 'Grey' then
		local colorFound = nil

		for testColor, steamId in pairs(greyPlayerSteamIds) do
			if steamId == Player[color].steam_id then
				colorFound = testColor
				break
			end
		end
		if colorFound then
			greyPlayerSteamIds[colorFound] = nil
			destroyObjectByGUID(greyAvatarGuids[colorFound])
			local textObj = getObjectFromGUID(GREY_TEXT_GUIDS[colorFound])
			if textObj then
				textObj.TextTool.setValue(' ')
			end
		end
	end
end

function setupStart(clickedObject, playerColor)
	if Player[playerColor].admin then
		startLuaCoroutine(Global, 'setupCoroutine')
	else
		broadcastToColor('Only the host or a promoted player can start the game.', playerColor, {1,0,0})
	end
end

function table.clone(org)
  return {table.unpack(org)}
end

function setupCoroutine()
	
	--Get seated players
	players = getSeatedPlayers()

	if #players < 5 then
		printToAll('Not enough players!', {1,1,1})
		return true
	end
	
	local playersToRole = getSeatedPlayers()
	local tmpObj

	-- if its hotseat dont shuffle and turn off policy safety
	local playerOneName = Player[players[1]].steam_name
	if not playerOneName or string.match(playerOneName, 'Player %d') then
		printToAll('Hotseat game detected.', {1,1,1})
		if options.shufflePlayers then
			options.shufflePlayers = false
			printToAll('Shuffle players is now disabled.', {1,0,0})
		end
		if options.policySafety then
			options.policySafety = false
			printToAll('Policy safety is now disabled.', {1,0,0})
		end
	end

	if options.shufflePlayers then
		printToAll('Shuffling Players...', {1,1,1})
		shufflePlayers()
		printToAll('shuffling done.', {1,1,1})
	end

	--Hidden zones and status buttons
	for i, player in pairs(MAIN_PLAYABLE_COLORS) do
		if not inTable(players, player) then
			getObjectFromGUID(HIDDEN_ZONE_GUIDS[player]).setScale({0,0,0})
		else
			if options.zoneType == 1 then
				local params = {
					type = 'BlockRectangle',
					scale = {15, 0.25, 0.5},
					position = {-100, 100, -100},
					sound = false
				}
				local block = spawnObject(params)
				block.setColorTint(stringColorToRGB(player))
				block.setLock(true)
				forceObjectToPlayer(block, player, {forward = 7, right = 0, up = 0, forceHeight = 1.09}, FACE_UP_ROT)
			end
			-- Player Status Buttons
			local paramsStatus = {
				type = 'backgammon_piece_white',
				position = {-100, 100, -100},
				callback = 'statusButtonCallback',
				sound = false
			}
			local buttonStatusBase = spawnObject(paramsStatus)
			buttonStatusBase.setName(player)
			buttonStatusBase.setColorTint(stringColorToRGB(player))
			buttonStatusBase.setLock(true)
			forceObjectToPlayer(buttonStatusBase, player, {forward = 11, right = -8.5, up = 0, forceHeight = 1.09}, FACE_UP_ROT)
		end
	end
	if options.zoneType == 6 then -- Tan and Maroon
		local paramsStatus = {
			type = 'backgammon_piece_white',
			callback = 'statusButtonCallback',
			sound = false
		}
		for _, color in ipairs(GREY_PLAYABLE_COLORS) do
			if greyPlayerSteamIds[color] then
				table.insert(players, 1, color)
				local buttonStatusBase = spawnObject(paramsStatus)
				buttonStatusBase.setName(color)
				buttonStatusBase.setColorTint(stringColorToRGBExtra(color))
				buttonStatusBase.setRotation({0, 180, 0})
				buttonStatusBase.setLock(true)
				forceObjectToPlayer(buttonStatusBase, color, {forward = 11, right = -8.5, up = 0, forceHeight = 1.09}, FACE_UP_ROT)
			else
				destroyObjectByGUID(greyPlayerHandGuids[color])
			end
		end
	end

	--Expansion
	local abilitiesDeck = getDeckFromZoneByGUID(ABILITIESPILE_ZONE_GUID)
	if abilitiesDeck then
		abilitiesDeck.randomize()
		for _, player in pairs(players) do
			if greyPlayer(player) then
				for i = 1, options.expansionAmount, 1 do
					local params = {}
					local card = abilitiesDeck.takeObject(params)
					if card then
						giveObjectToPlayer(card, player, {forward = GREY_FORWARD, right = GREY_EXPANSION_RIGHT, up = GREY_UP}, FACE_DOWN_ROT, false, true)
					end
				end
			else
				abilitiesDeck.deal(options.expansionAmount, player)
			end
		end
		if bit32.band(options.expansionOptionEnabled, 8) == 8 then
			Wait.frames(function() setupPowerAbilities(abilitiesDeck) end, 2)
		end
	else
		local tmpZone = getObjectFromGUID(ABILITIESPILE_ZONE_GUID)
		if tmpZone then
			local inZone = tmpZone.getObjects()
			for _, j in ipairs(inZone) do
				destroyObject(j)
			end
			destroyObject(tmpZone)
		end
		tmpZone = getObjectFromGUID(EFFECTSPILE_ZONE_GUID)
		if tmpZone then
			inZone = tmpZone.getObjects()
			for _, j in ipairs(inZone) do
				destroyObject(j)
			end
			destroyObject(tmpZone)
		end
	end

	--spawn note taker(s)
	local params = {position = {-100, 100, -100}, sound = false}
	if options.noteType == 1 then
		params.type = 'Chess_Board'
		params.scale = {1.55, 1.55, 1.55}
	elseif options.noteType == 2 then
		params.type = 'Go_Board'
		params.scale = {1.45, 1.45, 1.45}
	elseif options.noteType == 3 then
		params.type = 'Checker_Board'
		params.scale = {1.55, 1.55, 1.55}
	elseif options.noteType == 4 then
		params.type = 'reversi_board'
		params.scale = {1.45, 1.45, 1.45}
	elseif options.noteType == 5 then
		params.type = 'Custom_Board'
		params.scale = {1, 1, 1}
	elseif options.noteType == 6 then
		params.type = 'Custom_Model'
		params.scale = {1.05, 1.05, 1.05}
	elseif options.noteType > 6 then
		params.type = 'backgammon_board'
		params.scale = {1.8, 1.8, 1.8}
	end
	for _, player in pairs(players) do
		if not greyPlayer(player) then
			if Player[player].admin or options.noteType > 6 then
				local notetaker = spawnObject(params)
				if options.noteType < 7 then
					notetaker.setLuaScript(newNoteTakerLuaScript(player, 'true', 'false', 'false', 'false', 'false', 'true'))
				elseif options.noteType == 7 then
					notetaker.setLuaScript(newNoteTakerLuaScript(player, 'false', 'false', 'false', 'false', 'false', 'false'))
				elseif options.noteType == 8 then
					notetaker.setLuaScript(newNoteTakerLuaScript(player, 'false', 'true', 'false', 'false', 'false', 'false'))
				end
				if options.noteType == 5 then
					local custom = {}
					custom.image = 'http://cloud-3.steamusercontent.com/ugc/486766424829587499//FDF54ECD5D1706DE0A590239E84D62CDE757FE46/'
					notetaker.setCustomObject(custom)
				elseif options.noteType == 6 then
						local custom = {}
						custom.diffuse = 'http://cloud-3.steamusercontent.com/ugc/478894184492866532/6639B6E1AB511AB10D53DB91B2A47A0A63410DDF/'
						custom.mesh = 'http://cloud-3.steamusercontent.com/ugc/478894184492865468/51C18F993BBDD5D1B55FE5261A625B2CE0B2FD9F/'
						custom.type = 4
						custom.material = 3
						notetaker.setCustomObject(custom)
				end
			end
		end
	end

	--hide the settings pannel
	--destroyObjectByGUID(settingsPannel_guid)
	panel = getObjectFromGUID(settingsPannel_guid)
	panel.setPosition({32.91, -27.15, 0.00})
	panel.setScale({0.10, 0.10, 0.10})
	panel.setRotation({0.00, 180.00, 180.00})
	
	
	local numFascists = 0

	--figure out number of fascists
	numFascists = math.floor((#players-3)/2)
	--[[if #players > 10 then
		numFascists = 4
	elseif #players > 8 then
		numFascists = 3
	elseif #players > 6 then
		numFascists = 2
	else
		numFascists = 1
	end]]--

	printToAll( #players .. ' player game starting!', {1,1,1})
	
	--do roles
	
	
	local randomPlayer = math.random(#playersToRole)
	roles[playersToRole[randomPlayer]] = 'hitler'
	table.insert(hitler, 1, playersToRole[randomPlayer])
	if options.dealPartyCards then
		giveUsableCard(copyPartyCards[1], playersToRole[randomPlayer])
	end
	table.remove(playersToRole, randomPlayer)
	
	for i = 1, numFascists do
		randomPlayer = math.random(#playersToRole)
		roles[playersToRole[randomPlayer]] = 'fascist'
		table.insert(fascists, 1, playersToRole[randomPlayer])
		
		if options.dealPartyCards then
			giveUsableCard(copyPartyCards[1], playersToRole[randomPlayer])
		end
		table.remove(playersToRole, randomPlayer)
	end
	
	for i, player in ipairs(playersToRole) do
		roles[player] = 'liberal'
		if options.dealPartyCards then
			giveUsableCard(copyPartyCards[2], player)
		end
	end
	
	if (options.dealRoleCards) then
		giveRoleCards()
	end
	
	wait(5)

	-- this part is all for notes on info of the game
	mainNotes = 'For long games the old notes will be\nremoved automatically by the note taker.\nThis is functionality does not work well when\nenabling player names in the notes.\n\n'
	mainNotes = mainNotes .. 'Only the president can draw cards.\n\nTo topdeck a card move the election tracker\nto the \34REVEAL & PASS TOP POLICY\34 circle.\n\n'
	if not options.dealRoleCards then
		mainNotes = mainNotes .. '[FFFF00]No role cards will be dealt.[-]\n\n'
	end
	if not options.dealPartyCards then
		mainNotes = mainNotes .. '[FFFF00]No party membership cards will be dealt.[-]\n\n'
	end
	mainNotes = mainNotes .. 'There are [0000FF][b]' .. #players - #fascists - #hitler .. ' ' .. string.upper(text.liberal) .. 'S[/b][-]\nagainst '
	if #fascists > 0 then
		mainNotes = mainNotes .. '[FF0000][b]' .. #fascists .. ' ' .. string.upper(text.fascist) .. '[/b][-]'
	end
	if #hitler > 1 and #fascists > 0 then
		mainNotes = mainNotes .. ','
	end
	if #hitler > 1 then
		mainNotes = mainNotes .. ' [FF0000][b]' .. #hitler - 1 .. ' FAKE ' .. string.upper(text.hitler)
	end
	if #hitler == 2 then
		mainNotes = mainNotes .. '[/b][-]'
	elseif #hitler > 2 then
		mainNotes = mainNotes .. 'S[/b][-]'
	end
	mainNotes = mainNotes .. ' and [FF0000][b]' .. string.upper(text.hitler) .. '[/b][-].\n'
	mainNotes = mainNotes .. string.upper(text.hitler)
	if #players < 7 then
		mainNotes = mainNotes .. ' [b]knows[/b] who the '
	else
		mainNotes = mainNotes .. ' [b]doesn\'t know[/b] who the '
	end
	mainNotes = mainNotes .. string.upper(text.fascist) .. 'S are.\n\n'
	setNotes(mainNotes)

	-- Pick a random first president
	local randomPlayer = math.random(#players)
	local president = getObjectFromGUID(PRESIDENT_GUID)
	local pos = president.getPosition()
	president.setVar('lastPres', players[randomPlayer])
	president.setPositionSmooth({0, pos['y']+7, 0})
	local chancelor = getObjectFromGUID(CHANCELOR_GUID)
	pos = chancelor.getPosition()
	chancelor.setPositionSmooth({0, pos['y']+14, 0})

	-- Policy card setup
	for i = 1, options.liberalCards do
		spawnLiberalPolicy(getPositionByGUID(DRAW_ZONE_GUID), FACE_DOWN_ROT)
	end
	for i = 1, options.fascistCards do
		spawnFascistPolicy(getPositionByGUID(DRAW_ZONE_GUID), FACE_DOWN_ROT)
	end
	for i = 1, options.greyCards do
		spawnGreyPolicy(getPositionByGUID(DRAW_ZONE_GUID), FACE_DOWN_ROT)
	end

	sleep(0.5)

	-- Tell everyone their role
	printToAll('--------------------------------------', {1,1,1})
	for _, color in ipairs(players) do
		if greyPlayer(color) then
			local playerObj = getPlayerObj(color)
			if playerObj then
				playerObj:print(tellRole(color))
			end
		else
			Player[color]:print(tellRole(color))
		end
	end
	printToAll('--------------------------------------', {1,1,1})

	-- Move and tell first pres
	giveObjectToPlayer(president, players[randomPlayer], {forward = 11, right = 0, up = 0, forceHeight = 3}, NO_ROT)
	giveObjectToPlayer(chancelor, players[randomPlayer], {forward = 11, right = 0, up = 0, forceHeight = 5.5}, NO_ROT)
	local hcol = stringColorToRGBExtra(players[randomPlayer])
	printToAll(players[randomPlayer] .. ' is first president!', hcol)
	printToAll('--------------------------------------', {1,1,1})
	for _, color in ipairs(players) do
		if greyPlayer(color) then
			local playerObj = getPlayerObj(color)
			if playerObj then
				playerObj:print(chatHelp(playerObj.admin))
			end
		else
			Player[color]:print(chatHelp(Player[color].admin))
		end
	end

	deleteCustomBoardCards()

	sleep(1)

	--Shuffle the policy deck
	if not shuffleDrawDeck() then
		broadcastToAll('ERROR: Unable to shuffle draw deck! Restart required.', {1,0,0})
		return true
	end

	-- interactable/unlock other items
	president.setLock(false)
	president.interactable = true
	chancelor.setLock(false)
	chancelor.interactable = true
	tmpObj = getObjectFromGUID(ELECTION_TRACKER_GUID)
	tmpObj.setLock(false)
	if #players == 5 then
		destroyObjectByGUID(PREV_PRESIDENT_GUID)
	else
		tmpObj = getObjectFromGUID(PREV_PRESIDENT_GUID)
		tmpObj.setLock(false)
	end
	tmpObj = getObjectFromGUID(PREV_CHANCELOR_GUID)
	tmpObj.setLock(false)

	-- Lock placed board cards
	testActionUsedPolicyZones(
		function(p) return isBoardCard(p) or isPolicyNotUsedCard(p) end,
		function(p) p.setLock(true) end,
		boardCardWaitId)

	--Set the started variable to true
	started = true
	refreshStatusButtons()
	refreshUI()
	spawnNikosTimer()
	wait(5)
	recreateVotes("setup","setup","setup")

	return true
end

function giveUsableCard(guid, color)
	-- @@ might need to set pos elsewhere
	local newCard = getObjectFromGUID(guid).clone()
	startLuaCoroutine(Global, 'waitCo')
	newCard.setScale({1.51, 1, 1.51})
	newCard.interactable = true
	newCard.setLock(false)
	newCard.setPosition(getObjectFromGUID(HIDDEN_ZONE_GUIDS[color]).getPosition())
end

function waitCo()
	wait(3)
	return true
end

function setupPowerAbilities(abilitiesDeck)
	local tmpZoneGuid
	local params = {index = 1}
	local card
	for _, tmpZoneGuid in ipairs(liberal_zone_guids) do
		tmpZone = getObjectFromGUID(tmpZoneGuid)
		if tmpZone then
			inZone = tmpZone.getObjects()
			for _, j in ipairs(inZone) do
				if isBoardCardBelowAbility(j) then
					local pos = j.getPosition()
					pos["z"] = pos["z"] - 7.8
					card = abilitiesDeck.takeObject(params)
					card.setPositionSmooth(pos)
					card.setRotationSmooth(FACE_UP_ROT)
				elseif isBoardCardBelowHiddenAbility(j) then
					local pos = j.getPosition()
					pos["z"] = pos["z"] - 7.8
					card = abilitiesDeck.takeObject(params)
					card.setPositionSmooth(pos)
					card.setRotationSmooth(FACE_DOWN_ROT)
				end
			end
		end
	end
	for _, tmpZoneGuid in ipairs(fascist_zone_guids) do
		tmpZone = getObjectFromGUID(tmpZoneGuid)
		if tmpZone then
			inZone = tmpZone.getObjects()
			for _, j in ipairs(inZone) do
				if isBoardCardAboveAbility(j) then
					local pos = j.getPosition()
					pos["z"] = pos["z"] + 7.7
					card = abilitiesDeck.takeObject(params)
					card.setPositionSmooth(pos)
					card.setRotationSmooth(FACE_UP_ROT)
				elseif isBoardCardAboveHiddenAbility(j) then
					local pos = j.getPosition()
					pos["z"] = pos["z"] + 7.7
					card = abilitiesDeck.takeObject(params)
					card.setPositionSmooth(pos)
					card.setRotationSmooth(FACE_DOWN_ROT)
				end
			end
		end
	end
end

function statusButtonCallback(objIn, paramsIn)
	table.insert(playerStatusButtonGuids, 1, objIn.getGUID())
end

function greyPlayerHandCallback(objIn, paramsIn)
	local color = string.gsub(objIn.getDescription(), ' Hand', '')
	greyPlayerHandGuids[color] = objIn.getGUID()
	objIn.AssetBundle.playLoopingEffect(1)
end

function changePlayerStatus(clickedObject, playerColor)
	if Player[playerColor].admin then
		local ownerColor = clickedObject.getName()
		_G.playerStatus[ownerColor] = _G.playerStatus[ownerColor] + 1
		local abilitiesDeck = getDeckFromZoneByGUID(ABILITIESPILE_ZONE_GUID)
		if not abilitiesDeck then
			if _G.playerStatus[ownerColor] == 3 then
				_G.playerStatus[ownerColor] = 5
			end
		end
		--fixme > 7 to allow Imprisoned
		if _G.playerStatus[ownerColor] > 6 then _G.playerStatus[ownerColor] = 1 end
		refreshStatusButtons()
	else
		printToColor('ERROR: You are not the host or a promoted player.', playerColor, {1, 0, 0})
	end
end

function tellRole(player)
	local msg = ''
	if player == 'Black' then
		if #hitler == 0 and #fascists == 0 and #players > 0 then
			msg = msg .. '[0080F8]Everyone is ' .. text.liberalArticle .. ' ' .. text.liberal .. '![-]\n'
		else
			for _, l in pairs(hitler) do
				msg = msg .. '[' .. stringColorToHex(l) .. ']' .. l .. ' is ' .. text.hitler .. '!' .. '[-]\n'
			end
			for _, l in pairs(fascists) do
				msg = msg .. '[' .. stringColorToHex(l) .. ']' .. l .. ' is ' .. text.fascistArticle .. ' ' .. text.fascist .. '!' .. '[-]\n'
			end
		end
	else
		local role = roles[player]
		if role == 'fascist' then
			msg = msg .. '[' .. stringColorToHex(player) .. ']You are ' .. text.fascistArticle .. ' [FF0000]' .. text.fascist .. '[-]![-]\n'
			for _, l in pairs(hitler) do
				msg = msg .. '[' .. stringColorToHex(l) .. ']' .. l .. ' is ' .. text.hitler .. '!' .. '[-]\n'
			end
			for _, l in pairs(fascists) do
				if not (l == player) then
					msg = msg .. '[' .. stringColorToHex(l) .. ']' .. l .. ' is ' .. text.fascistArticle .. ' ' .. text.fascist .. ', too!' .. '[-]\n'
				end
			end
		elseif role == 'hitler' then
			msg = msg .. '[' .. stringColorToHex(player) .. ']You are [FF0000]' .. text.hitler .. '[-]![-]\n'
			if #players < 7 then
				for _, l in pairs(hitler) do
					if not (l == player) then
						msg = msg .. '[' .. stringColorToHex(l) .. ']' .. l .. ' is also ' .. text.hitler .. '!' .. '[-]\n'
					end
				end
				for _, l in pairs(fascists) do
					msg = msg .. '[' .. stringColorToHex(l) .. ']' .. l .. ' is ' .. text.fascistArticle .. ' ' .. text.fascist .. '!' .. '[-]\n'
				end
			end
		elseif role == 'liberal' then
			msg = msg .. '[' .. stringColorToHex(player) .. ']You are ' .. text.liberalArticle .. ' [0080F8]' .. text.liberal .. '[-]![-]\n'
		else
			msg = msg .. player .. ' is not Playing!\n'
		end
	end

	return string.gsub(msg, '\n$', '')
end

function shuffleDrawDeck()
	local drawDeck = getDeckFromZoneByGUID(DRAW_ZONE_GUID)
	if drawDeck then
		drawDeck.shuffle()
		return true
	end

	return false
end

function toggleSecurity()
	--startLuaCoroutine(Global, 'toggleSecurityCoroutine')
	toggleSecurityCoroutine()
end

function toggleSecurityCoroutine()
	local allObjs = getAllObjects()
	local tmpObj
	
	if (currentlyDisabled == nil) then
		Global.setVar('hold', true)
		broadcastToAll('WARNING: Security has been disabled!', {1,0,0})
		for _, tmpObj in ipairs(allObjs) do
			if isPolicyCard(tmpObj) then
				tmpObj.interactable = true
			elseif tmpObj.tag == 'Deck' then
				tmpObj.interactable = true
			end
		end
		currentlyDisabled = true
	elseif (currentlyDisabled) then
		broadcastToAll('WARNING: Security has been enabled!', {1,0,0})
		
		--Expansion
		tmpObj = getDeckFromZoneByGUID(ABILITIESPILE_ZONE_GUID)
		if tmpObj then tmpObj.interactable = false end
		tmpObj = getDeckFromZoneByGUID(EFFECTSPILE_ZONE_GUID)
		if tmpObj then	tmpObj.interactable = false end

		Global.setVar('hold', false)
		currentlyDisabled = nil
	end
end

function disableSecurityCoroutine()
	local allObjs = getAllObjects()
	local tmpObj

	Global.setVar('hold', true)
	broadcastToAll('WARNING: Security has been disabled for 30 seconds!', {1,0,0})
	for _, tmpObj in ipairs(allObjs) do
		if isPolicyCard(tmpObj) then
			tmpObj.interactable = true
		elseif tmpObj.tag == 'Deck' then
			tmpObj.interactable = true
		end
	end
	sleep(30)

	--Expansion
	tmpObj = getDeckFromZoneByGUID(ABILITIESPILE_ZONE_GUID)
	if tmpObj then tmpObj.interactable = false end
	tmpObj = getDeckFromZoneByGUID(EFFECTSPILE_ZONE_GUID)
	if tmpObj then	tmpObj.interactable = false end

	Global.setVar('hold', false)

	return true
end

function enableSecurity()
	
end

function createInspectButtons(powerHolder)
	function createInspectButtonsCoroutine()
		local membershipCard = getObjectFromGUID(fakeMembership_card_guid)
		if membershipCard then
			activePowerColor = powerHolder
			if greyPlayer(powerHolder) then
				smartBroadcastToColor('Use the UI to inspect a player.', powerHolder, {1, 1, 1})
			else
				broadcastToColor('Click on the party membership card of the person you want to inspect.', powerHolder, {1, 1, 1})
			end
			for i, playerColor in ipairs(players) do
				if playerColor ~= powerHolder and not inTable(inspected, playerColor) and not (_G.playerStatus[playerColor] > 4) then
					local params = {rotation = {0, 0, 0}, sound = false}
					card = membershipCard.clone(params)
					card.setDescription('Fake Party Card')
					card.setLuaScript(
						'playerColor = \'' .. playerColor .. '\'\r\n\r\n' ..
						'function onCollisionEnter(collision_info)\r\n' ..
						'	if Global.call(\'greyPlayer\', {playerColor}) then\r\n' ..
						'		--hard coded\r\n' ..
						'		self.setRotation({0, 180, 0})\r\n' ..
						'	else\r\n' ..
						'		local ph = Player[playerColor].getPlayerHand()\r\n' ..
						'		if ph then\r\n' ..
						'			self.setRotation({0, ph[\'rot_y\']+180, 0})\r\n' ..
						'		end\r\n' ..
						'	end\r\n' ..
						'	self.setLock(true)\r\n' ..
						'end\r\n\r\n' ..
						'function onLoad(saveString)\r\n' ..
						'	local button = {}\r\n' ..
						'	button.click_function = \'' .. playerColor .. 'Inspected\'\r\n' ..
						'	button.label = \'Inspect\\n' .. playerColor .. '\'\r\n' ..
						'	button.function_owner = Global\r\n' ..
						'	button.position = {0, 1, 0}\r\n' ..
						'	button.rotation = {0, 0, 0}\r\n' ..
						'	button.width = 1000\r\n' ..
						'	button.height = 1500\r\n' ..
						'	button.font_size = 150\r\n' ..
						'	self.createButton(button)\r\n' ..
						'end')
					card.setPosition({0, 30 + (i * 0.25), 0})
					card.setLock(false)
					wait(5)
					giveObjectToPlayer(card, playerColor, {forward = 16.5, right = 0, up = 0}, FACE_UP_ROT, false, true)
				end
			end
		else
			printToAll('ERROR: Base membership card not found.', {1,0,0})
		end

		return true
	end
	startLuaCoroutine(Global, 'createInspectButtonsCoroutine')
end

function playerInspected(clickedObject, inspectorColor, checkedColor)
	if inspectorColor == activePowerColor and needInspect() then
		local role = roles[checkedColor]
		local playerColor = stringColorToRGBExtra(checkedColor)
		local roleText
		local roleColor
		if role == 'hitler' or role == 'fascist' then
			roleText = text.fascistArticle .. ' ' .. string.lower(text.fascist)
			roleColor = {1, 0, 0}
		else
			roleText = text.liberalArticle .. ' ' .. string.lower(text.liberal)
			roleColor = {0.1, 0.3, 1}
		end
		printToAll(inspectorColor .. ' inspected ' .. checkedColor, playerColor)
		smartBroadcastToColor(checkedColor .. ' is ' .. roleText .. '!', inspectorColor, roleColor)
		table.insert(inspected, 1, checkedColor)
		removeInspect()
		if options.autoNotate and notate.line and notate.action == 'inspects' then
			noteTakerNotes[notate.line].color2 = checkedColor
			refreshNotes(nil)
			notate.line = nil
			notate.action = ''
		end
		activePowerColor = nil
	end
end

function WhiteInspected(clickedObject, inspectorColor)
	playerInspected(clickedObject, inspectorColor, 'White')
end

function BrownInspected(clickedObject, inspectorColor)
	playerInspected(clickedObject, inspectorColor, 'Brown')
end

function RedInspected(clickedObject, inspectorColor)
	playerInspected(clickedObject, inspectorColor, 'Red')
end

function OrangeInspected(clickedObject, inspectorColor)
	playerInspected(clickedObject, inspectorColor, 'Orange')
end

function YellowInspected(clickedObject, inspectorColor)
	playerInspected(clickedObject, inspectorColor, 'Yellow')
end

function GreenInspected(clickedObject, inspectorColor)
	playerInspected(clickedObject, inspectorColor, 'Green')
end

function TealInspected(clickedObject, inspectorColor)
	playerInspected(clickedObject, inspectorColor, 'Teal')
end

function BlueInspected(clickedObject, inspectorColor)
	playerInspected(clickedObject, inspectorColor, 'Blue')
end

function PurpleInspected(clickedObject, inspectorColor)
	playerInspected(clickedObject, inspectorColor, 'Purple')
end

function PinkInspected(clickedObject, inspectorColor)
	playerInspected(clickedObject, inspectorColor, 'Pink')
end

function TanInspected(clickedObject, inspectorColor)
	playerInspected(clickedObject, inspectorColor, 'Tan')
end

function MaroonInspected(clickedObject, inspectorColor)
	playerInspected(clickedObject, inspectorColor, 'Maroon')
end

function removeInspect()
	local allObjs = getAllObjects()
	for _, object in ipairs(allObjs) do
		if object.tag == 'Card' and (object.getDescription() == 'Fake Party Card') then
			destroyObject(object)
		end
	end
end

function needInspect()
	local allObjs = getAllObjects()
	for _, object in ipairs(allObjs) do
		if object.tag == 'Card' and (object.getDescription() == 'Fake Party Card') then
			return true
		end
	end
	return false
end

function giveRoleCards()
	if (started ~= true) then
		return false
	end

	startLuaCoroutine(Global, 'giveRoleCardsCo')
end
	
function giveRoleCardsCo()
	local spawnParams = {
		type = "Deck", 
		sound = false,
		scale = {1.51, 1, 1.51}
	}
	
	local newVoteDeck = spawnObject(spawnParams)
	wait(5)
	newVoteDeck.setCustomObject(roleInfo)
	wait(5)
	
	local libCards = {}
	local fasCards = {}
	
	for i = 1, 9 do
		if (i < 7) then
			table.insert(libCards, newVoteDeck.takeObject())
		else
			table.insert(fasCards, newVoteDeck.takeObject())
		end
	end
	local hitCard = newVoteDeck.takeObject({position=newPosition})
	
	if not options.dealRoleCards then
		local colours = {"White","Brown","Red","Orange","Yellow","Green","Teal","Blue","Purple","Pink"}
		
		for i, color in pairs(colours) do
			if (roles[color] ~= nil) then
				if (roles[color] == 'hitler') then
					hitCard.setDescription("Hitler Role Card")
					hitCard.setPosition(getObjectFromGUID(HIDDEN_ZONE_GUIDS[color]).getPosition())
				elseif (roles[color] == 'fascist') then
					local randomCard = math.random(#fasCards)
					fasCards[randomCard].setDescription("Fascist Role Card")
					fasCards[randomCard].setPosition(getObjectFromGUID(HIDDEN_ZONE_GUIDS[color]).getPosition())
					table.remove(fasCards, randomCard)
				elseif (roles[color] == 'liberal') then
					local randomCard = math.random(#libCards)
					libCards[randomCard].setDescription("Liberal Role Card")
					libCards[randomCard].setPosition(getObjectFromGUID(HIDDEN_ZONE_GUIDS[color]).getPosition())
					table.remove(libCards, randomCard)
				end
			end
		end
	end
	
	for i, value in pairs(libCards) do
		value.destruct()
	end
	for i, value in pairs(fasCards) do
		value.destruct()
	end
	
	return 1
end

function findUnusedColor()
	local checkList = {'Brown', 'Teal', 'Black', 'White', 'Red', 'Orange', 'Yellow', 'Green', 'Blue', 'Purple', 'Pink'}

	for _, playerColor in ipairs(checkList) do
		if not Player[playerColor].seated then
			return playerColor
		end
	end
end

--[[function shufflePlayers()
	local blackSteamId
	if #getSeatedPlayers() == 10 and Player['Black'].seated then
		blackSteamId = Player['Black'].steam_id
		Player['Black']:changeColor('Grey')
		while Player['Black'].seated do
			coroutine.yield()
		end
	end
	swapColor = findUnusedColor()

	local ranColors = {}
	for _, v in pairs(getSeatedPlayers()) do
		if (not Player[v].host) or options.shuffleHost then
			table.insert(ranColors, 1, v)
		end
	end
	shuffleTable(ranColors)

	seatedPlayers = {}
	local j = 1
	for _, v in pairs(getSeatedPlayers()) do
		if (not Player[v].host) or options.shuffleHost then
			local playerInfo = {}
			playerInfo.target = ranColors[j]
			playerInfo.myColor = v
			table.insert(seatedPlayers, 1, playerInfo)
			j = j + 1
		end
	end

	local doneCount = 0
	local tryCount = #seatedPlayers
	while doneCount ~= #seatedPlayers and tryCount > 0 do
		doneCount = 0
		for i, v in pairs(seatedPlayers) do
			if v.target ~= v.myColor then
				if Player[v.target].seated == false then
					local myC = v.myColor
					if Player[myC].seated == true then
						Player[myC]:changeColor(v.target)
						while Player[myC].seated and not Player[v.target].seated do
							coroutine.yield()
						end
						v.myColor = v.target
						doneCount = doneCount + 1
					end
				elseif Player[swapColor].seated == false then
					local myC = v.myColor
					if Player[myC].seated == true then
						Player[myC]:changeColor(swapColor)
						while Player[myC].seated and not Player[swapColor].seated do
							coroutine.yield()
						end
						v.myColor = swapColor
					end
				end
			else
				doneCount = doneCount + 1
			end
		end
		tryCount = tryCount - 1
		coroutine.yield()
	end

	if blackSteamId then
		for _, p in pairs(Player.getSpectators()) do
			if p.steam_id == blackSteamId then
				p:changeColor('Black')
			end
		end
	end
end]]--

function notateColor2ByObject(tableIn)
	if type(tableIn) == 'table' then
		if tableIn[1] then
			local playerColor = closestPlayer(tableIn[1], players, 18)
			if playerColor and notate.line then
				if noteTakerNotes[notate.line] then
					if noteTakerNotes[notate.line].color1 ~= playerColor then
						noteTakerNotes[notate.line].color2 = playerColor
						refreshNotes(nil)
						notate.line = nil
						notate.action = ''
					end
				end
			end
		end
	end
end

----#include \SecretHitlerCE\main.ttslua
----#include \SecretHitlerCE\cardsboard.ttslua

--Board cards
TOPTHREE_STRING = "The president examines\nthe top three cards."
PICKPRES_STRING = "The president picks\nthe next presidential\ncandidate."
INSPECT_STRING = "The president\ninvestigates a\nplayer\'s identity\ncard."
BULLET_STRING = "The president must\nkill a player."
TOPCARD_STRING = "The president examines\nthe top card."
IMPRISON_STRING = "The president must\nimprison a player."
PRESTAKESABOVE_STRING = "The president takes\nthe card above."
PRESTAKESBELOW_STRING = "The president takes\nthe card below."
PRESTAKESHIDDENABOVE_STRING = "The president takes\nthe hidden card above."
PRESTAKESHIDDENBELOW_STRING = "The president takes\nthe hidden card below."
PRESGIVESABOVE_STRING = "The president gives\nthe card above\nto another player."
PRESGIVESBELOW_STRING = "The president gives\nthe card below\nto another player."
PRESGIVESHIDDENABOVE_STRING = "The president gives\nthe card above\nto another player\nafter examining it."
PRESGIVESHIDDENBELOW_STRING = "The president gives\nthe card below\nto another player\nafter examining it."
DOESNOTHING_STRING = "The president\ndoes nothing."
VETO_STRING = "Veto power is\nunlocked."
CHANCELLOR_STRING = "The chancellor gets the power."
--Policy cards
LIBERALPOLICY_STRING = "Liberal Policy"
FASCISTPOLICY_STRING = "Fascist Policy"
GREYPOLICY_STRING = "Grey Policy"
NOTUSED_STRING = "Not Used"

function isBoardCard(objIn)
	if objIn.tag == "Card" and
	   (objIn.getDescription() == TOPTHREE_STRING or
		 objIn.getDescription() == PICKPRES_STRING or
	    objIn.getDescription() == INSPECT_STRING or
	    objIn.getDescription() == BULLET_STRING or
		 objIn.getDescription() == TOPCARD_STRING or
		 objIn.getDescription() == IMPRISON_STRING or
		 objIn.getDescription() == PRESTAKESABOVE_STRING or
		 objIn.getDescription() == PRESTAKESBELOW_STRING or
		 objIn.getDescription() == PRESTAKESHIDDENABOVE_STRING or
		 objIn.getDescription() == PRESTAKESHIDDENBELOW_STRING or
		 objIn.getDescription() == PRESGIVESABOVE_STRING or
		 objIn.getDescription() == PRESGIVESBELOW_STRING or
		 objIn.getDescription() == PRESGIVESHIDDENABOVE_STRING or
		 objIn.getDescription() == PRESGIVESHIDDENBELOW_STRING or
		 objIn.getDescription() == DOESNOTHING_STRING or
		 objIn.getDescription() == VETO_STRING or
		 objIn.getDescription() == CHANCELLOR_STRING) then
		return true
	end
	return false
end

function isSubBoardCard(objIn)
	if objIn.tag == "Card" and
	   (objIn.getDescription() == VETO_STRING or
		 objIn.getDescription() == CHANCELLOR_STRING) then
		return true
	end
	return false
end

function isBoardCardAboveAbility(objIn)
	if objIn.tag == "Card" and
	   (objIn.getDescription() == PRESTAKESABOVE_STRING or
		 objIn.getDescription() == PRESGIVESABOVE_STRING) then
		return true
	end
	return false
end

function isBoardCardAboveHiddenAbility(objIn)
	if objIn.tag == "Card" and
	   (objIn.getDescription() == PRESTAKESHIDDENABOVE_STRING or
		 objIn.getDescription() == PRESGIVESHIDDENABOVE_STRING) then
		return true
	end
	return false
end

function isBoardCardBelowAbility(objIn)
	if objIn.tag == "Card" and
	   (objIn.getDescription() == PRESTAKESBELOW_STRING or
		 objIn.getDescription() == PRESGIVESBELOW_STRING) then
		return true
	end
	return false
end

function isBoardCardBelowHiddenAbility(objIn)
	if objIn.tag == "Card" and
	   (objIn.getDescription() == PRESTAKESHIDDENBELOW_STRING or
		 objIn.getDescription() == PRESGIVESHIDDENBELOW_STRING) then
		return true
	end
	return false
end

function isBoardCardTopThree(objIn)
	if objIn.tag == "Card" and objIn.getDescription() == TOPTHREE_STRING then
		return true
	end
	return false
end

function isBoardCardPickPres(objIn)
	if objIn.tag == "Card" and objIn.getDescription() == PICKPRES_STRING then
		return true
	end
	return false
end

function isBoardCardInspect(objIn)
	if objIn.tag == "Card" and objIn.getDescription() == INSPECT_STRING then
		return true
	end
	return false
end

function isBoardCardBullet(objIn)
	if objIn.tag == "Card" and objIn.getDescription() == BULLET_STRING then
		return true
	end
	return false
end

function isBoardCardTopCard(objIn)
	if objIn.tag == "Card" and objIn.getDescription() == TOPCARD_STRING then
		return true
	end
	return false
end

function isBoardCardImprison(objIn)
	if objIn.tag == "Card" and objIn.getDescription() == IMPRISON_STRING then
		return true
	end
	return false
end

function isPolicyCard(objIn)
	if objIn.tag == "Card" and (objIn.getDescription() == FASCISTPOLICY_STRING
		or objIn.getDescription() == LIBERALPOLICY_STRING
		or objIn.getDescription() == GREYPOLICY_STRING)
		and not objIn.held_by_color then
		return true
	end
	return false
end

function isFascistPolicyCard(objIn)
	if objIn.tag == "Card" and objIn.getDescription() == FASCISTPOLICY_STRING
		and not objIn.held_by_color then
		return true
	end
	return false
end

function isLiberalPolicyCard(objIn)
	if objIn.tag == "Card" and objIn.getDescription() == LIBERALPOLICY_STRING
		and not objIn.held_by_color then
		return true
	end
	return false
end

function isGreyPolicyCard(objIn)
	if objIn.tag == "Card" and objIn.getDescription() == GREYPOLICY_STRING
		and not objIn.held_by_color then
		return true
	end
	return false
end

function isPolicyNotUsedCard(objIn)
	if objIn.tag == "Card" and objIn.getDescription() == NOTUSED_STRING
		and not objIn.held_by_color then
		return true
	end
	return false
end

function refreshBoardCards()
	if options.gameType == 2 then
		deleteCustomBoardCards()
		spawnCustomBoardCards()
		-- Unlock board cards
		testActionUsedPolicyZones(
			function(p) return isBoardCard(p) or isPolicyNotUsedCard(p) end,
			function(p) p.setLock(false) end,
			boardCardWaitId)
	else
		--delete board cards
		deleteCustomBoardCards()
		testActionUsedPolicyZones(
			function(p) return isBoardCard(p) or isPolicyNotUsedCard(p) end,
			function(p) p.destruct() end,
			nil)
		spawnNotUsedFascist(getPositionByGUIDOffsetZ(fascist_zone_guids[1], 0.1))
		spawnNotUsedLiberal(getPositionByGUIDOffsetZ(liberal_zone_guids[1], 0.1))
		if #getSeatedPlayers() > 8 then
			spawnInspectOrange(getPositionByGUIDOffsetZ(fascist_zone_guids[2], 0.1))
			spawnInspectOrange(getPositionByGUIDOffsetZ(fascist_zone_guids[3], 0.1))
			spawnPickPresOrange(getPositionByGUIDOffsetZ(fascist_zone_guids[4], 0.1))
		elseif #getSeatedPlayers() > 6 then
			spawnInspectOrange(getPositionByGUIDOffsetZ(fascist_zone_guids[3], 0.1))
			spawnPickPresOrange(getPositionByGUIDOffsetZ(fascist_zone_guids[4], 0.1))
		else
			spawnTopThreeOrange(getPositionByGUIDOffsetZ(fascist_zone_guids[4], 0.1))
		end
		spawnBulletRed(getPositionByGUIDOffsetZ(fascist_zone_guids[5], 0.1))
		spawnBulletRed(getPositionByGUIDOffsetZ(fascist_zone_guids[6], 0.1))
		spawnVetoRed(getPositionByGUIDOffsetZ(fascist_zone_guids[6], -2))
		if boardCardWaitId then
			Wait.stop(boardCardWaitId)
		end
		boardCardWaitId = Wait.time(
			function()
				testReadyToLock(
					function(p)
						return isBoardCard(p) or isPolicyNotUsedCard(p)
					end, boardCardWaitId)
			end, 5, -1)
	end
	lastPlayerCt = #getSeatedPlayers()
end

function testActionUsedPolicyZones(testFunc, actionFunc, waitID)
	local tmpZoneGuid
	if waitID then
		Wait.stop(waitID)
	end
	for _, tmpZoneGuid in ipairs(liberal_zone_guids) do
		tmpZone = getObjectFromGUID(tmpZoneGuid)
		if tmpZone then
			inZone = tmpZone.getObjects()
			for _, j in ipairs(inZone) do
				if testFunc(j) then
					actionFunc(j)
				end
			end
		end
	end
	for _, tmpZoneGuid in ipairs(fascist_zone_guids) do
		tmpZone = getObjectFromGUID(tmpZoneGuid)
		if tmpZone then
			inZone = tmpZone.getObjects()
			for _, j in ipairs(inZone) do
				if testFunc(j) then
					actionFunc(j)
				end
			end
		end
	end
end

function testReadyToLock(testFunc, waitID)
	if (started ~= true) then
		return false
	end
	local lock = true
	--check if anything is loading
	for _, j in pairs(getAllObjects()) do
		if j.loading_custom and j.tag ~= "3D Text" then lock = false end
	end
	--check if resting
	if lock then
		for _, tmpZoneGuid in ipairs(liberal_zone_guids) do
			tmpZone = getObjectFromGUID(tmpZoneGuid)
			if tmpZone then
				inZone = tmpZone.getObjects()
				for _, j in ipairs(inZone) do
					if testFunc(j) then
						if not j.resting then lock = false end
					end
				end
			end
		end
	end
	if lock then
		for _, tmpZoneGuid in ipairs(fascist_zone_guids) do
			tmpZone = getObjectFromGUID(tmpZoneGuid)
			if tmpZone then
				inZone = tmpZone.getObjects()
				for _, j in ipairs(inZone) do
					if testFunc(j) then
						if not j.resting then lock = false end
					end
				end
			end
		end
	end
	if lock then
		-- lock board cards
		testActionUsedPolicyZones(
			function(p) return testFunc(p) end,
			function(p) p.setLock(true) end,
			waitID)
	end
end

function deleteCustomBoardCards()
	local tmpZoneGuid
	local inUse = {}
	for _, tmpZoneGuid in ipairs(liberal_zone_guids) do
		tmpZone = getObjectFromGUID(tmpZoneGuid)
		if tmpZone then
			inZone = tmpZone.getObjects()
			for _, j in ipairs(inZone) do
				if isBoardCard(j) or isPolicyNotUsedCard(j) then
					smartTableInsert(inUse, j.getGUID())
				end
			end
		end
	end
	for _, tmpZoneGuid in ipairs(fascist_zone_guids) do
		tmpZone = getObjectFromGUID(tmpZoneGuid)
		if tmpZone then
			inZone = tmpZone.getObjects()
			for _, j in ipairs(inZone) do
				if isBoardCard(j) or isPolicyNotUsedCard(j) then
					smartTableInsert(inUse, j.getGUID())
				end
			end
		end
	end
	for _, j in pairs(getAllObjects()) do
		if (isBoardCard(j) or isPolicyNotUsedCard(j)) and not inTable(inUse, j.getGUID()) then
			destroyObject(j);
		end
	end
end

do -- spawn functions

function spawnCustomBoardCards()
	spawnTopThreeOrange({-38, 2, 19})
	spawnTopThreeRed({-38, 2, 15})
	spawnTopThreeBlue({-38, 2, 11})
	spawnInspectOrange({-34, 2, 19})
	spawnInspectRed({-34, 2, 15})
	spawnInspectBlue({-34, 2, 11})
	spawnPickPresOrange({-30, 2, 19})
	spawnPickPresRed({-30, 2, 15})
	spawnPickPresBlue({-30, 2, 11})
	spawnBulletOrange({-26, 2, 19})
	spawnBulletRed({-26, 2, 15})
	spawnBulletBlue({-26, 2, 11})
	spawnVetoOrange({-36, 2, 8})
	spawnVetoRed({-36, 2, 6})
	spawnVetoBlue({-36, 2, 4})
	spawnNotUsedFascist({-32, 2, 6})
	spawnNotUsedLiberal({-28, 2, 6})
	spawnTopCardOrange({-36, 2, 1})
	spawnTopCardRed({-36, 2, -3})
	spawnTopCardBlue({-36, 2, -7})
	spawnImprisonOrange({-32, 2, 1})
	spawnImprisonRed({-32, 2, -3})
	spawnImprisonBlue({-32, 2, -7})
	spawnDoesNothingOrange({-28, 2, 1})
	spawnDoesNothingRed({-28, 2, -3})
	spawnDoesNothingBlue({-28, 2, -7})
	spawnPresTakesOrange({-38, 2, -11})
	spawnPresTakesRed({-38, 2, -15})
	spawnPresTakesBlue({-38, 2, -19})
	spawnPresTakesHiddenOrange({-34, 2, -11})
	spawnPresTakesHiddenRed({-34, 2, -15})
	spawnPresTakesHiddenBlue({-34, 2, -19})
	spawnPresGivesOrange({-30, 2, -11})
	spawnPresGivesRed({-30, 2, -15})
	spawnPresGivesBlue({-30, 2, -19})
	spawnPresGivesHiddenOrange({-26, 2, -11})
	spawnPresGivesHiddenRed({-26, 2, -15})
	spawnPresGivesHiddenBlue({-26, 2, -19})
	--spawnChancellorOrange({-36, 2, -22})
	--spawnChancellorRed({-32, 2, -22})
	--spawnChancellorBlue({-28, 2, -22})
end

function spawnTopThreeOrange(pos)
	return spawnBoardCard("10000", TOPTHREE_STRING, pos)
end

function spawnTopThreeRed(pos)
	return spawnBoardCard("10001", TOPTHREE_STRING, pos)
end

function spawnTopThreeBlue(pos)
	return spawnBoardCard("10002", TOPTHREE_STRING, pos)
end

function spawnPickPresOrange(pos)
	return spawnBoardCard("10003", PICKPRES_STRING, pos)
end

function spawnPickPresRed(pos)
	return spawnBoardCard("10004", PICKPRES_STRING, pos)
end

function spawnPickPresBlue(pos)
	return spawnBoardCard("10005", PICKPRES_STRING, pos)
end

function spawnInspectOrange(pos)
	return spawnBoardCard("10006", INSPECT_STRING, pos)
end

function spawnInspectRed(pos)
	return spawnBoardCard("10007", INSPECT_STRING, pos)
end

function spawnInspectBlue(pos)
	return spawnBoardCard("10008", INSPECT_STRING, pos)
end

function spawnBulletOrange(pos)
	return spawnBoardCard("10009", BULLET_STRING, pos)
end

function spawnBulletRed(pos)
	return spawnBoardCard("10010", BULLET_STRING, pos)
end

function spawnBulletBlue(pos)
	return spawnBoardCard("10011", BULLET_STRING, pos)
end

function spawnTopCardOrange(pos)
	return spawnBoardCard("10012", TOPCARD_STRING, pos)
end

function spawnTopCardRed(pos)
	return spawnBoardCard("10013", TOPCARD_STRING, pos)
end

function spawnTopCardBlue(pos)
	return spawnBoardCard("10014", TOPCARD_STRING, pos)
end

function spawnImprisonOrange(pos)
	return spawnBoardCard("10015", IMPRISON_STRING, pos)
end

function spawnImprisonRed(pos)
	return spawnBoardCard("10016", IMPRISON_STRING, pos)
end

function spawnImprisonBlue(pos)
	return spawnBoardCard("10017", IMPRISON_STRING, pos)
end

function spawnPresTakesOrange(pos)
	return spawnBoardCard("10018", PRESTAKESABOVE_STRING, pos)
end

function spawnPresTakesRed(pos)
	return spawnBoardCard("10019", PRESTAKESABOVE_STRING, pos)
end

function spawnPresTakesBlue(pos)
	return spawnBoardCard("10020", PRESTAKESBELOW_STRING, pos)
end

function spawnPresTakesHiddenOrange(pos)
	return spawnBoardCard("10021", PRESTAKESHIDDENABOVE_STRING, pos)
end

function spawnPresTakesHiddenRed(pos)
	return spawnBoardCard("10022", PRESTAKESHIDDENABOVE_STRING, pos)
end

function spawnPresTakesHiddenBlue(pos)
	return spawnBoardCard("10023", PRESTAKESHIDDENBELOW_STRING , pos)
end

function spawnPresGivesOrange(pos)
	return spawnBoardCard("10024", PRESGIVESABOVE_STRING, pos)
end

function spawnPresGivesRed(pos)
	return spawnBoardCard("10025", PRESGIVESABOVE_STRING, pos)
end

function spawnPresGivesBlue(pos)
	return spawnBoardCard("10026", PRESGIVESBELOW_STRING, pos)
end

function spawnPresGivesHiddenOrange(pos)
	return spawnBoardCard("10027", PRESGIVESHIDDENABOVE_STRING, pos)
end

function spawnPresGivesHiddenRed(pos)
	return spawnBoardCard("10028", PRESGIVESHIDDENABOVE_STRING, pos)
end

function spawnPresGivesHiddenBlue(pos)
	return spawnBoardCard("10029", PRESGIVESHIDDENBELOW_STRING, pos)
end

function spawnDoesNothingOrange(pos)
	return spawnBoardCard("10030", DOESNOTHING_STRING, pos)
end

function spawnDoesNothingRed(pos)
	return spawnBoardCard("10031", DOESNOTHING_STRING, pos)
end

function spawnDoesNothingBlue(pos)
	return spawnBoardCard("10032", DOESNOTHING_STRING, pos)
end

function spawnBoardCard(cardID, desc, pos)
   local params = {
      json =
			"{" ..
			"\"Name\": \"Card\", " ..
			"\"Transform\": {\"posX\": 0,\"posY\": 0,\"posZ\": 0,\"rotX\": 0,\"rotY\": 0,\"rotZ\": 0,\"scaleX\": 1,\"scaleY\": 1,\"scaleZ\": 1}, " ..
			"\"CardID\": " .. cardID .. ", " ..
			"\"CustomDeck\": {" ..
			"\"" .. string.sub(cardID, 1, 3) .. "\": {" ..
			"\"FaceURL\": \"http://cloud-3.steamusercontent.com/ugc/809997459545222830/36C579AD5879CA194D3142C7C1940E2AE19F888E/\", " ..
			"\"BackURL\": \"http://cloud-3.steamusercontent.com/ugc/809997459545150312/0CAC8BEF72548FBBABB723081596771432C78476/\", " ..
			"\"NumWidth\": 10, " ..
			"\"NumHeight\": 7, " ..
			"\"BackIsHidden\": false, " ..
			"\"UniqueBack\": false " ..
			"}" ..
			"}" ..
			"}",
      position = pos,
      rotation = FACE_UP_ROT,
      scale = {x = 1, y = 1, z = 1},
      sound = false
   }
	local card = spawnObjectJSON(params)
	card.setDescription(desc)
	card.use_grid = false
   return card
end

function spawnVetoOrange(pos)
	return spawnSubBoardCard("10100", VETO_STRING, pos)
end

function spawnVetoRed(pos)
	return spawnSubBoardCard("10101", VETO_STRING, pos)
end

function spawnVetoBlue(pos)
	return spawnSubBoardCard("10102", VETO_STRING, pos)
end

function spawnChancellorOrange(pos)
	return spawnSubBoardCard("10103", CHANCELLOR_STRING, pos)
end

function spawnChancellorRed(pos)
	return spawnSubBoardCard("10104", CHANCELLOR_STRING, pos)
end

function spawnChancellorBlue(pos)
	return spawnSubBoardCard("10105", CHANCELLOR_STRING, pos)
end

function spawnSubBoardCard(cardID, desc, pos)
   local params = {
      json =
			"{" ..
			"\"Name\": \"Card\", " ..
			"\"Transform\": {\"posX\": 0,\"posY\": 0,\"posZ\": 0,\"rotX\": 0,\"rotY\": 0,\"rotZ\": 0,\"scaleX\": 1,\"scaleY\": 1,\"scaleZ\": 1}, " ..
			"\"CardID\": " .. cardID .. ", " ..
			"\"CustomDeck\": {" ..
			"\"" .. string.sub(cardID, 1, 3) .. "\": {" ..
			"\"FaceURL\": \"http://cloud-3.steamusercontent.com/ugc/972100947052102628/F255D2E89C2A1D4FAA9C1AEC714802863A388D8C/\", " ..
			"\"BackURL\": \"http://cloud-3.steamusercontent.com/ugc/972100947052102628/F255D2E89C2A1D4FAA9C1AEC714802863A388D8C/\", " ..
			"\"NumWidth\": 3, " ..
			"\"NumHeight\": 2, " ..
			"\"BackIsHidden\": false, " ..
			"\"UniqueBack\": true " ..
			"}" ..
			"}" ..
			"}",
      position = pos,
      rotation = FACE_UP_ROT,
      scale = {x = 0.3, y = 1, z = 0.3},
      sound = false
   }
	local card = spawnObjectJSON(params)
	card.setDescription(desc)
	card.use_grid = false
   return card
end

function spawnLiberalPolicy(pos, rot)
	return spawnPolicyCard("10200", LIBERALPOLICY_STRING, pos, rot, true)
end

function spawnFascistPolicy(pos, rot)
	return spawnPolicyCard("10201", FASCISTPOLICY_STRING, pos, rot, true)
end

function spawnGreyPolicy(pos, rot)
	return spawnPolicyCard("10203", GREYPOLICY_STRING, pos, rot, true)
end

function spawnNotUsedLiberal(pos)
	return spawnPolicyCard("10204", NOTUSED_STRING, pos, FACE_UP_ROT, false)
end

function spawnNotUsedFascist(pos)
	return spawnPolicyCard("10205", NOTUSED_STRING, pos, FACE_UP_ROT, false)
end

function spawnPolicyCard(cardID, desc, pos, rot, luaBool)
   local params = {
      json =
			"{" ..
			"\"Name\": \"Card\", " ..
			"\"Transform\": {\"posX\": 0,\"posY\": 0,\"posZ\": 0,\"rotX\": 0,\"rotY\": 0,\"rotZ\": 0,\"scaleX\": 1,\"scaleY\": 1,\"scaleZ\": 1}, " ..
			"\"CardID\": " .. cardID .. ", " ..
			"\"CustomDeck\": {" ..
			"\"" .. string.sub(cardID, 1, 3) .. "\": {" ..
			"\"FaceURL\": \"http://cloud-3.steamusercontent.com/ugc/968725783513761884/D20A41E646CE901CA81FC067E81072BBDA9313C4/\", " ..
			"\"BackURL\": \"http://cloud-3.steamusercontent.com/ugc/486767005708571374/C5FBC566556E3FBE9A6C8ACCDB2472FA911A253A/\", " ..
			"\"NumWidth\": 4, " ..
			"\"NumHeight\": 2, " ..
			"\"BackIsHidden\": false, " ..
			"\"UniqueBack\": false " ..
			"}" ..
			"}" ..
			"}",
      position = pos,
      rotation = rot,
      scale = {x = 1.51, y = 1, z = 1.51},
      sound = false
   }
	local card = spawnObjectJSON(params)
	card.setDescription(desc)
	card.use_grid = false
	if luaBool then
		card.setLuaScript(
			'enabled = false -- workaround for rewind error\r\n' ..
			'\r\n' ..
			'function onDrop(playerColor)\r\n' ..
			'	enabled = true\r\n' ..
			'	Global.call(\'createPolicyCardWait\')\r\n' ..
			'end\r\n' ..
			'\r\n' ..
			'function onCollisionEnter(collisionInfo)\r\n' ..
			'	if enabled then\r\n' ..
			'		Global.call(\'createPolicyCardWait\')\r\n' ..
			'	end\r\n' ..
			'end\r\n')
	end
   return card
end

end

----#include \SecretHitlerCE\cardsboard.ttslua
----#include \SecretHitlerCE\UI.ttslua

UIActionTable = {}
UITargetColorTable = {}
UIPlayerNameTable = {}
UIInputTable = {}
UIhidden = false

function refreshUI()
	if options.zoneType == 6 then
		local abilitiesDeck = getDeckFromZoneByGUID(ABILITIESPILE_ZONE_GUID)
		if abilitiesDeck then
			UI.setAttribute("greyCommandsExp", "visibility", "Grey")
			UI.setAttribute("greyCommands", "visibility", " ")
		else
			UI.setAttribute("greyCommands", "visibility", "Grey")
			UI.setAttribute("greyCommandsExp", "visibility", " ")
		end
		UI.setAttribute("greyPolicy", "visibility", "Grey")
		UI.setAttribute("greyVote", "visibility", "Grey")
		UI.setAttribute("adminButton", "visibility", "Admin")
		UI.setAttribute("admin", "visibility", "Admin")
		UI.setAttribute("adminButton", "active", "true")
	end
	if started == nil or started == false then
		for _, playerColor in pairs(MAIN_PLAYABLE_COLORS) do
			UI.hide("player" .. playerColor)
			UI.hide("hit" .. playerColor)
			UI.hide("fas" .. playerColor)
		end
		UI.hide("youLib")
		UI.hide("youFas")
		UI.hide("youHitler")
		UI.hide("youNotPlaying")
		UIhidden = true
	end
	
	if started then
		if UIhidden == true then
			for _, playerColor in pairs(MAIN_PLAYABLE_COLORS) do
				UI.show("player" .. playerColor)
				UI.show("hit" .. playerColor)
				UI.show("fas" .. playerColor)
			end
			UI.show("youLib")
			UI.show("youFas")
			UI.show("youHitler")
			UI.show("youNotPlaying")
			UIhidden = false
		end
		
		local youHitler = " "
		local youFas = " "
		local youLib = " "
		local youNotPlaying = "Grey"
		local hitWhite = ""
		local hitBrown = ""
		local hitRed = ""
		local hitOrange = ""
		local hitYellow = ""
		local hitGreen = ""
		local hitTeal = ""
		local hitBlue = ""
		local hitPurple = ""
		local hitPink = ""
		local hitTan = ""
		local hitMaroon = ""
		local fasWhite = ""
		local fasBrown = ""
		local fasRed = ""
		local fasOrange = ""
		local fasYellow = ""
		local fasGreen = ""
		local fasTeal = ""
		local fasBlue = ""
		local fasPurple = ""
		local fasPink = ""
		local fasTan = ""
		local fasMaroon = ""

		if options.zoneType == 6 then
			youNotPlaying = " "
			for _, playerColor in pairs(GREY_PLAYABLE_COLORS) do
				if roles[playerColor] == "hitler" then
					UI.setValue("hit" .. playerColor, playerColor .. " is " .. text.hitler .. "!")
				elseif roles[playerColor] == "fascist" then
					UI.setValue("fas" .. playerColor, playerColor .. " is " .. text.fascistArticle .. " " .. text.fascist .. "!")
				end
			end
		end
		for _, playerColor in pairs(MAIN_PLAYABLE_COLORS) do
			UI.setAttribute("player" .. playerColor, "visibility", playerColor)
			if roles[playerColor] == "hitler" then
				UI.setValue("hit" .. playerColor, playerColor .. " is " .. text.hitler .. "!")
				if youHitler == " " then
					youHitler = playerColor
				else
					youHitler = youHitler .. "|" .. playerColor
				end
			elseif roles[playerColor] == "fascist" then
				UI.setValue("fas" .. playerColor, playerColor .. " is " .. text.fascistArticle .. " " .. text.fascist .. "!")
				if youFas == " " then
					youFas = playerColor
				else
					youFas = youFas .. "|" .. playerColor
				end
			elseif roles[playerColor] == "liberal" then
				if youLib == " " then
					youLib = playerColor
				else
					youLib = youLib .. "|" .. playerColor
				end
			else
				if youNotPlaying == " " then
					youNotPlaying = playerColor
				else
					youNotPlaying = youNotPlaying .. "|" .. playerColor
				end
			end
		end
		hitWhite = hitVisibility("White")
		hitBrown = hitVisibility("Brown")
		hitRed = hitVisibility("Red")
		hitOrange = hitVisibility("Orange")
		hitYellow = hitVisibility("Yellow")
		hitGreen = hitVisibility("Green")
		hitTeal = hitVisibility("Teal")
		hitBlue = hitVisibility("Blue")
		hitPurple = hitVisibility("Purple")
		hitPink = hitVisibility("Pink")
		hitTan = hitVisibility("Tan")
		hitMaroon = hitVisibility("Maroon")
		fasWhite = fasVisibility("White")
		fasBrown = fasVisibility("Brown")
		fasRed = fasVisibility("Red")
		fasOrange = fasVisibility("Orange")
		fasYellow = fasVisibility("Yellow")
		fasGreen = fasVisibility("Green")
		fasTeal = fasVisibility("Teal")
		fasBlue = fasVisibility("Blue")
		fasPurple = fasVisibility("Purple")
		fasPink = fasVisibility("Pink")
		fasTan = fasVisibility("Tan")
		fasMaroon = fasVisibility("Maroon")

		UI.setValue("youLib", "You are " .. text.liberalArticle .. " " .. text.liberal .. "!")
		UI.setValue("youFas", "You are " .. text.fascistArticle .. " " .. text.fascist .. "!")
		UI.setValue("youHitler", "You are " .. text.hitler .. "!")
		UI.setAttribute("youLib", "visibility", youLib)
		UI.setAttribute("youFas", "visibility", youFas)
		UI.setAttribute("youHitler", "visibility", youHitler)
		UI.setAttribute("youNotPlaying", "visibility", youNotPlaying)
		UI.setAttribute("hitWhite", "visibility", hitWhite)
		UI.setAttribute("hitBrown", "visibility", hitBrown)
		UI.setAttribute("hitRed", "visibility", hitRed)
		UI.setAttribute("hitOrange", "visibility", hitOrange)
		UI.setAttribute("hitYellow", "visibility", hitYellow)
		UI.setAttribute("hitGreen", "visibility", hitGreen)
		UI.setAttribute("hitTeal", "visibility", hitTeal)
		UI.setAttribute("hitBlue", "visibility", hitBlue)
		UI.setAttribute("hitPurple", "visibility", hitPurple)
		UI.setAttribute("hitPink", "visibility", hitPink)
		UI.setAttribute("hitTan", "visibility", hitTan)
		UI.setAttribute("hitMaroon", "visibility", hitMaroon)
		UI.setAttribute("fasWhite", "visibility", fasWhite)
		UI.setAttribute("fasBrown", "visibility", fasBrown)
		UI.setAttribute("fasRed", "visibility", fasRed)
		UI.setAttribute("fasOrange", "visibility", fasOrange)
		UI.setAttribute("fasYellow", "visibility", fasYellow)
		UI.setAttribute("fasGreen", "visibility", fasGreen)
		UI.setAttribute("fasTeal", "visibility", fasTeal)
		UI.setAttribute("fasBlue", "visibility", fasBlue)
		UI.setAttribute("fasPurple", "visibility", fasPurple)
		UI.setAttribute("fasPink", "visibility", fasPink)
		UI.setAttribute("fasTan", "visibility", fasTan)
		UI.setAttribute("fasMaroon", "visibility", fasMaroon)
	end
end

function hitVisibility(colorIn)
	local visList = ""

	if inTable(hitler, colorIn) then
		visList = "Black"
		for _, playerColor in pairs(fascists) do
			if playerColor ~= colorIn and not inTable(GREY_PLAYABLE_COLORS, playerColor) then
				visList = visList .. "|" .. playerColor
			end
		end
		if #players < 7 then
			for _, playerColor in pairs(hitler) do
				if playerColor ~= colorIn and not inTable(GREY_PLAYABLE_COLORS, playerColor) then
					visList = visList .. "|" .. playerColor
				end
			end
		end
	end

	if visList == "" then
		visList = " "
	end

	return visList
end

function fasVisibility(colorIn)
	local visList = ""

	if inTable(fascists, colorIn) then
		visList = "Black"
		for _, playerColor in pairs(fascists) do
			if playerColor ~= colorIn and not inTable(GREY_PLAYABLE_COLORS, playerColor) then
				visList = visList .. "|" .. playerColor
			end
		end
		if #players < 7 then
			for _, playerColor in pairs(hitler) do
				if playerColor ~= colorIn and not inTable(GREY_PLAYABLE_COLORS, playerColor) then
					visList = visList .. "|" .. playerColor
				end
			end
		end
	end

	if visList == "" then
		visList = " "
	end

	return visList
end

function chooseChan12P(targetColor, playerColor)
	local player = getPlayerObj(playerColor)
	local currPres = getPres()
	if currPres == playerColor then
		local tmpChan = getObjectFromGUID(CHANCELOR_GUID)
		if tmpChan then giveObjectToPlayer(tmpChan, targetColor, {forward = 11, right = 0, up = 0, forceHeight = 2.8}, NO_ROT, false, false) end
	else
		player.print("You are not the current president.", {1,0,0})
	end
end

function deal12P(amount, playerColor)
	function deal12PCoroutine()
		local drawDeck = getDeckFromZoneByGUID(DRAW_ZONE_GUID)
		local takeParam = {}

		for i = 1, amount do
			local card = drawDeck.takeObject(takeParam)
			local cardRot = {x = 0, y = 180, z = 180, exactRot = true}
			giveObjectToPlayer(card, playerColor, {forward = GREY_FORWARD, right = GREY_POLICY_RIGHT, up = GREY_UP}, cardRot, false, true)
			sleep(0.1)
		end
		sleep(2)
		printPolicyCards12P("Draw", playerColor)
		return 1
	end
	startLuaCoroutine(Global, "deal12PCoroutine")
end

function discard12P(policy, playerColor)
	local discardZone = getObjectFromGUID(DISCARD_ZONE_GUID)
	if discardZone then
		local pos = discardZone.getPosition()
		pos = {pos['x'], 2.5, pos['z']}
		local result = moveCard12P(nil, policy, pos, FACE_DOWN_ROT, playerColor)
		if result ~= -1 then
			smartBroadcastToColor("You discarded a " .. policy .. " card.", playerColor, {1, 1, 1})
		end
	else
		broadcastToAll("ERROR: Discard zone not found", {1, 0, 0})
	end
end

function givePres12P(targetColor, playerColor)
	local player = getPlayerObj(playerColor)
	local currPres = getPres()
	if currPres == playerColor then
		movePlacards(targetColor, true)
	else
		player.print("You are not the current president.",{1,0,0})
	end
end

function moveCard12P(name, description, pos, rot, playerColor)
	local foundIndex = nil

	local zoneObjs = getObjsFromZone(GREY_HAND_ZONE_GUIDS[playerColor])
	if #zoneObjs == nil then
		smartBroadcastToColor("ERROR: No cards found in your hand.", playerColor, {1, 0, 0})
		return -1
	end
	if name == nil then
		for i = 1, #zoneObjs do
			if string.match(zoneObjs[i].description, description) then
				foundIndex = i
				break
			end
		end
	else
		for i = 1, #zoneObjs do
			if string.match(string.lower(zoneObjs[i].name), string.lower(name)) then
				foundIndex = i
				break
			end
		end
	end
	if foundIndex == nil then
		smartBroadcastToColor("ERROR: Card not found.", playerColor, {1, 0, 0})
		return -1
	end
	if zoneObjs[foundIndex].deck_guid == nil then
		local card = getObjectFromGUID(zoneObjs[foundIndex].guid)
		card.setPositionSmooth(pos)
		card.setRotationSmooth(rot)
	else
		local deck = getObjectFromGUID(zoneObjs[foundIndex].deck_guid)
		takeParam =
		{
			position = pos,
			rotation = rot,
			index = zoneObjs[foundIndex].index
		}
		deck.takeObject(takeParam)
	end

	return zoneObjs[foundIndex]
end

function printPolicyCards12P(mode, playerColor)
	local player = getPlayerObj(playerColor)
	local zoneObjs = {}
	local policyCardStr = ""
	local expansionCardStr = "Your other cards are:"
	local outStr = ""

	if player then
		zoneObjs = getObjsFromZone(GREY_HAND_ZONE_GUIDS[playerColor])
		for k, v in pairs(zoneObjs) do
			if v.description == "Liberal Policy" then
				policyCardStr = policyCardStr .. "[0000FF]L[-]"
			elseif v.description == "Fascist Policy" then
				policyCardStr = policyCardStr .. "[FF0000]F[-]"
			elseif not (string.match(v.description, "Ja Card") or string.match(v.description, "Nein Card")) then
				expansionCardStr = expansionCardStr .. "\n" .. v.name
			end
		end
		if mode == "Draw" then
			outStr = "You drew " .. policyCardStr .. ".\n"
		elseif mode == "Check" then
			if policyCardStr == "" then
				outStr = "You have no policy cards.\n"
			else
				outStr = "Your policy cards are:" .. policyCardStr .. "\n"
			end
		end
		if expansionCardStr == "Your other cards are:" or mode == "Draw" then
			bigBroadcast(outStr, player)
		else
			bigBroadcast(outStr .. expansionCardStr, player)
		end
	end
end

function vote12P(playerColor, voteName)
	function vote12PCoroutine()
		local jaCard = getObjectFromGUID(jaCardGuids[playerColor])
		local neinCard = getObjectFromGUID(neinCardGuids[playerColor])

		-- move found cards back
		if jaCard then
			local jaCardRot = {x = 0, y = 180, z = 180, exactRot = true}
			giveObjectToPlayer(jaCard, playerColor, {forward = GREY_FORWARD, right = GREY_RIGHT, up = GREY_UP}, jaCardRot, false, true)
		end
		if neinCard then
			local neinCardRot = {x = 0, y = 180, z = 180, exactRot = true}
			giveObjectToPlayer(neinCard, playerColor, {forward = GREY_FORWARD, right = GREY_RIGHT, up = GREY_UP}, neinCardRot, false, true)
		end
		sleep(0.1)
		-- move vote out
		moveCard12P(nil, voteName, GREY_VOTE_POS[playerColor], FACE_DOWN_ROT, playerColor)

		return 1
	end
	startLuaCoroutine(Global, "vote12PCoroutine")
end

function playerNameUIIF(player, value, id)
	UIPlayerNameTable[player.steam_id] = value
end

function sitMaroonUIB(player, value, id)
	sitColorGrey(player, "Maroon")
end

function sitTanUIB(player, value, id)
	sitColorGrey(player, "Tan")
end

function sitColorGrey(player, color)
	if player.admin then
		if UIPlayerNameTable[player.steam_id] then
			local sitPlayer = getPlayerByNameSteamID(UIPlayerNameTable[player.steam_id], Player.getSpectators())
		 	if not sitPlayer then
				player.broadcast(UIPlayerNameTable[player.steam_id] .. " not found or is not grey.", {1, 0, 0})
		      return
		 	end
			if inTable(greyPlayerSteamIds, sitPlayer.steam_id) then
		   	player.broadcast(sitPlayer.steam_name .. " is already seated.", {1, 0, 0})
		      return
			end
			printToAll(sitPlayer.steam_name .. " is color " .. color .. ".", GREY_PLAYABLE_COLORS_RGB[color])
			local textObj = getObjectFromGUID(GREY_TEXT_GUIDS[color])
			textObj.TextTool.setValue(sitPlayer.steam_name)
			greyPlayerSteamIds[color] = sitPlayer.steam_id
			local objParam = {
				type = "Custom_Model",
				position = GREY_AVATAR_POS[color],
				rotation = {0, 0, 0},
				scale = {2.5, 2.5, 1},
				callback = "greyAvatarCallback",
				sound = false
			}
			if greyAvatarGuids[color] then
				destroyObjectByGUID(greyAvatarGuids[color])
			end
			local avatar = spawnObject(objParam)
			avatar.setLock(true)
			avatar.setDescription(color .. " Avatar")
			avatar.interactable = false
			local customParam = {
				diffuse = generateAvatarImageUrl(sitPlayer.steam_id),
				mesh = "http://cloud-3.steamusercontent.com/ugc/933813375177509684/900B7683E01C43C394C408BC38E034B305F1B3AA/",
				collider = "http://cloud-3.steamusercontent.com/ugc/487893695356616224/E3E39A827C062914E4185D8757A81D4D14892B8B/",
				type = 0,
				material = 3
			}
			avatar.setCustomObject(customParam)
		end
	end
end

function greyAvatarCallback(objIn, paramsIn)
	local color = string.gsub(objIn.getDescription(), " Avatar", "")
	greyAvatarGuids[color] = objIn.getGUID()
end

function removeColorGreyUIB(player, value, id)
	if player.admin then
		local sitPlayer = getPlayerByNameSteamID(UIPlayerNameTable[player.steam_id], Player.getSpectators())
	 	if not sitPlayer then
			player.broadcast(UIPlayerNameTable[player.steam_id] .. " not found or is not grey.", {1, 0, 0})
	      return
	 	end
		local colorFound = getGreyColor(sitPlayer.steam_id)
		if colorFound then
			greyPlayerSteamIds[colorFound] = nil
			destroyObjectByGUID(greyAvatarGuids[colorFound])
			local textObj = getObjectFromGUID(GREY_TEXT_GUIDS[colorFound])
			if textObj then
				textObj.TextTool.setValue(" ")
			end
		else
			player.print(sitPlayer.steam_name .. " is not seated.")
		end
	end
end

function tellRoleButtonUIB(player, value, id)
	local colorFound = getGreyColor(player.steam_id)
	if colorFound then
   	bigBroadcast(tellRole(colorFound), player)
	else
		bigBroadcast(tellRole(player.color), player)
	end
end

function voteJaUIB(player, value, id)
	if not started then
		player.print("Game has not started.")
		return
	end
	local colorFound = getGreyColor(player.steam_id)
	if colorFound then
		vote12P(colorFound, "Ja Card")
	else
		player.print("You are not seated.")
	end
end

function voteNeinUIB(player, value, id)
	if not started then
		player.print("Game has not started.")
		return
	end
	local colorFound = getGreyColor(player.steam_id)
	if colorFound then
		vote12P(colorFound, "Nein Card")
	else
		player.print("You are not seated.")
	end
end

function voteRemoveUIB(player, value, id)
	if not started then
		player.print('Game has not started.')
		return
	end
	local colorFound = getGreyColor(player.steam_id)
	if colorFound then
		local jaCard = getObjectFromGUID(jaCardGuids[colorFound])
		local neinCard = getObjectFromGUID(neinCardGuids[colorFound])
		if jaCard then
			local jaCardRot = {x = 0, y = 180, z = 180, exactRot = true}
			giveObjectToPlayer(jaCard, colorFound, {forward = GREY_FORWARD, right = GREY_RIGHT, up = GREY_UP}, jaCardRot, false, true)
		end
		if neinCard then
			local neinCardRot = {x = 0, y = 180, z = 180, exactRot = true}
			giveObjectToPlayer(neinCard, colorFound, {forward = GREY_FORWARD, right = GREY_RIGHT, up = GREY_UP}, neinCardRot, false, true)
		end
	else
		player.print('You are not seated.')
	end
end

function UIDrawCards(player, value, id)
	if not started then
   	player.print("Game has not started.")
		return
	end
	local colorFound = getGreyColor(player.steam_id)
	if colorFound then
		drawThree(nil, colorFound)
	else
		player.print("You are not seated.")
	end
end

function discardFUIB(player, value, id)
	if not started then
		player.print("Game has not started.")
		return
	end
	local colorFound = getGreyColor(player.steam_id)
	if colorFound then
		discard12P("Fascist Policy", colorFound)
   else
		player.print("You are not seated.")
	end
end

function discardLUIB(player, value, id)
	if not started then
   	player.print("Game has not started.")
		return
   end
	local colorFound = getGreyColor(player.steam_id)
	if colorFound then
   	discard12P("Liberal Policy", colorFound)
	else
   	player.print("You are not seated.")
	end
end

function checkCardsUIB(player, value, id)
	if not started then
		player.print("Game has not started.")
		return
	end
	local colorFound = getGreyColor(player.steam_id)
	if colorFound then
		printPolicyCards12P("Check", colorFound)
	else
		player.print("You are not seated.")
	end
end

function actionUID(player, value, id)
	UIActionTable[player.steam_id] = value
end

function colorUID(player, value, id)
	UITargetColorTable[player.steam_id] = value
end

function inputUIIF(player, value, id)
	UIInputTable[player.steam_id] = value
end

function startUIB(player, value, id)
	if not started then
		player.print("Game has not started.")
		return
	end
	local colorFound = getGreyColor(player.steam_id)
	if colorFound then
		if UIActionTable[player.steam_id] == "Choose Chancellor" then
			chooseChan12P(UITargetColorTable[player.steam_id], colorFound)
		elseif UIActionTable[player.steam_id] == "Inspect Player" then
			playerInspected(nil, colorFound, UITargetColorTable[player.steam_id])
		elseif UIActionTable[player.steam_id] == "Give Presidency To" then
			givePres12P(UITargetColorTable[player.steam_id], colorFound)
		elseif UIActionTable[player.steam_id] == "Discard Ability" then
			discardAbility(UIInputTable[player.steam_id], colorFound)
		elseif UIActionTable[player.steam_id] == "Reveal Ability" then
			revealAbility(UIInputTable[player.steam_id], colorFound)
		elseif UIActionTable[player.steam_id] == "Examine Ability Deck" then
			examineAbilityDeck(colorFound)
		elseif UIActionTable[player.steam_id] == "Take from Ability Deck" then
			takeAbility(UIInputTable[player.steam_id], colorFound)
		elseif UIActionTable[player.steam_id] == "Give Card to" then
			giveCardExp(UIInputTable[player.steam_id], UITargetColorTable[player.steam_id], colorFound)
		end
 	else
		player.print("You are not seated.")
	end
end

function discardAbility(cardName, playerColor)
	local abilityDeck = getDeckFromZoneByGUID(ABILITIESPILE_ZONE_GUID)
	local pos = abilityDeck.getPosition()
	local result = {}

	result = moveCard12P(cardName, nil, pos, FACE_DOWN_ROT, playerColor)
	if result ~= -1 then
		smartBroadcastToColor("You discarded " .. result.name, playerColor, {1, 1, 1})
	end
end

function revealAbility(cardName, playerColor)
	local pos = GREY_ABILITY_POS[playerColor]
	local result = {}

	result = moveCard12P(cardName, nil, pos, FACE_UP_ROT, playerColor)
	if result ~= -1 then
		broadcastToAll(playerColor .. " has played " .. result.name, {1, 1, 1})
	end
end

function examineAbilityDeck(playerColor)
	local player = getPlayerObj(playerColor)
	local abilityDeck = getDeckFromZoneByGUID(ABILITIESPILE_ZONE_GUID)
	local deckString = ""
	if abilityDeck == nil then
		player.broadcast("ERROR: Ability deck not found.", {1, 1, 1})
		return
	end
	local deckTable = abilityDeck.getObjects()
	player.print("Cards in the ability deck:")
	for k, v in pairs(deckTable) do
		deckString = deckString .. v.nickname .. " "
	end
	player.print(deckString)
	broadcastToAll(playerColor .. " examines the Ability deck.", {1, 1, 1})
end

function takeAbility(cardName, playerColor)
	local player = getPlayerObj(playerColor)
	local foundIndex = nil
	local abilityDeck = getDeckFromZoneByGUID(ABILITIESPILE_ZONE_GUID)
	if abilityDeck == nil then
		player.broadcast("ERROR: Ability deck not found.", {1, 0, 0})
		return
	end
	local deckTable = abilityDeck.getObjects()
	for k,v in pairs(deckTable) do
		if string.match(string.lower(v.nickname), string.lower(cardName)) then
			foundIndex = v.index
		end
	end
	if foundIndex == nil then
		player.broadcast("ERROR: Ability not found in deck.", {1, 0, 0})
	else
		local info = getPlayerPosRotVectors(playerColor)
		if info.pos then
			local takeParams = {
				index = foundIndex,
				position = info.pos
			}
			abilityDeck.takeObject(takeParams)
			player.broadcast("You drew " .. deckTable[foundIndex + 1].nickname .. " [FFFFFF]from the Ability deck.", {1, 1, 1})
			broadcastToAll(playerColor .. " takes an ability from the Ability deck", {1, 1, 1})
		end
	end
end

function giveCardExp(cardName, targetColor, playerColor)
	local info = getPlayerPosRotVectors(targetColor)
	local result = {}

	if info.pos then
		result = moveCard12P(cardName, nil, info.pos, FACE_DOWN_ROT, playerColor)
	end
	if result ~= -1 then
		smartBroadcastToColor("You gave " .. targetColor .. " the " .. result.name .. " card.", playerColor, {1, 1, 1})
	end
end

function closeAdminUIB(player, value, id)
	if player.admin then
		UI.setAttribute("admin", "active", false)
		UI.setAttribute("adminButton", "active", true)
	end
end

function showAdminUIB(player, value, id)
	if player.admin then
		UI.setAttribute("admin", "active", true)
		UI.setAttribute("adminButton", "active", false)
	end
end

function drawCardsUIB(player, value, id)
	if not started then
   		player.print("Game has not started.")
		return
	end
	local colorFound = getGreyColor(player.steam_id)
	if colorFound then
		drawThree(player, colorFound)
	else
		player.print("You are not seated.")
	end
end

----#include \SecretHitlerCE\UI.ttslua
----#include \SecretHitlerCE\notetaker.ttslua


useColor = true
cooperative = false
colorMatch = false
useNames = false
playerNoteTaker = ''
privateFogGUID = nil
privateScreenGUID = nil
swapLF = false
moveTracker = true
prevPresColor = nil
prevChanColor = nil
nextPost = nil
forceMenu = nil
lastGUID = nil
editMode = true -- true is right, false is left


--CUT HERE
model_list = {}
image_list = {}

savedButtons = {}
securityIsDisabled = false

menu_unicode = '☰'
up_unicode = '▲'
right_unicode = '►'
down_unicode = '▼'
left_unicode = '◄'

noteTakerNotes = {}
noteTakerCurrLine = 0

rightOffset = {White = 0, Brown = 0, Red = 0, Orange = 2.5, Yellow = -2.5, Green = 0, Teal = 0, Blue = 0, Purple = 2.5, Pink = -2.5}
colorOffset = {White = 0, Brown = 0, Red = 0, Orange = 0, Yellow = 0, Green = 5, Teal = 5, Blue = 5, Purple = 5, Pink = 5}
cancelDestroy = false
functionName = nil
sharedHistory = false

-- Defaults (Custom_Board)
posXscale = 1
posY = 0.6
posZscale = 1
posZoffsetMenu = 0
posZoffsetPostRetrieve = 0
posZoffsetColors = 0
posZoffsetSettingsColors = 0
posZoffsetCenterButtons = 0
posZoffsetOther = 0
rotZ = 0
giveHeight = 0
giveForward = -19
buttonScale = 1
fontScale = 1
maxLines = 25
textColorReplace = 'FFFFFF]'

-- tracker (default)
electionTrackerOrgPos = {x = -3.970005, y = 1.27525151, z = -9.385001}
electionTrackerMoveX = 2.7

function noteTakerOnLoad(saveString)
	self.setDescription('Note Taker by Lost Savage\nBased on the work of:\nsmiling Aktheon,\nSwiftPanda,\nThe Blind Dragon\nand Max\n')
	if not (saveString == '') then
		local save = JSON.decode(saveString)
		useColor = save['c']
		cooperative = save['co']
		colorMatch = save['m']
		useNames = save['n']
		noteTakerNotes = save['ntn']
		noteTakerCurrLine = save['ntcl']
		playerNoteTaker = save['p']
		privateFogGUID = save['pfg']
		privateScreenGUID = save['psg']
		swapLF = save['s']
		moveTracker = save['t']
	end

	if self.name ~= 'backgammon_board' then
		sharedHistory = true
		Global.call('initNoteTakerValues', {self.name})
		if Global.getVar('noteTakerCurrLine') == 0 then
			Global.call('addNewLine')
		end
	else
		initNoteTakerValues(self.name)
		if noteTakerCurrLine == 0 then
			addNewLine()
		end
		local oldNoteTaker = getObjectFromGUID(lastGUID)
		if oldNoteTaker then
			noteTakerNotes = oldNoteTaker.getTable('noteTakerNotes')
			noteTakerCurrLine = oldNoteTaker.getVar('noteTakerCurrLine')
		end
	end

	if playerNoteTaker and not (playerNoteTaker == '') then
		if forceMenu then
			forceMenu = false
			if sharedHistory then
				Global.call('menu', {self})
			else
				menu(self)
			end
		else
			if sharedHistory then
				Global.call('setupBoard', {self})
			else
				setupBoard(self)
			end
		end
	else
		if sharedHistory then
			Global.call('menu', {self})
		else
			menu(self)
		end
	end
end

function notetakerOnSave()
	local save = {}
	save['c'] = useColor
	save['co'] = cooperative
	save['m'] = colorMatch
	save['n'] = useNames
	save['ntn'] = noteTakerNotes
	save['ntcl'] = noteTakerCurrLine
	save['p'] = playerNoteTaker
	save['pfg'] = privateFogGUID
	save['psg'] = privateScreenGUID
	save['s'] = swapLF
	save['t'] = moveTracker

	local saveString = JSON.encode(save)

	return saveString
end

function notetakerOnDestroy()
	if not cancelDestroy then
		if privateScreenGUID then destroyObjectByGUID(privateScreenGUID) end
		if privateFogGUID then destroyObjectByGUID(privateFogGUID) end
	end
end

function initNoteTakerValues(boardName)
	if type(boardName) == 'table' then
		boardName = boardName[1]
	end
	local options = Global.getTable('options')

	if boardName == 'Custom_Board' then
		if options.zoneType == 6 then
			posZoffsetMenu = -0.25
			posZoffsetCenterButtons = -0.25
		end
	elseif boardName == 'Chess_Board' then
		posXscale = -1
		posY = -0.9
		rotZ = 180
		if options.zoneType == 6 then
			posZoffsetMenu = -0.25
			posZoffsetCenterButtons = -0.25
		end
	elseif boardName == 'Checker_Board' then
		posXscale = -1
		posY = -0.1
		rotZ = 180
		giveHeight = 1
		if options.zoneType == 6 then
			posZoffsetMenu = -0.25
			posZoffsetCenterButtons = -0.25
		end
	elseif boardName == 'Go_Board' then
		posXscale = -1.1
		posY = -1.3
		posZscale = 1.1
		rotZ = 180
		giveHeight = -1
		buttonScale = 1.1
		fontScale = 1.1
		if options.zoneType == 6 then
			posZoffsetMenu = -0.25
			posZoffsetCenterButtons = -0.25
		end
	elseif boardName == 'reversi_board' then
		posXscale = -1.1
		posY = -1.5
		posZscale = 1.1
		rotZ = 180
		giveHeight = -1
		buttonScale = 1.1
		fontScale = 1.1
		if options.zoneType == 6 then
			posZoffsetMenu = -0.25
			posZoffsetCenterButtons = -0.25
		end
	elseif boardName == 'backgammon_board' then
		posXscale = -0.9
		posY = -0.1
		posZscale = 0.9
		posZoffsetMenu = -3.7
		posZoffsetColors = 4.5
		posZoffsetSettingsColors = 4.5
		if options.zoneType == 6 then
			posZoffsetCenterButtons = 4.25
		else
			posZoffsetCenterButtons = 4.5
		end
		posZoffsetOther = 4.2
		rotZ = 180
		giveHeight = 1
		giveForward = -26
		buttonScale = 0.9
		fontScale = 0.9
		maxLines = 10
		textColorReplace = '000000]'
		noteTakerSetNotes = function(stringIn)
			local out = string.gsub(stringIn, stringColorToHex('White') .. ']', textColorReplace)
			local screen = getObjectFromGUID(privateScreenGUID)
			if screen then
				screen.setDescription(out)
			end
		end
	elseif boardName == 'Custom_Model' then
		posXscale = 1.5
		posZscale = 1.5
		buttonScale = 1.5
		fontScale = 1.5
		if options.zoneType == 6 then
			posZoffsetMenu = -0.25
			posZoffsetCenterButtons = -0.25
		end
	end

	if options.scriptedVoting and boardName ~= 'backgammon_board' then
		maxLines = 19
	end

	if options.zoneType == 6 then
		rightOffset = {White = 0, Brown = 0, Red = 0, Orange = 0, Yellow = 0, Green = 0, Teal = 0, Blue = 0, Purple = 0, Pink = 0, Tan = 0, Maroon = 0}
		colorOffset = {White = 10, Brown = 1, Red = 1, Orange = 1, Yellow = 4, Green = 4, Teal = 4, Blue = 7, Purple = 7, Pink = 7, Tan = 10, Maroon = 10}
	end
end

function spawnWaitDestructCoroutine()
	local params = {
		type = self.name,
		scale = self.getScale(),
		position = self.getPosition(),
		rotation = self.getRotation(),
		sound = false
	}
	local notetaker = spawnObject(params)
	notetaker.setLuaScript(respawnNoteTakerLuaScript())
	notetaker.setLock(true)
	if params.type == 'Custom_Board' then
		local custom = {}
		if image_list[functionName] then
			custom.image = image_list[functionName]
		elseif image_list['default'] then
			custom.image = image_list['default']
		else
			custom.image = 'http://cloud-3.steamusercontent.com/ugc/486766424829587499/FDF54ECD5D1706DE0A590239E84D62CDE757FE46/'
		end
		notetaker.setCustomObject(custom)
	elseif params.type == 'Custom_Model' then
		local custom = {}
		if image_list[functionName] then
			custom.diffuse = image_list[functionName]
		elseif image_list['default'] then
			custom.diffuse = image_list['default']
		else
			custom.diffuse = 'http://cloud-3.steamusercontent.com/ugc/478894184492866532/6639B6E1AB511AB10D53DB91B2A47A0A63410DDF/'
		end
		if model_list[functionName] then
			custom.mesh = model_list[functionName]
		elseif image_list['default'] then
			custom.mesh = model_list['default']
		else
			custom.mesh = 'http://cloud-3.steamusercontent.com/ugc/478894184492865468/51C18F993BBDD5D1B55FE5261A625B2CE0B2FD9F/'
		end
		custom.type = 4
		custom.material = 3
		notetaker.setCustomObject(custom)
	end
	wait(5)
	cancelDestroy = true
	self.destruct()

	return true
end

function menuButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		clickedObject.setVar('forceMenu', true)
		clickedObject.setVar('functionName', 'menu')
		startLuaCoroutine(clickedObject, 'spawnWaitDestructCoroutine')
	end
end

function menu(selfIn)
	if type(selfIn) == 'table' then
		selfIn = selfIn[1]
	end

	if selfIn.name == 'backgammon_board' then
		local screen = getObjectFromGUID(privateScreenGUID)
		if screen then
			forceObjectToPlayer(screen, selfIn.getVar('playerNoteTaker'), {forward = giveForward + 12.5, right = rightOffset[selfIn.getVar('playerNoteTaker')], up = 0, forceHeight = 0.9}, {x = 0, y = 180 - rotZ, z = 0})
			screen.setLock(true)
			startLuaCoroutine(selfIn, 'spawnFogCoroutine')
		else
			if selfIn.getVar('playerNoteTaker') ~= '' then
				forceMenu = true
				spawnScreen(selfIn)
				return
			end
		end
	end

	local buttonParam = {rotation = {0, 0, rotZ}, font_size = 300 * fontScale}
	if sharedHistory then
		buttonParam.function_owner = Global
	else
		buttonParam.function_owner = self
	end

	selfIn.clearButtons()

	local fakePlayerNoteTaker = false
	if selfIn.getVar('playerNoteTaker') == '' then
		fakePlayerNoteTaker = true
		selfIn.setVar('playerNoteTaker', 'White')
	end

	-- Who is the note taker?
	if selfIn.name == 'backgammon_board' then
		local screen = getObjectFromGUID(privateScreenGUID)
		if screen then
			screen.setDescription('\n\n\n\n\n\n\n\n\n                      Who is the note taker?')
		end
	else
		buttonParam.click_function = 'nullFunction'
		buttonParam.label = 'Who is the note taker?'
		buttonParam.position = {posXscale * 0, posY, (-7.3 * posZscale) + posZoffsetSettingsColors}
		buttonParam.height = 500 * buttonScale
		buttonParam.width = 3500 * buttonScale
		selfIn.createButton(buttonParam)
	end

	-- Player Options
	buttonParam.height = 700 * buttonScale
	buttonParam.width = 1800 * buttonScale
	if not cooperative or Player[selfIn.getVar('playerNoteTaker')].admin then
		buttonParam.click_function = 'setupWhite'
		buttonParam.label = 'White'
		buttonParam.position = {posXscale * 4, posY, (-1.25 * posZscale) + posZoffsetSettingsColors}
		buttonParam.color = stringColorToRGB('White')
		selfIn.createButton(buttonParam)

		buttonParam.click_function = 'setupBrown'
		buttonParam.label = 'Brown'
		buttonParam.position = {posXscale * 0, posY, (-1.25 * posZscale) + posZoffsetSettingsColors}
		buttonParam.color = stringColorToRGB('Brown')
		selfIn.createButton(buttonParam)

		buttonParam.click_function = 'setupRed'
		buttonParam.label = 'Red'
		buttonParam.position = {posXscale * -4, posY, (-1.25 * posZscale) + posZoffsetSettingsColors}
		buttonParam.color = stringColorToRGB('Red')
		selfIn.createButton(buttonParam)

		buttonParam.click_function = 'setupOrange'
		buttonParam.label = 'Orange'
		buttonParam.position = {posXscale * -6, posY, (-2.75 * posZscale) + posZoffsetSettingsColors}
		buttonParam.color = stringColorToRGB('Orange')
		selfIn.createButton(buttonParam)

		buttonParam.click_function = 'setupYellow'
		buttonParam.label = 'Yellow'
		buttonParam.position = {posXscale * -6, posY, (-4.25 * posZscale) + posZoffsetSettingsColors}
		buttonParam.color = stringColorToRGB('Yellow')
		selfIn.createButton(buttonParam)

		buttonParam.click_function = 'setupGreen'
		buttonParam.label = 'Green'
		buttonParam.position = {posXscale * -4, posY, (-5.75 * posZscale) + posZoffsetSettingsColors}
		buttonParam.color = stringColorToRGB('Green')
		selfIn.createButton(buttonParam)

		buttonParam.click_function = 'setupTeal'
		buttonParam.label = 'Teal'
		buttonParam.position = {posXscale * 0, posY, (-5.75 * posZscale) + posZoffsetSettingsColors}
		buttonParam.color = stringColorToRGB('Teal')
		selfIn.createButton(buttonParam)

		buttonParam.click_function = 'setupBlue'
		buttonParam.label = 'Blue'
		buttonParam.position = {posXscale * 4, posY, (-5.75 * posZscale) + posZoffsetSettingsColors}
		buttonParam.color = stringColorToRGB('Blue')
		selfIn.createButton(buttonParam)

		buttonParam.click_function = 'setupPurple'
		buttonParam.label = 'Purple'
		buttonParam.position = {posXscale * 6, posY, (-4.25 * posZscale) + posZoffsetSettingsColors}
		buttonParam.color = stringColorToRGB('Purple')
		selfIn.createButton(buttonParam)

		buttonParam.click_function = 'setupPink'
		buttonParam.label = 'Pink'
		buttonParam.position = {posXscale * 6, posY, (-2.75 * posZscale) + posZoffsetSettingsColors}
		buttonParam.color = stringColorToRGB('Pink')
		selfIn.createButton(buttonParam)
	end

	buttonParam.click_function = 'setupMe'
	buttonParam.label = 'Me'
	buttonParam.position = {posXscale * 0, posY, (-3.5 * posZscale) + posZoffsetSettingsColors}
	buttonParam.color = stringColorToRGB('White')
	selfIn.createButton(buttonParam)

	menuBase(selfIn)

	if fakePlayerNoteTaker then
		selfIn.setVar('playerNoteTaker', '')
	end
end

function menuBase(selfIn)
	local buttonParam = {rotation = {0, 0, rotZ}, font_size = 300 * fontScale}
	local text = Global.getTable('text')

	if sharedHistory then
		buttonParam.function_owner = Global
	else
		buttonParam.function_owner = self
	end

	buttonParam.click_function = 'flipUseNames'
	if useNames then buttonParam.label = 'x' else buttonParam.label = '' end
	buttonParam.position = {posXscale * -7.5, posY, (1.25 * posZscale) + posZoffsetOther}
	buttonParam.width = 300 * buttonScale
	buttonParam.height = 300 * buttonScale
	selfIn.createButton(buttonParam)
	buttonParam.label = 'Use player names'
	buttonParam.position = {posXscale * -4, posY, (1.25 * posZscale) + posZoffsetOther}
	buttonParam.width = 2700 * buttonScale
	buttonParam.height = 700 * buttonScale
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'flipUseColor'
	if useColor then buttonParam.label = 'x' else buttonParam.label = '' end
	buttonParam.position = {posXscale * -7.5, posY, (2.75 * posZscale) + posZoffsetOther}
	buttonParam.width = 300 * buttonScale
	buttonParam.height = 300 * buttonScale
	selfIn.createButton(buttonParam)
	buttonParam.label = 'Use color'
	buttonParam.position = {posXscale * -4, posY, (2.75 * posZscale) + posZoffsetOther}
	buttonParam.width = 2700 * buttonScale
	buttonParam.height = 700 * buttonScale
	selfIn.createButton(buttonParam)

	if selfIn.name ~= 'backgammon_board' or Player[selfIn.getVar('playerNoteTaker')].admin then
		buttonParam.click_function = 'flipMoveTracker'
		if moveTracker then buttonParam.label = 'x' else buttonParam.label = '' end
		buttonParam.position = {posXscale * -7.5, posY, (4.25 * posZscale) + posZoffsetOther}
		buttonParam.width = 300 * buttonScale
		buttonParam.height = 300 * buttonScale
		selfIn.createButton(buttonParam)
		buttonParam.label = 'Move tracker'
		buttonParam.position = {posXscale * -4, posY, (4.25 * posZscale) + posZoffsetOther}
		buttonParam.width = 2700 * buttonScale
		buttonParam.height = 700 * buttonScale
		selfIn.createButton(buttonParam)
	end

	buttonParam.click_function = 'flipSwapLF'
	if swapLF then buttonParam.label = 'x' else buttonParam.label = '' end
	buttonParam.position = {posXscale * -7.5, posY, (5.75 * posZscale) + posZoffsetOther}
	buttonParam.width = 300 * buttonScale
	buttonParam.height = 300 * buttonScale
	selfIn.createButton(buttonParam)
	buttonParam.label = 'Swap ' .. text.liberalLetter .. ' and ' .. text.fascistLetter
	buttonParam.position = {posXscale * -4, posY, (5.75 * posZscale) + posZoffsetOther}
	buttonParam.width = 2700 * buttonScale
	buttonParam.height = 700 * buttonScale
	selfIn.createButton(buttonParam)

	if selfIn.name == 'Checker_Board' or selfIn.name == 'Go_Board' then
		buttonParam.click_function = 'flipColorMatch'
		if colorMatch then buttonParam.label = 'x' else buttonParam.label = '' end
		buttonParam.position = {posXscale * -7.5, posY, (7.25 * posZscale) + posZoffsetOther}
		buttonParam.width = 300 * buttonScale
		buttonParam.height = 300 * buttonScale
		selfIn.createButton(buttonParam)
		buttonParam.label = 'Color match'
		buttonParam.position = {posXscale * -4, posY, (7.25 * posZscale) + posZoffsetOther}
		buttonParam.width = 2700 * buttonScale
		buttonParam.height = 700 * buttonScale
		selfIn.createButton(buttonParam)
	elseif selfIn.name == 'backgammon_board' and Player[selfIn.getVar('playerNoteTaker')].admin then
		buttonParam.click_function = 'flipCooperative'
		if cooperative then buttonParam.label = 'x' else buttonParam.label = '' end
		buttonParam.position = {posXscale * -7.5, posY, (7.25 * posZscale) + posZoffsetOther}
		buttonParam.width = 300 * buttonScale
		buttonParam.height = 300 * buttonScale
		selfIn.createButton(buttonParam)
		buttonParam.label = 'Cooperative'
		buttonParam.position = {posXscale * -4, posY, (7.25 * posZscale) + posZoffsetOther}
		buttonParam.width = 2700 * buttonScale
		buttonParam.height = 700 * buttonScale
		selfIn.createButton(buttonParam)
	end

	buttonParam.click_function = 'shuffleDrawDeckButton'
	buttonParam.label = 'Shuffle'
	buttonParam.position = {posXscale * 4, posY, 1.25  * posZscale + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'disableSecurityButton'
	savedButtons[buttonParam.click_function] = #selfIn.getButtons()
	buttonParam.label = 'Disable security'
	buttonParam.position = {posXscale * 4, posY, 2.75 * posZscale + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'giveRoleCardsButton'
	buttonParam.label = 'Give role cards'
	buttonParam.position = {posXscale * 4, posY, 4.25 * posZscale + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'forceVotePass'
	buttonParam.label = 'Vote Passed'
	buttonParam.position = {posXscale * 4, posY, 5.75 * posZscale + posZoffsetOther}
	selfIn.createButton(buttonParam)
end

function setupPlayer(clickedObject, playerIn)
	clickedObject.setVar('playerNoteTaker', playerIn)
	functionName = setupBoardGetFunction(playerIn) .. colorOffset[playerIn]
	startLuaCoroutine(clickedObject, 'spawnWaitDestructCoroutine')
end

function setupBoard(selfIn)
	if type(selfIn) == 'table' then
		selfIn = selfIn[1]
	end
	local playerNT = selfIn.getVar('playerNoteTaker')
	local imagename = setupBoardGetFunction(playerIn) .. colorOffset[playerNT]
	if colorMatch then selfIn.setColorTint(stringColorToRGBExtra(playerNT)) end
	forceObjectToPlayer(selfIn, playerNT, {forward = giveForward, right = rightOffset[playerNT], up = 0, forceHeight = giveHeight}, {x = rotZ, y = 180 - rotZ, z = 0})
	selfIn.setLock(true)
	if selfIn.name == 'backgammon_board' then
		local screen = getObjectFromGUID(privateScreenGUID)
		if screen then
			forceObjectToPlayer(screen, playerNT, {forward = giveForward + 12.5, right = rightOffset[playerNT], up = 0, forceHeight = 0.9}, {x = 0, y = 180 - rotZ, z = 0})
			screen.setLock(true)
			refreshNotes(selfIn)
			startLuaCoroutine(selfIn, 'spawnFogCoroutine')
		else
			spawnScreen(selfIn)
			return
		end
	end
	local fName = setupBoardGetFunction(playerNT)
	_G[fName](selfIn, colorOffset[playerNT])
end

function setupBoardGetFunction(playerIn)
	local options = Global.getTable('options')
	if options.zoneType == 6 then
		return 'init12Player'
	elseif playerIn == 'Orange' or playerIn == 'Yellow' or playerIn == 'Purple' or playerIn == 'Pink' then
		return 'initVertical'
	else
		return 'initHorizontal'
	end
end

function setupMe(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		setupPlayer(clickedObject, playerColor)
	end
end

function setupWhite(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		setupPlayer(clickedObject, 'White')
	end
end

function setupBrown(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		setupPlayer(clickedObject, 'Brown')
	end
end

function setupRed(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		setupPlayer(clickedObject, 'Red')
	end
end

function setupOrange(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		setupPlayer(clickedObject, 'Orange')
	end
end

function setupYellow(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		setupPlayer(clickedObject, 'Yellow')
	end
end

function setupGreen(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		setupPlayer(clickedObject, 'Green')
	end
end

function setupTeal(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		setupPlayer(clickedObject, 'Teal')
	end
end

function setupBlue(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		setupPlayer(clickedObject, 'Blue')
	end
end

function setupPurple(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		setupPlayer(clickedObject, 'Purple')
	end
end

function setupPink(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		setupPlayer(clickedObject, 'Pink')
	end
end

function flipUseNames(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		useNames = not useNames
		refreshNotes(clickedObject)
		menu(clickedObject)
	end
end

function flipUseColor(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		useColor = not useColor
		refreshNotes(clickedObject)
		menu(clickedObject)
	end
end

function flipSwapLF(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		swapLF = not swapLF
		menu(clickedObject)
	end
end

function flipColorMatch(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		colorMatch = not colorMatch
		menu(clickedObject)
	end
end

function flipCooperative(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		cooperative = not cooperative
		menu(clickedObject)
	end
end

function flipMoveTracker(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		moveTracker = not moveTracker
		menu(clickedObject)
	end
end

function shuffleDrawDeckButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if not Global.call('shuffleDrawDeck') then
			broadcastToColor('ERROR: Failed to shuffle draw deck.', playerColor, {1,0,0})
		end
	end
end

function disableSecurityButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		Global.call('toggleSecurity')
		securityIsDisabled = not securityIsDisabled
		if (securityIsDisabled) then
			local tempParams = {}
			tempParams.index = savedButtons["disableSecurityButton"]
			tempParams.label = "Enable Security"
			clickedObject.editButton(tempParams)
		else
			local tempParams = {}
			tempParams.index = savedButtons["disableSecurityButton"]
			tempParams.label = "Disable Security"
			clickedObject.editButton(tempParams)
		end
	end
end

function giveRoleCardsButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		Global.call('giveRoleCards')
	end
end

function forceVotePass(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		Global.setVar('votePassed', true)
		Global.setVar('blockDraw', false)
	end
end

function initHorizontal(selfIn, offset)
	local buttonParam = {rotation = {0, 0, rotZ}, width = 1800 * buttonScale, height = 700 * buttonScale, font_size = 300 * fontScale}

	if sharedHistory then
		buttonParam.function_owner = Global
	else
		buttonParam.function_owner = self
	end

	-- Players
	local color = offset + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 4, posY, (-2.25 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 0, posY, (-2.25 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -4, posY, (-2.25 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -6, posY, (-3.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -6, posY, (-5.25 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -4, posY, (-6.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 0, posY, (-6.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 4, posY, (-6.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 6, posY, (-5.25 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 6, posY, (-3.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	initCommon(selfIn)
end

function initVertical(selfIn, offset)
	local buttonParam = {rotation = {0, 0, rotZ}, width = 1800 * buttonScale, height = 700 * buttonScale, font_size = 300 * fontScale}

	if sharedHistory then
		buttonParam.function_owner = Global
	else
		buttonParam.function_owner = self
	end

	-- Players
	local color = offset + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 6, posY, (-6.0 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 6, posY, (-4.5 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 6, posY, (-3.0 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 2, posY, (-2.25 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -2, posY, (-2.25 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -6, posY, (-3.0 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -6, posY, (-4.5 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -6, posY, (-6.0 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -2, posY, (-6.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 10 then color = color - 10 end
	buttonParam.click_function = MAIN_PLAYABLE_COLORS[color]
	buttonParam.label = MAIN_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 2, posY, (-6.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(MAIN_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	initCommon(selfIn)
end

function init12Player(selfIn, offset)
	local buttonParam = {rotation = {0, 0, rotZ}, width = 1800 * buttonScale, height = 700 * buttonScale, font_size = 300 * fontScale}

	if sharedHistory then
		buttonParam.function_owner = Global
	else
		buttonParam.function_owner = self
	end

	-- Players
	local color = offset + 1
	if color > 12 then color = color - 12 end
	buttonParam.click_function = ALL_PLAYABLE_COLORS[color]
	buttonParam.label = ALL_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 4, posY, (-1.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(ALL_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 12 then color = color - 12 end
	buttonParam.click_function = ALL_PLAYABLE_COLORS[color]
	buttonParam.label = ALL_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 0, posY, (-1.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(ALL_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 12 then color = color - 12 end
	buttonParam.click_function = ALL_PLAYABLE_COLORS[color]
	buttonParam.label = ALL_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -4, posY, (-1.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(ALL_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 12 then color = color - 12 end
	buttonParam.click_function = ALL_PLAYABLE_COLORS[color]
	buttonParam.label = ALL_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -6, posY, (-3.25 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(ALL_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 12 then color = color - 12 end
	buttonParam.click_function = ALL_PLAYABLE_COLORS[color]
	buttonParam.label = ALL_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -6, posY, (-4.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(ALL_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 12 then color = color - 12 end
	buttonParam.click_function = ALL_PLAYABLE_COLORS[color]
	buttonParam.label = ALL_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -6, posY, (-6.25 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(ALL_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 12 then color = color - 12 end
	buttonParam.click_function = ALL_PLAYABLE_COLORS[color]
	buttonParam.label = ALL_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * -4, posY, (-7.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(ALL_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 12 then color = color - 12 end
	buttonParam.click_function = ALL_PLAYABLE_COLORS[color]
	buttonParam.label = ALL_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 0, posY, (-7.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(ALL_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 12 then color = color - 12 end
	buttonParam.click_function = ALL_PLAYABLE_COLORS[color]
	buttonParam.label = ALL_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 4, posY, (-7.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(ALL_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 12 then color = color - 12 end
	buttonParam.click_function = ALL_PLAYABLE_COLORS[color]
	buttonParam.label = ALL_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 6, posY, (-6.25 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(ALL_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 12 then color = color - 12 end
	buttonParam.click_function = ALL_PLAYABLE_COLORS[color]
	buttonParam.label = ALL_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 6, posY, (-4.75 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(ALL_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	color = color + 1
	if color > 12 then color = color - 12 end
	buttonParam.click_function = ALL_PLAYABLE_COLORS[color]
	buttonParam.label = ALL_PLAYABLE_COLORS[color]
	buttonParam.position = {posXscale * 6, posY, (-3.25 * posZscale) + posZoffsetColors}
	buttonParam.color = stringColorToRGBExtra(ALL_PLAYABLE_COLORS[color])
	selfIn.createButton(buttonParam)

	initCommon(selfIn)
end

function initCommon(selfIn)
	local buttonParam = {rotation = {0, 0, rotZ}, font_size = 300 * fontScale}
	local bulletInfo = Global.getTable('bulletInfo')
	local text = Global.getTable('text')

	if sharedHistory then
		buttonParam.function_owner = Global
	else
		buttonParam.function_owner = self
	end

	-- Info
	if selfIn.name == 'backgammon_board' then
		local screen = getObjectFromGUID(privateScreenGUID)
		if screen then
			screen.setName('Private Notes')
		end
	end

	-- Settings
	buttonParam.click_function = 'menuButton'
	buttonParam.label = menu_unicode
	buttonParam.width = 600 * buttonScale
	buttonParam.height = 500 * buttonScale
	buttonParam.position = {posXscale * 7.6, posY, (-7.5 * posZscale) + posZoffsetMenu}
	selfIn.createButton(buttonParam)

	-- Post/Retrieve
	if selfIn.name == 'backgammon_board' and cooperative then
		buttonParam.click_function = 'postButton'
		buttonParam.label = 'Post'
		buttonParam.width = 1500 * buttonScale
		buttonParam.position = {posXscale * -6.25, posY, (-11.6 * posZscale) + posZoffsetPostRetrieve}
		selfIn.createButton(buttonParam)

		buttonParam.click_function = 'retrieveButton'
		buttonParam.label = 'Retrieve'
		buttonParam.position = {posXscale * 5, posY, (-11.6 * posZscale) + posZoffsetPostRetrieve}
		selfIn.createButton(buttonParam)
	end

	-- Center
	buttonParam.click_function = 'autoButton'
	buttonParam.label = 'Auto Gov'
	buttonParam.height = 700 * buttonScale
	if Player[selfIn.getVar('playerNoteTaker')].admin or selfIn.name ~= 'backgammon_board' then
		buttonParam.width = 1800 * buttonScale
		buttonParam.position = {posXscale * -2, posY, (-5.25 * posZscale) + posZoffsetCenterButtons}
		selfIn.createButton(buttonParam)

		buttonParam.click_function = 'setPreviousPlacs'
		buttonParam.label = 'Move Prev'
		buttonParam.position = {posXscale * 2, posY, (-5.25 * posZscale) + posZoffsetCenterButtons}
		selfIn.createButton(buttonParam)
	else
		buttonParam.width = 3700 * buttonScale
		buttonParam.position = {posXscale * 0, posY, (-5.25 * posZscale) + posZoffsetCenterButtons}
		selfIn.createButton(buttonParam)
	end

	buttonParam.click_function = 'downvotedButton'
	buttonParam.label = 'Downvoted'
	buttonParam.width = 3700 * buttonScale
	buttonParam.position = {posXscale * 0, posY, (-3.75 * posZscale) + posZoffsetCenterButtons}
	selfIn.createButton(buttonParam)

	-- Left
	buttonParam.click_function = 'examinesButton'
	buttonParam.label = 'Ex Deck'
	buttonParam.width = 1500 * buttonScale
	buttonParam.height = 700 * buttonScale
	buttonParam.position = {posXscale * -6.5, posY, (-0.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'conflictButton'
	buttonParam.label = 'Conflict'
	buttonParam.position = {posXscale * -6.5, posY, (1.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'reshuffleButton'
	buttonParam.label = 'Reshuffle'
	buttonParam.position = {posXscale * -6.5, posY, (2.75 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'hZoneButton'
	buttonParam.label = string.sub(text.hitler, 1, 1) .. ' Zone'
	buttonParam.position = {posXscale * -6.5, posY, (4.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'topdeckButton'
	buttonParam.label = 'Topdeck'
	buttonParam.position = {posXscale * -6.5, posY, (5.75 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'revisedButton'
	buttonParam.label = 'Revised'
	buttonParam.position = {posXscale * -6.5, posY, (7.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	-- Right
	buttonParam.click_function = 'deleteLineButton'
	buttonParam.label = 'Delete Line'
	buttonParam.position = {posXscale * 6.5, posY, (-0.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'insertLineButton'
	buttonParam.label = 'Insert Line'
	buttonParam.position = {posXscale * 6.5, posY, (1.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'topButton'
	buttonParam.label = 'Top'
	buttonParam.position = {posXscale * 6.5, posY, (2.75 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'bottomButton'
	buttonParam.label = 'Bottom'
	buttonParam.position = {posXscale * 6.5, posY, (4.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'upButton'
	buttonParam.label = up_unicode
	buttonParam.width = 700 * buttonScale
	buttonParam.position = {posXscale * 5.75, posY, (5.75 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'rightButton'
	buttonParam.label = right_unicode
	buttonParam.position = {posXscale * 7.25, posY, (6.5 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'downButton'
	buttonParam.label = down_unicode
	buttonParam.position = {posXscale * 5.75, posY, (7.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'leftButton'
	buttonParam.label = left_unicode
	buttonParam.position = {posXscale * 4.25, posY, (6.5 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	-- Policy x3
	buttonParam.click_function = 'QQQ'
	buttonParam.label = '???'
	buttonParam.position = {posXscale * 3.8, posY, (2.75 * posZscale) + posZoffsetOther}
	buttonParam.width = 900 * buttonScale
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'FFF'
	buttonParam.label = text.fascistLetter .. text.fascistLetter .. text.fascistLetter
	if swapLF then
		buttonParam.position = {posXscale * -3.8, posY, (2.75 * posZscale) + posZoffsetOther}
	else
		buttonParam.position = {posXscale * 1.9, posY, (2.75 * posZscale) + posZoffsetOther}
	end
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'FFL'
	buttonParam.label = text.fascistLetter .. text.fascistLetter .. text.liberalLetter
	if swapLF then
		buttonParam.position = {posXscale * -1.9, posY, (2.75 * posZscale) + posZoffsetOther}
	else
		buttonParam.position = {posXscale * 0.0, posY, (2.75 * posZscale) + posZoffsetOther}
	end
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'FLL'
	buttonParam.label = text.fascistLetter .. text.liberalLetter .. text.liberalLetter
	if swapLF then
		buttonParam.position = {posXscale * 0.0, posY, (2.75 * posZscale) + posZoffsetOther}
	else
		buttonParam.position = {posXscale * -1.9, posY, (2.75 * posZscale) + posZoffsetOther}
	end
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'LLL'
	buttonParam.label = text.liberalLetter .. text.liberalLetter .. text.liberalLetter
	if swapLF then
		buttonParam.position = {posXscale * 1.9, posY, (2.75 * posZscale) + posZoffsetOther}
	else
		buttonParam.position = {posXscale * -3.8, posY, (2.75 * posZscale) + posZoffsetOther}
	end
	selfIn.createButton(buttonParam)

	-- Policy x2
	buttonParam.click_function = 'QQ'
	buttonParam.label = '??'
	buttonParam.position = {posXscale * 2.85, posY, (4.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'FF'
	buttonParam.label = text.fascistLetter .. text.fascistLetter
	if swapLF then
		buttonParam.position = {posXscale * -2.85, posY, (4.25 * posZscale) + posZoffsetOther}
	else
		buttonParam.position = {posXscale * 0.95, posY, (4.25 * posZscale) + posZoffsetOther}
	end
	selfIn.createButton(buttonParam)

	-- same if swapLF
	buttonParam.click_function = 'FL'
	buttonParam.label = text.fascistLetter .. text.liberalLetter
	buttonParam.position = {posXscale * -0.95, posY, (4.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'LL'
	buttonParam.label = text.liberalLetter .. text.liberalLetter
	if swapLF then
		buttonParam.position = {posXscale * 0.95, posY, (4.25 * posZscale) + posZoffsetOther}
	else
		buttonParam.position = {posXscale * -2.85, posY, (4.25 * posZscale) + posZoffsetOther}
	end
	selfIn.createButton(buttonParam)

	-- Policy final
	buttonParam.click_function = 'vetoButton'
	buttonParam.label = 'Veto'
	buttonParam.position = {posXscale * 1.9, posY, (5.75 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'F'
	buttonParam.label = text.fascistLetter
	if swapLF then
		buttonParam.position = {posXscale * -1.9, posY, (5.75 * posZscale) + posZoffsetOther}
	else
		buttonParam.position =  {posXscale * 0.0, posY, (5.75 * posZscale) + posZoffsetOther}
	end
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'L'
	buttonParam.label = text.liberalLetter
	if swapLF then
		buttonParam.position = {posXscale * 0.0, posY, (5.75 * posZscale) + posZoffsetOther}
	else
		buttonParam.position = {posXscale * -1.9, posY, (5.75 * posZscale) + posZoffsetOther}
	end
	selfIn.createButton(buttonParam)

	-- Power buttons
	buttonParam.click_function = 'investigate'
	buttonParam.label = 'Investigates'
	buttonParam.position = {posXscale * -2.9, posY, (-0.25 * posZscale) + posZoffsetOther}
	buttonParam.width = 1800 * buttonScale
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'givesTo'
	buttonParam.label = 'Gives to'
	buttonParam.position = {posXscale * 0.5, posY, (-0.25 * posZscale) + posZoffsetOther}
	buttonParam.width = 1400 * buttonScale
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'shoots'
	buttonParam.label = bulletInfo.action
	buttonParam.position = {posXscale * 3.4, posY, (-0.25 * posZscale) + posZoffsetOther}
	buttonParam.width = 1300 * buttonScale
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'liberal'
	buttonParam.label = text.liberalAbbr
	buttonParam.width = 1500 * buttonScale
	if swapLF then
		buttonParam.position = {posXscale * 0.0, posY, (1.25 * posZscale) + posZoffsetOther}
	else
		buttonParam.position = {posXscale * -3.2, posY, (1.25 * posZscale) + posZoffsetOther}
	end
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'fascist'
	buttonParam.label = text.fascistAbbr
	if swapLF then
		buttonParam.position = {posXscale * -3.2, posY, (1.25 * posZscale) + posZoffsetOther}
	else
		buttonParam.position = {posXscale * 0.0, posY, (1.25 * posZscale) + posZoffsetOther}
	end
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'noComment'
	buttonParam.label = 'Nothing'
	buttonParam.position = {posXscale * 3.20, posY, (1.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	-- Bottom
	buttonParam.click_function = 'exDiscardButton'
	buttonParam.label = 'Ex Discard'
	buttonParam.width = 1300 * buttonScale
	buttonParam.position = {posXscale * -3.4, posY, (7.25 * posZscale) + posZoffsetOther}
	buttonParam.font_size = 250
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'discardsButton'
	buttonParam.label = 'Discards'
	buttonParam.position = {posXscale * -0.65, posY, (7.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

	buttonParam.click_function = 'addsButton'
	buttonParam.label = 'Adds to\nDeck'
	buttonParam.position = {posXscale * 2.1, posY, (7.25 * posZscale) + posZoffsetOther}
	selfIn.createButton(buttonParam)

end

function spawnScreen(selfIn)
	local params = {
		type = 'Notecard',
		scale = {3.79999614, 3.79999614, 3.79999614},
		position = {-100, 100, -100},
		callback = 'spawnScreenCallback',
		callback_owner = selfIn,
		sound = false
	}
	spawnObject(params)
end

function spawnScreenCallback(objIn, paramsIn)
	privateScreenGUID = objIn.getGUID()
	refreshNotes(self)
	if playerNoteTaker and not (playerNoteTaker == '') then
		if forceMenu then
			forceMenu = false
			menu(self)
		else
			setupBoard(self)
		end
	else
		menu(self)
	end
end

function spawnFogCoroutine()
	local screen = getObjectFromGUID(privateScreenGUID)
	if screen then
		if privateFogGUID ~= HIDDEN_ZONE_GUIDS[playerNoteTaker] then
			destroyObjectByGUID(privateFogGUID)
		end
		local secretZone = getObjectFromGUID(HIDDEN_ZONE_GUIDS[playerNoteTaker])
		local params = {position = {-100, 100, -100}, sound = false}
		local fog
		if secretZone then
			fog = secretZone.clone(params) -- only way I know to set the color
		else
			params.type = 'FogOfWarTrigger'
			fog = spawnObject(params)
		end
		wait(5)
		fog.setPosition(screen.getPosition())
		fog.setRotation(screen.getRotation())
		fog.setScale({26.2, 3.5, 15.8})
		privateFogGUID = fog.getGUID()
	end

	return true
end

function postButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor then
		if nextPost == nil or nextPost < os.clock() then
			nextPost = os.clock() + 30
			Global.setTable('noteTakerNotes', noteTakerNotes)
			Global.setVar('noteTakerCurrLine', noteTakerCurrLine)
			local options = Global.getTable('options')
			if options.scriptedVoting then
				local notesString = noteTakerNotesString(19, false, true)
				Global.setVar('mainNotes', notesString)
				setNotes(Global.getVar('voteNotes') .. '\n\n' .. notesString)
			else
				local notesString = noteTakerNotesString(25, false, true)
				setNotes(notesString)
			end
		else
			broadcastToColor('You can only post once every 30 seconds.', playerNoteTaker, {1, 0, 0})
		end
	end
end

function retrieveButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor then
		noteTakerNotes = Global.getTable('noteTakerNotes')
		noteTakerCurrLine = Global.getVar('noteTakerCurrLine')
		if not noteTakerCurrLine or noteTakerCurrLine == 0 then
			noteTakerNotes = {}
			noteTakerCurrLine = 0
			addNewLine()
		end
		refreshNotes(clickedObject)
	end
end

function addNewLine()
	noteTakerCurrLine = noteTakerCurrLine + 1
	if noteTakerCurrLine > #noteTakerNotes then
		table.insert(noteTakerNotes, defaultLine())
	end
	editMode = true
end

function refreshNotes(selfIn)
	local tempNotes = noteTakerNotesString(maxLines, true, useColor)

	if selfIn and selfIn.name == 'backgammon_board' then
		tempNotes = string.gsub(tempNotes, stringColorToHex('White') .. ']', textColorReplace)
		local screen = getObjectFromGUID(privateScreenGUID)
		if screen then -- save the long version by not using noteTakerSetNotes
			screen.setDescription(tempNotes)
		end
	else
		noteTakerSetNotes(tempNotes)
	end
end

function buttonColor(clickedObject, playerColor, colorClicked)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		local bulletInfo = Global.getTable('bulletInfo')
		if noteTakerNotes[noteTakerCurrLine].color1 == '' or not editMode then
			noteTakerNotes[noteTakerCurrLine].color1 = colorClicked
			noteTakerNotes[noteTakerCurrLine].action = '>'
			prevPresColor = colorClicked
		else
			noteTakerNotes[noteTakerCurrLine].color2 = colorClicked
			prevChanColor = colorClicked
		end
		if (noteTakerNotes[noteTakerCurrLine].action == string.lower(bulletInfo.action)
			 or noteTakerNotes[noteTakerCurrLine].action == string.lower(imprisonInfo.action)
			 or noteTakerNotes[noteTakerCurrLine].action == 'gives pres to')
			 and noteTakerNotes[noteTakerCurrLine].color1 ~= '' and noteTakerNotes[noteTakerCurrLine].color2 ~= '' then
			addNewLine()
		end
		refreshNotes(clickedObject)
	end
end

function White(clickedObject, playerColor)
	buttonColor(clickedObject, playerColor, 'White')
end

function Brown(clickedObject, playerColor)
	buttonColor(clickedObject, playerColor, 'Brown')
end

function Red(clickedObject, playerColor)
	buttonColor(clickedObject, playerColor, 'Red')
end

function Orange(clickedObject, playerColor)
	buttonColor(clickedObject, playerColor, 'Orange')
end

function Yellow(clickedObject, playerColor)
	buttonColor(clickedObject, playerColor, 'Yellow')
end

function Green(clickedObject, playerColor)
	buttonColor(clickedObject, playerColor, 'Green')
end

function Teal(clickedObject, playerColor)
	buttonColor(clickedObject, playerColor, 'Teal')
end

function Blue(clickedObject, playerColor)
	buttonColor(clickedObject, playerColor, 'Blue')
end

function Purple(clickedObject, playerColor)
	buttonColor(clickedObject, playerColor, 'Purple')
end

function Pink(clickedObject, playerColor)
	buttonColor(clickedObject, playerColor, 'Pink')
end

function Tan(clickedObject, playerColor)
	buttonColor(clickedObject, playerColor, 'Tan')
end

function Maroon(clickedObject, playerColor)
	buttonColor(clickedObject, playerColor, 'Maroon')
end

-- Top
function autoButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		local tempObj = getObjectFromGUID(PRESIDENT_GUID)
		local pres = closestPlayer(tempObj, MAIN_PLAYABLE_COLORS, 1000)
		tempObj = getObjectFromGUID(CHANCELOR_GUID)
		local chan = closestPlayer(tempObj, MAIN_PLAYABLE_COLORS, 1000)

		if pres then
			noteTakerNotes[noteTakerCurrLine].color1 = pres
			noteTakerNotes[noteTakerCurrLine].action = '>'
			prevPresColor = pres
		end
		if chan then
			noteTakerNotes[noteTakerCurrLine].color2 = chan
			noteTakerNotes[noteTakerCurrLine].action = '>'
			prevChanColor = chan
		end
		refreshNotes(clickedObject)
	end
end

function setPreviousPlacs(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if prevPresColor and prevChanColor then
			local tmpPres = getObjectFromGUID(PREV_PRESIDENT_GUID)
			if tmpPres then giveObjectToPlayer(tmpPres, prevPresColor, {forward = 11, right = 0, up = 0, forceHeight = 1.1}, NO_ROT, false, true) end
			local tmpChan = getObjectFromGUID(PREV_CHANCELOR_GUID)
			if tmpChan then giveObjectToPlayer(tmpChan, prevChanColor, {forward = 11, right = 0, up = 0, forceHeight = 1.1}, NO_ROT, false, true) end
		end
	end
end

function downvotedButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		noteTakerNotes[noteTakerCurrLine].result = '[222222]Downvoted[-]'
		noteTakerNotes[noteTakerCurrLine].action = '>'
		noteTakerNotes[noteTakerCurrLine].claim3 = ''
		noteTakerNotes[noteTakerCurrLine].claim2 = ''
		noteTakerNotes[noteTakerCurrLine].claim1 = ''
		addNewLine()
		refreshNotes(clickedObject)
		incTracker()
	end
end

-- Left
function examinesButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerNotes[noteTakerCurrLine].action == 'examines deck:' then
			noteTakerNotes[noteTakerCurrLine].action = '>'
		else
			noteTakerNotes[noteTakerCurrLine].action = 'examines deck:'
			noteTakerNotes[noteTakerCurrLine].color2 = ''
		end
		if noteTakerNotes[noteTakerCurrLine].result ~= '' then
			addNewLine()
		end
		refreshNotes(clickedObject)
	end
end

function conflictButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerConflict(noteTakerCurrLine) then
			noteTakerNotes[noteTakerCurrLine].conflict = ''
			noteTakerNotes[noteTakerCurrLine].claim2 = ''
		else
			noteTakerNotes[noteTakerCurrLine].conflict = '(Conflict)'
		end
		refreshNotes(clickedObject)
	end
end

function reshuffleButton(clickedObject, playerColor)
	resultOnly(clickedObject, playerColor, '*Reshuffle*')
end

function hZoneButton(clickedObject, playerColor)
	local text = Global.getTable('text')
	resultOnly(clickedObject, playerColor, '[FF0000]' .. text.hitler .. ' territory![-]')
end

function resultOnly(clickedObject, playerColor, text)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerNotes[noteTakerCurrLine].result == text then
			noteTakerNotes[noteTakerCurrLine].result = ''
		else
			noteTakerNotes[noteTakerCurrLine].conflict = ''
			noteTakerNotes[noteTakerCurrLine].color1 = ''
			noteTakerNotes[noteTakerCurrLine].action = ''
			noteTakerNotes[noteTakerCurrLine].color2 = ''
			noteTakerNotes[noteTakerCurrLine].claim3 = ''
			noteTakerNotes[noteTakerCurrLine].claim2 = ''
			noteTakerNotes[noteTakerCurrLine].claim1 = ''
			noteTakerNotes[noteTakerCurrLine].result = text
			addNewLine()
		end
		refreshNotes(clickedObject)
	end
end

function topdeckButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerNotes[noteTakerCurrLine].action == 'Topdeck:' then
			noteTakerNotes[noteTakerCurrLine].action = ''
		else
			noteTakerNotes[noteTakerCurrLine].conflict = ''
			noteTakerNotes[noteTakerCurrLine].color1 = ''
			noteTakerNotes[noteTakerCurrLine].action = 'Topdeck:'
			noteTakerNotes[noteTakerCurrLine].color2 = ''
			noteTakerNotes[noteTakerCurrLine].claim3 = ''
			noteTakerNotes[noteTakerCurrLine].claim2 = ''
			noteTakerNotes[noteTakerCurrLine].claim1 = ''
			if noteTakerNotes[noteTakerCurrLine].result ~= '' then
				addNewLine()
			end
		end
		refreshNotes(clickedObject)
	end
end

function revisedButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerConflict(noteTakerCurrLine) then
			if noteTakerNotes[noteTakerCurrLine].conflict == '(Rev Con)' then
				noteTakerNotes[noteTakerCurrLine].conflict = '(Conflict)'
			else
				noteTakerNotes[noteTakerCurrLine].conflict = '(Rev Con)'
			end
		elseif noteTakerNotes[noteTakerCurrLine].conflict == '(Rev)' then
			noteTakerNotes[noteTakerCurrLine].conflict = ''
		else
			noteTakerNotes[noteTakerCurrLine].conflict = '(Rev)'
		end
		refreshNotes(clickedObject)
	end
end

-- Right
function deleteLineButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerCurrLine == #noteTakerNotes then
			table.remove(noteTakerNotes, noteTakerCurrLine)
			noteTakerCurrLine = noteTakerCurrLine - 1
			addNewLine()
		else
			table.remove(noteTakerNotes, noteTakerCurrLine)
		end
		refreshNotes(clickedObject)
	end
end

function insertLineButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		table.insert(noteTakerNotes, noteTakerCurrLine, defaultLine())
		refreshNotes(clickedObject)
	end
end

function topButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		noteTakerCurrLine = 1
		refreshNotes(clickedObject)
		editMode = true
	end
end

function bottomButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		noteTakerCurrLine = #noteTakerNotes
		refreshNotes(clickedObject)
		editMode = true
	end
end

function upButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerCurrLine - 1 > 0 then
			noteTakerCurrLine = noteTakerCurrLine - 1
		end
		editMode = true
		refreshNotes(clickedObject)
		if noteTakerNotes[noteTakerCurrLine].color1 ~= '' then
			prevPresColor = noteTakerNotes[noteTakerCurrLine].color1
		end
		if noteTakerNotes[noteTakerCurrLine].color2 ~= '' then
			prevChanColor = noteTakerNotes[noteTakerCurrLine].color2
		end
	end
end

function downButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		addNewLine()
		editMode = true
		refreshNotes(clickedObject)
		if noteTakerNotes[noteTakerCurrLine].color1 ~= '' then
			prevPresColor = noteTakerNotes[noteTakerCurrLine].color1
		end
		if noteTakerNotes[noteTakerCurrLine].color2 ~= '' then
			prevChanColor = noteTakerNotes[noteTakerCurrLine].color2
		end
	end
end

function rightButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		editMode = true
		refreshNotes(clickedObject)
	end
end

function leftButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		editMode = false
		refreshNotes(clickedObject)
	end
end

-- Center
function investigate(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerNotes[noteTakerCurrLine].action == 'inspects' then
			noteTakerNotes[noteTakerCurrLine].action = '>'
		else
			noteTakerNotes[noteTakerCurrLine].action = 'inspects'
		end
		if noteTakerNotes[noteTakerCurrLine].color1 ~= ''
			and noteTakerNotes[noteTakerCurrLine].color2 ~= ''
			and noteTakerNotes[noteTakerCurrLine].result ~= '' then
			addNewLine()
		end
		refreshNotes(clickedObject)
	end
end

function givesTo(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerNotes[noteTakerCurrLine].action == 'gives pres to' then
			noteTakerNotes[noteTakerCurrLine].action = '>'
		else
			noteTakerNotes[noteTakerCurrLine].action = 'gives pres to'
		end
		if noteTakerNotes[noteTakerCurrLine].color1 ~= ''
			and noteTakerNotes[noteTakerCurrLine].color2 ~= '' then
			addNewLine()
		end
		refreshNotes(clickedObject)
	end
end

function shoots(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		local bulletInfo = Global.getTable('bulletInfo')
		if noteTakerNotes[noteTakerCurrLine].action == string.lower(bulletInfo.action) then
			noteTakerNotes[noteTakerCurrLine].action = '>'
		else
			noteTakerNotes[noteTakerCurrLine].action = string.lower(bulletInfo.action)
		end
		if noteTakerNotes[noteTakerCurrLine].color1 ~= ''
			and noteTakerNotes[noteTakerCurrLine].color2 ~= '' then
			addNewLine()
		end
		refreshNotes(clickedObject)
	end
end

function liberal(clickedObject, playerColor)
	local text = Global.getTable('text')
	resultText(clickedObject, playerColor, 'claims [0080F8]' .. text.liberalAbbr .. '[-]')
end

function fascist(clickedObject, playerColor)
	local text = Global.getTable('text')
	resultText(clickedObject, playerColor, 'claims [FF0000]' .. text.fascistAbbr .. '[-]')
end

function noComment(clickedObject, playerColor)
	resultText(clickedObject, playerColor, 'says [i]Nothing[/i]')
end

function resultText(clickedObject, playerColor, text)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerNotes[noteTakerCurrLine].result == text then
			noteTakerNotes[noteTakerCurrLine].result = ''
		else
			noteTakerNotes[noteTakerCurrLine].result = text
			addNewLine()
		end
		refreshNotes(clickedObject)
	end
end

function LLL(clickedObject, playerColor)
	local text = Global.getTable('text')
	XXX(clickedObject, playerColor, '[0080F8]' .. text.liberalLetter .. text.liberalLetter .. text.liberalLetter .. '[-]')
end

function FLL(clickedObject, playerColor)
	local text = Global.getTable('text')
	XXX(clickedObject, playerColor, '[FF0000]' .. text.fascistLetter .. '[-][0080F8]' .. text.liberalLetter .. text.liberalLetter .. '[-]')
end

function FFL(clickedObject, playerColor)
	local text = Global.getTable('text')
	XXX(clickedObject, playerColor, '[FF0000]' .. text.fascistLetter .. text.fascistLetter .. '[-][0080F8]' .. text.liberalLetter .. '[-]')
end

function FFF(clickedObject, playerColor)
	local text = Global.getTable('text')
	XXX(clickedObject, playerColor, '[FF0000]' .. text.fascistLetter .. text.fascistLetter .. text.fascistLetter .. '[-]')
end

function QQQ(clickedObject, playerColor)
	XXX(clickedObject, playerColor, '???')
end

function XXX(clickedObject, playerColor, text)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerNotes[noteTakerCurrLine].action == 'examines deck:' then
			if noteTakerNotes[noteTakerCurrLine].result == text then
				noteTakerNotes[noteTakerCurrLine].result = ''
			else
				noteTakerNotes[noteTakerCurrLine].result = text
				addNewLine()
			end
		else
			if noteTakerNotes[noteTakerCurrLine].claim3 == text then
				noteTakerNotes[noteTakerCurrLine].claim3 = ''
			else
				noteTakerNotes[noteTakerCurrLine].claim3 = text
				if noteTakerNotes[noteTakerCurrLine].claim1 ~= ''
						and noteTakerNotes[noteTakerCurrLine].result ~= ''
						and noteTakerCurrLine == #noteTakerNotes then
					addNewLine()
				end
			end
		end
		refreshNotes(clickedObject)
	end
end

function LL(clickedObject, playerColor)
	local text = Global.getTable('text')
	XX(clickedObject, playerColor, '[0080F8]' .. text.liberalLetter .. text.liberalLetter .. '[-]')
end

function FL(clickedObject, playerColor)
	local text = Global.getTable('text')
	XX(clickedObject, playerColor, '[FF0000]' .. text.fascistLetter .. '[-][0080F8]' .. text.liberalLetter .. '[-]')
end

function FF(clickedObject, playerColor)
	local text = Global.getTable('text')
	XX(clickedObject, playerColor, '[FF0000]' .. text.fascistLetter .. text.fascistLetter .. '[-]')
end

function QQ(clickedObject, playerColor)
	XX(clickedObject, playerColor, '??')
end

function XX(clickedObject, playerColor, text)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if not editMode or (noteTakerNotes[noteTakerCurrLine].claim2 == ''
			and noteTakerConflict(noteTakerCurrLine)) then
			if noteTakerNotes[noteTakerCurrLine].claim2 == text then
				noteTakerNotes[noteTakerCurrLine].claim2 = ''
			else
				noteTakerNotes[noteTakerCurrLine].claim2 = text
			end
		else
			if noteTakerNotes[noteTakerCurrLine].claim1 == text then
				noteTakerNotes[noteTakerCurrLine].claim1 = ''
			else
				noteTakerNotes[noteTakerCurrLine].claim1 = text
			end
		end
		refreshNotes(clickedObject)
	end
end

function L(clickedObject, playerColor)
	local text = Global.getTable('text')
	X(clickedObject, playerColor, '[0080F8]' .. text.liberalLetter .. '[-]')
end

function F(clickedObject, playerColor)
	local text = Global.getTable('text')
	X(clickedObject, playerColor, '[FF0000]' .. text.fascistLetter .. '[-]')
end

function X(clickedObject, playerColor, text)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerNotes[noteTakerCurrLine].result == text then
			noteTakerNotes[noteTakerCurrLine].result = ''
		else
			noteTakerNotes[noteTakerCurrLine].result = text
			if noteTakerCurrLine == #noteTakerNotes and
				((noteTakerNotes[noteTakerCurrLine].claim1 ~= ''
				  and noteTakerNotes[noteTakerCurrLine].claim3 ~= '')
				 or noteTakerNotes[noteTakerCurrLine].action == 'Topdeck:'
				 or noteTakerNotes[noteTakerCurrLine].action == 'examines deck:') then
				addNewLine()
			end
			resetTracker()
		end
		refreshNotes(clickedObject)
	end
end

function vetoButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		noteTakerNotes[noteTakerCurrLine].result = 'Veto!'
		addNewLine()
		refreshNotes(clickedObject)
		incTracker()
	end
end

--Bottom
function exDiscardButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerNotes[noteTakerCurrLine].action == 'examines discard:' then
			noteTakerNotes[noteTakerCurrLine].action = '>'
		else
			noteTakerNotes[noteTakerCurrLine].action = 'examines discard:'
			noteTakerNotes[noteTakerCurrLine].color2 = ''
		end
		if noteTakerNotes[noteTakerCurrLine].result ~= '' then
			addNewLine()
		end
		refreshNotes(clickedObject)
	end
end

function discardsButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerNotes[noteTakerCurrLine].action == 'discards:' then
			noteTakerNotes[noteTakerCurrLine].action = '>'
		else
			noteTakerNotes[noteTakerCurrLine].action = 'discards:'
			noteTakerNotes[noteTakerCurrLine].color2 = ''
		end
		if noteTakerNotes[noteTakerCurrLine].result ~= '' then
			addNewLine()
		end
		refreshNotes(clickedObject)
	end
end

function addsButton(clickedObject, playerColor)
	if clickedObject.getVar('playerNoteTaker') == playerColor or Player[playerColor].admin then
		if noteTakerNotes[noteTakerCurrLine].action == 'adds to deck:' then
			noteTakerNotes[noteTakerCurrLine].action = '>'
		else
			noteTakerNotes[noteTakerCurrLine].action = 'adds to deck:'
			noteTakerNotes[noteTakerCurrLine].color2 = ''
		end
		if noteTakerNotes[noteTakerCurrLine].result ~= '' then
			addNewLine()
		end
		refreshNotes(clickedObject)
	end
end

function incTracker()
	local tracker = getObjectFromGUID(ELECTION_TRACKER_GUID)
	if moveTracker and tracker then
		tracker.translate({electionTrackerMoveX, 0, 0})
	end
end

function resetTracker()
	local tracker = getObjectFromGUID(ELECTION_TRACKER_GUID)
	if moveTracker and tracker then
		tracker.setPositionSmooth(electionTrackerOrgPos)
		tracker.setRotationSmooth({0, 315, 0})
	end
end

function defaultLine()
	return {conflict = '', color1 = '', action = '', color2 = '', claim3 = '', claim2 = '', claim1 = '', result = ''}
end

function noteTakerNotesString(maxLinesIn, showArrow, useColorIn)
	local stringOut = ''
	local startLine = 1
	local lastLine = #noteTakerNotes

	if maxLinesIn < #noteTakerNotes then
		startLine = #noteTakerNotes - maxLinesIn + 1
	end
	if startLine > noteTakerCurrLine then
		startLine = noteTakerCurrLine
		lastLine = startLine + maxLinesIn - 1
		if lastLine > #noteTakerNotes then
			lastLine = #noteTakerNotes
		end
	end

	for i = startLine, lastLine, 1 do
		if noteTakerCurrLine == i and showArrow then
			if editMode then
				stringOut = stringOut .. right_unicode .. ' '
			else
				stringOut = stringOut .. left_unicode .. ' '
			end
		end
		stringOut = stringOut .. noteTakerNotesLine(i, useColorIn)
	end

	if not useColorIn then
		stringOut = string.gsub(stringOut, '0080F8]', textColorReplace) -- Liberal color
		stringOut = string.gsub(stringOut, 'FF0000]', textColorReplace) -- Fascist color
		stringOut = string.gsub(stringOut, '222222]', textColorReplace) -- Downvote color
	end

	return stringOut
end

function noteTakerNotesLine(lineIn, useColorIn)
	local bulletInfo = Global.getTable('bulletInfo')
	local stringOut = ''

	if noteTakerNotes[lineIn].conflict ~= '' then
		stringOut = stringOut .. noteTakerNotes[lineIn].conflict .. ' '
	end
	if noteTakerNotes[lineIn].color1 ~= '' then
		local text = noteTakerNotes[lineIn].color1
		if useNames then
			local playerObj = nil
			if greyPlayer(noteTakerNotes[lineIn].color1) then
				playerObj = getPlayerObj(noteTakerNotes[lineIn].color1)
			else
				playerObj = Player[noteTakerNotes[lineIn].color1]
			end
			if playerObj then text = string.sub(playerObj.steam_name, 1, 7) end
		end
		if useColorIn then
			text = '[' .. stringColorToHex(noteTakerNotes[lineIn].color1) .. ']' .. text .. '[-]'
		end
		stringOut = stringOut .. '[i]' .. text .. '[/i]' .. ' '
	end
	if noteTakerNotes[lineIn].action ~= '' then
		stringOut = stringOut .. noteTakerNotes[lineIn].action .. ' '
	end
	if noteTakerNotes[lineIn].color2 ~= '' then
		local text = noteTakerNotes[lineIn].color2
		if useNames then
			local playerObj = nil
			if greyPlayer(noteTakerNotes[lineIn].color2) then
				playerObj = getPlayerObj(noteTakerNotes[lineIn].color2)
			else
				playerObj = Player[noteTakerNotes[lineIn].color2]
			end
			if playerObj then text = string.sub(playerObj.steam_name, 1, 7) end
		end
		if useColorIn then
			text = '[' .. stringColorToHex(noteTakerNotes[lineIn].color2) .. ']' .. text .. '[-]'
		end
		stringOut = stringOut .. '[i]' .. text .. '[/i]'
		if noteTakerNotes[lineIn].action ~= 'gives pres to'
			and noteTakerNotes[lineIn].action ~= string.lower(bulletInfo.action)
			and noteTakerNotes[lineIn].action ~= string.lower(imprisonInfo.action) then
			stringOut = stringOut .. ': '
		elseif noteTakerNotes[lineIn].claim3 ~= ''
				or noteTakerNotes[lineIn].claim2 ~= ''
				or noteTakerNotes[lineIn].claim1 ~= ''
				or noteTakerNotes[lineIn].result ~= '' then
			stringOut = stringOut .. ' '
		end
	end
	if noteTakerNotes[lineIn].claim3 ~= '' then
		stringOut = stringOut .. noteTakerNotes[lineIn].claim3 .. ' > '
	end
	if noteTakerNotes[lineIn].claim2 ~= '' then
		stringOut = stringOut .. noteTakerNotes[lineIn].claim2 .. ' > '
	end
	if noteTakerNotes[lineIn].claim1 ~= '' then
		stringOut = stringOut .. noteTakerNotes[lineIn].claim1 .. ' > '
	end
	if noteTakerNotes[lineIn].result ~= '' then
		stringOut = stringOut .. noteTakerNotes[lineIn].result
	end
	stringOut = stringOut .. '\n'

	return stringOut
end

function noteTakerConflict(currLineIn)
	if noteTakerNotes[currLineIn].conflict == '(Conflict)' then
		return true
	elseif noteTakerNotes[currLineIn].conflict == '(Rev Con)' then
		return true
	end

	return false
end

function notateInfo(color1In, actionIn, color2In, resultIn, updateLaterIn)
	local lineSave = noteTakerCurrLine
	noteTakerCurrLine = #noteTakerNotes
	if not noteTakerBlankLine(noteTakerCurrLine) then
		addNewLine()
		noteTakerCurrLine = #noteTakerNotes
	end
	noteTakerNotes[noteTakerCurrLine].color1 = color1In
	noteTakerNotes[noteTakerCurrLine].action = actionIn
	noteTakerNotes[noteTakerCurrLine].color2 = color2In
	noteTakerNotes[noteTakerCurrLine].result = resultIn
	if updateLaterIn then
		notate.line = noteTakerCurrLine
		notate.action = actionIn
	end
	noteTakerCurrLine = lineSave
	refreshNotes(nil)
end

function noteTakerBlankLine(currLineIn)
	if noteTakerNotes[noteTakerCurrLine].conflict == ''
		and noteTakerNotes[noteTakerCurrLine].color1 == ''
		and noteTakerNotes[noteTakerCurrLine].action == ''
		and noteTakerNotes[noteTakerCurrLine].color2 == ''
		and noteTakerNotes[noteTakerCurrLine].claim3 == ''
		and noteTakerNotes[noteTakerCurrLine].claim2 == ''
		and noteTakerNotes[noteTakerCurrLine].claim1 == ''
		and noteTakerNotes[noteTakerCurrLine].result == '' then
			return true
	end

	return false
end

function noteTakerSetNotes(stringIn)
	local options = Global.getTable('options')
	if options.scriptedVoting then
		Global.setVar('mainNotes', stringIn)
		setNotes(Global.getVar('voteNotes') .. '\n\n' .. stringIn)
	else
		setNotes(stringIn)
	end
end

function newNoteTakerLuaScript(playerNoteTakerIn, useColorIn, cooperativeIn, colorMatchIn, useNamesIn, swapLFIn, moveTrackerIn)
	local mainScript = Global.getLuaScript()
	local cutHerePos = string.find(mainScript, '--CUT HERE')

	return 'useColor = ' .. useColorIn .. '\r\n' ..
	'cooperative = ' .. cooperativeIn .. '\r\n' ..
	'colorMatch = ' .. colorMatchIn .. '\r\n' ..
	'useNames = ' .. useNamesIn .. '\r\n' ..
	'playerNoteTaker = \'' .. playerNoteTakerIn .. '\'\r\n' ..
	'privateFogGUID = nil\r\n' ..
	'privateScreenGUID = nil\r\n' ..
	'swapLF = ' .. swapLFIn .. '\r\n' ..
	'moveTracker = ' .. moveTrackerIn .. '\r\n' ..
	'prevPresColor = nil\r\n' ..
	'prevChanColor = nil\r\n' ..
	'nextPost = nil\r\n' ..
	'forceMenu = nil\r\n' ..
	'lastGUID = nil\r\n' ..
	'\r\n' ..
	'function onLoad(saveString)\r\n' ..
	'	noteTakerOnLoad(saveString)\r\n' ..
	'end\r\n' ..
	'\r\n' ..
	'function onSave()\r\n' ..
	'	return notetakerOnSave()\r\n' ..
	'end\r\n' ..
	'\r\n' ..
	'function onDestroy()\r\n' ..
	'	notetakerOnDestroy()\r\n' ..
	'end\r\n' ..
	string.sub(mainScript, cutHerePos, string.len(mainScript))
end

function respawnNoteTakerLuaScript()
	local mainScript = self.getLuaScript()
	local cutHerePos = string.find(mainScript, '--CUT HERE')

	return 'useColor = ' .. tostring(useColor) .. '\r\n' ..
	'cooperative = ' .. tostring(cooperative) .. '\r\n' ..
	'colorMatch = ' .. tostring(colorMatch) .. '\r\n' ..
	'useNames = ' .. tostring(useNames) .. '\r\n' ..
	'playerNoteTaker = ' .. easyQuotes(playerNoteTaker) .. '\r\n' ..
	'privateFogGUID = ' .. easyQuotes(privateFogGUID) .. '\r\n' ..
	'privateScreenGUID = ' .. easyQuotes(privateScreenGUID) .. '\r\n' ..
	'swapLF = ' .. tostring(swapLF) .. '\r\n' ..
	'moveTracker = ' .. tostring(moveTracker) .. '\r\n' ..
	'prevPresColor = ' .. easyQuotes(prevPresColor) .. '\r\n' ..
	'prevChanColor = ' .. easyQuotes(prevChanColor) .. '\r\n' ..
	'nextPost = ' .. tostring(nextPost) .. '\r\n' ..
	'forceMenu = ' ..  tostring(forceMenu) .. '\r\n' ..
	'lastGUID = ' .. easyQuotes(self.getGUID()) .. '\r\n' ..
	'\r\n' ..
	'function onLoad(saveString)\r\n' ..
	'	noteTakerOnLoad(saveString)\r\n' ..
	'end\r\n' ..
	'\r\n' ..
	'function onSave()\r\n' ..
	'	return notetakerOnSave()\r\n' ..
	'end\r\n' ..
	'\r\n' ..
	'function onDestroy()\r\n' ..
	'	notetakerOnDestroy()\r\n' ..
	'end\r\n' ..
	string.sub(mainScript, cutHerePos, string.len(mainScript))
end

function easyQuotes(stringIn)
	if stringIn then
		return string.char(39) .. stringIn .. string.char(39)
	else
		return 'nil'
	end
end

----#include \SecretHitlerCE\notetaker.ttslua
----#include \SecretHitlerCE\common.ttslua
--Static
ALL_PLAYABLE_COLORS = {"White", "Brown", "Red", "Orange", "Yellow", "Green", "Teal", "Blue", "Purple", "Pink", "Tan", "Maroon"}
MAIN_PLAYABLE_COLORS = {"White", "Brown", "Red", "Orange", "Yellow", "Green", "Teal", "Blue", "Purple", "Pink"}

GREY_PLAYABLE_COLORS = {"Tan", "Maroon"}
GREY_PLAYABLE_COLORS_RGB = {Tan = {r = 210/255, g = 180/255, b = 140/255}, Maroon = {r = 128/255, g = 0/255, b = 0/255}}
GREY_AVATAR_POS = {Tan = {29.30, 9.4, -54}, Maroon = {0, 9.4, -54}}
GREY_HAND_ZONE_GUIDS = {Maroon = "b9a8d0", Tan = "409da9"}
GREY_TEXT_GUIDS = {Tan = "37d7b5", Maroon = "13f08c"}
GREY_VOTE_POS = {Tan = {29.30, 1.05, -35.50}, Maroon = {0, 1.05, -35.50}}
-- FIXME don't hardcode GREY_ABILITY_POS
GREY_ABILITY_POS = {Tan = {37, 1.2, -41}, Maroon = {12.60, 1.2, -41}}
GREY_FORWARD = 0
GREY_RIGHT = 0
GREY_UP = 0.3

NO_ROT = {x = 0, y = 0, z = 0}
FACE_UP_ROT = {x = 0, y = 180, z = 0}
FACE_DOWN_ROT = {x = 0, y = 180, z = 180}

function getPlayerPosRotVectors(playerColor)
	local returnVal = {}

	if greyPlayer(playerColor) then
		local ph = getObjectFromGUID(greyPlayerHandGuids[playerColor])
		if ph then
			local pos = ph.getPosition()
			returnVal.pos = {x = pos["x"], y = pos["y"], z = pos["z"] - 2.26}
			returnVal.rot = ph.getRotation()
			returnVal.vForward = ph.getTransformForward()
			returnVal.vRight = ph.getTransformRight()
			returnVal.vUp = ph.getTransformUp()
		end
	else
		local ph = Player[playerColor].getPlayerHand();
		if ph then
			returnVal.pos = {x = ph["pos_x"], y = ph["pos_y"], z = ph["pos_z"]}
			returnVal.rot = {x = ph["rot_x"], y = ph["rot_y"], z = ph["rot_z"]}
			returnVal.vForward = {x = ph["trigger_forward_x"], y = ph["trigger_forward_y"], z = ph["trigger_forward_z"]}
			returnVal.vRight = {x = ph["trigger_right_x"], y = ph["trigger_right_y"], z = ph["trigger_right_z"]}
			returnVal.vUp = {x = ph["trigger_up_x"], y = ph["trigger_up_y"], z = ph["trigger_up_z"]}
		end
	end

	return returnVal
end

--function giveObjectToPlayer(object, playerColor, posAdd, rotAdd, collide, fast)
function giveObjectToPlayer(object, playerColor, posAdd, rotAdd, ...)
	local info = getPlayerPosRotVectors(playerColor)
	if info then
		if rotAdd["exactRot"] then
			object.setRotationSmooth({rotAdd["x"], rotAdd["y"], rotAdd["z"]}, ...)
		else
			object.setRotationSmooth({info.rot["x"] + rotAdd["x"], info.rot["y"] + rotAdd["y"], info.rot["z"] + rotAdd["z"]}, ...)
		end
		if posAdd["forceHeight"] then
			object.setPositionSmooth({info.pos["x"] + info.vForward["x"] * posAdd["forward"] + info.vRight["x"] * posAdd["right"] + info.vUp["x"] * posAdd["up"],
											  posAdd["forceHeight"],
											  info.pos["z"] + info.vForward["z"] * posAdd["forward"] + info.vRight["z"] * posAdd["right"] + info.vUp["z"] * posAdd["up"]}, ...)
		else
			object.setPositionSmooth({info.pos["x"] + info.vForward["x"] * posAdd["forward"] + info.vRight["x"] * posAdd["right"] + info.vUp["x"] * posAdd["up"],
											  info.pos["y"] + info.vForward["y"] * posAdd["forward"] + info.vRight["y"] * posAdd["right"] + info.vUp["y"] * posAdd["up"],
											  info.pos["z"] + info.vForward["z"] * posAdd["forward"] + info.vRight["z"] * posAdd["right"] + info.vUp["z"] * posAdd["up"]}, ...)
		end
	end
end

function forceObjectToPlayer(object, playerColor, posAdd, rotAdd)
	local info = getPlayerPosRotVectors(playerColor)
	if info then
		if rotAdd["exactRot"] then
			object.setRotation({rotAdd["x"], rotAdd["y"], rotAdd["z"]})
		else
			object.setRotation({info.rot["x"] + rotAdd["x"], info.rot["y"] + rotAdd["y"], info.rot["z"] + rotAdd["z"]})
		end
		if posAdd["forceHeight"] then
			object.setPosition({info.pos["x"] + info.vForward["x"] * posAdd["forward"] + info.vRight["x"] * posAdd["right"] + info.vUp["x"] * posAdd["up"],
									  posAdd["forceHeight"],
									  info.pos["z"] + info.vForward["z"] * posAdd["forward"] + info.vRight["z"] * posAdd["right"] + info.vUp["z"] * posAdd["up"]})
		else
			object.setPosition({info.pos["x"] + info.vForward["x"] * posAdd["forward"] + info.vRight["x"] * posAdd["right"] + info.vUp["x"] * posAdd["up"],
									  info.pos["y"] + info.vForward["y"] * posAdd["forward"] + info.vRight["y"] * posAdd["right"] + info.vUp["y"] * posAdd["up"],
									  info.pos["z"] + info.vForward["z"] * posAdd["forward"] + info.vRight["z"] * posAdd["right"] + info.vUp["z"] * posAdd["up"]})
		end
	end
end

--tableIn = {guid = , max = , forward = , height = }
function moveObjectToPlayerByGUID(tableIn)
	local object = getObjectFromGUID(tableIn.guid)
	if object then
		local playerColor = closestPlayer(object, players, tableIn.max)
		if playerColor then
			giveObjectToPlayer(object, playerColor, {forward = tableIn.forward, right = 0, up = 0, forceHeight = tableIn.height}, NO_ROT, false, true)
		end
	end
end

function findDistance(posA, posB)
	return math.sqrt((posA["x"] - posB["x"])^2 +
						  (posA["y"] - posB["y"])^2 +
						  (posA["z"] - posB["z"])^2)
end

function closestPlayer(objectIn, playerListIn, maxIn)
	local playerColorOut = nil
	local pos = nil

	local lastDistance = maxIn
	if objectIn then
		local tempPos = objectIn.getPosition()
		for i, playerColor in ipairs(playerListIn) do
			if greyPlayer(playerColor) then
				ph = getObjectFromGUID(greyPlayerHandGuids[playerColor])
				if ph then
					pos = ph.getPosition()
					pos = {x = pos["x"], y = pos["y"], z = pos["z"] - 2.26}
				end
			else
				local ph = Player[playerColor].getPlayerHand()
				if ph then
					pos = {x = ph["pos_x"], y = ph["pos_y"], z = ph["pos_z"]}
				end
			end
			if pos then
				local distance = findDistance(tempPos, pos);
				if distance < lastDistance then
					lastDistance = distance
					playerColorOut = playerColor
				end
			end
		end
	end

	return playerColorOut
end

function sleep(numSeconds)
	local t0 = os.clock()
	while os.clock() - t0 <= numSeconds do coroutine.yield(0) end
end

function wait(numFrames)
	for i=1,numFrames,1 do coroutine.yield(0) end
end

function destroyObjectByGUID(guidIn)
	local dObject = getObjectFromGUID(guidIn)
	if dObject then destroyObject(dObject) end
end

function rgbToHex(c)
	return string.format("%02x%02x%02x", c["r"] * 255 , c["g"] * 255, c["b"] * 255)
end

function stringColorToHex(color)
	return rgbToHex(stringColorToRGBExtra(color))
end

function stringColorToRGBExtra(color)
	if greyPlayer(color) then
		return GREY_PLAYABLE_COLORS_RGB[color]
	else
		return stringColorToRGB(color)
	end
end

function removeBBCode(stringIn)
	local out = ""
	local formating = false

	for i = 1, string.len(stringIn) do
		local tmpChar = string.sub(stringIn, i, i)
		if tmpChar == "[" then
			formating = true
		elseif tmpChar == "]" then
			formating = false
		else
			if not formating then out = out .. tmpChar end
		end
	end

	return out
end

function getPositionByGUID(guidIn)
	local tmpObj = getObjectFromGUID(guidIn)
	return tmpObj.getPosition()
end

function getPositionByGUIDOffsetZ(guidIn, offsetZ)
	local tmpObj = getObjectFromGUID(guidIn)
	local pos = tmpObj.getPosition()
	pos["z"] = pos["z"] + offsetZ
	return pos
end

function getDeckFromZoneByGUID(guidIn)
	local deck = nil
	local deck_ct = 0
	local zone = getObjectFromGUID(guidIn)
	local object

	if zone then
		local inZone = zone.getObjects()
		for _, object in ipairs(inZone) do
			if object.tag == "Card" then
				deck_ct = 2
			elseif object.tag == "Deck" then
				deck = object
				deck_ct = deck_ct + 1
			end
		end
	end
	if deck_ct == 1 then
		return deck
	end
	return nil
end

function inTable(tableIn, valueIn)
	local value
	if tableIn then
		for _, value in pairs(tableIn) do
			if value == valueIn then
				return true
			end
		end
	end
	return false
end

function smartTableInsert(tableIn, valueIn)
	if not inTable(tableIn, valueIn) then
		table.insert(tableIn, valueIn)
	end
end

function versionInfo()
	local msg

	msg = _VERSION -- Lua info
	if MOD_NAME then
		msg = msg .. "\nMOD_NAME = " .. MOD_NAME
	else
		msg = msg .. "\nMOD_NAME = nil"
	end
	if UPDATE_VERSION then
		msg = msg .. "\nUPDATE_VERSION = " .. UPDATE_VERSION
	else
		msg = msg .. "\nUPDATE_VERSION = nil"
	end
	msg = msg .. "\nGlobal Lua length " .. string.len(Global.getLuaScript())

	return msg
end

function nullFunction()
	--nothing here
end

-- This allows outside objects to call any function from this code.
-- Global.call("callFunction", { fcn = "drawCards", params = {amountToDraw, color} })
function callFunction(packet)
    assert(type(_G[packet.fcn]) == "function", "No function named " .. packet.fcn .. " exists!")
    return table.pack(_G[packet.fcn](unpack(packet.params or {})))
end

function tableToString(tbl, indent)
	if not indent then indent = 0 end
	local out = ""

	for k, v in pairs(tbl) do
   	formatting = string.rep("  ", indent) .. k .. ": "
   	if type(v) == "table" then
      	out = out .. formatting .. "\n" .. tableToString(v, indent + 1)
   	elseif type(v) == "boolean" then
      	out = out .. formatting .. tostring(v) .. "\n"
   	else
			out = out .. formatting .. v .. "\n"
    end
  end

  return out
end

function generateAvatarImageUrl(steamId)
   return string.format("http://steam-tts.bclass.info/avatar/?i=%s&s=l", steamId)
end

function greyPlayer(color)
	if type(color) == "table" then
		color = color[1]
	end
	if inTable(GREY_PLAYABLE_COLORS, color) then
		return true
	else
		return false
	end
end

function getPlayerObj(color)
	if greyPlayer(color) then
		local playerFound = nil
		steamId = greyPlayerSteamIds[color]
		for _, player in ipairs(Player.getSpectators()) do
			if steamId == player.steam_id then
				playerFound = player
				break
			end
		end
		return playerFound
	else
		return Player[color]
	end
end

function getGreyColor(steamId)
	local colorFound = nil
 	for testColor, testSteamId in pairs(greyPlayerSteamIds) do
		if steamId == testSteamId then
			colorFound = testColor
			break
		end
	end
	return colorFound
end

--Returns a simple table with all objects and their container GUIDs
function getObjsFromZone(zoneGUID)
	local zoneObj = getObjectFromGUID(zoneGUID)
	local objs = zoneObj.getObjects()
	local returnTable = {}
	local deckTab = {}
	local deckGUID

	for k1,v1 in pairs(objs) do
		if v1.tag == "Card" then
			table.insert(returnTable, {
				name = v1.getName(),
				description = v1.getDescription(),
				deck_guid = nil,
				index = nil,
				guid = v1.getGUID()
			})
		elseif v1.tag == "Deck" then
			deckGuid = v1.getGUID()
			deckTab = v1.getObjects()
			for k2, v2 in pairs(deckTab) do
				table.insert(returnTable, {
					name = v2.nickname,
					description = v2.description,
					deck_guid = deckGuid,
					index = v2.index,
					guid = v2.guid
				})
			end
		end
	end
	return returnTable
end

function shufflePosition(objects)
	local positionA
	local positionB

	for i = 1, #objects * 5 do
		local a = math.random(#objects)
		local b = math.random(#objects)
		positionA = objects[a].getPosition()
		positionB = objects[b].getPosition()
		objects[b].setPosition(positionA)
		objects[a].setPosition(positionB)
	end
end

function shuffleTable(objects)
	for i = 1, #objects * 5 do
		local a = math.random(#objects)
		local b = math.random(#objects)
		objects[a], objects[b] = objects[b], objects[a]
	end
end

function string:tokenize(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function string:titlecase()
	return string.upper(string.sub(self, 1, 1)) .. string.lower(string.sub(self, 2))
end

function bigBroadcast(msgIn, playerObjIn)
	local messageTable = string.tokenize(msgIn, "\n")

	for i=#messageTable, 1, -1 do
		playerObjIn:broadcast(messageTable[i])
	end
end

function getPlayerByName(playerName, playerList)
   local amountOfPlayersFound = 0
   local playerToReturn = nil

	if playerName then
	   for index, name in pairs(playerList) do
	   	if string.match(string.lower(playerList[index].steam_name), string.lower(playerName)) then
	         playerToReturn = playerList[index]
				amountOfPlayersFound = amountOfPlayersFound + 1
			end
		end

	   if amountOfPlayersFound == 1 then
			return playerToReturn
		end
	end

	return nil
end

function getPlayerByNameSteamID(playerNameSteamID, playerList)
	if playerNameSteamID then
		local playerFound = getPlayerByName(playerNameSteamID, playerList)
		if playerFound then
			return playerFound
		else
			for _, p in pairs(playerList) do
				if p.steam_id == playerNameSteamID then
					return p
				end
			end
		end
	end

	return nil
end

function smartBroadcastToColor(msg, playerColor, msgColor)
	if greyPlayer(playerColor) then
		local player = getPlayerObj(playerColor)
		if player then
			player.broadcast(msg, msgColor)
		end
	else
		broadcastToColor(msg, playerColor, msgColor)
	end
end

----#include \SecretHitlerCE\common.ttslua



