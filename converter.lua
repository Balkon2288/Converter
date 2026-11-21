local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("BABFT_ObjUltra") then
    CoreGui.BABFT_ObjUltra:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BABFT_ObjUltra"
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 530)
Main.Position = UDim2.new(0.5, -160, 0.5, -265)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main)

local function CreateLabel(text, pos, size)
    local l = Instance.new("TextLabel")
    l.Size = size or UDim2.new(1, -40, 0, 30)
    l.Position = pos
    l.Text = text
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = Main
    return l
end

local Title = CreateLabel(
    "BALKON CONVERTER",
    UDim2.new(0, 20, 0, 5),
    UDim2.new(0, 240, 0, 40)
)
Title.TextSize = 14

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Close.Parent = Main
Instance.new("UICorner", Close)

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local function CreateInput(text, pos, default)
    local i = Instance.new("TextBox")
    i.Size = UDim2.new(0, 280, 0, 30)
    i.Position = pos
    i.PlaceholderText = text
    i.Text = default or ""
    i.TextSize = 12
    i.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    i.TextColor3 = Color3.new(1, 1, 1)
    i.Parent = Main
    Instance.new("UICorner", i)
    return i
end

local FileInput = CreateInput(
    "File (e.g. model.obj)",
    UDim2.new(0, 20, 0, 50)
)

local MatInput = CreateInput(
    "Material",
    UDim2.new(0, 20, 0, 90),
    "MetalBlock"
)

FileInput.Visible = false
MatInput.Visible = false

local ScaleInput = CreateInput(
    "Scale",
    UDim2.new(0, 20, 0, 130),
    "1"
)

local ThickInput = CreateInput(
    "Thickness (Face/Wire)",
    UDim2.new(0, 20, 0, 170),
    "0.5"
)

local function CreateSelectButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 280, 0, 30)
    button.Position = UDim2.new(0, 20, 0, y)
    button.Text = text
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = Main
    Instance.new("UICorner", button)
    return button
end

local FileBtn = CreateSelectButton("SELECT OBJ FILE", 50)
local MaterialBtn = CreateSelectButton("MATERIAL: MetalBlock", 90)

local function CreateScrollMenu(y)
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(0, 280, 0, 160)
    frame.Position = UDim2.new(0, 20, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 5
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.Visible = false
    frame.ZIndex = 20
    frame.Parent = Main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.Parent = frame

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.CanvasSize = UDim2.new(
            0, 0, 0,
            layout.AbsoluteContentSize.Y + 5
        )
    end)

    return frame
end

local FileMenu = CreateScrollMenu(85)
local MaterialMenu = CreateScrollMenu(125)

local function ClearMenu(menu)
    for _, child in ipairs(menu:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
end

local function AddMenuItem(menu, name, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 27)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.Text = name
    button.ZIndex = 21
    button.Parent = menu

    button.MouseButton1Click:Connect(callback)
end

local materials = {
    "PlasticBlock",
    "GlassBlock",
    "MetalBlock",
    "WoodBlock",
    "NeonBlock",
    "FabricBlock",
    "GraniteBlock",
    "MarbleBlock",
    "SlateBlock",
    "BrickBlock",
    "CobblestoneBlock",
    "GrassBlock",
    "IceBlock",
    "SandBlock",
    "ConcreteBlock",
    "CorrodedMetalBlock",
    "PebbleBlock"
}

for _, material in ipairs(materials) do
    AddMenuItem(MaterialMenu, material, function()
        MatInput.Text = material
        MaterialBtn.Text = "MATERIAL: " .. material
        MaterialMenu.Visible = false
    end)
end

MaterialBtn.MouseButton1Click:Connect(function()
    FileMenu.Visible = false
    MaterialMenu.Visible = not MaterialMenu.Visible
end)

FileBtn.MouseButton1Click:Connect(function()
    MaterialMenu.Visible = false
    FileMenu.Visible = not FileMenu.Visible

    if not FileMenu.Visible then
        return
    end

    ClearMenu(FileMenu)

    if not listfiles or not isfile then
        AddMenuItem(FileMenu, "File browsing unavailable", function() end)
        return
    end

    local success, files = pcall(function()
        return listfiles(".")
    end)

    if not success or type(files) ~= "table" then
        AddMenuItem(FileMenu, "Cannot read files", function() end)
        return
    end

    local found = 0
    table.sort(files)

    for _, path in ipairs(files) do
        if type(path) == "string"
        and path:lower():match("%.obj$")
        and isfile(path) then

            found += 1

            local fileName = path:match("[^/\\]+$") or path

            AddMenuItem(FileMenu, fileName, function()
                FileInput.Text = path
                FileBtn.Text = fileName
                FileMenu.Visible = false
            end)
        end
    end

    if found == 0 then
        AddMenuItem(FileMenu, "No OBJ files found", function() end)
    end
end)

local Mode = "Wire"

local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0, 280, 0, 30)
ModeBtn.Position = UDim2.new(0, 20, 0, 210)
ModeBtn.Text = "MODE: WIREFRAME"
ModeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ModeBtn.TextColor3 = Color3.new(1, 1, 1)
ModeBtn.Parent = Main
Instance.new("UICorner", ModeBtn)

ModeBtn.MouseButton1Click:Connect(function()
    if Mode == "Wire" then
        Mode = "Face"
        ModeBtn.Text = "MODE: FACE"
    elseif Mode == "Face" then
        Mode = "Solid"
        ModeBtn.Text = "MODE: SOLID"
    else
        Mode = "Wire"
        ModeBtn.Text = "MODE: WIREFRAME"
    end
end)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 280, 0, 20)
Status.Position = UDim2.new(0, 20, 0, 245)
Status.Text = "Ready"
Status.TextColor3 = Color3.fromRGB(0, 255, 150)
Status.BackgroundTransparency = 1
Status.Parent = Main

local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(0, 280, 0, 4)
ProgressBG.Position = UDim2.new(0, 20, 0, 270)
ProgressBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ProgressBG.Parent = Main

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBG

local PreviewBtn = Instance.new("TextButton")
PreviewBtn.Size = UDim2.new(0, 135, 0, 40)
PreviewBtn.Position = UDim2.new(0, 20, 0, 290)
PreviewBtn.Text = "PREVIEW"
PreviewBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
PreviewBtn.TextColor3 = Color3.new(1, 1, 1)
PreviewBtn.Parent = Main
Instance.new("UICorner", PreviewBtn)

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 135, 0, 40)
SaveBtn.Position = UDim2.new(0, 165, 0, 290)
SaveBtn.Text = "SAVE .BUILD"
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SaveBtn.TextColor3 = Color3.new(1, 1, 1)
SaveBtn.Parent = Main
Instance.new("UICorner", SaveBtn)

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 280, 0, 35)
ClearBtn.Position = UDim2.new(0, 20, 0, 340)
ClearBtn.Text = "DELETE PREVIEW"
ClearBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ClearBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
ClearBtn.Parent = Main
Instance.new("UICorner", ClearBtn)

-- MOVE MODEL

local MoveTitle = CreateLabel(
    "MOVE MODEL",
    UDim2.new(0, 20, 0, 380),
    UDim2.new(0, 180, 0, 25)
)

local StepInput = Instance.new("TextBox")
StepInput.Size = UDim2.new(0, 85, 0, 25)
StepInput.Position = UDim2.new(0, 215, 0, 380)
StepInput.Text = "1"
StepInput.PlaceholderText = "STEP"
StepInput.TextColor3 = Color3.new(1, 1, 1)
StepInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
StepInput.TextSize = 12
StepInput.Parent = Main
Instance.new("UICorner", StepInput)

local previewFolder = nil
local previewOffset = Vector3.zero

local function CreateMoveButton(text, x, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 88, 0, 32)
    button.Position = UDim2.new(0, x, 0, y)
    button.Text = text
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = Main
    Instance.new("UICorner", button)
    return button
end

local LeftBtn = CreateMoveButton("LEFT", 20, 415)
local UpBtn = CreateMoveButton("UP", 116, 415)
local RightBtn = CreateMoveButton("RIGHT", 212, 415)

local BackBtn = CreateMoveButton("BACK", 20, 455)
local DownBtn = CreateMoveButton("DOWN", 116, 455)
local ForwardBtn = CreateMoveButton("FORWARD", 212, 455)

local function MovePreview(offset)
    if not previewFolder then
        Status.Text = "Preview first!"
        return
    end

    local step = tonumber(StepInput.Text)

    if not step or step <= 0 then
        Status.Text = "Invalid STEP!"
        return
    end

    local movement = offset * step

    for _, obj in ipairs(previewFolder:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CFrame = obj.CFrame + movement
        end
    end

    previewOffset += movement
    Status.Text = "Model moved!"
end

LeftBtn.MouseButton1Click:Connect(function()
    MovePreview(Vector3.new(-1, 0, 0))
end)

RightBtn.MouseButton1Click:Connect(function()
    MovePreview(Vector3.new(1, 0, 0))
end)

UpBtn.MouseButton1Click:Connect(function()
    MovePreview(Vector3.new(0, 1, 0))
end)

DownBtn.MouseButton1Click:Connect(function()
    MovePreview(Vector3.new(0, -1, 0))
end)

ForwardBtn.MouseButton1Click:Connect(function()
    MovePreview(Vector3.new(0, 0, -1))
end)

BackBtn.MouseButton1Click:Connect(function()
    MovePreview(Vector3.new(0, 0, 1))
end)

local function GetMyZone()
    local teamColor = LocalPlayer.TeamColor.Name

    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart")
        and obj.Name:find("Zone")
        and obj.Name:lower():find(teamColor:lower()) then
            return obj
        end
    end

    return nil
end

local function SavePart(cf, sizeV, buildTable)
    local zone = GetMyZone()
    if not zone then return end

    local lCF = zone.CFrame:ToObjectSpace(cf)
    local rx, ry, rz = lCF:ToEulerAnglesXYZ()

    table.insert(buildTable, {
        ["ShowShadow"] = true,
        ["CanCollide"] = true,
        ["Anchored"] = true,
        ["Rotation"] = string.format(
            "%.3f, %.3f, %.3f",
            math.deg(rx),
            math.deg(ry),
            math.deg(rz)
        ),
        ["Position"] = string.format(
            "%.6f, %.6f, %.6f",
            lCF.Position.X,
            lCF.Position.Y,
            lCF.Position.Z
        ),
        ["Size"] = string.format(
            "%.6f, %.6f, %.6f",
            sizeV.X,
            sizeV.Y,
            sizeV.Z
        ),
        ["ID"] = #buildTable + 1,
        ["Transparency"] = 0
    })
end

local function CreatePart(cf, sizeV, isPreview, folder, buildTable)
    if isPreview then
        local p = Instance.new("Part")
        p.Size = sizeV
        p.CFrame = cf
        p.Anchored = true
        p.Color = Color3.fromRGB(150, 150, 150)
        p.CanCollide = false
        p.Parent = folder
    else
        SavePart(cf, sizeV, buildTable)
    end
end

local function GetTriangleRectangle(a, b, c)
    local points = {a, b, c}
    local bestArea = math.huge
    local bestCF = nil
    local bestSize = nil

    for i = 1, 3 do
        local p1 = points[i]
        local p2 = points[i % 3 + 1]
        local p3 = points[(i + 1) % 3 + 1]

        local edge = p2 - p1
        if edge.Magnitude < 0.0001 then
            continue
        end

        local xAxis = edge.Unit
        local cross = edge:Cross(p3 - p1)

        if cross.Magnitude < 0.0001 then
            continue
        end

        local normal = cross.Unit
        local yAxis = normal:Cross(xAxis).Unit

        local minX = math.huge
        local maxX = -math.huge
        local minY = math.huge
        local maxY = -math.huge

        for _, point in ipairs(points) do
            local delta = point - p1
            local x = delta:Dot(xAxis)
            local y = delta:Dot(yAxis)

            minX = math.min(minX, x)
            maxX = math.max(maxX, x)
            minY = math.min(minY, y)
            maxY = math.max(maxY, y)
        end

        local width = maxX - minX
        local height = maxY - minY
        local area = width * height

        if area < bestArea then
            bestArea = area

            local center =
                p1
                + xAxis * ((minX + maxX) / 2)
                + yAxis * ((minY + maxY) / 2)

            bestCF = CFrame.fromMatrix(
                center,
                xAxis,
                yAxis,
                normal
            )

            bestSize = Vector3.new(width, height, 1)
        end
    end

    return bestCF, bestSize
end

local function DrawTriangle(a, b, c, isPreview, folder, buildTable, thick)
    local cf, sizeV = GetTriangleRectangle(a, b, c)

    if not cf or not sizeV then
        return
    end

    sizeV = Vector3.new(
        math.max(sizeV.X, 0.05),
        math.max(sizeV.Y, 0.05),
        thick
    )

    CreatePart(cf, sizeV, isPreview, folder, buildTable)
end

local function ParseFaceIndex(token, vertexCount)
    local indexText = token:match("^([^/]+)")
    local index = tonumber(indexText)

    if not index then
        return nil
    end

    if index < 0 then
        index = vertexCount + index + 1
    end

    if index < 1 or index > vertexCount then
        return nil
    end

    return index
end

local function process(isPreview)
    local zone = GetMyZone()

    if not zone then
        Status.Text = "Zone not found!"
        return
    end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if not root then
        Status.Text = "No Character!"
        return
    end

    local file = FileInput.Text

    if not isfile or not readfile or not writefile then
        Status.Text = "File functions unavailable!"
        return
    end

    if not isfile(file) then
        Status.Text = "File not found!"
        return
    end

    local scale = tonumber(ScaleInput.Text) or 1
    local thick = tonumber(ThickInput.Text) or 0.5

    if scale <= 0 then
        Status.Text = "Invalid scale!"
        return
    end

    if thick <= 0 then
        Status.Text = "Invalid thickness!"
        return
    end

    local spawnPoint = root.Position
        + Vector3.new(0, 20, 0)
        + previewOffset

    if isPreview then
        if previewFolder then
            previewFolder:Destroy()
        end

        previewFolder = Instance.new("Model")
        previewFolder.Name = "OBJ_Preview"
        previewFolder.Parent = workspace
    end

    Status.Text = "Processing..."
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)

    local content = readfile(file)
    local vertices = {}
    local buildParts = {}
    local edgeCache = {}

    local mat = MatInput.Text
    local lines = content:split("\n")
    local totalLines = #lines

    for i, line in ipairs(lines) do
        if i % 300 == 0 then
            task.wait()
            ProgressBar.Size = UDim2.new(i / totalLines, 0, 1, 0)
        end

        line = line:gsub("\r", "")
        local prefix = line:sub(1, 2)

        if prefix == "v " then
            local values = {}

            for value in line:gmatch("%S+") do
                table.insert(values, value)
            end

            local x = tonumber(values[2])
            local y = tonumber(values[3])
            local z = tonumber(values[4])

            if x and y and z then
                table.insert(
                    vertices,
                    Vector3.new(x, y, z) * scale
                )
            end

        elseif prefix == "f " then
            local f_idx = {}

            for token in line:gmatch("%S+") do
                if token ~= "f" then
                    local index = ParseFaceIndex(token, #vertices)

                    if index then
                        table.insert(f_idx, index)
                    end
                end
            end

            if Mode == "Wire" then
                for j = 1, #f_idx do
                    local i1 = f_idx[j]
                    local i2 = f_idx[j % #f_idx + 1]

                    local key = i1 < i2
                        and (i1 .. "_" .. i2)
                        or (i2 .. "_" .. i1)

                    if not edgeCache[key] then
                        edgeCache[key] = true

                        local v1 = vertices[i1]
                        local v2 = vertices[i2]

                        if v1 and v2 then
                            local p1 = v1 + spawnPoint
                            local p2 = v2 + spawnPoint
                            local delta = p2 - p1
                            local dist = delta.Magnitude

                            if dist > 0.0001 then
                                local cf = CFrame.lookAt(
                                    (p1 + p2) / 2,
                                    p2
                                )

                                local sizeV = Vector3.new(
                                    thick,
                                    thick,
                                    dist
                                )

                                CreatePart(
                                    cf,
                                    sizeV,
                                    isPreview,
                                    previewFolder,
                                    buildParts
                                )
                            end
                        end
                    end
                end

            elseif Mode == "Solid" then
                for j = 2, #f_idx - 1 do
                    local triangle = {
                        f_idx[1],
                        f_idx[j],
                        f_idx[j + 1]
                    }

                    for k = 1, 3 do
                        local i1 = triangle[k]
                        local i2 = triangle[k % 3 + 1]

                        local v1 = vertices[i1]
                        local v2 = vertices[i2]

                        if v1 and v2 then
                            local p1 = v1 + spawnPoint
                            local p2 = v2 + spawnPoint
                            local delta = p2 - p1
                            local dist = delta.Magnitude

                            if dist > 0.0001 then
                                local cf = CFrame.lookAt(
                                    (p1 + p2) / 2,
                                    p2
                                )

                                local sizeV = Vector3.new(
                                    0.05,
                                    0.05,
                                    dist
                                )

                                CreatePart(
                                    cf,
                                    sizeV,
                                    isPreview,
                                    previewFolder,
                                    buildParts
                                )
                            end
                        end
                    end
                end

            else
                for j = 2, #f_idx - 1 do
                    local iA = f_idx[1]
                    local iB = f_idx[j]
                    local iC = f_idx[j + 1]

                    local a = vertices[iA]
                    local b = vertices[iB]
                    local c = vertices[iC]

                    if a and b and c then
                        DrawTriangle(
                            a + spawnPoint,
                            b + spawnPoint,
                            c + spawnPoint,
                            isPreview,
                            previewFolder,
                            buildParts,
                            thick
                        )
                    end
                end
            end
        end
    end

    ProgressBar.Size = UDim2.new(1, 0, 1, 0)

    if not isPreview then
        local outputFile = file:gsub("%.[Oo][Bb][Jj]$", "") .. ".build"

        writefile(
            outputFile,
            HttpService:JSONEncode({
                {mat},
                {[mat] = buildParts}
            })
        )

        Status.Text = "Saved successfully!"
    else
        Status.Text = "Preview Ready!"
    end
end

PreviewBtn.MouseButton1Click:Connect(function()
    process(true)
end)

SaveBtn.MouseButton1Click:Connect(function()
    process(false)
end)

ClearBtn.MouseButton1Click:Connect(function()
    if previewFolder then
        previewFolder:Destroy()
        previewFolder = nil
    end

    previewOffset = Vector3.zero
    Status.Text = "Cleared"
end)