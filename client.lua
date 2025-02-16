local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target
local bagObj = nil
local bagEquipped = false
local bagModel = GetHashKey('p_michael_backpack_s')

RegisterCommand("ob", function()
    TriggerEvent("outfitbag:equip")
end)

local function PickupBag()
    if bagObj and not bagEquipped then
        local playerPed = PlayerPedId()

        -- Caricare l'animazione "pickup_low"
        RequestAnimDict("pickup_object")
        while not HasAnimDictLoaded("pickup_object") do
            Wait(100)
        end

        -- Eseguire l'animazione
        TaskPlayAnim(playerPed, "pickup_object", "pickup_low", 8.0, -8.0, 1500, 49, 0, false, false, false)
        Wait(1500) -- Attendere che l'animazione finisca

        -- Eliminare l'oggetto e restituire l'item
        DeleteObject(bagObj)
        bagObj = nil
        TriggerServerEvent('outfitbag:giveBagItem')

        -- Notifica di conferma
        lib.notify({
            title = "Outfit Bag",
            description = "You picked up your outfit bag!",
            type = "success"
        })
    end
end


local function PutOnBag()
    local playerPed = PlayerPedId()

    if bagEquipped then
        lib.notify({
            title = "Error",
            description = "You already have a bag equipped!",
            type = "error"
        })
        return
    end

    local x, y, z = table.unpack(GetEntityCoords(playerPed))

    -- Ensure model is requested and loaded
    RequestModel(bagModel)
    while not HasModelLoaded(bagModel) do Wait(100) end

    if not HasModelLoaded(bagModel) then
        lib.notify({
            title = "Error",
            description = "Bag model failed to load!",
            type = "error"
        })
        return
    end

    -- Create and attach the bag
    bagObj = CreateObjectNoOffset(bagModel, x, y, z, true, true, false)
    AttachEntityToEntity(bagObj, playerPed, GetPedBoneIndex(playerPed, 24818), 
        0.15, -0.10, -0.05,  -- Position adjustment
        0.0, 90.0, 180.0,    -- Rotation
        true, true, false, true, 1, true)

    bagEquipped = true

    lib.showTextUI("Press [E] to place the bag")
-- When placing the bag, remove 1 from inventory

    -- Handling bag placement
    CreateThread(function()
        while bagEquipped do
            Wait(0)
            if IsControlJustReleased(0, 38) then
                ClearPedTasks(playerPed)
                ResetPedMovementClipset(playerPed, 0) -- Reset walk style
                DetachEntity(bagObj, true, true)

                -- Adjust bag placement on the ground
                local bagCoords = GetEntityCoords(bagObj)
                SetEntityCoords(bagObj, bagCoords.x, bagCoords.y, bagCoords.z - 0.98, false, false, false, true)
                Wait(500)
                PlaceObjectOnGroundProperly(bagObj)
                TriggerServerEvent('outfitbag:removeBagItem')
                RequestAnimDict("pickup_object")
                while not HasAnimDictLoaded("pickup_object") do
                    Wait(100)
                end
        
                -- Eseguire l'animazione
                TaskPlayAnim(playerPed, "pickup_object", "pickup_low", 8.0, -8.0, 1500, 49, 0, false, false, false)
                Wait(1500) -- Attendere che l'animazione finisca
        
                FreezeEntityPosition(bagObj, true)

                lib.hideTextUI()

                -- Add interaction zone
                exports.ox_target:addSphereZone({
                    coords = GetEntityCoords(bagObj),
                    radius = 1.0,
                    options = {
                        {
                            label = Config.Locale.show_outfits,
                            icon = "fas fa-tshirt",
                            onSelect = function()
                                OpenOutfitBagMenu()
                            end
                        },
                        {
                            label = "Pickup Bag",
                            icon = "fas fa-hand-paper",
                            onSelect = function()
                                PickupBag()
                            end
                        }
                    }
                })
                

                bagEquipped = false -- Mark bag as placed
                break
            end
        end
    end)
end

local function RemoveBag()
    if DoesEntityExist(bagObj) then
        DeleteObject(bagObj)
        bagObj = nil
    end
    SetModelAsNoLongerNeeded(bagModel)
    bagEquipped = false
end

RegisterNetEvent('outfitbag:equip')
AddEventHandler('outfitbag:equip', function()
    local playerPed = PlayerPedId()
    local hasItem = ox_inventory:Search('count', Config.ItemName)

    if hasItem > 0 and not bagEquipped then
        PutOnBag()
    elseif hasItem > 0 and bagEquipped then
        RemoveBag()
    else
        lib.notify({
            title = "Error",
            description = Config.Locale.no_bag,
            type = "error"
        })
    end
end)
RegisterNetEvent('outfitbag:deleteOutfit')
AddEventHandler('outfitbag:deleteOutfit', function(outfitId)
    TriggerServerEvent('outfitbag:deleteOutfit', outfitId)
end)
function OpenOutfitBagMenu()
    local playerId = GetPlayerServerId(PlayerId())

    lib.callback('outfitbag:getOutfits', false, function(outfits)
        if not outfits or type(outfits) ~= "table" then
            outfits = {}
        end

        local options = {
            {
                title = Config.Locale.wear_outfit,
                icon = "fas fa-tshirt",
                event = "outfitbag:openWearMenu"
            },
            {
                title = Config.Locale.save_outfit,
                icon = "fas fa-save",
                event = "outfitbag:saveOutfit"
            },
            {
                title = Config.Locale.delete_outfit,
                icon = "fas fa-trash",
                event = "outfitbag:openDeleteMenu"
            }
        }

        lib.registerContext({
            id = "outfitbag_main_menu",
            title = "Outfit Bag",
            options = options
        })

        lib.showContext("outfitbag_main_menu")
    end, playerId)
end

RegisterNetEvent("outfitbag:openWearMenu")
AddEventHandler("outfitbag:openWearMenu", function()
    local playerId = GetPlayerServerId(PlayerId())

    lib.callback("outfitbag:getOutfits", false, function(outfits)
        local options = {}

        for _, outfit in pairs(outfits) do
            table.insert(options, {
                title = outfit.name,
                event = "outfitbag:wearOutfit",
                args = outfit.id
            })
        end

        lib.registerContext({
            id = "outfitbag_wear_menu",
            title = Config.Locale.wear_outfit,
            menu = "outfitbag_main_menu",
            options = options
        })

        lib.showContext("outfitbag_wear_menu")
    end, playerId)
end)

RegisterNetEvent("outfitbag:openDeleteMenu")
AddEventHandler("outfitbag:openDeleteMenu", function()
    local playerId = GetPlayerServerId(PlayerId())

    lib.callback("outfitbag:getOutfits", false, function(outfits)
        local options = {}

        for _, outfit in pairs(outfits) do
            table.insert(options, {
                title = "❌ " .. outfit.name,
                event = "outfitbag:confirmDeleteOutfit",
                args = outfit.id
            })
        end

        lib.registerContext({
            id = "outfitbag_delete_menu",
            title = Config.Locale.delete_outfit,
            menu = "outfitbag_main_menu",
            options = options
        })

        lib.showContext("outfitbag_delete_menu")
    end, playerId)
end)

RegisterNetEvent("outfitbag:confirmDeleteOutfit")
AddEventHandler("outfitbag:confirmDeleteOutfit", function(outfitId)
    local confirm = lib.alertDialog({
        header = Config.Locale.delete_outfit,
        content = Config.Locale.confirm_delete,
        centered = true,
        cancel = true
    })

    if confirm == "confirm" then
        TriggerServerEvent("outfitbag:deleteOutfit", outfitId)
    end
end)


RegisterNetEvent('outfitbag:saveOutfit')
AddEventHandler('outfitbag:saveOutfit', function()
    local input = lib.inputDialog(Config.Locale.save_outfit, {"Outfit Name"})
    if input then
        TriggerServerEvent('outfitbag:saveOutfit', input[1])
    end
end)

RegisterNetEvent('outfitbag:wearOutfit')
AddEventHandler('outfitbag:wearOutfit', function(outfitId)
    local playerPed = PlayerPedId()

    -- Play outfit change animation
    RequestAnimDict("clothingshirt")
    while not HasAnimDictLoaded("clothingshirt") do
        Wait(100)
    end

    TaskPlayAnim(playerPed, "clothingshirt", "try_shirt_positive_a", 8.0, -8.0, 5000, 49, 0, false, false, false)
    Wait(5000) -- Wait for animation to finish

    TriggerServerEvent('outfitbag:applyOutfit', outfitId)
end)

RegisterNetEvent('outfitbag:requestClothingData')
AddEventHandler('outfitbag:requestClothingData', function(outfitName, identifier)
    local playerPed = PlayerPedId()
    local components = {}

    -- Save all clothing components
    for i = 1, 11 do
        local drawable = GetPedDrawableVariation(playerPed, i)
        local texture = GetPedTextureVariation(playerPed, i)
        local palette = GetPedPaletteVariation(playerPed, i)

        components[i] = {drawable = drawable, texture = texture, palette = palette}
    end

    -- Send back to server
    TriggerServerEvent('outfitbag:storeOutfit', outfitName, identifier, components)
end)

RegisterNetEvent('outfitbag:applyClothing')
AddEventHandler('outfitbag:applyClothing', function(components)
    local playerPed = PlayerPedId()

    for i, data in pairs(components) do
        SetPedComponentVariation(playerPed, i, data.drawable, data.texture, data.palette)
    end

    lib.notify({
        title = "Outfit",
        description = Config.Locale.weared_outfit,
        type = "success"
    })
end)
