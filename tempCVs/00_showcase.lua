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
