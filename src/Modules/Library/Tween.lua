--[[
Module made by FromLegoUniverse
Base tweening by Crazyman32
Easing methods by Robert Penner
Modification to work with NevermoreEngine by David Minnerly


---------------Usage:---------------
	First note is that these modules are not like Frame:TweenPosition, the instance is an arguement
	Second note is that they will run THEN continue. This is on purpose. A guide for around that will be below.

CFrames:   Module:TweenCFrame(Instance Instance, String PropertyName,CFrame EndCFrame,Number Time,Enum Easing)
--For MODELS, use "SetPrimaryPartCFrame" to use :SetPrimaryPartCFrame
Vector3s:   Module:TweenVector3(Instance Instance, String PropertyName,Vector3 EndVector3,Number Time,Enum Easing)
Vector3s:   Module:TweenVector2(Instance Instance, String PropertyName,Vector2 EndVector2,Number Time,Enum Easing)
Color3s:   Module:TweenColor3(Instance Instance, String PropertyName,Color3 EndColor3,Number Time,Enum Easing)
Numbers:   Module:TweenNumber(Instance Instance, String PropertyName,Number EndNumber,Number Time,Enum Easing)
UDims:   Module:TweenUDim(Instance Instance, String PropertyName,UDim EndUDim,Number Time,Enum Easing)
UDim2s:   Module:TweenUDim2(Instance Instance, String PropertyName,UDim2 EndUDim2,Number Time,Enum Easing)




Easing Methods:

To index them, you must start with this:
	Module.Ease

Next, you need to decide weather it is In, Out, or InOut

	Module.Ease.In
	Module.Ease.Out
	Module.Ease.InOut

Finally, add the method (Replace the [Insert] with the last step)

	Module.Ease.[Inser].Linear
	Module.Ease.[Inser].Quad
	Module.Ease.[Inser].Cubic
	Module.Ease.[Inser].Quart
	Module.Ease.[Inser].Quint
	Module.Ease.[Inser].Sine
	Module.Ease.[Inser].Expo
	Module.Ease.[Inser].Circ
	Module.Ease.[Inser].Elastic
	Module.Ease.[Inser].Back
	Module.Ease.[Inser].Bounce


Making them act like Frame:TweenPosition()

A basic method is using spawn(). Cooroutines are more recommended.


	local Module = require(game.ServerScriptService.TweenModule)
	spawn(function()
		Module:TweenCFrame(game.Workspace.Weld, "C0",CFrame.new(),5,Module.Ease.In.Cubic)
	end)









--]]

local replicatedStorage = game:GetService("ReplicatedStorage")

local Nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local Easing = Nevermore.LoadLibrary("Easing")












local RenderWait do
	local rs
	if game.Players.LocalPlayer then
		rs = game:GetService("RunService").RenderStepped
	else
		rs = game:GetService("RunService").Stepped
	end
	function RenderWait()
		rs:wait()
	end
end








function CFrameToVectors(CFrame)
	local Data = {0,0,0,0,0,0,0,0,0,0,0,0}
	local i = 0
	for Number in string.gmatch(tostring(CFrame),"[%d%-.eE]+") do
		i = i + 1
		Data[i] = tonumber(Number)
	end
	return Vector3.new(Data[1],Data[2],Data[3]),Vector3.new(Data[4],Data[5],Data[6]),Vector3.new(Data[7],Data[8],Data[9]),Vector3.new(Data[10],Data[11],Data[12])
end

function EncodeVectors(V1,V2,V3,V4)
	local Data = {}
	for Number in string.gmatch(tostring(V1),"[%d%-.eE]+") do
		table.insert(Data,tonumber(Number))
	end
	for Number in string.gmatch(tostring(V2),"[%d%-.eE]+") do
		table.insert(Data,tonumber(Number))
	end
	for Number in string.gmatch(tostring(V3),"[%d%-.eE]+") do
		table.insert(Data,tonumber(Number))
	end
	for Number in string.gmatch(tostring(V4),"[%d%-.eE]+") do
		table.insert(Data,tonumber(Number))
	end
	return CFrame.new(unpack(Data))
end

function CFrameLerp(OC,CFrame,LerpNum)
	local V1,V2,V3,V4 = CFrameToVectors(CFrame)
	local OV1,OV2,OV3,OV4 = CFrameToVectors(OC)
	local V1L,V2L,V3L,V4L = OV1:lerp(V1,LerpNum),OV2:lerp(V2,LerpNum),OV3:lerp(V3,LerpNum),OV4:lerp(V4,LerpNum)
	return EncodeVectors(V1L,V2L,V3L,V4L)
end








function Tween(easingFunc, duration, callbackFunc)
	local tick = tick
	local start = tick()
	local dur = 0
	local ratio = 0
	local RW = RenderWait
	while (dur < duration) do
		ratio = easingFunc(dur, 0, 1, duration)
		dur = (tick() - start)
		callbackFunc(ratio)
		RW()
	end
	callbackFunc(1)
end




API = {}

function API:TweenCFrame(Ins,Property, cframeEnd, duration, easingFunc)
	local start
	if Ins.className == "Model" and Property == "SetPrimaryPartCFrame" then
		if Ins.PrimaryPart then
			start = Ins:GetPrimaryPartCFrame()
		else
			print("To tween a model, you need a PrimaryPart")
			return
		end
	else
		start = Ins[Property]
	end
	local cur = start
	local function Callback(ratio)
		cur = CFrameLerp(start,cframeEnd,ratio)
		if Ins.className == "Model" and Property == "SetPrimaryPartCFrame" then
			Ins:SetPrimaryPartCFrame(cur)
		else
			Ins[Property] = cur
		end
	end
	Tween(easingFunc, duration, Callback)
end

function API:TweenVector3(Ins,Property, posEnd, duration, easingFunc)
	local start = Ins[Property]
	local cur = start
	local function Callback(ratio)
		cur = start:lerp(posEnd,ratio)
		Ins[Property] = cur
	end
	Tween(easingFunc, duration, Callback)
end

function API:TweenColor3(Ins,Property, ColorEnd, duration, easingFunc)
	local start = Ins[Property]
	local cur = start
	local DifR,DifG,DifB = ColorEnd.r - start.r,ColorEnd.g - start.g,ColorEnd.b - start.b
	local function Callback(ratio)
		cur = Color3.new(start.r + (DifR*ratio),start.g + (DifG*ratio),start.b + (DifB*ratio))
		Ins[Property] = cur
	end
	Tween(easingFunc, duration, Callback)
end

function API:TweenNumber(Ins,Property, End, duration, easingFunc)
	local start = Ins[Property]
	local cur = start
	local Dif = End - start
	local function Callback(ratio)
		cur = start + (Dif*ratio)
		Ins[Property] = cur
	end
	Tween(easingFunc, duration, Callback)
end

function API:TweenVector2(Ins,Property, End, duration, easingFunc)
	local start = Ins[Property]
	local cur = start
	local Dif = End - start
	local function Callback(ratio)
		cur = start + (Dif*ratio)
		Ins[Property] = cur
	end
	Tween(easingFunc, duration, Callback)
end

function API:TweenUDim2(Ins,Property, End, duration, easingFunc)
	local start = Ins[Property]
	local cur = start
	local DifX1,DifX2,DifY1,DifY2 = End.X.Scale - start.X.Scale,End.X.Offset - start.X.Offset,End.Y.Scale - start.Y.Scale,End.Y.Offset - start.Y.Offset
	local function Callback(ratio)
		cur = UDim2.new(start.X.Scale + (DifX1*ratio),start.X.Offset + (DifX2*ratio),start.Y.Scale + (DifY1*ratio),start.Y.Offset + (DifY2*ratio))
		Ins[Property] = cur
	end
	Tween(easingFunc, duration, Callback)
end

function API:TweenUDim(Ins,Property, End, duration, easingFunc)
	local start = Ins[Property]
	local cur = start
	local Dif1,Dif2 = End.Scale - start.Scale,End.Offset - start.Offset
	local function Callback(ratio)
		cur = UDim2.new(start.Scale + (Dif1*ratio),start.Offset + (Dif2*ratio))
		Ins[Property] = cur
	end
	Tween(easingFunc, duration, Callback)
end


--Rest is by Crazyman32 with slight modifications, for "easing" methods


API.Ease = (function()
	local In, Out, InOut = {}, {}, {}
	for name,func in pairs(Easing) do	-- "Parse" out the easing functions:
		if (name == "linear") then
			In["Linear"] = func
			Out["Linear"] = func
			InOut["Linear"] = func
		else
			local t,n = name:match("^(inOut)(.+)")
			if (not t or not n) then t,n = name:match("^(in)(.+)") end
			if (not t or not n) then t,n = name:match("^(out)(.+)") end
			if (n) then
				n = (n:sub(1, 1):upper() .. n:sub(2):lower())
			end
			if (t == "inOut") then
				InOut[n] = func
			elseif (t == "in") then
				In[n] = func
			elseif (t == "out") then
				Out[n] = func
			end
		end
	end
	return {In=In,Out=Out,InOut=InOut}
end)();


return API
