require "ISUI/Maps/ISMiniMap"
require "ISUI/Maps/ISMapDefinitions"

local OPTION_NAME = "ShowStreetNames"
local SETTING_KEY = "MiniMap.ShowStreetNames"
local INIT_KEY = "MiniMap.StreetNamesOnMini.Initialized"

local function loadPreference()
    local settings = WorldMapSettings.getInstance()
    if not settings:getBoolean(INIT_KEY) then
        settings:setBoolean(INIT_KEY, true)
        settings:setBoolean(SETTING_KEY, true)
        settings:save()
        return true
    end
    return settings:getBoolean(SETTING_KEY)
end

local function savePreference(value)
    local settings = WorldMapSettings.getInstance()
    settings:setBoolean(INIT_KEY, true)
    settings:setBoolean(SETTING_KEY, value)
    settings:save()
end

local original_getVisibleOptions = ISMiniMapOptionsPanel.getVisibleOptions
function ISMiniMapOptionsPanel:getVisibleOptions()
    local result = original_getVisibleOptions(self)
    if not self.showAllOptions then
        for i = 1, self.map.mapAPI:getOptionCount() do
            local option = self.map.mapAPI:getOptionByIndex(i - 1)
            if option:getName() == OPTION_NAME then
                table.insert(result, option)
                break
            end
        end
    end
    return result
end

local original_onTickBox = ISMiniMapOptionsPanel.onTickBox
function ISMiniMapOptionsPanel:onTickBox(index, selected, option)
    original_onTickBox(self, index, selected, option)
    if option:getName() == OPTION_NAME and self.map and self.map.playerNum == 0 then
        savePreference(option:getValue())
    end
end

local original_InitPlayer = ISMiniMap.InitPlayer
function ISMiniMap.InitPlayer(playerNum)
    local MINIMAP = original_InitPlayer(playerNum)
    MapUtils.initDefaultStreetData(MINIMAP.inner)
    if playerNum == 0 then
        MINIMAP.inner.mapAPI:setBoolean(OPTION_NAME, loadPreference())
    end
    return MINIMAP
end
