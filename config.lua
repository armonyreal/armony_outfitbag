Config = {}

-- Item settings
Config.ItemName = "outfitbag"

-- Localization
Config.Languages = {
    ["en"] = {
        save_outfit = "Save New Outfit",
        show_outfits = "Open The Bag",
        no_bag = "You don't have an Outfit Bag!",
        wear_outfit = "Wear an outfit",
        weared_outfit = "You wore the outfit!",
        delete_outfit = "Delete Outfit",
        confirm_delete = "Are you sure you want to delete this outfit?"
    },
    ["fr"] = {
        save_outfit = "Sauvegarder une nouvelle tenue",
        show_outfits = "Ouvrir le sac",
        no_bag = "Vous n'avez pas de sac à vêtements!",
        wear_outfit = "Vous portez maintenant la tenue!",
        weared_outfit = "You wore the outfit!",
        delete_outfit = "Supprimer la tenue",
        confirm_delete = "Êtes-vous sûr de vouloir supprimer cette tenue?"
    },
    ["es"] = {
        save_outfit = "Guardar Nuevo Atuendo",
        show_outfits = "Abrir la Bolsa",
        no_bag = "¡No tienes una bolsa de atuendos!",
        wear_outfit = "¡Ahora estás usando el atuendo!",
        weared_outfit = "You wore the outfit!",
        delete_outfit = "Eliminar Atuendo",
        confirm_delete = "¿Estás seguro de que quieres eliminar este atuendo?"
    }
}

-- Set default language
Config.Locale = Config.Languages["en"]
