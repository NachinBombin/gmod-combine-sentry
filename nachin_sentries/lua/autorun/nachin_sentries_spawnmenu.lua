-- nachin_sentries/lua/autorun/nachin_sentries_spawnmenu.lua
-- Registers all sentry entities in the spawn menu

if CLIENT then
    hook.Add("PopulateEntities", "NachinSentries", function()
        list.Set("SpawnableEntities", "nachin_sentry_mg42", {
            PrintName = "[SENTRY] MG 42",
            ClassName = "nachin_sentry_mg42",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_mg42_alt", {
            PrintName = "[SENTRY] MG 42 Alt",
            ClassName = "nachin_sentry_mg42_alt",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_mg34", {
            PrintName = "[SENTRY] MG 34",
            ClassName = "nachin_sentry_mg34",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_mg34_alt", {
            PrintName = "[SENTRY] MG 34 Alt",
            ClassName = "nachin_sentry_mg34_alt",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_mg3", {
            PrintName = "[SENTRY] MG 3",
            ClassName = "nachin_sentry_mg3",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_m240b", {
            PrintName = "[SENTRY] M240B",
            ClassName = "nachin_sentry_m240b",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_m60", {
            PrintName = "[SENTRY] M60",
            ClassName = "nachin_sentry_m60",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_m2", {
            PrintName = "[SENTRY] M2HB",
            ClassName = "nachin_sentry_m2",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_m2a1", {
            PrintName = "[SENTRY] M2A1",
            ClassName = "nachin_sentry_m2a1",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_m2_low", {
            PrintName = "[SENTRY] M2 Low Mount",
            ClassName = "nachin_sentry_m2_low",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_m1919", {
            PrintName = "[SENTRY] M1919",
            ClassName = "nachin_sentry_m1919",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_dshk", {
            PrintName = "[SENTRY] DShK",
            ClassName = "nachin_sentry_dshk",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_kord", {
            PrintName = "[SENTRY] KORD",
            ClassName = "nachin_sentry_kord",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_fnmag", {
            PrintName = "[SENTRY] FN MAG",
            ClassName = "nachin_sentry_fnmag",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_bar", {
            PrintName = "[SENTRY] BAR",
            ClassName = "nachin_sentry_bar",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_bren", {
            PrintName = "[SENTRY] Bren",
            ClassName = "nachin_sentry_bren",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_rpk", {
            PrintName = "[SENTRY] RPK",
            ClassName = "nachin_sentry_rpk",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_vickers", {
            PrintName = "[SENTRY] Vickers",
            ClassName = "nachin_sentry_vickers",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_mg15", {
            PrintName = "[SENTRY] MG 15",
            ClassName = "nachin_sentry_mg15",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_mg15_alt", {
            PrintName = "[SENTRY] MG 15 Alt",
            ClassName = "nachin_sentry_mg15_alt",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_mg81z", {
            PrintName = "[SENTRY] MG 81Z",
            ClassName = "nachin_sentry_mg81z",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_gau19", {
            PrintName = "[SENTRY] GAU-19",
            ClassName = "nachin_sentry_gau19",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_m5", {
            PrintName = "[SENTRY] M5 Quad .50",
            ClassName = "nachin_sentry_m5",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_m134", {
            PrintName = "[SENTRY] M134 Minigun",
            ClassName = "nachin_sentry_m134",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_m61", {
            PrintName = "[SENTRY] M61 Vulcan",
            ClassName = "nachin_sentry_m61",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_phalanx", {
            PrintName = "[SENTRY] Phalanx CIWS",
            ClassName = "nachin_sentry_phalanx",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_flak38", {
            PrintName = "[SENTRY] Flak 38",
            ClassName = "nachin_sentry_flak38",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_flakvierling38", {
            PrintName = "[SENTRY] Flakvierling 38",
            ClassName = "nachin_sentry_flakvierling38",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_flak36", {
            PrintName = "[SENTRY] Flak 36 88mm",
            ClassName = "nachin_sentry_flak36",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_flak37", {
            PrintName = "[SENTRY] Flak 37",
            ClassName = "nachin_sentry_flak37",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_flak40z", {
            PrintName = "[SENTRY] Flak 40Z",
            ClassName = "nachin_sentry_flak40z",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_breda35", {
            PrintName = "[SENTRY] Breda 35",
            ClassName = "nachin_sentry_breda35",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_bofors", {
            PrintName = "[SENTRY] Bofors 40mm",
            ClassName = "nachin_sentry_bofors",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_artemis30", {
            PrintName = "[SENTRY] Artemis 30",
            ClassName = "nachin_sentry_artemis30",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_zpu4_1931", {
            PrintName = "[SENTRY] ZPU-4 1931",
            ClassName = "nachin_sentry_zpu4_1931",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_zpu4_1949", {
            PrintName = "[SENTRY] ZPU-4 1949",
            ClassName = "nachin_sentry_zpu4_1949",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_zsu23", {
            PrintName = "[SENTRY] ZSU-23",
            ClassName = "nachin_sentry_zsu23",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_pak38", {
            PrintName = "[SENTRY] PaK 38",
            ClassName = "nachin_sentry_pak38",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_pak40", {
            PrintName = "[SENTRY] PaK 40",
            ClassName = "nachin_sentry_pak40",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_pak43", {
            PrintName = "[SENTRY] PaK 43",
            ClassName = "nachin_sentry_pak43",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_zis2", {
            PrintName = "[SENTRY] ZiS-2",
            ClassName = "nachin_sentry_zis2",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_zis3", {
            PrintName = "[SENTRY] ZiS-3",
            ClassName = "nachin_sentry_zis3",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_6pdr", {
            PrintName = "[SENTRY] 6-Pdr AT",
            ClassName = "nachin_sentry_6pdr",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_kwk", {
            PrintName = "[SENTRY] KwK AT",
            ClassName = "nachin_sentry_kwk",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_lefh18", {
            PrintName = "[SENTRY] leFH 18",
            ClassName = "nachin_sentry_lefh18",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_2a65", {
            PrintName = "[SENTRY] 2A65 Howitzer",
            ClassName = "nachin_sentry_2a65",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_gpf155", {
            PrintName = "[SENTRY] GPF 155mm",
            ClassName = "nachin_sentry_gpf155",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_m777", {
            PrintName = "[SENTRY] M777",
            ClassName = "nachin_sentry_m777",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_grw34", {
            PrintName = "[SENTRY] GrW 34 Mortar",
            ClassName = "nachin_sentry_grw34",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_m1mortar", {
            PrintName = "[SENTRY] M1 Mortar",
            ClassName = "nachin_sentry_m1mortar",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_3inchmortar", {
            PrintName = "[SENTRY] 3-inch Mortar",
            ClassName = "nachin_sentry_3inchmortar",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_pm41", {
            PrintName = "[SENTRY] PM-41 Mortar",
            ClassName = "nachin_sentry_pm41",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
        list.Set("SpawnableEntities", "nachin_sentry_nebelwerfer", {
            PrintName = "[SENTRY] Nebelwerfer",
            ClassName = "nachin_sentry_nebelwerfer",
            Category  = "Nachin Sentries",
            NPC       = false,
        })
    end)
end