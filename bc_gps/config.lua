Config = {}

Config.Item = "ujtracker"

Config.Jobs = {
    ['police'] = {
        ignoreDuty = true,
        blip = {
            sprite = 1,
            color = 0,
            flashColors = {
                0,
                0,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
            ['cycles'] = {
                sprite = 859,
                color = 0,
            },
            ['heli'] = {
                sprite = 422,
                color = 0,
            },
            ['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['police'] = true,
            ['navi'] = true,
            ['ambulance'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
            ['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true, --
            ['servicess'] = true,
            ['gov'] = true, --
        }
    },
    ['navi'] = {
        ignoreDuty = true,
        blip = {
            sprite = 1,
            color = 1,
            flashColors = {
                0,
                0,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 1,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['police'] = true,
            ['navi'] = true,
            ['ambulance'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
            ['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true, --
            ['servicess'] = true,
            ['gov'] = true, --
        }
    },
    ['atf'] = {
        ignoreDuty = true,
        blip = {
            sprite = 1,
            color = 24,
            flashColors = {
                0,
                0,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 24,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['police'] = true,
            ['navi'] = true,
            ['ambulance'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
            ['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true, --
            ['servicess'] = true,
            ['gov'] = true, --
        }
    },
    ['ambulance'] = {
        ignoreDuty = true,
        blip = {
            sprite = 61,
            color = 59,
            flashColors = {
                0,
                59,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['ambulance'] = true,
            ['police'] = true,
            ['navi'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
            ['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true,
            ['servicess'] = true,
            ['gov'] = true,
        }
    },
    ['fbi'] = {
        ignoreDuty = true,
        blip = {
            sprite = 60,
            color = 5,
            flashColors = {
                0,
                5,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 5,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 5,
            },
        },
        canSee = {
            ['fbi'] = true,
            ['ambulance'] = true,
            ['navi'] = true,
			['police'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
            ['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true,
            ['servicess'] = true,
            ['gov'] = true,
        }
    },
    ['irs'] = {
        ignoreDuty = true,
        blip = {
            sprite = 6,
            color = 10,
            flashColors = {
                0,
                1,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 10,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 10,
            },
        },
        canSee = {
            ['police'] = true,
            ['navi'] = true,
            ['ambulance'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
            ['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true,
            ['servicess'] = true,
            ['gov'] = true,
        }
    },
    ['fbiuj'] = {
        ignoreDuty = true,
        blip = {
            sprite = 6,
            color = 46,
            flashColors = {
                0,
                1,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 46,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 10,
            },
        },
        canSee = {
            ['police'] = true,
            ['navi'] = true,
            ['ambulance'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
			['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true,
            ['servicess'] = true,
            ['gov'] = true,
        }
    },
    ['uss'] = {
        ignoreDuty = true,
        blip = {
            sprite = 6,
            color = 48,
            flashColors = {
                0,
                1,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 48,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 10,
            },
        },
        canSee = {
            ['police'] = true,
            ['navi'] = true,
            ['ambulance'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
			['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true,
            ['servicess'] = true,
            ['gov'] = true,
        }
    },
    ['detective'] = {
        ignoreDuty = true,
        blip = {
            sprite = 6,
            color = 6,
            flashColors = {
                0,
                1,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 6,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 2,
            },
        },
        canSee = {
            ['police'] = true,
            ['navi'] = true,
            ['ambulance'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
			['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true,
            ['servicess'] = true,
            ['gov'] = true,
        }
    },
    ['usms'] = {
        ignoreDuty = true,
        blip = {
            sprite = 1,
            color = 7,
            flashColors = {
                0,
                1,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 7,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 46,
            },
        },
        canSee = {
            ['police'] = true,
            ['navi'] = true,
            ['ambulance'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
			['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true,
            ['servicess'] = true,
            ['gov'] = true,
        }
    },
   ['mechanic'] = {
        ignoreDuty = true,
        blip = {
            sprite = 402,
            color = 55,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 55,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 55,
            },
        },
        canSee = {
            ['mechanic'] = true,
        }
    },
   ['offmechanic'] = {
        ignoreDuty = true,
        blip = {
            sprite = 402,
            color = 55,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 55,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 55,
            },
        },
        canSee = {
            ['offmechanic'] = true,
        }
    },
    ['lostmc'] = {
        ignoreDuty = true,
        blip = {
            sprite = 402,
            color = 55,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 55,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 55,
            },
        },
        canSee = {
            ['lostmc'] = true,
        }
    },
    ['corleone'] = {
        ignoreDuty = true,
        blip = {
            sprite = 402,
            color = 55,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 55,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 55,
            },
        },
        canSee = {
            ['corleone'] = true,
        }
    },
   ['blacksheeps'] = {
        ignoreDuty = true,
        blip = {
            sprite = 536,
            color = 85,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 85,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 85,
            },
        },
        canSee = {
            ['blacksheeps'] = true,
        }
    },
    ['vagoos'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
            ['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['vagoos'] = true,
        }
    },
    ['gentle'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['gentle'] = true,
        }
    },
   ['bloods'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['bloods'] = true,
        }
    },
    ['yoshi2'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['yoshi2'] = true,
        }
    },
    ['depapel'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['depapel'] = true,
        }
    },
    ['pbgang'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['pbgang'] = true,
        }
    },
    ['camorra1'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['camorra1'] = true,
        }
    },
   ['gunshop'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['gunshop'] = true,
        }
    },
    ['acabmechanic'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['acabmechanic'] = true,
        }
    },
    ['irspub'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['irspub'] = true,
        }
    },
    ['tongva'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['tongva'] = true,
        }
    },
   ['bac'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['bac'] = true,
        }
    },
   ['blackmamba'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['blackmamba'] = true,
        }
    },
   ['gabee'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['gabee'] = true,
        }
    },
   ['diavoltelep'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['diavoltelep'] = true,
        }
    },
   ['diavoltelepoff'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['diavoltelepoff'] = true,
        }
    },
    ['ballas'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['ballas'] = true,
        }
    },
   ['crips'] = {
        ignoreDuty = true,
        blip = {
            sprite = 674,
            color = 38,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 38,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 38,
            },
        },
        canSee = {
            ['crips'] = true,
        }
    },
   ['medellin'] = {
        ignoreDuty = true,
        blip = {
            sprite = 480,
            color = 28,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 28,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 28,
            },
        },
        canSee = {
            ['medellin'] = true,
        }
    },
    ['furioza'] = {
        ignoreDuty = true,
        blip = {
            sprite = 480,
            color = 28,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 28,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 28,
            },
        },
        canSee = {
            ['furioza'] = true,
        }
    },
   ['whole'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 59,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 59,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 59,
            },
        },
        canSee = {
            ['whole'] = true,
        }
    },
    ['offluxduty'] = {
        ignoreDuty = true,
        blip = {
            sprite = 792,
            color = 28,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 18,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 18,
            },
        },
        canSee = {
            ['offluxduty'] = true,
        }
    },
   ['ms13'] = {
        ignoreDuty = true,
        blip = {
            sprite = 185,
            color = 29,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 18,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 18,
            },
        },
        canSee = {
            ['ms13'] = true,
        }
    },
   ['kingsman'] = {
        ignoreDuty = true,
        blip = {
            sprite = 185,
            color = 29,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 18,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 18,
            },
        },
        canSee = {
            ['kingsman'] = true,
			['mob'] = true,
        }
    },
   ['admin'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 28,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 28,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 28,
            },
        },
        canSee = {
            ['admin'] = true,
        }
    },
   ['bahamas'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 27,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 27,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 27,
            },
        },
        canSee = {
            ['bahamas'] = true,
        }
    },
   ['ndrangheta'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 27,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 27,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 27,
            },
        },
        canSee = {
            ['ndrangheta'] = true,
        }
    },
    ['taxi'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 27,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 27,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 27,
            },
        },
        canSee = {
            ['taxi'] = true,
        }
    },
   ['kingmaffia'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 1,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 1,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 1,
            },
        },
        canSee = {
            ['kingmaffia'] = true,
        },
	},
   ['army'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 1,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 1,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 1,
            },
        },
        canSee = {
            ['army'] = true,
        }
    },
   ['saint'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 0,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['saint'] = true,
        }
    },
   ['gorilla'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 0,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['gorilla'] = true,
        }
    },
   ['asian'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 0,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['asian'] = true,
        }
    },
   ['bulgar'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['bulgar'] = true,
        }
    },
    ['fired'] = {
        ignoreDuty = true,
        blip = {
            sprite = 1,
            color = 1,
            flashColors = {
                0,
                0,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 1,
            },
            ['bike'] = {
                sprite = 226,
                color = 1,
            },
            ['cycles'] = {
                sprite = 859,
                color = 1,
            },
            ['heli'] = {
                sprite = 422,
                color = 1,
            },
            ['boat'] = {
                sprite = 427,
                color = 1,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 1,
            },
        },
        canSee = {
            ['fired'] = true,
        }
    },
   ['gym'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['gym'] = true,
        }
    },
   ['orosz'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
			['orosz'] = true,
        }
    },
   ['ms'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['ms'] = true,
        }
    },
   ['roma'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['roma'] = true,
        }
    },
   ['yaku'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['yaku'] = true,
        }
    },
   ['gov'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['police'] = true,
            ['navi'] = true,
            ['ambulance'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
			['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true, --
            ['servicess'] = true,
            ['gov'] = true, --
        }
    },
    ['servicess'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 8,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 8,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['police'] = true,
            ['navi'] = true,
            ['ambulance'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
			['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true, --
            ['servicess'] = true,
            ['gov'] = true, --
        }
    },
    ['guardarmy'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 9,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 9,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['police'] = true,
            ['navi'] = true,
            ['ambulance'] = true,
			['fbi'] = true,
			['fbiuj'] = true,
			['uss'] = true,
			['irs'] = true,
			['atf'] = true,
			['detective'] = true,
			['guardarmy'] = true,
            ['usms'] = true, --
            ['servicess'] = true,
            ['gov'] = true, --
        }
    },
   ['commando'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['commando'] = true,
        }
    },
   ['gomorra'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['gomorra'] = true,
        }
    },
    ['themetalshop'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['themetalshop'] = true,
        }
    },
    ['alkaidaoff'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['alkaidaoff'] = true,
        }
    },
    ['farm'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['farm'] = true,
        }
    },
   ['asianuj'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['asianuj'] = true,
        }
    },
  ['offluxduty'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['offluxduty'] = true,
        }
    },
    ['lkings'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['lkings'] = true,
        }
    },
    ['areab'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['areab'] = true,
        }
    },
    ['cronos'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['cronos'] = true,
        }
    },
    ['szeged'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['szeged'] = true,
        }
    },
    ['killenc'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['killenc'] = true,
        }
    },
  ['raven'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['raven'] = true,
        }
    },
  ['kingston'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['kingston'] = true,
        }
    },
  ['loscuba'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['loscuba'] = true,
        }
    },
  ['dd'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['dd'] = true,
        }
    },
  ['teszt'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['teszt'] = true,
        }
    },
  ['ssouls'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['ssouls'] = true,
        }
    },
  ['sonsofanarchy'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['sonsofanarchy'] = true,
        }
    },
  ['ujfrakciodawe3'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['ujfrakciodawe3'] = true,
        }
    },
  ['ujfrakcio'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['ujfrakcio'] = true,
        }
    },
  ['ujfrakciodawe1'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                25,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['ujfrakciodawe1'] = true,
        }
    },
  ['peakybb'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
            [`supervolito2`] = {
                sprite = 43,
                color = 0,
            },
        },
        canSee = {
            ['peakybb'] = true,
        }
    },
    ['los_vagos'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['los_vagos'] = true,
        }
    },
    ['1125crew'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['1125crew'] = true,
        }
    },
    ['remmo'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['remmo'] = true,
        }
    },
    ['mob'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['mob'] = true,
			['kingsman'] = true,
        }
    },
    ['groove'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['groove'] = true,
        }
    },
	
    ['caffee'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['caffee'] = true,
        }
    },
	
    ['soa'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['soa'] = true,
            --['balen'] = true,
        }
    },
	
    ['bratva'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['bratva'] = true,
        }
    },
	
    ['balen'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['balen'] = true,
        }
    },--russian
    ['russian'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['russian'] = true,
        }
    },
    ['doa'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['doa'] = true,
        }
    },
    ['akuma95fraki'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['akuma95fraki'] = true,
        }
    },
    ['exotic'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['exotic'] = true,
        }
    },
    ['khc'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['khc'] = true,
        }
    },
    ['pollos'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['pollos'] = true,
        }
    },
    ['uwu'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['uwu'] = true,
        }
    },
    ['huligan'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['huligan'] = true,
        }
    },
    ['piekarz'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['piekarz'] = true,
        }
    },
    ['reapers'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['reapers'] = true,
        }
    },
    ['boonkgang'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['boonkgang'] = true,
        }
    },
    ['ngz'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['ngz'] = true,
        }
    },
    ['pearlsillegal'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['pearlsillegal'] = true,
        }
    },

     ['conte'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['conte'] = true,
        }
    },

     ['thelost'] = {
        ignoreDuty = true,
        blip = {
            sprite = 617,
            color = 10,
            flashColors = {
                0,
                40,
            }
        },
        vehBlip = {
            ['default'] = {
                sprite = 56,
                color = 0,
            },
['bike'] = {
                sprite = 226,
                color = 0,
            },
['cycles'] = {
                sprite = 859,
                color = 0,
            },
['heli'] = {
                sprite = 422,
                color = 0,
            },
['boat'] = {
                sprite = 427,
                color = 0,
            },
        },
        canSee = {
            ['thelost'] = true,
        }
    },
}

