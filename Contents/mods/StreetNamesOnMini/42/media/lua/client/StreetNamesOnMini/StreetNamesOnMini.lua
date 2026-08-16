require "ISUI/Maps/ISMiniMap"
require "ISUI/Maps/ISMapDefinitions"

local original_getVisibleOptions = ISMiniMapOptionsPanel.getVisibleOptions
function ISMiniMapOptionsPanel:getVisibleOptions()
    local result = original_getVisibleOptions(self)
    if not self.showAllOptions then
        for i = 1, self.map.mapAPI:getOptionCount() do
            local option = self.map.mapAPI:getOptionByIndex(i - 1)
            if option:getName() == "ShowStreetNames" then
                table.insert(result, option)
                break
            end
        end
    end
    return result
end

local original_InitPlayer = ISMiniMap.InitPlayer
function ISMiniMap.InitPlayer(playerNum)
    local MINIMAP = original_InitPlayer(playerNum)
    MapUtils.initDefaultStreetData(MINIMAP.inner)
    return MINIMAP
end

local original_saveSettings = ISMiniMapOuter.saveSettings
function ISMiniMapOuter:saveSettings()
    original_saveSettings(self)
    if self.playerNum ~= 0 then return end
    local settings = WorldMapSettings.getInstance()
    settings:setBoolean("MiniMap.ShowStreetNames", self.inner.mapAPI:getBoolean("ShowStreetNames"))
    settings:save()
end

local original_restoreSettings = ISMiniMapOuter.restoreSettings
function ISMiniMapOuter:restoreSettings()
    original_restoreSettings(self)
    if self.playerNum ~= 0 then return end
    local settings = WorldMapSettings.getInstance()
    if settings:getFileVersion() ~= 1 then
        self.inner.mapAPI:setBoolean("ShowStreetNames", true)
        return
    end
    self.inner.mapAPI:setBoolean("ShowStreetNames", settings:getBoolean("MiniMap.ShowStreetNames"))
end
