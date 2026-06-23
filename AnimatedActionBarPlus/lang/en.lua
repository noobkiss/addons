local strings =
{
    SI_AAB_PANEL_DESCRIPTION =
        "Adds a bounce animation and a customizable glow effect to your action bar. " ..
        "Works alongside FancyActionbar+, Bandits UI, LUI Extended, Ability Framework " ..
        "(including custom Style Packs), AlphaGear, Azurah and the vanilla UI.",

    SI_AAB_SUB_BOUNCE          = "Bounce Animation",
    SI_AAB_SUB_BOUNCE_TT       = "Settings that control the squish-and-grow animation played on your ability icons.",

    SI_AAB_ANIM_STYLE          = "Animation style",
    SI_AAB_ANIM_STYLE_TT       = "Which animation plays when an ability is used or procs. " ..
                                        "Bounce: shrink + grow. Flash: brightness blink. " ..
                                        "Shake: horizontal wobble. Tilt: brief rotation.",
    SI_AAB_ANIM_BOUNCE         = "Bounce",
    SI_AAB_ANIM_FLASH          = "Flash",
    SI_AAB_ANIM_SHAKE          = "Shake",
    SI_AAB_ANIM_TILT           = "Tilt",
    SI_AAB_SUB_GLOW            = "Glow Effect",
    SI_AAB_SUB_GLOW_TT         = "A colored highlight that fades over your ability icon when you press it.",
    SI_AAB_SUB_PULSE           = "Proc Pulse",
    SI_AAB_SUB_PULSE_TT        = "Continuous glow effect that runs while an ability is proc'd and ready to use.",

    SI_AAB_BOUNCE_ENABLE       = "Enable bounce",
    SI_AAB_BOUNCE_ENABLE_TT    = "Master switch for the bounce animation. When off, no icons will animate.",
    SI_AAB_BOUNCE_ON_PROC      = "Bounce on procs",
    SI_AAB_BOUNCE_ON_PROC_TT   = "Also play the bounce animation when an ability procs (e.g. Crystal Fragments, " ..
                                        "Assassin's Will, Grim Focus), not just when you press it.",
    SI_AAB_BOUNCE_QUICKSLOT    = "Bounce on consumables",
    SI_AAB_BOUNCE_QUICKSLOT_TT = "Play the bounce animation when you use a quickslot item " ..
                                        "(potions, food, drinks, poisons, siege weapons, etc).",
    SI_AAB_BOUNCE_GROW         = "Grow scale",
    SI_AAB_BOUNCE_GROW_TT      = "How much the icon grows at the peak of the bounce. 1.10 = 10% larger than normal. " ..
                                        "Higher = more dramatic.",
    SI_AAB_BOUNCE_SHRINK       = "Shrink scale",
    SI_AAB_BOUNCE_SHRINK_TT    = "How much the icon shrinks at the start of the bounce. 0.90 = 10% smaller than normal. " ..
                                        "Lower = sharper squish.",
    SI_AAB_BOUNCE_RESET        = "Reset duration (ms)",
    SI_AAB_BOUNCE_RESET_TT     = "How long the icon takes to return to its normal size after the peak. " ..
                                        "Lower = snappier feel.",

    SI_AAB_GLOW_ENABLE         = "Enable glow",
    SI_AAB_GLOW_ENABLE_TT      = "Master switch for the glow effect. When off, no glow will be drawn on press.",
    SI_AAB_GLOW_COLOR          = "Glow color",
    SI_AAB_GLOW_COLOR_TT       = "Color of the glow effect. The alpha (A) slider controls maximum brightness.",
    SI_AAB_GLOW_DURATION       = "Glow duration (ms)",
    SI_AAB_GLOW_DURATION_TT    = "How long the press-glow takes to fade out. Higher = stays visible longer.",
    SI_AAB_GLOW_PADDING        = "Glow padding (px)",
    SI_AAB_GLOW_PADDING_TT     = "Extra pixels the glow extends beyond the icon edges. " ..
                                        "Higher = bigger halo around the icon.",
    SI_AAB_GLOW_INTENSITY      = "Glow strength",
    SI_AAB_GLOW_INTENSITY_TT   = "Brightness multiplier of the glow. 1.00 = default, higher = brighter/more intense. " ..
                                        "Affects press glow, proc pulse and quickslot glow.",

    SI_AAB_PULSE_ENABLE        = "Enable proc pulse",
    SI_AAB_PULSE_ENABLE_TT     = "When an ability procs, keep pulsing the glow until the proc is used or expires.",
    SI_AAB_PROC_VANILLA_GLOW       = "Vanilla ESO proc glow",
    SI_AAB_PROC_VANILLA_GLOW_TT    = "Show the original ESO highlight glow that appears on an ability the moment it procs. " ..
                                        "Turn this OFF to rely only on this addon's proc pulse and keep the bar clean. " ..
                                        "Turning this back ON requires a UI reload to restore the original texture.",
    SI_AAB_PULSE_STOP_ON_PRESS          = "Stop pulse on press",
    SI_AAB_PULSE_STOP_ON_PRESS_TT       = "Stop the pulse the instant you press the proc'd ability, instead of waiting " ..
                                        "for the game's proc-fade event (which can lag a frame).",
    SI_AAB_PULSE_STYLE         = "Pulse style",
    SI_AAB_PULSE_STYLE_TT      = "Smooth: a gentle fade in and out.\n" ..
                                        "Blink: a clearly visible on/off toggle.\n" ..
                                        "Strobe: a fast, aggressive flicker for maximum attention.",
    SI_AAB_PULSE_STYLE_SMOOTH  = "Smooth",
    SI_AAB_PULSE_STYLE_BLINK   = "Blink",
    SI_AAB_PULSE_STYLE_STROBE  = "Strobe",
    SI_AAB_PULSE_SMOOTH_DUR    = "Smooth pulse duration (ms)",
    SI_AAB_PULSE_SMOOTH_DUR_TT = "Length of one fade cycle in Smooth mode. Only applies when Pulse style is set to Smooth.",
    SI_AAB_PULSE_BLINK_INT     = "Blink interval (ms)",
    SI_AAB_PULSE_BLINK_INT_TT  = "Time between on and off in Blink mode. Lower = faster blinking. " ..
                                        "Only applies when Pulse style is set to Blink.",
    SI_AAB_PULSE_STROBE_INT    = "Strobe interval (ms)",
    SI_AAB_PULSE_STROBE_INT_TT = "Time between on and off in Strobe mode. Very low values produce a harsh flicker. " ..
                                        "Only applies when Pulse style is set to Strobe.",
    SI_AAB_PULSE_MIN_ALPHA     = "Pulse minimum alpha",
    SI_AAB_PULSE_MIN_ALPHA_TT  = "Lowest visibility the pulse fades down to. " ..
                                        "0 = fully transparent at the dim point, 1 = always fully visible.",
    SI_AAB_PULSE_MAX_ALPHA     = "Pulse maximum alpha",
    SI_AAB_PULSE_MAX_ALPHA_TT  = "Highest visibility the pulse reaches at its peak. 1 = fully opaque.",
    SI_AAB_PULSE_COLOR_CYCLE   = "Color cycle",
    SI_AAB_PULSE_COLOR_CYCLE_TT= "Alternate the pulse between the primary Glow color and the Secondary color below " ..
                                        "for a two-tone flashing effect.",
    SI_AAB_PULSE_COLOR_SECOND  = "Secondary color",
    SI_AAB_PULSE_COLOR_SECOND_TT = "Second color used when Color cycle is enabled.",

    SI_AAB_SUB_ULT             = "Ultimate",
    SI_AAB_SUB_ULT_TT          = "Dedicated settings for the ultimate slot, independent from the bounce and glow on normal slots.",

    SI_AAB_ULT_HEADER_EFFECTS  = "Ultimate effects",
    SI_AAB_ULT_BOUNCE_ENABLE   = "Bounce on ultimate",
    SI_AAB_ULT_BOUNCE_ENABLE_TT= "Play the bounce animation on the ultimate slot too.",
    SI_AAB_ULT_GLOW_ENABLE     = "Glow on ultimate",
    SI_AAB_ULT_GLOW_ENABLE_TT  = "Glow effect on press for the ultimate slot.",
    SI_AAB_ULT_GLOW_COLOR      = "Ultimate glow color",
    SI_AAB_ULT_GLOW_COLOR_TT   = "Color of the press-glow on the ultimate slot. The alpha (A) slider controls brightness.",
    SI_AAB_ULT_GLOW_DURATION   = "Ultimate glow duration (ms)",
    SI_AAB_ULT_GLOW_DURATION_TT= "How long the ultimate press-glow takes to fade out.",
    SI_AAB_ULT_GLOW_PADDING    = "Ultimate glow strength (px)",
    SI_AAB_ULT_GLOW_PADDING_TT = "Extra pixels the ultimate glow extends beyond the icon edges. " ..
                                        "Higher = larger/stronger halo, lower = subtler.",
    SI_AAB_ULT_GLOW_INTENSITY  = "Ultimate glow brightness",
    SI_AAB_ULT_GLOW_INTENSITY_TT = "Brightness multiplier of the ultimate press-glow. " ..
                                        "1.00 = default, higher = brighter/more intense.",

    SI_AAB_ULT_HEADER_READY    = "Ultimate-ready border",
    SI_AAB_ULT_VANILLA_SHIMMER = "Vanilla ESO ready shimmer",
    SI_AAB_ULT_VANILLA_SHIMMER_TT = "Show the original ESO golden shimmer/glow on the ultimate slot the moment it becomes ready. " ..
                                        "Works alongside the custom ready border below — enable one or both. " ..
                                        "Turning this OFF after it was ON requires a UI reload to fully clear the textures.",
    SI_AAB_ULT_ENABLE          = "Enable ultimate ready border",
    SI_AAB_ULT_ENABLE_TT       = "Show a colored border around your ultimate slot the moment you have enough " ..
                                        "ultimate power to use the slotted ability.",
    SI_AAB_ULT_COLOR           = "Border color",
    SI_AAB_ULT_COLOR_TT        = "Color of the ultimate-ready border. The alpha (A) slider controls its brightness.",
    SI_AAB_ULT_PULSE           = "Pulse the border",
    SI_AAB_ULT_PULSE_TT        = "When enabled, the border gently pulses to draw the eye. " ..
                                        "When off, it stays at a constant brightness.",
    SI_AAB_ULT_PULSE_MODE      = "Border animation",
    SI_AAB_ULT_PULSE_MODE_TT   = "Smooth: a gentle fade in and out.\n" ..
                                        "Blink: a clearly visible hard on/off toggle.",
    SI_AAB_ULT_BLINK_INT       = "Blink interval (ms)",
    SI_AAB_ULT_BLINK_INT_TT    = "Time between on and off in Blink mode. Lower = faster blinking. " ..
                                        "Only applies when Border animation is set to Blink.",
    SI_AAB_ULT_COLOR_CYCLE     = "Color cycle",
    SI_AAB_ULT_COLOR_CYCLE_TT  = "Alternate the ultimate border between the primary color and the Secondary " ..
                                        "color below instead of toggling on/off. Only applies in Blink mode.",
    SI_AAB_ULT_COLOR_SECOND    = "Secondary color",
    SI_AAB_ULT_COLOR_SECOND_TT = "Second color used for the ultimate border when Color cycle is enabled.",
    SI_AAB_ULT_PADDING         = "Border padding (px)",
    SI_AAB_ULT_PADDING_TT      = "Extra pixels the border extends beyond the icon edges. " ..
                                        "Higher = larger halo.",

    SI_AAB_ULT_PULSE_DUR       = "Pulse duration (ms)",
    SI_AAB_ULT_PULSE_DUR_TT    = "Length of one fade in/out cycle. Lower = faster pulsing.",
    SI_AAB_ULT_PULSE_MIN       = "Pulse: min visibility (alpha)",
    SI_AAB_ULT_PULSE_MIN_TT    = "Lowest visibility the pulse fades down to. " ..
                                        "Lower = stronger pulse contrast.",
    SI_AAB_ULT_INTENSITY       = "Glow strength",
    SI_AAB_ULT_INTENSITY_TT    = "Brightness multiplier of the glow. 1.00 = default, higher = brighter/more intense.",

    SI_AAB_SUB_FRAME           = "Frame Appearance",
    SI_AAB_SUB_FRAME_TT        = "Controls the frame drawn around each ability icon.",
    SI_AAB_THIN_FRAME          = "Use thin custom frame",
    SI_AAB_THIN_FRAME_TT       = "Replaces the vanilla 64px ability frame with a thin custom border " ..
                                        "(drawn from CustomEdge.dds and CustomCenter.dds). Glow effects play above this frame. " ..
                                        "Requires a UI reload to fully apply or remove.",
    SI_AAB_FRAME_ALPHA         = "Frame opacity",
    SI_AAB_FRAME_ALPHA_TT      = "0 = frame fully invisible (clean look, glow only). " ..
                                        "1 = full opacity. Lower values make the frame thinner/dimmer.",
    SI_AAB_EDGE_STYLE          = "Frame style",
    SI_AAB_EDGE_STYLE_TT       = "Selects the texture for the custom frame. " ..
                                        "Classic = the original frame, EldenRingUI = matches the EldenRingUI addon.",
    SI_AAB_EDGE_CLASSIC        = "Classic",
    SI_AAB_EDGE_V2             = "EldenRingUI",
    SI_AAB_EDGE_PURPLE         = "Purple Frames",
    SI_AAB_EDGE_RED            = "Red Frames",
    SI_AAB_EDGE_BLUE           = "Blue Frames",
    SI_AAB_EDGE_AQUA           = "Aqua Frames",
    SI_AAB_EDGE_DARKRED        = "Dark Red Frames",
    SI_AAB_EDGE_DARKPURPLE     = "Dark Purple Frames",
    SI_AAB_RELOAD_NOTE         = "A UI reload (/reloadui) is required for this change to fully take effect.",
    SI_AAB_FRAME_THEME_NOTE    = "|cAAAAAAUI creators who would like their own custom theme, please contact |r|cFFFFFFhaze.3169|r|cAAAAAA on Discord. Got ideas for more themes? Reach out there too!|r",
    SI_AAB_RELOAD_UI           = "Reload UI",
    SI_AAB_RELOAD_UI_TT        = "Reload the UI to fully apply frame changes.",

    SI_AAB_DBG_ON              = "on",
    SI_AAB_DBG_OFF             = "off",
    SI_AAB_DBG_FRAME           = "Frame",
    SI_AAB_DBG_THINFRAME       = "thin frame",
    SI_AAB_DBG_STYLE           = "style",
    SI_AAB_DBG_TEMPLATE        = "template",
    SI_AAB_DBG_ALPHA           = "alpha",
    SI_AAB_DBG_BOUNCE          = "Bounce",
    SI_AAB_DBG_ACTIVE          = "active",
    SI_AAB_DBG_ONPROC          = "on proc",
    SI_AAB_DBG_ULTI            = "ulti",
    SI_AAB_DBG_GLOWPULSE       = "Glow / Pulse",
    SI_AAB_DBG_GLOW            = "glow",
    SI_AAB_DBG_PULSE           = "pulse",
    SI_AAB_DBG_PULSEMODE       = "pulse mode",
    SI_AAB_DBG_COLORCYCLE      = "color cycle",
    SI_AAB_DBG_VANILLAPROC     = "vanilla proc glow",
    SI_AAB_DBG_ULTFRAME        = "Ultimate frame",
    SI_AAB_DBG_READY           = "ready",
    SI_AAB_DBG_MODE            = "mode",
    SI_AAB_DBG_VANILLASHIMMER  = "vanilla shimmer",
    SI_AAB_DBG_SERVER          = "Server",

    SI_AAB_PULSE_STYLE_RAINBOW = "Smooth-Rainbow",
    SI_AAB_ULT_RAINBOW_SAT     = "Rainbow saturation",
    SI_AAB_ULT_RAINBOW_SAT_TT  = "Saturation of the rainbow colors. 0 = grayscale, 1 = full color.",
    SI_AAB_ULT_RAINBOW_LIGHT   = "Rainbow lightness",
    SI_AAB_ULT_RAINBOW_LIGHT_TT= "Brightness of the rainbow colors. 0 = black, 0.5 = full brightness, 1 = white.",
    SI_AAB_DBG_RAINBOW_SAT     = "rainbow sat",
    SI_AAB_DBG_RAINBOW_LIGHT   = "rainbow light",

    SI_AAB_SUB_CONTACT            = "Contact Creator",
    SI_AAB_SUB_CONTACT_TT         = "Support the creator with an in-game donation.",
    SI_AAB_CONTACT_DESC           = "Enjoying the addon? In-game donations are very welcome - Potions, Gold and crafting Resources all help! Click below to open a mail addressed to @haze068.",
    SI_AAB_CONTACT_DONATE_BTN     = "Donate via in-game mail",
    SI_AAB_CONTACT_DONATE_BTN_TT  = "Opens the in-game mail panel with recipient and title prefilled.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
