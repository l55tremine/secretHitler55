
--nikos's timer script

--[[ to do

unmute all
text boxs why

]]--

parameters = {
	click_function="startTurn", 
	function_owner=self,
	rotation={90,180,0},
	height=400, 
	width=1200,
	font_size = 350,
	scale = {0.1, 0.021, 0.1},--{0.2,0,0.33},
	font_color = stringColorToRGB("Black")
}

editParams = {index = 1,label="Currently Off"}
clrnums = {White = "[ffffff]",Brown = "[703A16]",Red = "[DA1917]", Orange = "[F3631C]", Yellow = "[E6E42B]", Green = "[30B22A]", Teal = "[20B09A]", Blue = "[1E87FF]", Purple = "[9F1FEF]", Pink = "[F46FCD]", Black = "[3F3F3F]"}
add45sUsed = {}
--savedTime45 = -1
after45 = -1
currentlyMuted = false
presOnlyTime = false

freeTalkTime = 7*60
max45s = 1
new45sTime = 45

function onLoad(save_script)
	parameters.label="Start" --Players
	parameters.position={0.3, -0.1, 0}
	self.createButton(parameters)
	
	parameters.click_function = "nilFunction"
	parameters.label="Currently Error" --Players
	parameters.width=4000
	parameters.position={0, -0.2, 0}
	self.createButton(parameters)
	
	parameters.click_function = "add45"
	parameters.label="add 45" --Players
	parameters.width=1200
	parameters.position={-0.3, -0.1, 0}
	self.createButton(parameters)
	
	self.setScale({1.00, 1.00, 0.21})
	--self.setRotation({90.00, 0, 0.00})
	
	local inputParams = {
		label="free\ntalk", input_function="setFreeTalkTime", function_owner=self, scale = {0.1, 0.021, 0.1}, rotation={90,180,0},
		position={-0.1, -0.1, 0}, height=400, width=400, font_size=175
	}
	
	inputParams.label = "free\ntalk"
	inputParams.input_function = "setFreeTalkTime"
	inputParams.position = {-0.1, -0.1, 0}
	inputParams.value = freeTalkTime
	self.createInput(inputParams)
	
	inputParams.label = "num\n45s"
	inputParams.input_function = "setNum45s"
	inputParams.position = {0, -0.1, 0}
	inputParams.value = max45s
	self.createInput(inputParams)
	
	inputParams.label = "45s\ntime"
	inputParams.input_function = "set45sTime"
	inputParams.position = {0.1, -0.1, 0}
	inputParams.value = new45sTime
	self.createInput(inputParams)
	
	setOff()
    --[[for i, name in pairs(Player.getPlayers()) do
		players
	end]]--
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
					playerObj.mute()
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
		
	self.setValue(60*1)
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
					playerObj.mute()
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

--[[]]--
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






















