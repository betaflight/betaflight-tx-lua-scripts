return {
    labels = { "", "", "ROLL", "PITCH", "YAW", "RC", "Rate", "Max", "Rate", "", "Expo" },
    fields = {
        { min = 1, max = 255, scale = 100 },
        { min = 1, max = 255, scale = 100 },
        { min = 1, max = 255, scale = 100 },
        { min = 0, max = 200, scale = 0.1 },
        { min = 0, max = 200, scale = 0.1 },
        { min = 0, max = 200, scale = 0.1 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 }
    },
    defaults = { 1.0, 1.0, 1.0, 670, 670, 670, 0.0, 0.0, 0.0 }
}
