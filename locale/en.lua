local Translations = {
    error = {
        fingerprints = 'You\'ve left a fingerprint on the glass',
        minimum_police = 'Minimum of %{value} police needed',
        wrong_weapon = 'Your weapon is not strong enough...',
        too_much = 'You have too much in your pocket'
    },

    success = {},

    info = {
        progressbar = 'Smashing the display case',
    },

    general = {
        target_label = 'Smash the display case',
        drawtextui_grab = '[E] Smash the display case',
        drawtextui_broken = 'Display case is broken'
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})