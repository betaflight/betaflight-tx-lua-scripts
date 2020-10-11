return {
    labels = { "", "", "ROLL", "PITCH", "YAW", "", "Rate", "", "Acro+", "", "Expo" },
    fields = {
        { min = 1, max = 200, scale = 0.1 },
        { min = 1, max = 200, scale = 0.1 },
        { min = 1, max = 200, scale = 0.1 },
        { min = 0, max = 100, scale = 1 },
        { min = 0, max = 100, scale = 1 },
        { min = 0, max = 100, scale = 1 },
        { min = 0, max = 100, scale = 1 },
        { min = 0, max = 100, scale = 1 },
        { min = 0, max = 100, scale = 1 }
    },
    defaults = { 370, 370, 370, 80, 80, 80, 50, 50, 50 }
}
