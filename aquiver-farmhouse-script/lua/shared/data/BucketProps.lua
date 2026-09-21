local eBucketContent = require("lua.shared.enums.eBucketContent")

---@type table<eBucketContent, string>
local BucketProps = {
    [eBucketContent.EMPTY] = "",
    [eBucketContent.WATER] = "avp_animal_farm_prop_bucket_fill_water",
    [eBucketContent.CHICKEN_FEED] = "avp_animal_farm_prop_bucket_fill_chicken",
    [eBucketContent.COW_FEED] = "avp_animal_farm_prop_bucket_fill_cow",
    [eBucketContent.GRAIN_MIX_FEED] = "avp_animal_farm_prop_bucket_fill_grainmix",
    [eBucketContent.PIG_FEED] = "avp_animal_farm_prop_bucket_fill_pig",
    [eBucketContent.PROTEIN_FEED] = "avp_animal_farm_prop_bucket_fill_protein",
    [eBucketContent.UNIVERSAL_FEED] = "avp_animal_farm_prop_bucket_fill_universal"
}

return BucketProps
