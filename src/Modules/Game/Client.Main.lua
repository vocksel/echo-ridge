-- Name: Client.Main
-- ClassName: LocalScript

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local nevermore = require(replicatedStorage:WaitForChild("NevermoreEngine"))
local getRemoteEvent = nevermore.GetRemoteEvent
local import = nevermore.LoadLibrary

local BindableAction    = import("BindableAction")
local ClientWaveRoad    = import("ClientWaveRoad")
local ClientWaveStation = import("ClientWaveStation")
local InteractionGui    = import("InteractionGui")

local player = players.LocalPlayer
local playerGui = player.PlayerGui


--------------------------------------------------------------------------------
-- Wave World Interaction
--------------------------------------------------------------------------------

local function handleWaveStation()
  local skyWaveModel     = replicatedStorage.SkyWave
  local waveStationModel = workspace.SectionBottomLeft.WaveStation
  local skyWave          = ClientWaveRoad.new(skyWaveModel)
  local waveStation      = ClientWaveStation.new(waveStationModel)
  local skyWaveEntered   = getRemoteEvent("SkyWaveEntered")

  local popupMsg = "Press [E] to access the Wave World"
  local popupGui = InteractionGui.new(playerGui, popupMsg)

  local function interact(_, inputState)
    if inputState == Enum.UserInputState.End then return end
    skyWave:Show()
    skyWaveEntered:FireServer()
  end

  local useWaveStation = BindableAction.new("UseWaveStation", {Enum.KeyCode.E})
  useWaveStation:BindFunction("Primary", interact)

  local function detectOutOfBounds(part)
    local inBounds = skyWave:PartWithinBoundary(part)

    if not inBounds then
      skyWave:Hide()
    end
  end

  local function enableInteraction()
    popupGui:Show()
    useWaveStation:Bind()
  end

  local function disableInteraction()
    popupGui:Hide()
    useWaveStation:Unbind()
  end

  local function setInteractionState(rootPart)
    local inRange = waveStation:PartInRange(rootPart, 10)
    local actionIsBound = useWaveStation:IsBound()

    -- If an action is bound or unbound twice, an error occurs. To compensate
    -- for this, we use a flip-flop style logic gate to toggle between bound and
    -- unbound.

    if inRange and not actionIsBound then
      enableInteraction()
    elseif not inRange and actionIsBound then
      disableInteraction()
    end
  end

  local function runInteractionLoop()
    while true do
      local rootPart = player.Character:FindFirstChild("HumanoidRootPart")

      if rootPart then
        detectOutOfBounds(rootPart)
        setInteractionState(rootPart)
      end

      wait(.25) -- Abritrary delay. It feels good while playtesting.
    end
  end

  coroutine.wrap(runInteractionLoop)()
end


--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

local function initialize()
  nevermore.ClearSplash()
  handleWaveStation()
end

initialize()
