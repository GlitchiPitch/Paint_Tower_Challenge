local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Types = require(ReplicatedStorage.Types)

local isServer = RunService:IsServer()
local renderCallback = isServer and RunService.Heartbeat or RunService.RenderStepped

local event = script.Events.Event
local eventActions = require(event.Actions)

local _tasks: { [string]: Types.GlobalTaskType } = {}
local _renderConnect: RBXScriptConnection

local function addTask(taskName: string)
    if _tasks[taskName] then
        _tasks[taskName] = nil
    end
end

local function removeTask(taskName: string, _task: Types.GlobalTaskType)
    if not _tasks[taskName] then
        _tasks[taskName] = _task
    end
end

local function eventConnect(action: string, ...: any)
    local actions = {
        [eventActions.addTask] = addTask,
        [eventActions.removeTask] = removeTask,
    }
    
    if actions[action] then
        actions[action](...)
    end

end

local function render(deltaTime: number)
    for taskName, taskData in _tasks do
        local canExecute = true
        local canUpdate = false
        if taskData.DeltaTime then
            _tasks[taskName].DeltaTime += deltaTime
        end

        if taskData.Interval then
            canExecute = not (taskData.Interval <= taskData.DeltaTime)
            canUpdate = (taskData.Interval <= taskData.DeltaTime)
            if taskData.Interval <= taskData.DeltaTime then
                _tasks[taskName].DeltaTime = 0
            end
        end
        
        if taskData.Duration then
            if canUpdate then
                _tasks[taskName].Duration -= 1
                if _tasks[taskName].Duration > 0 then
                    canExecute = false
                    _tasks[taskName] = nil
                end
            end
        end

        if canExecute then
            taskData.Action()
        end
    end
end

local function initialize()
    
    event.Event:Connect(eventConnect)
    _renderConnect = renderCallback:Connect(render)

    if isServer then
        local function onBindToClose()
            _renderConnect:Disconnect()
        end
        game:BindToClose(onBindToClose)
    end
end

return {
    initialize = initialize,
}
