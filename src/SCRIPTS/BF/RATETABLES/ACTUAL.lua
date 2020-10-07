return {
    labels = { "", "", "ROLL", "PITCH", "YAW", "Cntr", "Sens", "Max", "Rate", "", "Expo" },
    fields = {
        { min = 1, max = 200, scale = 0.1 },
        { min = 1, max = 200, scale = 0.1 },
        { min = 1, max = 200, scale = 0.1 },
        { min = 0, max = 200, scale = 0.1 },
        { min = 0, max = 200, scale = 0.1 },
        { min = 0, max = 200, scale = 0.1 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 }
    },
    defaults = { 200, 200, 200, 670, 670, 670, 0.54, 0.54, 0.54 }
}
