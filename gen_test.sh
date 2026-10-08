#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Dynamic CV layout stress-test generator
#
# Expected layout:
#   ./cvgen
#   ./generate_test_cvs.sh
#
# Produces:
#   ./tempCVs/*.lua
#   ./exports/*.png
#   ./exports/*.pdf
#
# All people, emails, GitHub handles, schools, companies and
# projects below are intentionally fictional test data.
# ------------------------------------------------------------

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CVGEN="${CVGEN:-$ROOT/cvgen}"
CV_DIR="$ROOT/tempCVs"
EXPORT_DIR="$ROOT/exports"

if [[ ! -x "$CVGEN" ]]; then
  echo "error: cvgen not found or not executable: $CVGEN" >&2
  echo "Build it first, then run this script again." >&2
  exit 1
fi

rm -rf "$CV_DIR" "$EXPORT_DIR"
mkdir -p "$CV_DIR" "$EXPORT_DIR"

cat >"$CV_DIR/00_showcase.lua" <<'LUA'
-- ============================================================
-- CV GENERATOR SHOWCASE
-- ============================================================
-- This CV intentionally uses raw variable/field names as values.
-- It is meant to visually document the data model supported by
-- the renderer rather than represent a real person.
--
-- Example:
--     Name = "name"
--     customField = "customField"
-- ============================================================

local function title()
    return "title"
end

local function os()
    return "os"
end

PersonalInfo = {
    Name = "name",
    Title = title,
    Location = "location",
    OS = os,
    Email = "email",
    GitHub = "github",
    Summary = "summary"
}

Skills = {
    Languages = {"language", "language2", "language3"},
    Graphics = {"graphics", "graphics2", "graphics3"},
    Tools = {"tool", "tool2", "tool3"},
    Systems = {"system", "system2", "system3"}
}

Education = {
    {
        Institute = "institute",
        Degree = "degree",
        Status = "status"
    },
    {
        Institute = "institute2",
        Degree = "degree2",
        Status = "status2"
    }
}

Projects = {
    {
        Title = "projectTitle",
        Role = "projectRole",
        Description = "projectDescription",
        Tech = {"projectTech", "projectTech2", "projectTech3"}
    },
    {
        Title = "projectTitle2",
        Role = "projectRole2",
        Description = "projectDescription2",
        Tech = {"projectTech4", "projectTech5"}
    }
}

-- Custom scalar fields
CustomFields = {
    customField = "customField",
    customValue = "customValue",
    customNumber = 123,
    customBoolean = true
}

-- Custom arrays
CustomLists = {
    customList = {"customItem", "customItem2", "customItem3"},
    anotherList = {"anotherItem", "anotherItem2"}
}

-- Nested custom data
CustomData = {
    customGroup = {
        nestedField = "nestedField",
        nestedValue = "nestedValue",
        nestedNumber = 456,
        nestedBoolean = false
    },
    anotherGroup = {
        fieldA = "fieldA",
        fieldB = "fieldB",
        fieldC = "fieldC"
    }
}

-- Generic scalar array
Highlights = {
    "highlight",
    "highlight2",
    "highlight3",
    "highlight4"
}

-- Generic nested structure
Experience = {
    company = {
        name = "companyName",
        role = "companyRole",
        period = "companyPeriod"
    },
    responsibilities = {
        "responsibility",
        "responsibility2",
        "responsibility3"
    }
}

-- Additional scalar values
Metadata = {
    version = "version",
    category = "category",
    identifier = "identifier",
    url = "url"
}

-- Booleans and numeric values are included deliberately so the
-- generic renderer can be visually tested with different types.
Options = {
    enabled = true,
    featured = false,
    priority = 10
}
LUA

cat >"$CV_DIR/01_compact_engineer.lua" <<'LUA'
PersonalInfo = {
    Name = "Mira Vale",
    Title = "Graphics Systems Engineer",
    Location = "Northbridge, Testland",
    OS = "Linux / Wayland",
    Email = "mira.vale@example.test",
    GitHub = "github.com/fake-mira-vale",
    Summary = "Systems-focused engineer building compact rendering infrastructure, asset pipelines, and developer tooling."
}

Skills = {
    Languages = {"C++", "C", "Lua", "Python"},
    Graphics = {"Vulkan", "OpenGL", "GLSL", "SPIR-V"},
    Systems = {"Linux", "CMake", "Git", "Profiling"},
    Tools = {"RenderDoc", "Ninja", "Neovim"}
}

Education = {
    {
        Institute = "Northbridge Institute of Computing",
        Degree = "BSc Computer Graphics",
        Status = "Completed"
    }
}

Projects = {
    {
        Title = "Starling Render Lab",
        Role = "Lead Renderer",
        Description = "Fictional renderer used to test bindless materials, transient resources, and GPU-driven scene submission.",
        Tech = {"C++", "Vulkan", "SPIR-V", "CMake"}
    },
    {
        Title = "PixelForge Asset Tool",
        Role = "Developer",
        Description = "Small offline tool for validating meshes, materials, and texture metadata before import.",
        Tech = {"C++", "Lua", "CLI"}
    }
}
LUA

cat >"$CV_DIR/02_dense_graphics.lua" <<'LUA'
PersonalInfo = {
    Name = "Orin Kest",
    Title = "Realtime Graphics Programmer",
    Location = "Fictional District 7",
    OS = "Linux / X11",
    Email = "orin.kest@example.test",
    GitHub = "github.com/fake-orin-kest",
    Summary = "Realtime rendering specialist with a strong focus on frame architecture, shader systems, GPU debugging, and deterministic tooling."
}

Skills = {
    Languages = {"C++", "C", "Rust", "Lua", "Python", "Bash"},
    Rendering = {"Vulkan", "OpenGL", "GLSL", "HLSL", "SPIR-V", "Deferred Rendering"},
    Architecture = {"Render Graphs", "RHI Design", "ECS", "Resource Lifetime"},
    Infrastructure = {"CMake", "Git", "Ninja", "Linux", "CI"},
    Debugging = {"RenderDoc", "GPU Capture", "Validation Layers", "Sanitizers"}
}

Education = {
    {
        Institute = "Imaginary Technical University",
        Degree = "MEng Interactive Systems",
        Status = "Graduated"
    },
    {
        Institute = "Fictional School of Engineering",
        Degree = "Diploma in Digital Systems",
        Status = "Completed"
    }
}

Projects = {
    {
        Title = "Aurora Framegraph",
        Role = "Rendering Architect",
        Description = "Experimental framegraph that derives pass ordering and resource transitions from declared read/write relationships.",
        Tech = {"C++20", "Vulkan", "Render Graph", "SPIR-V"}
    },
    {
        Title = "Nebula Material Lab",
        Role = "Graphics Programmer",
        Description = "Material sandbox exploring bindless texture arrays, descriptor indexing, and shader-driven material selection.",
        Tech = {"C++", "GLSL", "Vulkan", "GPU Driven"}
    },
    {
        Title = "Quanta Capture",
        Role = "Tools Engineer",
        Description = "Fictional capture utility that records synthetic frame metrics and exports compact debugging reports.",
        Tech = {"C++", "JSON", "CMake"}
    }
}

Performance = {
    FrameBudget = "16.67 ms target",
    CaptureMode = "GPU + CPU markers",
    Validation = true,
    Notes = {"Designed for sustained realtime workloads", "No network dependency", "Deterministic test scenes"}
}
LUA

cat >"$CV_DIR/03_long_academic.lua" <<'LUA'
PersonalInfo = {
    Name = "Sera Nolin",
    Title = "Rendering Researcher",
    Location = "Lakeview Research Campus",
    OS = "Linux",
    Email = "sera.nolin@example.test",
    GitHub = "github.com/fake-sera-nolin",
    Summary = "Research-oriented graphics programmer investigating visibility, material representation, GPU scheduling, and practical renderer architecture."
}

Skills = {
    Programming = {"C++", "C", "Python", "Lua"},
    Graphics = {"Vulkan", "OpenGL", "GLSL", "SPIR-V", "PBR", "Shadow Mapping"},
    Mathematics = {"Linear Algebra", "Geometry", "Probability"},
    Research = {"Benchmark Design", "Experiment Tracking", "Technical Writing"},
    Build = {"CMake", "Ninja", "Git", "Linux"}
}

Education = {
    {
        Institute = "Fictional Academy of Visual Computing",
        Degree = "MSc Computer Graphics",
        Status = "Research completed"
    },
    {
        Institute = "Imaginary Polytechnic",
        Degree = "BSc Software Systems",
        Status = "First Class"
    },
    {
        Institute = "Northstar Technical College",
        Degree = "Advanced Diploma in Programming",
        Status = "Completed"
    }
}

Projects = {
    {
        Title = "Visibility Atlas",
        Role = "Research Engineer",
        Description = "Synthetic benchmark investigating visibility-buffer layouts across scenes with highly different triangle and material distributions.",
        Tech = {"C++", "Vulkan", "Compute", "Benchmarking"}
    },
    {
        Title = "Lumenless",
        Role = "Rendering Researcher",
        Description = "Fictional renderer prototype comparing tiled lighting and clustered-light approaches under controlled workloads.",
        Tech = {"C++", "GLSL", "Vulkan", "Lighting"}
    },
    {
        Title = "Shader Observatory",
        Role = "Tooling Engineer",
        Description = "Offline shader inspection tool that groups reflection metadata and reports resource usage per pipeline.",
        Tech = {"C++", "SPIR-V", "Reflection"}
    },
    {
        Title = "Mesh Census",
        Role = "Pipeline Developer",
        Description = "Asset-analysis utility for measuring topology, UV density, material count, and texture footprint in synthetic datasets.",
        Tech = {"C++", "Assimp", "CLI"}
    }
}

Research = {
    Focus = {"GPU resource scheduling", "Material systems", "Visibility", "Frame graphs"},
    Methods = {"Controlled benchmarks", "GPU captures", "Micro-tests"},
    Output = {"Technical reports", "Reproducible scenes", "Performance tables"}
}

Talks = {
    {
        Event = "Fictional Graphics Meetup",
        Topic = "Thinking in GPU Resource Lifetimes"
    },
    {
        Event = "Imaginary Rendering Workshop",
        Topic = "From Pass Declarations to a Working Frame"
    }
}
LUA

cat >"$CV_DIR/04_minimal.lua" <<'LUA'
PersonalInfo = {
    Name = "Tavi Rook",
    Title = "Junior C++ Developer",
    Location = "Test City",
    OS = "Linux",
    Email = "tavi.rook@example.test",
    GitHub = "github.com/fake-tavi-rook"
}

Skills = {
    Languages = {"C++", "Lua"},
    Tools = {"Git", "CMake"}
}

Education = {
    {
        Institute = "Fictional Coding School",
        Degree = "Software Development Certificate",
        Status = "Completed"
    }
}

Projects = {
    {
        Title = "Tiny Tile Lab",
        Role = "Solo Developer",
        Description = "Small fictional 2D experiment for testing input, batching, and texture management.",
        Tech = {"C++", "OpenGL"}
    }
}
LUA

cat >"$CV_DIR/05_custom_sections.lua" <<'LUA'
PersonalInfo = {
    Name = "Ivo Merin",
    Title = "Engine & Tools Programmer",
    Location = "Harborline, Testland",
    OS = "Linux / Wayland",
    Email = "ivo.merin@example.test",
    GitHub = "github.com/fake-ivo-merin",
    Summary = "Builds engine foundations and editor tooling with an emphasis on clean APIs, predictable ownership, and measurable performance."
}

Skills = {
    Core = {"C++", "C", "Lua"},
    Engine = {"Vulkan", "OpenGL", "ECS", "Asset Pipelines"},
    Build = {"CMake", "Ninja", "Git", "Bash"}
}

Education = {
    {
        Institute = "Fictional Institute of Engine Technology",
        Degree = "BSc Game Technology",
        Status = "Completed"
    }
}

Projects = {
    {
        Title = "Copper Engine",
        Role = "Engine Programmer",
        Description = "Fictional C++ engine with an editor, asset database, renderer abstraction, and hot-reload experiments.",
        Tech = {"C++", "Vulkan", "ImGui", "CMake"}
    }
}

Architecture = {
    Philosophy = "Small interfaces, explicit ownership, data-oriented hot paths",
    Renderer = {
        Backend = "Vulkan",
        API = "Explicit resource lifetime",
        Features = {"Bindless textures", "Dynamic rendering", "Validation"}
    },
    Editor = {
        UI = "Immediate mode",
        Panels = {"Viewport", "Scene", "Inspector", "Console"},
        Experimental = true
    }
}

Workflow = {
    Daily = {"Implement", "Capture", "Measure", "Refactor"},
    Review = {"Compiler warnings", "Validation output", "Frame captures"},
    Build = {"Debug", "RelWithDebInfo", "Release"}
}
LUA

cat >"$CV_DIR/06_nested_data.lua" <<'LUA'
PersonalInfo = {
    Name = "Nia Sol",
    Title = "Graphics Infrastructure Developer",
    Location = "Cloudmere",
    OS = "Linux",
    Email = "nia.sol@example.test",
    GitHub = "github.com/fake-nia-sol",
    Summary = "Infrastructure-minded graphics developer who enjoys turning complicated rendering state into inspectable data."
}

Skills = {
    Graphics = {"Vulkan", "OpenGL", "GLSL"},
    Systems = {"C++", "C", "Linux", "CMake"},
    Debug = {"Validation Layers", "RenderDoc", "Sanitizers"}
}

Education = {
    {
        Institute = "Cloudmere School of Computing",
        Degree = "BSc Computer Science",
        Status = "Completed"
    }
}

Projects = {
    {
        Title = "Glassbox Renderer",
        Role = "Graphics Engineer",
        Description = "Fictional renderer where resources, passes, and synchronization metadata are represented as inspectable graph data.",
        Tech = {"C++", "Vulkan", "Render Graph"}
    },
    {
        Title = "Texture Ledger",
        Role = "Tools Programmer",
        Description = "Synthetic asset tool for tracking texture ownership, format, dimensions, and material references.",
        Tech = {"C++", "Lua", "CLI"}
    }
}

EngineProfile = {
    Version = "0.8-test",
    Rendering = {
        API = "Vulkan 1.3",
        Presentation = "Swapchain",
        Features = {"Dynamic rendering", "Descriptor indexing", "GPU markers"}
    },
    ResourcePolicy = {
        Images = {"Immutable when possible", "Explicit format"},
        Buffers = {"Persistent staging", "Suballocation"},
        Synchronization = {"Declared dependencies", "Validation-first"}
    }
}

Availability = {
    Remote = true,
    OnSite = false,
    Contract = true,
    Relocation = false
}
LUA

cat >"$CV_DIR/07_functions_and_scalars.lua" <<'LUA'
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
LUA

cat >"$CV_DIR/08_wide_content.lua" <<'LUA'
PersonalInfo = {
    Name = "Ari Venn",
    Title = "Senior Rendering & Engine Programmer",
    Location = "Fictional Metropolitan Zone",
    OS = "Linux / X11",
    Email = "ari.venn@example.test",
    GitHub = "github.com/fake-ari-venn",
    Summary = "Senior-level fictional profile designed to create a high-content single-page CV. Specializes in native engines, rendering architecture, graphics debugging, and editor systems."
}

Skills = {
    Languages = {"C++17", "C++20", "C", "Lua", "Python", "Bash"},
    APIs = {"Vulkan", "OpenGL", "GLSL", "SPIR-V", "SDL"},
    Rendering = {"Deferred", "Forward+", "PBR", "Shadow Mapping", "Post Processing", "Compute"},
    Engine = {"ECS", "Resource Manager", "Asset Pipeline", "Scene Graph", "Editor"},
    Tooling = {"ImGui", "RenderDoc", "CMake", "Ninja", "Git"},
    Systems = {"Linux", "Threads", "Memory", "File IO", "Profiling"}
}

Education = {
    {
        Institute = "Imaginary Graduate School of Graphics",
        Degree = "MSc Real-Time Rendering",
        Status = "Completed"
    },
    {
        Institute = "Fictional Polytechnic",
        Degree = "BEng Computer Engineering",
        Status = "Completed"
    }
}

Projects = {
    {
        Title = "Vector Dawn",
        Role = "Lead Engine Programmer",
        Description = "Fictional native engine covering renderer initialization, resource management, scene submission, editor integration, and asset inspection.",
        Tech = {"C++", "Vulkan", "ImGui", "CMake", "ECS"}
    },
    {
        Title = "Nightjar Renderer",
        Role = "Graphics Lead",
        Description = "Experimental deferred renderer with G-buffer construction, clustered lights, material indirection, shadow passes, and post-processing.",
        Tech = {"C++", "Vulkan", "GLSL", "Compute", "PBR"}
    },
    {
        Title = "Forge Editor",
        Role = "Editor Programmer",
        Description = "Fictional desktop editor with dockable panels, scene inspection, gizmos, asset browsing, and renderer diagnostics.",
        Tech = {"C++", "ImGui", "ImGuizmo", "Lua"}
    },
    {
        Title = "Atlas Importer",
        Role = "Pipeline Engineer",
        Description = "Asset processing experiment covering meshes, materials, textures, metadata validation, and import diagnostics.",
        Tech = {"C++", "Assimp", "Lua", "CLI"}
    },
    {
        Title = "Signal Bench",
        Role = "Performance Engineer",
        Description = "Synthetic benchmark suite for CPU submission cost, descriptor updates, memory pressure, and frame pacing.",
        Tech = {"C++", "Vulkan", "Profiling"}
    }
}

Highlights = {
    Strengths = {"Low-level debugging", "Rendering architecture", "API design", "Performance analysis"},
    Practices = {"Small reproducible tests", "Warnings-as-errors", "Validation-first development"},
    Interests = {"GPU-driven rendering", "Shader reflection", "Render graphs", "Editor UX"}
}

Career = {
    Current = "Independent fictional engine development",
    Preferred = {"Graphics Programmer", "Engine Programmer", "Rendering Engineer"},
    Environment = {"Native code", "Linux", "GPU-focused systems"}
}
LUA

cat >"$CV_DIR/09_sparse_sections.lua" <<'LUA'
PersonalInfo = {
    Name = "Eli Quen",
    Title = "Technical Artist / Tools Developer",
    Location = "Silver Test Bay",
    OS = "Linux",
    Email = "eli.quen@example.test",
    GitHub = "github.com/fake-eli-quen",
    Summary = "Hybrid technical profile combining procedural content, shader experiments, and native tooling."
}

Skills = {
    Shaders = {"GLSL", "Shader Graph Concepts"},
    Tools = {"Lua", "Python", "C++"},
    Art = {"Procedural Materials", "UV Workflows", "Lighting"}
}

Education = {
    {
        Institute = "Fictional Digital Arts College",
        Degree = "Diploma in Technical Art",
        Status = "Completed"
    }
}

Projects = {
    {
        Title = "Prism Kitchen",
        Role = "Technical Artist",
        Description = "Fictional material laboratory containing deliberately varied procedural surfaces for renderer testing.",
        Tech = {"GLSL", "Lua", "Procedural"}
    }
}

Availability = {
    Remote = true
}
LUA

cat >"$CV_DIR/10_escape_and_long_text.lua" <<'LUA'
PersonalInfo = {
    Name = "Juno <Test> Vale",
    Title = "C++ / Vulkan Systems Developer",
    Location = "Sector & District <A>",
    OS = "Linux & Wayland",
    Email = "juno.vale@example.test",
    GitHub = "github.com/fake-juno-vale",
    Summary = "Stress profile for escaping, wrapping, and long-line handling. Contains symbols such as <, >, &, quotes, and deliberately verbose text to force the layout engine to make meaningful sizing decisions."
}

Skills = {
    Languages = {"C++", "C", "Lua"},
    Graphics = {"Vulkan", "GLSL", "SPIR-V"},
    Systems = {"Linux", "CMake", "Git"}
}

Education = {
    {
        Institute = "Fictional R&D Institute <Graphics>",
        Degree = "BSc Systems & Rendering",
        Status = "Completed & archived"
    }
}

Projects = {
    {
        Title = "Ampersand & Angle Lab",
        Role = "Developer",
        Description = "Synthetic project containing text like <resource>, buffer & image, and quoted values to exercise HTML escaping and wrapping.",
        Tech = {"C++", "Lua", "HTML-like data"}
    },
    {
        Title = "Long Paragraph Stressor",
        Role = "Test Author",
        Description = "This intentionally long description exists to push the card width, line wrapping, column balancing, and automatic font scaling. The content has no external references and is entirely fictional.",
        Tech = {"Layout", "Auto-fit", "Stress Test"}
    }
}

ExtraData = {
    Symbols = {"<tag>", "A & B", "\"quoted\"", "100%"},
    VeryLongKeyName = "A deliberately verbose scalar value that should wrap without overflowing the page or breaking the surrounding card structure."
}
LUA

cat >"$CV_DIR/11_project_heavy.lua" <<'LUA'
PersonalInfo = {
    Name = "Rin Ostel",
    Title = "Game Engine Rendering Programmer",
    Location = "Pinegrid, Testland",
    OS = "Linux",
    Email = "rin.ostel@example.test",
    GitHub = "github.com/fake-rin-ostel",
    Summary = "Project-heavy profile intended to test repeated cards, long technology tag groups, and balancing between dense sections."
}

Skills = {
    Cpp = {"C++", "Templates", "STL", "Multithreading"},
    GPU = {"Vulkan", "OpenGL", "GLSL", "Compute"},
    Engine = {"ECS", "Scene Systems", "Materials", "Textures"},
    Tools = {"CMake", "Ninja", "Git", "RenderDoc"}
}

Education = {
    {
        Institute = "Fictional Game Technology Institute",
        Degree = "BSc Game Engine Development",
        Status = "Graduated"
    }
}

Projects = {
    {
        Title = "Ember Scene",
        Role = "Rendering Programmer",
        Description = "Fictional scene renderer focused on camera, mesh submission, materials, and depth testing.",
        Tech = {"C++", "Vulkan"}
    },
    {
        Title = "Mosaic Materials",
        Role = "Graphics Programmer",
        Description = "Material prototype testing indexed textures, normal maps, roughness, and runtime material changes.",
        Tech = {"C++", "GLSL", "Vulkan"}
    },
    {
        Title = "Orbit Shadows",
        Role = "Rendering Programmer",
        Description = "Shadow-map playground with directional and point-light experiments across synthetic scenes.",
        Tech = {"C++", "GLSL", "Depth"}
    },
    {
        Title = "Pulse Post",
        Role = "Graphics Programmer",
        Description = "Post-processing chain for tone mapping, bloom, vignette, and color transforms.",
        Tech = {"Vulkan", "GLSL", "Fullscreen Pass"}
    },
    {
        Title = "Slate Editor",
        Role = "Engine Programmer",
        Description = "Editor shell containing scene hierarchy, inspector data, viewport controls, and renderer diagnostics.",
        Tech = {"C++", "ImGui", "ImGuizmo"}
    },
    {
        Title = "Crate Import",
        Role = "Pipeline Programmer",
        Description = "Fictional asset importer testbed covering mesh and material metadata.",
        Tech = {"C++", "Assimp", "Lua"}
    }
}
LUA

cat >"$CV_DIR/12_all_features.lua" <<'LUA'
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
LUA

cat >"$CV_DIR/00_showcase.lua" <<'LUA'
-- ============================================================
-- CV GENERATOR SHOWCASE
-- ============================================================
-- This CV intentionally uses raw variable/field names as values.
-- It is meant to visually document the data model supported by
-- the renderer rather than represent a real person.
--
-- Example:
--     Name = "name"
--     customField = "customField"
-- ============================================================

local function title()
    return "title"
end

local function os()
    return "os"
end

PersonalInfo = {
    Name = "name",
    Title = title,
    Location = "location",
    OS = os,
    Email = "email",
    GitHub = "github",
    Summary = "summary"
}

Skills = {
    Languages = {"language", "language2", "language3"},
    Graphics = {"graphics", "graphics2", "graphics3"},
    Tools = {"tool", "tool2", "tool3"},
    Systems = {"system", "system2", "system3"}
}

Education = {
    {
        Institute = "institute",
        Degree = "degree",
        Status = "status"
    },
    {
        Institute = "institute2",
        Degree = "degree2",
        Status = "status2"
    }
}

Projects = {
    {
        Title = "projectTitle",
        Role = "projectRole",
        Description = "projectDescription",
        Tech = {"projectTech", "projectTech2", "projectTech3"}
    },
    {
        Title = "projectTitle2",
        Role = "projectRole2",
        Description = "projectDescription2",
        Tech = {"projectTech4", "projectTech5"}
    }
}

-- Custom scalar fields
CustomFields = {
    customField = "customField",
    customValue = "customValue",
    customNumber = 123,
    customBoolean = true
}

-- Custom arrays
CustomLists = {
    customList = {"customItem", "customItem2", "customItem3"},
    anotherList = {"anotherItem", "anotherItem2"}
}

-- Nested custom data
CustomData = {
    customGroup = {
        nestedField = "nestedField",
        nestedValue = "nestedValue",
        nestedNumber = 456,
        nestedBoolean = false
    },
    anotherGroup = {
        fieldA = "fieldA",
        fieldB = "fieldB",
        fieldC = "fieldC"
    }
}

-- Generic scalar array
Highlights = {
    "highlight",
    "highlight2",
    "highlight3",
    "highlight4"
}

-- Generic nested structure
Experience = {
    company = {
        name = "companyName",
        role = "companyRole",
        period = "companyPeriod"
    },
    responsibilities = {
        "responsibility",
        "responsibility2",
        "responsibility3"
    }
}

-- Additional scalar values
Metadata = {
    version = "version",
    category = "category",
    identifier = "identifier",
    url = "url"
}

-- Booleans and numeric values are included deliberately so the
-- generic renderer can be visually tested with different types.
Options = {
    enabled = true,
    featured = false,
    priority = 10
}
LUA

# Render every generated Lua CV in both formats.
count=0
failed=0

for lua_file in "$CV_DIR"/*.lua; do
  base="$(basename "$lua_file" .lua)"

  echo "==> $base"

  if "$CVGEN" "$lua_file" "$EXPORT_DIR/$base.pdf"; then
    :
  else
    echo "    PDF FAILED: $base" >&2
    failed=$((failed + 1))
    continue
  fi

  if "$CVGEN" "$lua_file" "$EXPORT_DIR/$base.png"; then
    :
  else
    echo "    PNG FAILED: $base" >&2
    failed=$((failed + 1))
    continue
  fi

  count=$((count + 1))
done

echo
echo "========================================"
echo "CV stress test complete"
echo "========================================"
echo "Lua CVs : $CV_DIR"
echo "Exports : $EXPORT_DIR"
echo "Profiles rendered successfully: $count"
echo "Failures: $failed"
echo

echo "Generated files:"
find "$EXPORT_DIR" -maxdepth 1 -type f -print | sort

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi
