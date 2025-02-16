RegisterNetEvent('outfitbag:saveOutfit')
AddEventHandler('outfitbag:saveOutfit', function(outfitName)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)

    if not outfitName or outfitName == "" then
        TriggerClientEvent('ox_lib:notify', src, {
            title = "Error",
            description = "Invalid outfit name!",
            type = "error"
        })
        return
    end

    -- Get ped clothing components from client
    TriggerClientEvent('outfitbag:requestClothingData', src, outfitName, identifier)
end)

RegisterNetEvent('outfitbag:storeOutfit')
AddEventHandler('outfitbag:storeOutfit', function(outfitName, identifier, components)
    local src = source
    local query = 'INSERT INTO outfits (identifier, name, components) VALUES (?, ?, ?)'
    local params = {identifier, outfitName, json.encode(components)}

    exports.oxmysql:insert(query, params, function(id)
        if id then
            TriggerClientEvent('ox_lib:notify', src, {
                title = "Outfit Bag",
                description = "Outfit saved successfully!",
                type = "success"
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = "Error",
                description = "Failed to save outfit.",
                type = "error"
            })
        end
    end)
end)

RegisterNetEvent('outfitbag:applyOutfit')
AddEventHandler('outfitbag:applyOutfit', function(outfitId)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)

    MySQL.query('SELECT components FROM outfits WHERE id = ? AND identifier = ?', {outfitId, identifier}, function(result)
        if result[1] then
            local outfitData = json.decode(result[1].components)
            TriggerClientEvent('outfitbag:applyClothing', src, outfitData)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = "Error",
                description = "Failed to load outfit.",
                type = "error"
            })
        end
    end)
end)

lib.callback.register('outfitbag:getOutfits', function(source)
    local identifier = GetPlayerIdentifier(source, 0)
    local outfits = MySQL.query.await('SELECT * FROM outfits WHERE identifier = ?', {identifier}) or {}

    return outfits
end)
RegisterNetEvent('outfitbag:deleteOutfit')
AddEventHandler('outfitbag:deleteOutfit', function(outfitId)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)

    MySQL.query('DELETE FROM outfits WHERE id = ? AND identifier = ?', {outfitId, identifier}, function(affectedRows)
        if affectedRows and affectedRows > 0 then
            TriggerClientEvent('ox_lib:notify', src, {
                title = "Outfit Bag",
                description = Config.Locale.delete_outfit .. " success!",
                type = "success"
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = "Error",
                description = "Failed to delete outfit.",
                type = "error"
            })
        end
    end)
end)

RegisterNetEvent('outfitbag:removeBagItem')
AddEventHandler('outfitbag:removeBagItem', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.ItemName, 1)
end)
RegisterNetEvent('outfitbag:giveBagItem')
AddEventHandler('outfitbag:giveBagItem', function()
    local src = source
    exports.ox_inventory:AddItem(src, Config.ItemName, 1)
end)


-- VERSION ETC

print("\27[35m[ARMONY] \27[0m\27[36marmony_ob is made by Armony: discord.gg/v2BBSKe9\27[0m")
print("\27[32mThis script is FREE, so if someone sold you this, report them to us.\27[0m")

if GetCurrentResourceName() ~= "armony_outfitbag" then
    print("\27[31m[ERROR] This resource must be named 'armony_outfitbag' to work! Stopping server...\27[0m")
    os.exit() -- Completely shuts down the FiveM server
end
