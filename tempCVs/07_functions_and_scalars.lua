local function current_title()
    return "Rendering Tools Engineer"
end

local function target_environment()
    return "Linux / Wayland / Vulkan"
end

PersonalInfo = {
    Name = "Kiro Fen",
    Title = current_title,
    Location = "Redwood Test Sector",
    OS = target_environment,
    Email = "kiro.fen@example.test",
    GitHub = "github.com/fake-kiro-fen",
    Summary = "Toolmaker focused on graphics workflows, reproducible test scenes, and automation around native C++ renderers."
}

Skills = {
    Languages = {"C++", "Lua", "Python", "Bash"},
    Graphics = {"Vulkan", "GLSL", "SPIR-V"},
    Automation = {"CMake", "Shell", "CI"}
}

Education = {
    {
        Institute = "Fictional University of Systems",
        Degree = "BSc Software Engineering",
        Status = "Completed"
    }
}

Projects = {
    {
        Title = "FrameSmith",
        Role = "Tools Engineer",
        Description = "Synthetic toolchain that launches render tests, gathers frame statistics, and emits machine-readable summaries.",
        Tech = {"C++", "Lua", "Bash", "Vulkan"}
    },
    {
        Title = "Scene Seeds",
        Role = "Pipeline Engineer",
        Description = "Procedural collection of fake scenes designed to exercise renderer edge cases without external assets.",
        Tech = {"Lua", "C++", "Procedural"}
    }
}

Metrics = {
    AutomatedTests = 148,
    GPUBackends = 2,
    Headless = true,
    Reproducible = true
}

Notes = {
    "All benchmark inputs are generated locally",
    "No proprietary assets",
    "No network requirement"
}
