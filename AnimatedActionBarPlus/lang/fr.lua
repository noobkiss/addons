local strings =
{
    SI_AAB_PANEL_DESCRIPTION =
        "Ajoute une animation de rebond et un effet lumineux personnalisable à votre barre d'action. " ..
        "Compatible avec FancyActionbar+, Bandits UI, LUI Extended, Ability Framework " ..
        "(y compris les Style Packs personnalisés), AlphaGear, Azurah et l'interface par défaut.",

    SI_AAB_SUB_BOUNCE          = "Animation de rebond",
    SI_AAB_SUB_BOUNCE_TT       = "Réglages de l'animation d'écrasement et d'agrandissement de vos icônes de compétences.",

    SI_AAB_ANIM_STYLE          = "Style d'animation",
    SI_AAB_ANIM_STYLE_TT       = "Quelle animation est jouée lors de l'utilisation ou du proc d'une compétence. " ..
                                        "Bounce : rétrécir + grandir. Flash : clignotement. " ..
                                        "Shake : oscillation horizontale. Tilt : brève rotation.",
    SI_AAB_ANIM_BOUNCE         = "Bounce",
    SI_AAB_ANIM_FLASH          = "Flash",
    SI_AAB_ANIM_SHAKE          = "Shake",
    SI_AAB_ANIM_TILT           = "Tilt",
    SI_AAB_SUB_GLOW            = "Effet lumineux",
    SI_AAB_SUB_GLOW_TT         = "Surbrillance colorée qui apparaît brièvement quand vous appuyez sur une compétence.",
    SI_AAB_SUB_PULSE           = "Pulsation de proc",
    SI_AAB_SUB_PULSE_TT        = "Effet lumineux continu lorsqu'une compétence est procée et prête à être utilisée.",

    SI_AAB_BOUNCE_ENABLE       = "Activer le rebond",
    SI_AAB_BOUNCE_ENABLE_TT    = "Interrupteur principal pour l'animation de rebond. Désactivé, aucune icône ne s'animera.",
    SI_AAB_BOUNCE_ON_PROC      = "Rebond sur proc",
    SI_AAB_BOUNCE_ON_PROC_TT   = "Joue aussi l'animation quand une compétence proce (Fragments de Cristal, " ..
                                        "Volonté de l'Assassin, Concentration Sinistre…), pas seulement à la pression.",
    SI_AAB_BOUNCE_QUICKSLOT    = "Rebond sur consommables",
    SI_AAB_BOUNCE_QUICKSLOT_TT = "Joue l'animation de rebond quand vous utilisez un objet de la roue rapide " ..
                                        "(potions, nourriture, boissons, poisons, armes de siège, etc.).",
    SI_AAB_BOUNCE_GROW         = "Échelle d'agrandissement",
    SI_AAB_BOUNCE_GROW_TT      = "À quel point l'icône grandit au sommet du rebond. 1,10 = 10% plus grand que la normale. " ..
                                        "Plus haut = plus visible.",
    SI_AAB_BOUNCE_SHRINK       = "Échelle de rétrécissement",
    SI_AAB_BOUNCE_SHRINK_TT    = "À quel point l'icône rétrécit au début du rebond. 0,90 = 10% plus petit que la normale. " ..
                                        "Plus bas = écrasement plus net.",
    SI_AAB_BOUNCE_RESET        = "Durée de retour (ms)",
    SI_AAB_BOUNCE_RESET_TT     = "Temps que met l'icône à revenir à sa taille normale après le sommet. " ..
                                        "Plus bas = plus réactif.",

    SI_AAB_GLOW_ENABLE         = "Activer la lueur",
    SI_AAB_GLOW_ENABLE_TT      = "Interrupteur principal pour l'effet lumineux. Désactivé, aucune lueur n'apparaîtra à la pression.",
    SI_AAB_GLOW_COLOR          = "Couleur de la lueur",
    SI_AAB_GLOW_COLOR_TT       = "Couleur de l'effet lumineux. Le curseur alpha (A) contrôle la luminosité maximale.",
    SI_AAB_GLOW_DURATION       = "Durée de la lueur (ms)",
    SI_AAB_GLOW_DURATION_TT    = "Temps de disparition de la lueur déclenchée par la pression. Plus haut = reste visible plus longtemps.",
    SI_AAB_GLOW_PADDING        = "Marge de la lueur (px)",
    SI_AAB_GLOW_PADDING_TT     = "Pixels supplémentaires que la lueur dépasse autour de l'icône. " ..
                                        "Plus haut = halo plus large.",
    SI_AAB_GLOW_INTENSITY      = "Intensité du glow",
    SI_AAB_GLOW_INTENSITY_TT   = "Multiplicateur de luminosité. 1.00 = défaut, plus haut = plus brillant. " ..
                                        "Affecte le glow d'appui, la pulsation de proc et les consommables.",

    SI_AAB_PULSE_ENABLE        = "Activer la pulsation de proc",
    SI_AAB_PULSE_ENABLE_TT     = "Quand une compétence proce, la lueur continue de pulser jusqu'à utilisation ou expiration du proc.",
    SI_AAB_PROC_VANILLA_GLOW       = "Lueur de proc ESO d'origine",
    SI_AAB_PROC_VANILLA_GLOW_TT    = "Affiche la lueur d'origine d'ESO qui apparaît sur une compétence dès qu'elle proce. " ..
                                        "Désactivez pour n'utiliser que la pulsation de proc de cet addon et garder la barre épurée. " ..
                                        "Réactiver nécessite un rechargement de l'UI pour restaurer la texture d'origine.",
    SI_AAB_PULSE_STOP_ON_PRESS          = "Arrêter à la pression",
    SI_AAB_PULSE_STOP_ON_PRESS_TT       = "Arrête la pulsation dès que vous appuyez sur la compétence procée, sans attendre " ..
                                        "l'événement de fin de proc du jeu (qui peut être en retard d'une frame).",
    SI_AAB_PULSE_STYLE         = "Style de pulsation",
    SI_AAB_PULSE_STYLE_TT      = "Doux : fondu d'apparition et de disparition.\n" ..
                                        "Clignotant : marche/arrêt clairement visible.\n" ..
                                        "Stroboscope : scintillement rapide et agressif pour une attention maximale.",
    SI_AAB_PULSE_STYLE_SMOOTH  = "Doux",
    SI_AAB_PULSE_STYLE_BLINK   = "Clignotant",
    SI_AAB_PULSE_STYLE_STROBE  = "Stroboscope",
    SI_AAB_PULSE_SMOOTH_DUR    = "Doux : durée de pulsation (ms)",
    SI_AAB_PULSE_SMOOTH_DUR_TT = "Durée d'un cycle de fondu en mode Doux. Ne s'applique qu'avec le style Doux.",
    SI_AAB_PULSE_BLINK_INT     = "Clignotant : intervalle (ms)",
    SI_AAB_PULSE_BLINK_INT_TT  = "Temps entre marche et arrêt en mode Clignotant. Plus bas = clignotement plus rapide. " ..
                                        "Ne s'applique qu'avec le style Clignotant.",
    SI_AAB_PULSE_STROBE_INT    = "Stroboscope : intervalle (ms)",
    SI_AAB_PULSE_STROBE_INT_TT = "Temps entre marche et arrêt en mode Stroboscope. Valeurs très basses = scintillement agressif. " ..
                                        "Ne s'applique qu'avec le style Stroboscope.",
    SI_AAB_PULSE_MIN_ALPHA     = "Alpha minimum de pulsation",
    SI_AAB_PULSE_MIN_ALPHA_TT  = "Visibilité la plus basse atteinte par la pulsation. " ..
                                        "0 = totalement transparent, 1 = toujours pleinement visible.",
    SI_AAB_PULSE_MAX_ALPHA     = "Alpha maximum de pulsation",
    SI_AAB_PULSE_MAX_ALPHA_TT  = "Visibilité la plus haute atteinte au sommet de la pulsation. 1 = totalement opaque.",
    SI_AAB_PULSE_COLOR_CYCLE   = "Cycle de couleurs",
    SI_AAB_PULSE_COLOR_CYCLE_TT= "Alterne la pulsation entre la couleur principale et la couleur secondaire ci-dessous " ..
                                        "pour un effet de clignotement bicolore.",
    SI_AAB_PULSE_COLOR_SECOND  = "Couleur secondaire",
    SI_AAB_PULSE_COLOR_SECOND_TT = "Seconde couleur utilisée lorsque le Cycle de couleurs est activé.",

    SI_AAB_SUB_ULT             = "Ultime",
    SI_AAB_SUB_ULT_TT          = "Réglages dédiés à l'emplacement d'ultime, indépendants du bounce et du glow des emplacements normaux.",

    SI_AAB_ULT_HEADER_EFFECTS  = "Effets sur l'ultime",
    SI_AAB_ULT_BOUNCE_ENABLE   = "Bounce sur l'ultime",
    SI_AAB_ULT_BOUNCE_ENABLE_TT= "Joue aussi l'animation de rebond sur l'emplacement d'ultime.",
    SI_AAB_ULT_GLOW_ENABLE     = "Glow sur l'ultime",
    SI_AAB_ULT_GLOW_ENABLE_TT  = "Effet lumineux à la pression sur l'emplacement d'ultime.",
    SI_AAB_ULT_GLOW_COLOR      = "Couleur du glow d'ultime",
    SI_AAB_ULT_GLOW_COLOR_TT   = "Couleur du glow à la pression sur l'ultime. Le curseur alpha (A) contrôle la luminosité.",
    SI_AAB_ULT_GLOW_DURATION   = "Durée du glow d'ultime (ms)",
    SI_AAB_ULT_GLOW_DURATION_TT= "Temps de fondu du glow à la pression sur l'ultime.",
    SI_AAB_ULT_GLOW_PADDING    = "Intensité du glow ultime (px)",
    SI_AAB_ULT_GLOW_PADDING_TT = "Pixels supplémentaires que le glow ultime dépasse les bords de l'icône. " ..
                                        "Plus haut = halo plus large/intense, plus bas = plus discret.",
    SI_AAB_ULT_GLOW_INTENSITY  = "Luminosité du glow d'ultime",
    SI_AAB_ULT_GLOW_INTENSITY_TT = "Multiplicateur de luminosité du glow à la pression sur l'ultime. " ..
                                        "1.00 = défaut, plus haut = plus intense.",

    SI_AAB_ULT_HEADER_READY    = "Bordure d'ultime prête",
    SI_AAB_ULT_VANILLA_SHIMMER = "Scintillement ESO original",
    SI_AAB_ULT_VANILLA_SHIMMER_TT = "Affiche le scintillement/halo doré original d'ESO sur l'emplacement d'ultime dès qu'elle est prête. " ..
                                        "Fonctionne en parallèle de la bordure personnalisée ci-dessous — l'un ou l'autre, ou les deux. " ..
                                        "Désactiver ensuite nécessite un /reloadui pour effacer complètement les textures.",
    SI_AAB_ULT_ENABLE          = "Activer la bordure d'ultime prête",
    SI_AAB_ULT_ENABLE_TT       = "Affiche une bordure colorée autour de votre emplacement d'ultime dès que vous avez " ..
                                        "assez d'énergie ultime pour utiliser la compétence équipée.",
    SI_AAB_ULT_COLOR           = "Couleur de la bordure",
    SI_AAB_ULT_COLOR_TT        = "Couleur de la bordure d'ultime prête. Le curseur alpha (A) contrôle sa luminosité.",
    SI_AAB_ULT_PULSE           = "Pulsation de la bordure",
    SI_AAB_ULT_PULSE_TT        = "Si activé, la bordure pulse doucement pour attirer le regard. " ..
                                        "Si désactivé, elle reste à luminosité constante.",
    SI_AAB_ULT_PULSE_MODE      = "Animation de la bordure",
    SI_AAB_ULT_PULSE_MODE_TT   = "Doux : fondu progressif d'entrée et de sortie.\n" ..
                                        "Clignotement : bascule marche/arrêt nette et bien visible.",
    SI_AAB_ULT_BLINK_INT       = "Intervalle de clignotement (ms)",
    SI_AAB_ULT_BLINK_INT_TT    = "Temps entre marche et arrêt en mode Clignotement. Plus bas = clignotement plus rapide. " ..
                                        "S'applique uniquement quand l'animation de la bordure est réglée sur Clignotement.",
    SI_AAB_ULT_COLOR_CYCLE     = "Cycle de couleurs",
    SI_AAB_ULT_COLOR_CYCLE_TT  = "Alterne la bordure de l'ultime entre la couleur principale et la couleur secondaire " ..
                                        "ci-dessous au lieu d'un simple marche/arrêt. S'applique uniquement en mode Clignotement.",
    SI_AAB_ULT_COLOR_SECOND    = "Couleur secondaire",
    SI_AAB_ULT_COLOR_SECOND_TT = "Seconde couleur utilisée pour la bordure de l'ultime lorsque le Cycle de couleurs est activé.",
    SI_AAB_ULT_PADDING         = "Marge de la bordure (px)",
    SI_AAB_ULT_PADDING_TT      = "Pixels supplémentaires que la bordure dépasse autour de l'icône. " ..
                                        "Plus haut = halo plus large.",

    SI_AAB_ULT_PULSE_DUR       = "Durée de pulsation (ms)",
    SI_AAB_ULT_PULSE_DUR_TT    = "Durée d'un cycle de fondu. Plus bas = pulsation plus rapide.",
    SI_AAB_ULT_PULSE_MIN       = "Pulsation : visibilité min. (alpha)",
    SI_AAB_ULT_PULSE_MIN_TT    = "Valeur minimale d'opacité de la pulsation. " ..
                                        "Plus bas = contraste plus fort.",
    SI_AAB_ULT_INTENSITY       = "Intensité du glow",
    SI_AAB_ULT_INTENSITY_TT    = "Multiplicateur de luminosité. 1.00 = défaut, plus haut = plus brillant.",

    SI_AAB_SUB_FRAME           = "Apparence du cadre",
    SI_AAB_SUB_FRAME_TT        = "Contrôle le cadre dessiné autour de chaque icône de compétence.",
    SI_AAB_THIN_FRAME          = "Utiliser un cadre fin personnalisé",
    SI_AAB_THIN_FRAME_TT       = "Remplace le cadre de compétence standard 64px par un cadre fin personnalisé " ..
                                        "(dessiné depuis CustomEdge.dds et CustomCenter.dds). Les effets lumineux passent au-dessus. " ..
                                        "Un rechargement de l'interface est nécessaire pour appliquer complètement.",
    SI_AAB_FRAME_ALPHA         = "Opacité du cadre",
    SI_AAB_FRAME_ALPHA_TT      = "0 = cadre complètement invisible (look épuré, lueur uniquement). " ..
                                        "1 = opacité maximale. Valeurs plus basses = cadre plus fin/atténué.",
    SI_AAB_EDGE_STYLE          = "Style de cadre",
    SI_AAB_EDGE_STYLE_TT       = "Sélectionne la texture du cadre personnalisé. " ..
                                        "Classique = cadre d'origine, EldenRingUI = assorti à l'addon EldenRingUI.",
    SI_AAB_EDGE_CLASSIC        = "Classique",
    SI_AAB_EDGE_V2             = "EldenRingUI",
    SI_AAB_EDGE_PURPLE         = "Cadres violets",
    SI_AAB_EDGE_RED            = "Cadres rouges",
    SI_AAB_EDGE_BLUE           = "Cadres bleus",
    SI_AAB_EDGE_AQUA           = "Cadres turquoise",
    SI_AAB_EDGE_DARKRED        = "Cadres rouge foncé",
    SI_AAB_EDGE_DARKPURPLE     = "Cadres violet foncé",
    SI_AAB_RELOAD_NOTE         = "Un rechargement de l'interface (/reloadui) est nécessaire pour appliquer entièrement.",
    SI_AAB_FRAME_THEME_NOTE    = "|cAAAAAACréateurs d'UI souhaitant leur propre thème, contactez |r|cFFFFFFhaze.3169|r|cAAAAAA sur Discord. Des idées pour d'autres thèmes ? Écrivez aussi là-bas !|r",
    SI_AAB_RELOAD_UI           = "Recharger l'interface",
    SI_AAB_RELOAD_UI_TT        = "Recharge l'interface pour appliquer entièrement les changements de cadre.",

    SI_AAB_DBG_ON              = "activé",
    SI_AAB_DBG_OFF             = "désactivé",
    SI_AAB_DBG_FRAME           = "Cadre",
    SI_AAB_DBG_THINFRAME       = "cadre fin",
    SI_AAB_DBG_STYLE           = "style",
    SI_AAB_DBG_TEMPLATE        = "modèle",
    SI_AAB_DBG_ALPHA           = "opacité",
    SI_AAB_DBG_BOUNCE          = "Rebond",
    SI_AAB_DBG_ACTIVE          = "actif",
    SI_AAB_DBG_ONPROC          = "sur proc",
    SI_AAB_DBG_ULTI            = "ulti",
    SI_AAB_DBG_GLOWPULSE       = "Lueur / Pulsation",
    SI_AAB_DBG_GLOW            = "lueur",
    SI_AAB_DBG_PULSE           = "pulsation",
    SI_AAB_DBG_PULSEMODE       = "mode pulsation",
    SI_AAB_DBG_COLORCYCLE      = "cycle couleur",
    SI_AAB_DBG_VANILLAPROC     = "lueur proc vanilla",
    SI_AAB_DBG_ULTFRAME        = "Cadre ultime",
    SI_AAB_DBG_READY           = "prêt",
    SI_AAB_DBG_MODE            = "mode",
    SI_AAB_DBG_VANILLASHIMMER  = "scintillement vanilla",
    SI_AAB_DBG_SERVER          = "Serveur",

    SI_AAB_PULSE_STYLE_RAINBOW = "Arc-en-ciel",
    SI_AAB_ULT_RAINBOW_SAT     = "Saturation arc-en-ciel",
    SI_AAB_ULT_RAINBOW_SAT_TT  = "Saturation des couleurs arc-en-ciel. 0 = niveaux de gris, 1 = couleur pleine.",
    SI_AAB_ULT_RAINBOW_LIGHT   = "Luminosité arc-en-ciel",
    SI_AAB_ULT_RAINBOW_LIGHT_TT= "Luminosité des couleurs arc-en-ciel. 0 = noir, 0.5 = pleine luminosité, 1 = blanc.",
    SI_AAB_DBG_RAINBOW_SAT     = "rainbow sat",
    SI_AAB_DBG_RAINBOW_LIGHT   = "rainbow lum",

    SI_AAB_SUB_CONTACT            = "Contacter le créateur",
    SI_AAB_SUB_CONTACT_TT         = "Soutenez le créateur avec un don en jeu.",
    SI_AAB_CONTACT_DESC           = "L'addon vous plaît ? Les dons en jeu sont les bienvenus - Potions, Or et Ressources d'artisanat aident tous ! Cliquez ci-dessous pour ouvrir un courrier adressé à @haze068.",
    SI_AAB_CONTACT_DONATE_BTN     = "Faire un don par courrier",
    SI_AAB_CONTACT_DONATE_BTN_TT  = "Ouvre le panneau de courrier avec le destinataire et le titre pré-remplis.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 2)
end
