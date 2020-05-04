
--[[

Playerlist in order of when they joined
made by 55tremine

I thought this would be harder since I didnt know the getplayers
went by join order. (or the server id for players)

]]--

parameters = {
	click_function="nilFunction", 
	function_owner=self,
	rotation={0,0,0},
	height=0, 
	width=0,
	font_size = 350,
	scale = {0.212, 0, 0.1169},--{0.2,0,0.33},
	font_color = stringColorToRGB("White")
}


function onLoad()
	makeDisplay()
end

function onPlayerConnect(person)
	updateOnJoin()
end

function onPlayerDisconnect()
	updateOnJoin()
end

--this is needed only because onPlayerConnect is broken
function updateOnJoin()
	Timer.destroy(self.getGUID().."ReDisplay")
	local parameters = {}
	
	parameters.identifier = self.getGUID().."ReDisplay"
	parameters.function_name = 'makeDisplay'
	parameters.delay = 1
	Timer.create(parameters)
end

function onDestroy()
	Timer.destroy(self.getGUID().."ReDisplay")
end

function onPlayerChangeColor(color)
	makeDisplay()
end

function makeDisplay()
	self.clearButtons()

	parameters.font_color = stringColorToRGB("White")
	parameters.label="Players" --Players
	parameters.font_size = 350
	parameters.position={0, 0.55, -0.42}
	self.createButton(parameters)

	parameters.font_size = 150
	onNum = 0
	for i, playerObj in pairs(Player.getPlayers()) do
		--Player["Blue"].broadcast(i)
		parameters.label= i..". "..playerObj.steam_name --Players
		parameters.position={0, 0.55, -0.32+onNum*0.045}
		if (playerObj.seated) then
			parameters.font_color = stringColorToRGB(playerObj.color)
		else
			parameters.font_color = stringColorToRGB("Grey")
		end
		self.createButton(parameters)
		
		
		onNum = onNum + 1
	end
end

function nilFunction()
	return false
end