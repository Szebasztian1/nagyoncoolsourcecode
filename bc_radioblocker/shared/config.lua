return {
    model = 'prop_cs_hand_radio',

    itemName = 'radiozavaro',
    breakerItemName = 'radiochip',


    place_duration = 2000,
    place_animation = {
        dict = 'anim@heists@narcotics@trash',
        clip = 'pickup',
    },
    break_duration = 5000,
    break_animation = {
        dict = 'melee@large_wpn@streamed_core',
        clip = 'ground_attack_0',
    },

    allowedJobs = { "police", "fbiuj", "uss", "irs", "atf", "navi", "fbi", "detective", "guardarmy", "usms", "servicess" },

    default_radius = 50,
    min_radius = 50,
    max_radius = 300,

    despawn_time = 60 * 40 * 1000, -- 40 minutes
}
