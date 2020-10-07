return {
    labels = { "", "", "ROLL", "PITCH", "YAW", "RC", "Rate", "", "Rate", "RC", "Curve" },
    fields = {
        { min = 1, max = 255, scale = 100 },
        { min = 1, max = 255, scale = 100 },
        { min = 1, max = 255, scale = 100 },
        { min = 0, max = 99,  scale = 100 },
        { min = 0, max = 99,  scale = 100 },
        { min = 0, max = 99,  scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 }
    },
    defaults = { 1.0, 1.0, 1.0, 0.7, 0.7, 0.7, 0.0, 0.0, 0.0 }
}
