local function fake_title()
    return "Principal Fictional Engine Architect"
end

local function fake_os()
    return "Linux / Wayland / Vulkan"
end

PersonalInfo = {
    Name = "Vale Arden",
    Title = fake_title,
    Location = "Aster Test Region",
    OS = fake_os,
    Email = "vale.arden@example.test",
    GitHub = "github.com/fake-vale-arden",
    Summary = "Maximum-feature synthetic CV intended as a final integration test for the Lua-driven CV generator. It exercises scalar fields, arrays, nested tables, functions, booleans, numbers, custom sections, repeated project cards, education cards, tags, and dense text."
}

Skills = {
    Languages = {"C++", "C", "Lua", "Python", "Bash"},
    Graphics = {"Vulkan", "OpenGL", "GLSL", "SPIR-V", "PBR", "Deferred Rendering"},
    Engine = {"ECS", "Render Graph", "RHI", "Asset Pipeline", "Editor"},
    Build = {"CMake", "Ninja", "Git", "CI"},
    Debug = {"RenderDoc", "Validation Layers", "Sanitizers", "Profiling"}
}

Education = {
    {
        Institute = "Fictional Institute of Advanced Engine Systems",
        Degree = "MSc Rendering Systems",
        Status = "Completed"
    },
    {
        Institute = "Imaginary University",
        Degree = "BSc Computer Science",
        Status = "Completed"
    }
}

Projects = {
    {
        Title = "Helio Engine",
        Role = "Architect",
        Description = "Synthetic engine integrating a renderer, editor, asset pipeline, scene system, and profiling tools behind a native C++ codebase.",
        Tech = {"C++", "Vulkan", "ECS", "ImGui", "CMake"}
    },
    {
        Title = "GraphPilot",
        Role = "Graphics Architect",
        Description = "Fictional render graph that infers pass dependencies from resource declarations and emits an executable frame schedule.",
        Tech = {"C++", "Vulkan", "Render Graph", "Synchronization"}
    },
    {
        Title = "Material Atlas",
        Role = "Rendering Engineer",
        Description = "Synthetic bindless material system supporting texture indexing, material buffers, and shader-side lookup.",
        Tech = {"Vulkan", "GLSL", "Descriptor Indexing", "SPIR-V"}
    },
    {
        Title = "Viewport Forge",
        Role = "Editor Engineer",
        Description = "Fictional editor viewport with camera controls, scene selection, transform gizmos, overlays, and render diagnostics.",
        Tech = {"C++", "ImGui", "ImGuizmo", "Vulkan"}
    }
}

Architecture = {
    Renderer = {
        API = "Vulkan 1.3",
        Style = "Explicit",
        DynamicRendering = true,
        Bindless = true,
        Reflection = true
    },
    Memory = {
        Allocation = "Suballocated GPU resources",
        Staging = "Persistent upload arena",
        Lifetime = {"Frame-local", "Scene-local", "Global"}
    },
    Pipeline = {
        AssetImport = {"Mesh", "Material", "Texture", "Metadata"},
        Shader = {"Compile", "Reflect", "Validate"},
        Runtime = {"Load", "Cache", "Submit"}
    }
}

Metrics = {
    SyntheticProjects = 4,
    RenderPasses = 27,
    ShaderPermutations = 64,
    AutomatedChecks = 312,
    UsesNetwork = false,
    Reproducible = true
}

Principles = {
    "Make ownership explicit",
    "Keep GPU state inspectable",
    "Prefer data-driven pass declarations",
    "Treat validation output as an engineering signal",
    "Optimize only after measuring"
}

Availability = {
    Remote = true,
    Hybrid = true,
    OnSite = true,
    Travel = false
}
