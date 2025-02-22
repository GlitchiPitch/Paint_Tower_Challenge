export type LobbyType = Folder & {
    Pads: Folder & {
        Red: Model,
        Blue: Model,
    }
}

local Lobby: LobbyType

local Instances = {
    Lobby = Lobby,
}

return Instances