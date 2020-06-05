----#include \SHTools\LineDrawer.ttslua
--[[
Line Drawer
Made by Sionar
--]]


------------------Constants
VERSION = '1.6.2'
COLOR_TABLE = {'White', 'Brown', 'Red', 'Orange', 'Yellow', 'Green', 'Teal', 'Blue', 'Purple', 'Pink'}
LINE_HEIGHT = 1
LINE_SPACING = 1
HEIGHT_SPACING = 0.05
DEFAULT_LINE_COLOR = 'Red'

GLOBAL_X_OFF = GLOBAL_X_OFF or 0.4
X_OFF = 1.2
X_COL1 = -1.9 + GLOBAL_X_OFF
X_COL2 = X_COL1 + 0.6
PLAYER1_POS = {{X_COL2+X_OFF*0,0.2,0.7}, {X_COL2+X_OFF*0,0.2,1.1}, {X_COL1+X_OFF*0,0.2,1.1}, {X_COL1+X_OFF*0,0.2,0.7}, {X_COL1+X_OFF*0,0.2,0.3}, {X_COL1+X_OFF*0,0.2,-0.1}, {X_COL1+X_OFF*0,0.2,-0.5}, {X_COL2+X_OFF*0,0.2,-0.5}, {X_COL2+X_OFF*0,0.2,-0.1}, {X_COL2+X_OFF*0,0.2,0.3}}
PLAYER2_POS = {{X_COL2+X_OFF*1,0.2,0.7}, {X_COL2+X_OFF*1,0.2,1.1}, {X_COL1+X_OFF*1,0.2,1.1}, {X_COL1+X_OFF*1,0.2,0.7}, {X_COL1+X_OFF*1,0.2,0.3}, {X_COL1+X_OFF*1,0.2,-0.1}, {X_COL1+X_OFF*1,0.2,-0.5}, {X_COL2+X_OFF*1,0.2,-0.5}, {X_COL2+X_OFF*1,0.2,-0.1}, {X_COL2+X_OFF*1,0.2,0.3}}
COLOR_POS = {{X_COL2+X_OFF*2,0.2,0.7}, {X_COL2+X_OFF*2,0.2,1.1}, {X_COL1+X_OFF*2,0.2,1.1}, {X_COL1+X_OFF*2,0.2,0.7}, {X_COL1+X_OFF*2,0.2,0.3}, {X_COL1+X_OFF*2,0.2,-0.1}, {X_COL1+X_OFF*2,0.2,-0.5}, {X_COL2+X_OFF*2,0.2,-0.5}, {X_COL2+X_OFF*2,0.2,-0.1}, {X_COL2+X_OFF*2,0.2,0.3}}
GIVE_TOOL_BUTTON_POS = {{1,0.2,0.9}, {0,0.2,0.9}, {-1,0.2,0.9}, {-1.7 + GLOBAL_X_OFF,0.2,0.3}, {-1.7 + GLOBAL_X_OFF,0.2,-0.3}, {-1,0.2,-0.9}, {0,0.2,-0.9}, {1,0.2,-0.9}, {1.7 - GLOBAL_X_OFF,0.2,-0.3}, {1.7 - GLOBAL_X_OFF,0.2,0.3}}
DIVIDER_LINE_1 = {{1.0 - GLOBAL_X_OFF, 0.2, -0.6}, {1.0 - GLOBAL_X_OFF, 0.2, 1.2}}

POINTS =
{
    White = {29.3, LINE_HEIGHT, -26},
    Brown = {0, LINE_HEIGHT, -26},
    Red = {-29.3-0.5, LINE_HEIGHT, -26},
    Orange = {-44, LINE_HEIGHT, -11.73},
    Yellow = {-44, LINE_HEIGHT, 11.73+0.5},
    Green = {-29.3, LINE_HEIGHT, 26},
    Teal = {0, LINE_HEIGHT, 26},
    Blue = {29.3+0.5, LINE_HEIGHT, 26},
    Purple = {44, LINE_HEIGHT, 11.73},
    Pink = {44, LINE_HEIGHT, -11.73-0.5},
}

VALUE =
{
    White = 0,
    Brown = 1,
    Red = 2,
    Orange = 3,
    Yellow = 4,
    Green = 5,
    Teal = 6,
    Blue = 7,
    Purple = 8,
    Pink = 9
}

GROUP =
{
    White = 0,
    Brown = 0,
    Red = 0,
    Orange = 1,
    Yellow = 1,
    Green = 2,
    Teal = 2,
    Blue = 2,
    Purple = 3,
    Pink = 3
}


------------------Variables
nameLabels = {}
valLabels = {}
lineTable = {}
vectorTable = {}
player1 = ''
player2 = ''
lineColor = ''
promOnly = false
style = 'block'
arrowDrawing = true
dashed = false



------------------Functions
function onLoad(saveString)
    if not (saveString == '') then
        local save = JSON.decode(saveString)
        lineTable = save['lt']
        style = save['s']
        promOnly = save['p']
        arrowDrawing = save['a']
        dashed = save['d']
    end
    refreshButtons()

    local global_name = Global.getVar('MOD_NAME')
    local started = Global.getVar('started')
    if not started and global_name == 'Secret Hitler: CE' then
        lineTable = {}
        self.setLock(true)
        local tempScale = self.getScale()[1]
        self.scale(1/tempScale)
        self.scale(5.8)
        local pos = {forward = -13, right = 0, up = 3}
        local rot = {x = 0, y = 180, z = 0}
        giveObjectToPlayer(self, COLOR_TABLE[2], pos, rot)
    end
    self.setDescription('v ' .. VERSION .. '\nMade by Sionar\nModified by wchill\nUse with SH Consolidator Edition workshop mod.')
end

function onSave()
    local save = {}
    save['lt'] = lineTable
    save['s'] = style
    save['p'] = promOnly
    save['a'] = arrowDrawing
    save['d'] = dashed
    local saveString = JSON.encode(save)
    return saveString
end

function calcNormDirectionVector(startVec, endVec)
    dx = endVec[1] - startVec[1]
    dy = endVec[2] - startVec[2]
    dz = endVec[3] - startVec[3]
    length = math.sqrt(dx * dx + dy * dy + dz * dz)
    return {dx / length, dy / length, dz / length}
end

function rotateVector90Degrees(vec, plane)
    x = vec[2] * plane[3] - plane[2] * vec[3]
    y = vec[3] * plane[1] - plane[3] * vec[1]
    z = vec[1] * plane[2] - plane[1] * vec[2]
    return {x, y, z}
end

function calcArrowPoints(point1, point2)
    normVector = calcNormDirectionVector(point1, point2)
    rotated = rotateVector90Degrees(normVector, {0, 1, 0})

    arrowMidpoint = {point2[1] - normVector[1], point2[2] - normVector[2], point2[3] - normVector[3]}
    arrowLeft = {arrowMidpoint[1] + 0.5 * rotated[1], arrowMidpoint[2] + 0.5 * rotated[2], arrowMidpoint[3] + 0.5 * rotated[3]}
    arrowRight = {arrowMidpoint[1] - 0.5 * rotated[1], arrowMidpoint[2] - 0.5 * rotated[2], arrowMidpoint[3] - 0.5 * rotated[3]}

    return {point2, arrowLeft, arrowRight}
end

function addLineStraight(pColor1, pColor2, lColor)
    for k,v in pairs(lineTable) do
        if v.player1 == pColor1 and v.player2 == pColor2 or v.player1 == pColor2 and v.player2 == pColor1 then
            return
        end
    end

    if pColor1 == '' or pColor2 == '' then
        return
    end

    if lColor == '' then
        lineColor = DEFAULT_LINE_COLOR
        lColor = lineColor
    end

    local point1 = POINTS[pColor1]
    local point2 = POINTS[pColor2]
    if (pColor1 == 'White' and pColor2 == 'Red') or (pColor1 == 'Red' and pColor2 == 'White') then
        point1 = {point1[1],point1[2],point1[3]+0.5}
        point2 = {point2[1],point2[2],point2[3]+0.5}
    end
    if (pColor1 == 'Green' and pColor2 == 'Blue') or (pColor1 == 'Blue' and pColor2 == 'Green') then
        point1 = {point1[1],point1[2],point1[3]-0.5}
        point2 = {point2[1],point2[2],point2[3]-0.5}
    end
    addArrow(pColor1, pColor2, point1, point2, lColor)
end

function addLineBlock(pColor1, pColor2, lColor)
    for k,v in pairs(lineTable) do
        if v.player1 == pColor1 and v.player2 == pColor2 or v.player1 == pColor2 and v.player2 == pColor1 then
            return
        end
    end

    if pColor1 == '' or pColor2 == '' then
        return
    end

    if lColor == '' then
        lineColor = DEFAULT_LINE_COLOR
        lColor = lineColor
    end

    local point1 = POINTS[pColor1]
    local point2 = POINTS[pColor2]
    local point3 = nil
    local point4 = nil

    local pColor1Offset = VALUE[pColor2] - VALUE[pColor1] - 5
    if pColor1Offset <= -6 then
        pColor1Offset = pColor1Offset + 10
    end
    pColor2Offset = -1 * pColor1Offset

    if GROUP[pColor1] == 0 then
        point1 = {point1[1] + pColor1Offset * LINE_SPACING,point1[2],point1[3]}
    elseif GROUP[pColor1] == 1 then
        point1 = {point1[1],point1[2],point1[3] - pColor1Offset * LINE_SPACING}
    elseif GROUP[pColor1] == 2 then
        point1 = {point1[1] - pColor1Offset * LINE_SPACING,point1[2],point1[3]}
    elseif GROUP[pColor1] == 3 then
        point1 = {point1[1],point1[2],point1[3] + pColor1Offset * LINE_SPACING}
    end

    if GROUP[pColor2] == 0 then
        point2 = {point2[1] + pColor2Offset * LINE_SPACING,point2[2],point2[3]}
    elseif GROUP[pColor2] == 1 then
        point2 = {point2[1],point2[2],point2[3] - pColor2Offset * LINE_SPACING}
    elseif GROUP[pColor2] == 2 then
        point2 = {point2[1] - pColor2Offset * LINE_SPACING,point2[2],point2[3]}
    elseif GROUP[pColor2] == 3 then
        point2 = {point2[1],point2[2],point2[3] + pColor2Offset * LINE_SPACING}
    end

    if GROUP[pColor1] == GROUP[pColor2] then     --Same side of table
        if GROUP[pColor1] == 0 then
            if pColor1 == 'Brown' or pColor2 == 'Brown' then
                point3 = {point1[1], LINE_HEIGHT, POINTS['Orange'][3] - 5 * LINE_SPACING}
                point4 = {point2[1], LINE_HEIGHT, POINTS['Orange'][3] - 5 * LINE_SPACING}
            else
                point3 = {point1[1], LINE_HEIGHT, POINTS['Orange'][3] - 4 * LINE_SPACING}
                point4 = {point2[1], LINE_HEIGHT, POINTS['Orange'][3] - 4 * LINE_SPACING}
            end
        elseif GROUP[pColor1] == 2 then
            if pColor1 == 'Teal' or pColor2 == 'Teal' then
                point3 = {point1[1], LINE_HEIGHT, POINTS['Yellow'][3] + 5 * LINE_SPACING}
                point4 = {point2[1], LINE_HEIGHT, POINTS['Yellow'][3] + 5 * LINE_SPACING}
            else
                point3 = {point1[1], LINE_HEIGHT, POINTS['Yellow'][3] + 4 * LINE_SPACING}
                point4 = {point2[1], LINE_HEIGHT, POINTS['Yellow'][3] + 4 * LINE_SPACING}
            end
        elseif GROUP[pColor1] == 1 then
            point3 = {POINTS['Red'][1] - 4 * LINE_SPACING, LINE_HEIGHT, point1[3]}
            point4 = {POINTS['Red'][1] - 4 * LINE_SPACING, LINE_HEIGHT, point2[3]}
        else
            point3 = {POINTS['White'][1] + 4 * LINE_SPACING, LINE_HEIGHT, point1[3]}
            point4 = {POINTS['White'][1] + 4 * LINE_SPACING, LINE_HEIGHT, point2[3]}
        end
        addSegment(pColor1, pColor2, point1, point3, lColor)
        addSegment(pColor1, pColor2, point3, point4, lColor)
        addArrow(pColor1, pColor2, point4, point2, lColor)
    elseif GROUP[pColor1] % 2 == GROUP[pColor2] % 2 then    --Opposite sides of table
        if (pColor1 == 'White' and pColor2 == 'Blue') or    --Directly facing each other
           (pColor1 == 'Blue' and pColor2 == 'White') or
           (pColor1 == 'Brown' and pColor2 == 'Teal') or
           (pColor1 == 'Teal' and pColor2 == 'Brown') or
           (pColor1 == 'Red' and pColor2 == 'Green') or
           (pColor1 == 'Green' and pColor2 == 'Red') or
           (pColor1 == 'Yellow' and pColor2 == 'Purple') or
           (pColor1 == 'Purple' and pColor2 == 'Yellow') or
           (pColor1 == 'Orange' and pColor2 == 'Pink') or
           (pColor1 == 'Pink' and pColor2 == 'Orange') then
               addArrow(pColor1, pColor2, point1, point2, lColor)
        else
            if pColor1 == 'White' and pColor2 == 'Green' or pColor1 == 'Green' and pColor2 == 'White' then
                point3 = {point1[1], LINE_HEIGHT, 0.5}
                point4 = {point2[1], LINE_HEIGHT, 0.5}
            elseif pColor1 == 'White' and pColor2 == 'Teal' or pColor1 == 'Teal' and pColor2 == 'White' then
                    point3 = {point1[1], LINE_HEIGHT, 1}
                    point4 = {point2[1], LINE_HEIGHT, 1}
            elseif pColor1 == 'Brown' or pColor2 == 'Brown' then
                point3 = {point1[1], LINE_HEIGHT, 0}
                point4 = {point2[1], LINE_HEIGHT, 0}
            elseif pColor1 == 'Red' and pColor2 == 'Teal' or pColor1 == 'Teal' and pColor2 == 'Red' then
                point3 = {point1[1], LINE_HEIGHT, -1}
                point4 = {point2[1], LINE_HEIGHT, -1}
            elseif pColor1 == 'Red' and pColor2 == 'Blue' or pColor1 == 'Blue' and pColor2 == 'Red' then
                point3 = {point1[1], LINE_HEIGHT, -0.5}
                point4 = {point2[1], LINE_HEIGHT, -0.5}
            elseif pColor1 == 'Orange' or pColor2 == 'Orange' then
                point3 = {0.5, LINE_HEIGHT, point1[3]}
                point4 = {0.5, LINE_HEIGHT, point2[3]}
            elseif pColor1 == 'Yellow' or pColor2 == 'Yellow' then
                point3 = {-0.5, LINE_HEIGHT, point1[3]}
                point4 = {-0.5, LINE_HEIGHT, point2[3]}
            end
            addSegment(pColor1, pColor2, point1, point3, lColor)
            addSegment(pColor1, pColor2, point3, point4, lColor)
            addArrow(pColor1, pColor2, point4, point2, lColor)
        end
    else                                                       --Adjacent sides of table
        if GROUP[pColor1] % 2 == 0 then
            point3 = {point1[1], LINE_HEIGHT, point2[3]}
        else
            point3 = {point2[1], LINE_HEIGHT, point1[3]}
        end
        if pColor1 == 'White' or pColor2 == 'White' or pColor1 == 'Green' or pColor2 == 'Green' then
            point3[2] = LINE_HEIGHT + HEIGHT_SPACING * 0
        elseif pColor1 == 'Brown' or pColor2 == 'Brown' or pColor1 == 'Blue' or pColor2 == 'Blue' then
            point3[2] = LINE_HEIGHT + HEIGHT_SPACING * 1
        elseif pColor1 == 'Red' or pColor2 == 'Red' or pColor1 == 'Teal' or pColor2 == 'Teal' then
            point3[2] = LINE_HEIGHT + HEIGHT_SPACING * 2
        end

        addSegment(pColor1, pColor2, point1, point3, lColor)
        addArrow(pColor1, pColor2, point3, point2, lColor)
    end
end

function addSegment(playerColor1, playerColor2, point1, point2, lineColor)
    local lineData =
        {
            player1   = playerColor1,
            player2   = playerColor2,
            points    = {point1, point2},
            color     = lineColor,
            thickness = 0.5,
            rotation  = {0,0,0}
        }
    table.insert(lineTable, lineData)
end

function addArrow(playerColor1, playerColor2, point1, point2, lineColor)
    addSegment(playerColor1, playerColor2, point1, point2, lineColor)
    if arrowDrawing == true then
        arrowPoints = calcArrowPoints(point1, point2)
        addSegment(playerColor1, playerColor2, arrowPoints[1], arrowPoints[2], lineColor)
        addSegment(playerColor1, playerColor2, arrowPoints[2], arrowPoints[3], lineColor)
        addSegment(playerColor1, playerColor2, arrowPoints[3], arrowPoints[1], lineColor)
    end
end

function removeLine(playerColor1, playerColor2)
    for i = #lineTable, 1, -1 do
        if lineTable[i].player1 == playerColor1 and lineTable[i].player2 == playerColor2 or lineTable[i].player1 == playerColor2 and lineTable[i].player2 == playerColor1 then
            table.remove(lineTable, i)
        end
    end
end

function drawLineFunc(clickedButton, playerColor)
    if Player[playerColor].admin or not promOnly then
        clearLines()
        removeLine(player1, player2)
        if style == 'straight' then
            addLineStraight(player1, player2, player1)
        else
            addLineBlock(player1, player2, player1)
        end
        mergeTables()
        Global.setVectorLines(vectorTable)
        clearUI()
    end
end

function remLineFunc(clickedButton, playerColor)
    if Player[playerColor].admin or not promOnly then
        clearLines()
        removeLine(player1, player2)
        mergeTables()
        Global.setVectorLines(vectorTable)
        clearUI()
    end
end

function clearLinesFunc(clickedButton, playerColor)
    if Player[playerColor].admin or not promOnly then
        lineTable = {}
        clearLines()
        clearUI()
    end
end

function globalCallClear()
	lineTable = {}
	clearLines()
	clearUI()
end

function clearLines()
    vectorTable = Global.getVectorLines() or {}
    for i = #vectorTable, 1, -1 do
        if vectorTable[i].thickness == 0.5 then
            table.remove(vectorTable, i)
        end
    end
    Global.setVectorLines(vectorTable)
end

function importFunc(clickedButton, playerColor)
    if Player[playerColor].admin or not promOnly then
        clearLines()
        local noteTakerNotes = Global.getTable('noteTakerNotes')
        for i = 1, #noteTakerNotes do
            if ((noteTakerNotes[i].conflict == '(Conflict)' or noteTakerNotes[i].conflict == '(Rev Con)') and noteTakerNotes[i].color2 ~= '') or (noteTakerNotes[i].action == 'inspects' and noteTakerNotes[i].result == 'claims [FF0000]Fascist[-]' and noteTakerNotes[i].color2 ~= '') then
                local p1, p2, lC
                p1 = noteTakerNotes[i].color1
                p2 = noteTakerNotes[i].color2
                lC = p1
                if style == 'straight' then
                    addLineStraight(p1, p2, lC)
                else
                    addLineBlock(p1, p2, lC)
                end
            end
        end
        mergeTables()
        Global.setVectorLines(vectorTable)
        clearUI()
    end
end

function mergeTables()
    if vectorTable == nil then
        vectorTable = {}
    end

    for k,v in pairs(lineTable) do
        table.insert(vectorTable, v)
    end
end

function promStart(clickedButton, playerColor)
    if Player[playerColor].admin then
        if promOnly == true then
            promOnly = false
            broadcastToAll("Line drawing tool access has been granted to all users", {1,1,1})
        else
            promOnly = true
            broadcastToAll("Line drawing tool access has been granted to promoted users only", {1,1,1})
        end
    end
    refreshButtons()
end

function styleStart(clickedButton, playerColor)
    if Player[playerColor].admin or not promOnly then
        if style == 'block' then
            style = 'straight'
            broadcastToAll("Style has been changed to straight", {1,1,1})
        else
            style = 'block'
            broadcastToAll("Style has been changed to block", {1,1,1})
        end
    end
    refreshButtons()
end

function arrowStart(clickedButton, playerColor)
    if Player[playerColor].admin or not promOnly then
        if arrowDrawing == true then
            arrowDrawing = false
            broadcastToAll("Directional arrow will not be drawn", {1,1,1})
        else
            arrowDrawing = true
            broadcastToAll("Directional arrow will be drawn", {1,1,1})
        end
    end
    refreshButtons()
end

------------------UI
function refreshButtons()
    self.clearButtons()
    createLabels()
    createP1Buttons()
    createP2Buttons()
    createActionButtons()

    self.setVectorLines({
        {
            points    = DIVIDER_LINE_1,
            color     = 'White',
            thickness = 0.01,
            rotation  = {0,0,0}
        }
    })
end

function clearUI()
    player1 = ''
    player2 = ''
    lineColor = ''
    refreshButtons()
end

function createLabels()
    local buttonParam = {label = 'Player 1 → Player 2', click_function = 'nulFunc', color = {0,0,0,1}, font_color = stringColorToRGB('White'), function_owner = self,
            position = {-1.0 + GLOBAL_X_OFF,0.2,-1}, rotation = {0,0,0}, width = 0, height = 0, font_size = 250, scale = {0.5,0.5,0.5}}
    self.createButton(buttonParam)
end

function createP1Buttons()
    buttonParam = {}
    for i = 1,10 do
        buttonParam.click_function = 'setPlayer1-' .. i
        buttonParam.label = COLOR_TABLE[i]
        buttonParam.function_owner = self
        buttonParam.position = PLAYER1_POS[i]
        buttonParam.width = 1000
        buttonParam.height = 400
        buttonParam.font_color = stringColorToRGB(COLOR_TABLE[i])
        buttonParam.font_size = 200
        buttonParam.scale = {0.25,0.25,0.25}
        buttonParam.tooltip = COLOR_TABLE[i] .. ' initiates conflict'

        if player1 == COLOR_TABLE[i] then
            buttonParam.color = stringColorToRGB(COLOR_TABLE[i])
        else
            buttonParam.color = {0,0,0,1}
        end
        self.createButton(buttonParam)
    end
end

function setPlayer1(clickedButton, playerColor, index)
    if Player[playerColor].admin or not promOnly then
        if player1 == COLOR_TABLE[index] then
            player1 = ''
        else
            player1 = COLOR_TABLE[index]
        end
        refreshButtons()
    end
end

for k = 1,10 do
    _G['setPlayer1-' .. k] = function(obj, col)
        setPlayer1(obj, col, k)
    end
end

function createP2Buttons()
    buttonParam = {}
    for i = 1,10 do
        buttonParam.click_function = 'setPlayer2-' .. i
        buttonParam.label = COLOR_TABLE[i]
        buttonParam.function_owner = self
        buttonParam.position = PLAYER2_POS[i]
        buttonParam.width = 1000
        buttonParam.height = 400
        buttonParam.font_color = stringColorToRGB(COLOR_TABLE[i])
        buttonParam.font_size = 200
        buttonParam.scale = {0.25,0.25,0.25}
        buttonParam.tooltip = COLOR_TABLE[i] .. ' targeted by conflict'

        if player2 == COLOR_TABLE[i] then
            buttonParam.color = stringColorToRGB(COLOR_TABLE[i])
        else
            buttonParam.color = {0,0,0,1}
        end
        self.createButton(buttonParam)
    end
end

function setPlayer2(clickedButton, playerColor, index)
    if Player[playerColor].admin or not promOnly then
        if player2 == COLOR_TABLE[index] then
            player2 = ''
        else
            player2 = COLOR_TABLE[index]
        end
        refreshButtons()
    end
end

for k = 1,10 do
    _G['setPlayer2-' .. k] = function(obj, col)
        setPlayer2(obj, col, k)
    end
end

function createActionButtons()
    local buttonParam = {click_function = 'drawLineFunc', label = "Draw\nLine", color = {1,1,1}, font_color = stringColorToRGB('Black'), function_owner = self,
        position = {1.8-GLOBAL_X_OFF,0.2,-0.5}, rotation = {0,0,0}, width = 1600, height = 800, font_size = 300, scale = {0.25,0.25,0.25}}
    self.createButton(buttonParam)

    local buttonParam = {click_function = 'remLineFunc', label = "Remove\nLine", color = {1,1,1}, font_color = stringColorToRGB('Black'), function_owner = self,
        position = {1.8-GLOBAL_X_OFF,0.2,0}, rotation = {0,0,0}, width = 1600, height = 800, font_size = 300, scale = {0.25,0.25,0.25}}
    self.createButton(buttonParam)

    local buttonParam = {click_function = 'clearLinesFunc', label = "Clear\nAll Lines", color = {1,1,1}, font_color = stringColorToRGB('Black'), function_owner = self,
        position = {1.8-GLOBAL_X_OFF,0.2,0.5}, rotation = {0,0,0}, width = 1600, height = 800, font_size = 300, scale = {0.25,0.25,0.25}}
    self.createButton(buttonParam)

    local buttonParam = {click_function = 'importFunc', label = 'Import from\nNotetaker', color = {1,1,1}, font_color = stringColorToRGB('Black'), function_owner = self,
        position = {1.8-GLOBAL_X_OFF,0.2,1}, rotation = {0,0,0}, width = 1600, height = 800, font_size = 300, scale = {0.25,0.25,0.25}}
    self.createButton(buttonParam)

    local buttonParam = {click_function = 'styleStart', function_owner = self, label = '☆', color = {0,0,0,0.8}, font_color = stringColorToRGB('Blue'),
        position = {1.5-GLOBAL_X_OFF,0.2,-1.2}, width = 400, height = 400, font_size = 300, tooltip = 'Toggle Line Style', scale = {0.25,0.25,0.25}}
    if style == 'block' then
        buttonParam.label = '★'
    end
    self.createButton(buttonParam)

    local buttonParam = {click_function = 'promStart', function_owner = self, label = '☆', color = {0,0,0,0.8}, font_color = stringColorToRGB('Green'),
        position = {1.8-GLOBAL_X_OFF,0.2,-1.2}, width = 400, height = 400, font_size = 320, tooltip = 'Toggle Promoted Only', scale = {0.25,0.25,0.25}}
    if promOnly == true then
        buttonParam.label = '★'
    end
    self.createButton(buttonParam)

    local buttonParam = {click_function = 'givetMenu', function_owner = self, label = '☆', color = {0,0,0,0.8}, font_color = stringColorToRGB('Red'),
        position = {2.1-GLOBAL_X_OFF,0.2,-1.2}, width = 400, height = 400, font_size = 320, tooltip = 'Give Line\nDrawer to:', scale = {0.25,0.25,0.25}}
    self.createButton(buttonParam)

    local buttonParam = {click_function = 'arrowStart', function_owner = self, label = '☆', color = {0,0,0,0.8}, font_color = stringColorToRGB('White'),
        position = {1.5-GLOBAL_X_OFF,0.2,-0.9}, width = 400, height = 400, font_size = 300, tooltip = 'Toggle Arrow', scale = {0.25,0.25,0.25}}
    if arrowDrawing == true then
        buttonParam.label = '★'
    end
    self.createButton(buttonParam)
end

function givetMenu()
    self.clearButtons()
    self.setVectorLines({})

    for i = 1,10 do
        local buttonParam = {click_function = 'giveTool' .. i, label = COLOR_TABLE[i], color = stringColorToRGB(COLOR_TABLE[i]), function_owner = self,
            position = GIVE_TOOL_BUTTON_POS[i], rotation = {0,0,0}, width = 1800, height = 1000, font_size = 400, scale = {0.25,0.25,0.25}}
        self.createButton(buttonParam)
    end

    local buttonParam = {click_function = 'returnFunc', label = "Cancel", color = {1,1,1,0.8}, function_owner = self,
        position = {0,0.2,0}, rotation = {0,0,0}, width = 1800, height = 1000, font_size = 400, scale = {0.25,0.25,0.25}}
    self.createButton(buttonParam)
end

function giveTool(clickedButton, playerColor, index)
    if Player[playerColor].admin or not promOnly then
        self.setLock(true)
        local tempScale = self.getScale()[1]
        self.scale(1/tempScale)
        self.scale(5.8)
        local pos = {forward = -13, right = 0, up = 3}
        local rot = {x = 0, y = 180, z = 0}
        local options = Global.getTable('options')
        if options.zoneType ~= 6 then
            if COLOR_TABLE[index] == 'Purple' or COLOR_TABLE[index] == 'Orange' then
                pos['right'] = 5
            elseif COLOR_TABLE[index] == 'Pink' or COLOR_TABLE[index] == 'Yellow' then
                pos['right'] = -5
            end
        end
        giveObjectToPlayer(self, COLOR_TABLE[index], pos, rot)
        refreshButtons()
    end
end

for k = 1,10 do
    _G['giveTool' .. k] = function(obj, col)
        giveTool(obj, col, k)
    end
end

function returnFunc(clickedButton, playerColor)
    if Player[playerColor].admin or not promOnly then
        refreshButtons()
    end
end

function giveObjectToPlayer(object, playerColor, posAdd, rotAdd, ...)
	local pos
	local rot
	local vForward
	local vRight
	local vUp

	if playerColor == 'Maroon' or playerColor == 'Tan' then
        local greyPlayerHandGuids = Global.getTable('greyPlayerHandGuids')
		local ph = getObjectFromGUID(greyPlayerHandGuids[playerColor])
		if ph then
			pos = ph.getPosition()
			pos = {x = pos['x'], 0, z = pos['z'] - 2.26}
			rot = ph.getRotation()
			vForward = ph.getTransformForward()
			vRight = ph.getTransformRight()
			vUp = ph.getTransformUp()
		end
	else
		local ph = Player[playerColor].getPlayerHand();
		if ph then
			pos = {x = ph['pos_x'], y = ph['pos_y'], z = ph['pos_z']}
			rot = {x = ph['rot_x'], y = ph['rot_y'], z = ph['rot_z']}
			vForward = {x = ph['trigger_forward_x'], y = ph['trigger_forward_y'], z = ph['trigger_forward_z']}
			vRight = {x = ph['trigger_right_x'], y = ph['trigger_right_y'], z = ph['trigger_right_z']}
			vUp = {x = ph['trigger_up_x'], y = ph['trigger_up_y'], z = ph['trigger_up_z']}
		end
	end

	if pos then
		if rotAdd['exactRot'] then
			object.setRotationSmooth({rotAdd['x'], rotAdd['y'], rotAdd['z']}, ...)
		else
			object.setRotationSmooth({rot['x'] + rotAdd['x'], rot['y'] + rotAdd['y'], rot['z'] + rotAdd['z']}, ...)
		end
		if posAdd['forceHeight'] then
			object.setPositionSmooth({pos['x'] + vForward['x'] * posAdd['forward'] + vRight['x'] * posAdd['right'] + vUp['x'] * posAdd['up'],
											  0, --posAdd['forceHeight'],
											  pos['z'] + vForward['z'] * posAdd['forward'] + vRight['z'] * posAdd['right'] + vUp['z'] * posAdd['up']}, ...)
		else
			object.setPositionSmooth({pos['x'] + vForward['x'] * posAdd['forward'] + vRight['x'] * posAdd['right'] + vUp['x'] * posAdd['up'],
											  0, --pos['y'] + vForward['y'] * posAdd['forward'] + vRight['y'] * posAdd['right'] + vUp['y'] * posAdd['up'],
											  pos['z'] + vForward['z'] * posAdd['forward'] + vRight['z'] * posAdd['right'] + vUp['z'] * posAdd['up']}, ...)
		end
	end
end

----#include \SHTools\LineDrawer.ttslua