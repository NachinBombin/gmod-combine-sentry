-- sentry_register.lua
-- Registers all 48 auto-sentry re-skins + original combine_sentry
-- into the spawnmenu under "Combine Sentries".
-- This file is server-side autorun; the spawn menu entries are
-- already handled by each entity's Spawnable/Category fields.
-- This file exists as a convenience index.

if not SERVER then return end

local SENTRIES = {
    -- Original
    "combine_sentry",
    -- Rocket / AT / Artillery
    "sentry_nebelwerfer",
    "sentry_m1mortar",
    "sentry_3inchmortar",
    "sentry_grw34",
    "sentry_pm41",
    "sentry_pak38",
    "sentry_pak40",
    "sentry_pak43",
    "sentry_kwk",
    "sentry_zis2",
    "sentry_zis3",
    "sentry_6pdr",
    "sentry_m2a1",
    "sentry_m5",
    "sentry_m777",
    "sentry_gpf155",
    "sentry_lefh18",
    "sentry_2a65",
    -- Machine Guns / HMGs
    "sentry_m2hmg",
    "sentry_m2low",
    "sentry_m240b",
    "sentry_m60mg",
    "sentry_m1919",
    "sentry_mg34",
    "sentry_mg34alt",
    "sentry_mg42",
    "sentry_mg42alt",
    "sentry_mg15",
    "sentry_mg15alt",
    "sentry_mg3",
    "sentry_dshk",
    "sentry_kord",
    "sentry_rpk",
    "sentry_bren",
    "sentry_bar",
    "sentry_vickers",
    "sentry_fnmag",
    "sentry_breda35",
    -- Rotary / Gatling
    "sentry_m134",
    "sentry_m61",
    "sentry_gau19",
    "sentry_mg81z",
    -- AA / Autocannon
    "sentry_bofors",
    "sentry_flak36",
    "sentry_flak37",
    "sentry_flak38",
    "sentry_flak40z",
    "sentry_flakvierling",
    "sentry_artemis30",
    "sentry_phalanx",
    "sentry_zsu23",
    "sentry_zpu4_1931",
    "sentry_zpu4_1949",
}

for _, classname in ipairs(SENTRIES) do
    if not scripted_ents.GetStored(classname) then
        ErrorNoHalt("[Combine Sentries] Missing entity: " .. classname .. "\n")
    end
end

print("[Combine Sentries] Loaded " .. #SENTRIES .. " sentries.")
