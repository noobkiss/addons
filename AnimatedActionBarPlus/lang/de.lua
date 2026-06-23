local strings =
{
    SI_AAB_PANEL_DESCRIPTION =
        "Fügt deiner Aktionsleiste eine Bounce-Animation und einen anpassbaren Glow-Effekt hinzu. " ..
        "Funktioniert zusammen mit FancyActionbar+, Bandits UI, LUI Extended, Ability Framework " ..
        "(inkl. eigener Style Packs), AlphaGear, Azurah und der Standard-Benutzeroberfläche.",

    SI_AAB_SUB_BOUNCE          = "Bounce-Animation",
    SI_AAB_SUB_BOUNCE_TT       = "Einstellungen für die Schrumpf-und-Wachs-Animation deiner Fähigkeitssymbole.",

    SI_AAB_ANIM_STYLE          = "Animations-Stil",
    SI_AAB_ANIM_STYLE_TT       = "Welche Animation beim Drücken/Procken einer Fähigkeit abgespielt wird. " ..
                                        "Bounce: Schrumpfen + Wachsen. Flash: Helligkeits-Blink. " ..
                                        "Shake: horizontales Wackeln. Tilt: kurze Drehung.",
    SI_AAB_ANIM_BOUNCE         = "Bounce",
    SI_AAB_ANIM_FLASH          = "Flash",
    SI_AAB_ANIM_SHAKE          = "Shake",
    SI_AAB_ANIM_TILT           = "Tilt",
    SI_AAB_SUB_GLOW            = "Glow-Effekt",
    SI_AAB_SUB_GLOW_TT         = "Ein farbiger Lichtschein, der beim Drücken über dein Fähigkeitssymbol einblendet.",
    SI_AAB_SUB_PULSE           = "Proc-Pulsieren",
    SI_AAB_SUB_PULSE_TT        = "Dauerhafter Glow-Effekt, solange eine Fähigkeit proc't und einsatzbereit ist.",

    SI_AAB_BOUNCE_ENABLE       = "Bounce aktivieren",
    SI_AAB_BOUNCE_ENABLE_TT    = "Hauptschalter für die Bounce-Animation. Wenn aus, animieren sich keine Symbole.",
    SI_AAB_BOUNCE_ON_PROC      = "Bounce bei Procs",
    SI_AAB_BOUNCE_ON_PROC_TT   = "Spielt die Bounce-Animation auch, wenn eine Fähigkeit proc't (z.B. Kristallfragmente, " ..
                                        "Wille des Assassinen, Grimmiger Fokus), nicht nur beim Drücken.",
    SI_AAB_BOUNCE_QUICKSLOT    = "Bounce bei Verbrauchsgütern",
    SI_AAB_BOUNCE_QUICKSLOT_TT = "Spielt die Bounce-Animation, wenn du einen Schnellauswahl-Gegenstand benutzt " ..
                                        "(Tränke, Essen, Getränke, Gifte, Belagerungswaffen, usw.).",
    SI_AAB_BOUNCE_GROW         = "Wachstums-Skala",
    SI_AAB_BOUNCE_GROW_TT      = "Wie stark das Symbol am Höhepunkt der Bounce-Animation wächst. 1.10 = 10% größer als normal. " ..
                                        "Höher = auffälliger.",
    SI_AAB_BOUNCE_SHRINK       = "Schrumpf-Skala",
    SI_AAB_BOUNCE_SHRINK_TT    = "Wie stark das Symbol zu Beginn der Animation schrumpft. 0.90 = 10% kleiner als normal. " ..
                                        "Niedriger = härteres Stauchen.",
    SI_AAB_BOUNCE_RESET        = "Reset-Dauer (ms)",
    SI_AAB_BOUNCE_RESET_TT     = "Wie lange das Symbol braucht, um nach dem Höhepunkt zur Normalgröße zurückzukehren. " ..
                                        "Niedriger = knackiger.",

    SI_AAB_GLOW_ENABLE         = "Glow aktivieren",
    SI_AAB_GLOW_ENABLE_TT      = "Hauptschalter für den Glow-Effekt. Wenn aus, wird beim Drücken kein Glow gezeichnet.",
    SI_AAB_GLOW_COLOR          = "Glow-Farbe",
    SI_AAB_GLOW_COLOR_TT       = "Farbe des Glow-Effekts. Der Alpha-Regler (A) steuert die maximale Helligkeit.",
    SI_AAB_GLOW_DURATION       = "Glow-Dauer (ms)",
    SI_AAB_GLOW_DURATION_TT    = "Wie lange der Druck-Glow zum Ausblenden braucht. Höher = bleibt länger sichtbar.",
    SI_AAB_GLOW_PADDING        = "Glow-Abstand (px)",
    SI_AAB_GLOW_PADDING_TT     = "Zusätzliche Pixel, die der Glow über die Symbolränder hinaus reicht. " ..
                                        "Höher = größerer Lichthof um das Symbol.",
    SI_AAB_GLOW_INTENSITY      = "Glow-Stärke",
    SI_AAB_GLOW_INTENSITY_TT   = "Helligkeits-Multiplikator des Glows. 1.00 = Standard, höher = heller/intensiver. " ..
                                        "Wirkt auf Druck-Glow, Proc-Pulsieren und Verbrauchsgüter-Glow.",

    SI_AAB_PULSE_ENABLE        = "Proc-Pulsieren aktivieren",
    SI_AAB_PULSE_ENABLE_TT     = "Wenn eine Fähigkeit proc't, pulsiert der Glow weiter, bis die Fähigkeit benutzt wird oder ausläuft.",
    SI_AAB_PROC_VANILLA_GLOW       = "Vanilla-ESO-Proc-Glow",
    SI_AAB_PROC_VANILLA_GLOW_TT    = "Zeigt das originale ESO-Aufleuchten, das auf einer Fähigkeit erscheint, sobald sie proc't. " ..
                                        "Zum Abschalten deaktivieren, um nur das Proc-Pulsieren dieses Addons zu nutzen und die Leiste sauber zu halten. " ..
                                        "Wieder einschalten erfordert einen UI-Reload, um die Originaltextur wiederherzustellen.",
    SI_AAB_PULSE_STOP_ON_PRESS          = "Beim Drücken stoppen",
    SI_AAB_PULSE_STOP_ON_PRESS_TT       = "Stoppt das Pulsieren sofort beim Drücken der proc'd Fähigkeit, statt auf das Proc-Ende-Event " ..
                                        "des Spiels zu warten (das einen Frame zu spät kommen kann).",
    SI_AAB_PULSE_STYLE         = "Pulsier-Stil",
    SI_AAB_PULSE_STYLE_TT      = "Sanft: weiches Ein- und Ausblenden.\n" ..
                                        "Blinker: klar sichtbares An/Aus.\n" ..
                                        "Stroboskop: schnelles, aggressives Flackern für maximale Aufmerksamkeit.",
    SI_AAB_PULSE_STYLE_SMOOTH  = "Sanft",
    SI_AAB_PULSE_STYLE_BLINK   = "Blinker",
    SI_AAB_PULSE_STYLE_STROBE  = "Stroboskop",
    SI_AAB_PULSE_SMOOTH_DUR    = "Sanft: Pulsier-Dauer (ms)",
    SI_AAB_PULSE_SMOOTH_DUR_TT = "Länge eines Ein-/Ausblend-Zyklus im Sanft-Modus. Greift nur wenn Pulsier-Stil auf Sanft steht.",
    SI_AAB_PULSE_BLINK_INT     = "Blinker: Intervall (ms)",
    SI_AAB_PULSE_BLINK_INT_TT  = "Zeit zwischen An und Aus im Blinker-Modus. Niedriger = schnelleres Blinken. " ..
                                        "Greift nur wenn Pulsier-Stil auf Blinker steht.",
    SI_AAB_PULSE_STROBE_INT    = "Stroboskop: Intervall (ms)",
    SI_AAB_PULSE_STROBE_INT_TT = "Zeit zwischen An und Aus im Stroboskop-Modus. Sehr niedrige Werte erzeugen ein hartes Flackern. " ..
                                        "Greift nur wenn Pulsier-Stil auf Stroboskop steht.",
    SI_AAB_PULSE_MIN_ALPHA     = "Minimale Sichtbarkeit (Alpha)",
    SI_AAB_PULSE_MIN_ALPHA_TT  = "Niedrigster Sichtbarkeitswert, auf den das Pulsieren ausblendet. " ..
                                        "0 = komplett transparent am Dimm-Punkt, 1 = immer voll sichtbar.",
    SI_AAB_PULSE_MAX_ALPHA     = "Maximale Sichtbarkeit (Alpha)",
    SI_AAB_PULSE_MAX_ALPHA_TT  = "Höchster Sichtbarkeitswert, den das Pulsieren am Peak erreicht. 1 = komplett deckend.",
    SI_AAB_PULSE_COLOR_CYCLE   = "Farbwechsel",
    SI_AAB_PULSE_COLOR_CYCLE_TT= "Wechselt das Pulsieren zwischen der primären Glow-Farbe und der Sekundärfarbe unten " ..
                                        "für einen Zwei-Farben-Blink-Effekt.",
    SI_AAB_PULSE_COLOR_SECOND  = "Sekundärfarbe",
    SI_AAB_PULSE_COLOR_SECOND_TT = "Zweite Farbe, die genutzt wird, wenn Farbwechsel aktiv ist.",

    SI_AAB_SUB_ULT             = "Ultimative",
    SI_AAB_SUB_ULT_TT          = "Eigene Einstellungen für den Ultimativ-Slot, unabhängig von Bounce und Glow der normalen Slots.",

    SI_AAB_ULT_HEADER_EFFECTS  = "Ultimativ-Effekte",
    SI_AAB_ULT_BOUNCE_ENABLE   = "Bounce auf Ultimativ",
    SI_AAB_ULT_BOUNCE_ENABLE_TT= "Spielt die Bounce-Animation auch auf dem Ultimativ-Slot ab.",
    SI_AAB_ULT_GLOW_ENABLE     = "Glow auf Ultimativ",
    SI_AAB_ULT_GLOW_ENABLE_TT  = "Glow-Effekt beim Drücken auf dem Ultimativ-Slot.",
    SI_AAB_ULT_GLOW_COLOR      = "Ultimativ-Glow-Farbe",
    SI_AAB_ULT_GLOW_COLOR_TT   = "Farbe des Glow-Effekts auf dem Ultimativ-Slot. Der Alpha-Regler (A) steuert die Helligkeit.",
    SI_AAB_ULT_GLOW_DURATION   = "Ultimativ-Glow-Dauer (ms)",
    SI_AAB_ULT_GLOW_DURATION_TT= "Wie lange der Ultimativ-Glow zum Ausblenden braucht.",
    SI_AAB_ULT_GLOW_PADDING    = "Ultimativ-Glow-Stärke (px)",
    SI_AAB_ULT_GLOW_PADDING_TT = "Zusätzliche Pixel, die der Ultimativ-Glow über die Symbolränder hinaus reicht. " ..
                                        "Höher = größerer/stärkerer Lichthof, niedriger = dezenter.",
    SI_AAB_ULT_GLOW_INTENSITY  = "Ultimativ-Glow-Helligkeit",
    SI_AAB_ULT_GLOW_INTENSITY_TT = "Helligkeits-Multiplikator des Ultimativ-Glows beim Wirken. " ..
                                        "1.00 = Standard, höher = heller/intensiver.",

    SI_AAB_ULT_HEADER_READY    = "Ultimativ-Bereit-Rahmen",
    SI_AAB_ULT_VANILLA_SHIMMER = "Standard-ESO Bereit-Schimmern",
    SI_AAB_ULT_VANILLA_SHIMMER_TT = "Zeigt das originale goldene Schimmern/Glow von ESO auf dem Ultimativ-Slot, sobald die Ulti bereit ist. " ..
                                        "Funktioniert zusammen mit dem eigenen Bereit-Rahmen unten — eines oder beides aktivierbar. " ..
                                        "Deaktivieren nach einer aktiven Sitzung erfordert /reloadui, damit die Texturen vollständig verschwinden.",
    SI_AAB_ULT_ENABLE          = "Ultimativ-Bereit-Rahmen aktivieren",
    SI_AAB_ULT_ENABLE_TT       = "Zeigt einen farbigen Rahmen um deinen Ultimativ-Slot, sobald du genug " ..
                                        "Ultimativ-Energie hast, um die belegte Fähigkeit einzusetzen.",
    SI_AAB_ULT_COLOR           = "Rahmenfarbe",
    SI_AAB_ULT_COLOR_TT        = "Farbe des Ultimativ-Bereit-Rahmens. Der Alpha-Regler (A) steuert die Helligkeit.",
    SI_AAB_ULT_PULSE           = "Rahmen pulsieren",
    SI_AAB_ULT_PULSE_TT        = "Wenn aktiv, pulsiert der Rahmen sanft, um die Aufmerksamkeit zu erregen. " ..
                                        "Wenn aus, bleibt er bei konstanter Helligkeit.",
    SI_AAB_ULT_PULSE_MODE      = "Rahmen-Animation",
    SI_AAB_ULT_PULSE_MODE_TT   = "Sanft: weiches Ein- und Ausblenden.\n" ..
                                        "Blinken: klar sichtbares hartes An/Aus.",
    SI_AAB_ULT_BLINK_INT       = "Blink-Intervall (ms)",
    SI_AAB_ULT_BLINK_INT_TT    = "Zeit zwischen An und Aus im Blink-Modus. Niedriger = schnelleres Blinken. " ..
                                        "Gilt nur, wenn die Rahmen-Animation auf Blinken steht.",
    SI_AAB_ULT_COLOR_CYCLE     = "Farbwechsel",
    SI_AAB_ULT_COLOR_CYCLE_TT  = "Wechselt den Ulti-Rahmen zwischen der primären Farbe und der Sekundärfarbe " ..
                                        "unten, statt nur an/aus zu schalten. Gilt nur im Blink-Modus.",
    SI_AAB_ULT_COLOR_SECOND    = "Sekundärfarbe",
    SI_AAB_ULT_COLOR_SECOND_TT = "Zweite Farbe für den Ulti-Rahmen, wenn Farbwechsel aktiv ist.",
    SI_AAB_ULT_PADDING         = "Rahmen-Abstand (px)",
    SI_AAB_ULT_PADDING_TT      = "Zusätzliche Pixel, die der Rahmen über die Symbolränder hinaus reicht. " ..
                                        "Höher = größerer Lichthof.",

    SI_AAB_ULT_PULSE_DUR       = "Pulse-Dauer (ms)",
    SI_AAB_ULT_PULSE_DUR_TT    = "Länge eines Ein-/Ausblend-Zyklus. Niedriger = schnelleres Pulsieren.",
    SI_AAB_ULT_PULSE_MIN       = "Pulse: Min-Sichtbarkeit (Alpha)",
    SI_AAB_ULT_PULSE_MIN_TT    = "Niedrigster Sichtbarkeitswert, auf den das Pulsieren abdunkelt. " ..
                                        "Niedriger = stärkerer Pulse-Kontrast.",
    SI_AAB_ULT_INTENSITY       = "Glow-Stärke",
    SI_AAB_ULT_INTENSITY_TT    = "Helligkeits-Multiplikator des Glows. 1.00 = Standard, höher = heller/intensiver.",

    SI_AAB_SUB_FRAME           = "Rahmen-Darstellung",
    SI_AAB_SUB_FRAME_TT        = "Steuert den Rahmen um jedes Fähigkeitssymbol.",
    SI_AAB_THIN_FRAME          = "Dünnen Custom-Rahmen verwenden",
    SI_AAB_THIN_FRAME_TT       = "Ersetzt den Standard-64px-Fähigkeitsrahmen durch einen dünnen Custom-Rahmen " ..
                                        "(gezeichnet aus CustomEdge.dds und CustomCenter.dds). Glow-Effekte werden darüber gezeichnet. " ..
                                        "Ein UI-Neuladen ist erforderlich, damit Änderungen vollständig greifen.",
    SI_AAB_FRAME_ALPHA         = "Rahmen-Deckkraft",
    SI_AAB_FRAME_ALPHA_TT      = "0 = Rahmen komplett unsichtbar (cleanes Aussehen, nur Glow). " ..
                                        "1 = volle Deckkraft. Niedrigere Werte machen den Rahmen dünner/blasser.",
    SI_AAB_EDGE_STYLE          = "Rahmen-Stil",
    SI_AAB_EDGE_STYLE_TT       = "Wählt die Textur für den Custom-Rahmen. " ..
                                        "Klassisch = bisheriger Rahmen, EldenRingUI = passend zum EldenRingUI-Addon.",
    SI_AAB_EDGE_CLASSIC        = "Klassisch",
    SI_AAB_EDGE_V2             = "EldenRingUI",
    SI_AAB_EDGE_PURPLE         = "Lila Rahmen",
    SI_AAB_EDGE_RED            = "Rote Rahmen",
    SI_AAB_EDGE_BLUE           = "Blaue Rahmen",
    SI_AAB_EDGE_AQUA           = "Türkise Rahmen",
    SI_AAB_EDGE_DARKRED        = "Dunkelrote Rahmen",
    SI_AAB_EDGE_DARKPURPLE     = "Dunkellila Rahmen",
    SI_AAB_RELOAD_NOTE         = "Ein UI-Neuladen (/reloadui) ist erforderlich, damit diese Änderung vollständig wirkt.",
    SI_AAB_FRAME_THEME_NOTE    = "|cAAAAAAUI-Creator, die ein eigenes Theme möchten, kontaktiert bitte |r|cFFFFFFhaze.3169|r|cAAAAAA auf Discord. Ideen für weitere Themes? Meldet euch ebenfalls dort!|r",
    SI_AAB_RELOAD_UI           = "UI neu laden",
    SI_AAB_RELOAD_UI_TT        = "Lädt die Oberfläche neu, um Rahmen-Änderungen vollständig zu übernehmen.",

    SI_AAB_DBG_ON              = "an",
    SI_AAB_DBG_OFF             = "aus",
    SI_AAB_DBG_FRAME           = "Rahmen",
    SI_AAB_DBG_THINFRAME       = "dünner rahmen",
    SI_AAB_DBG_STYLE           = "stil",
    SI_AAB_DBG_TEMPLATE        = "template",
    SI_AAB_DBG_ALPHA           = "deckkraft",
    SI_AAB_DBG_BOUNCE          = "Bounce",
    SI_AAB_DBG_ACTIVE          = "aktiv",
    SI_AAB_DBG_ONPROC          = "auf proc",
    SI_AAB_DBG_ULTI            = "ulti",
    SI_AAB_DBG_GLOWPULSE       = "Glow / Pulse",
    SI_AAB_DBG_GLOW            = "glow",
    SI_AAB_DBG_PULSE           = "pulse",
    SI_AAB_DBG_PULSEMODE       = "pulse-modus",
    SI_AAB_DBG_COLORCYCLE      = "farbcycle",
    SI_AAB_DBG_VANILLAPROC     = "vanilla proc-glow",
    SI_AAB_DBG_ULTFRAME        = "Ulti-Rahmen",
    SI_AAB_DBG_READY           = "bereit",
    SI_AAB_DBG_MODE            = "modus",
    SI_AAB_DBG_VANILLASHIMMER  = "vanilla schimmern",
    SI_AAB_DBG_SERVER          = "Server",

    SI_AAB_PULSE_STYLE_RAINBOW = "Smooth-Rainbow",
    SI_AAB_ULT_RAINBOW_SAT     = "Rainbow-Sättigung",
    SI_AAB_ULT_RAINBOW_SAT_TT  = "Sättigung der Regenbogenfarben. 0 = Graustufen, 1 = volle Farbe.",
    SI_AAB_ULT_RAINBOW_LIGHT   = "Rainbow-Helligkeit",
    SI_AAB_ULT_RAINBOW_LIGHT_TT= "Helligkeit der Regenbogenfarben. 0 = schwarz, 0.5 = volle Helligkeit, 1 = weiß.",
    SI_AAB_DBG_RAINBOW_SAT     = "rainbow sät",
    SI_AAB_DBG_RAINBOW_LIGHT   = "rainbow hell",

    SI_AAB_SUB_CONTACT            = "Ersteller kontaktieren",
    SI_AAB_SUB_CONTACT_TT         = "Unterstütze den Ersteller mit einer Ingame-Spende.",
    SI_AAB_CONTACT_DESC           = "Gefällt dir das Addon? Ingame-Spenden sind sehr willkommen - Tränke, Gold und Handwerks-Ressourcen helfen alle! Klick unten, um eine Mail an @haze068 zu öffnen.",
    SI_AAB_CONTACT_DONATE_BTN     = "Per Ingame-Mail spenden",
    SI_AAB_CONTACT_DONATE_BTN_TT  = "Öffnet das Ingame-Mailfenster mit vorausgefülltem Empfänger und Titel.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 2)
end
