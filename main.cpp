// cvgen.cpp  -  Lua -> single-page CV (PDF or PNG) via headless Chrome
// Build (macOS):
//   brew install lua pkg-config
//   clang++ -std=c++17 -O2 cvgen.cpp -o cvgen $(pkg-config --cflags --libs lua)
// Run:
//   ./cvgen cv.lua resume.pdf     (or resume.png)

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <set>
#include <algorithm>
#include <cstdlib>
#include <cctype>
#include <filesystem>
#include <unistd.h>

extern "C" {
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
}

// Lua 5.1 / LuaJIT compatibility (5.2 - 5.4 work natively)
#if LUA_VERSION_NUM < 502
#define lua_rawlen lua_objlen
#define LUA_OK 0
#define lua_pushglobaltable(L) lua_pushvalue(L, LUA_GLOBALSINDEX)
static int lua_absindex(lua_State* L, int i) {
    return (i > 0 || i <= LUA_REGISTRYINDEX) ? i : lua_gettop(L) + i + 1;
}
#endif

namespace fs = std::filesystem;

// ---------------------------------------------------------------- helpers

static std::string esc(const std::string& s) {
    std::string r;
    for (char c : s) {
        switch (c) {
            case '&': r += "&amp;"; break;
            case '<': r += "&lt;"; break;
            case '>': r += "&gt;"; break;
            case '"': r += "&quot;"; break;
            case '\n': r += "<br>"; break;
            case '\r': break;
            default: r += c;
        }
    }
    return r;
}

static std::string shq(const std::string& s) {
    std::string r = "'";
    for (char c : s) { if (c == '\'') r += "'\\''"; else r += c; }
    return r + "'";
}

std::string formatCategoryTitle(const std::string& input) {
    std::string res;
    for (size_t i = 0; i < input.size(); ++i) {
        unsigned char c = input[i];
        if (i > 0 && std::isupper(c) &&
            (std::islower((unsigned char)input[i - 1]) ||
             (i + 1 < input.size() && std::islower((unsigned char)input[i + 1])))) {
            res += ' ';
        }
        res += (char)std::toupper(c);
    }
    return esc(res);
}

// string / number / boolean at idx -> text (never mutates the original stack value)
static bool scalar(lua_State* L, int idx, std::string& out) {
    int t = lua_type(L, idx);
    if (t == LUA_TSTRING || t == LUA_TNUMBER) {
        lua_pushvalue(L, idx);
        size_t n;
        const char* s = lua_tolstring(L, -1, &n);
        out.assign(s, n);
        lua_pop(L, 1);
        return true;
    }
    if (t == LUA_TBOOLEAN) { out = lua_toboolean(L, idx) ? "true" : "false"; return true; }
    return false;
}

// table field as string; functions are called (as in the original)
static std::string field(lua_State* L, int tbl, const char* key) {
    tbl = lua_absindex(L, tbl);
    std::string v;
    lua_getfield(L, tbl, key);
    if (lua_isfunction(L, -1)) {
        lua_pushvalue(L, -1);
        if (lua_pcall(L, 0, 1, 0) == LUA_OK) scalar(L, -1, v);
        lua_pop(L, 1);
    } else {
        scalar(L, -1, v);
    }
    lua_pop(L, 1);
    return v;
}

static bool isArray(lua_State* L, int idx) {
    return lua_istable(L, idx) && lua_rawlen(L, idx) > 0;
}

// true if idx is an array whose items are all scalars
static bool scalarArray(lua_State* L, int idx, std::vector<std::string>& out) {
    idx = lua_absindex(L, idx);
    if (!isArray(L, idx)) return false;
    size_t len = lua_rawlen(L, idx);
    for (size_t i = 1; i <= len; ++i) {
        lua_rawgeti(L, idx, (int)i);
        std::string v;
        bool ok = scalar(L, -1, v);
        lua_pop(L, 1);
        if (!ok) { out.clear(); return false; }
        if (!v.empty()) out.push_back(v);
    }
    return true;
}

static std::vector<std::string> sortedKeys(lua_State* L, int idx) {
    idx = lua_absindex(L, idx);
    std::vector<std::string> keys;
    lua_pushnil(L);
    while (lua_next(L, idx) != 0) {
        if (lua_type(L, -2) == LUA_TSTRING) keys.push_back(lua_tostring(L, -2));
        lua_pop(L, 1);
    }
    std::sort(keys.begin(), keys.end());
    return keys;
}

static std::string tags(const std::vector<std::string>& v, const char* cls = "tag") {
    std::string r;
    for (auto& t : v) r += std::string("<span class=\"") + cls + "\">" + esc(t) + "</span>";
    return r;
}

static std::string sectionBlock(const std::string& title, const std::string& inner) {
    return "<div class=\"section-block\"><div class=\"section-title\"><span class=\"slash\">///</span> " +
           title + "</div>" + inner + "</div>";
}

// ---------------------------------------------------------------- renderers

bool renderGeneric(lua_State* L, int idx, std::stringstream& html) {
    idx = lua_absindex(L, idx);
    bool any = false;

    if (isArray(L, idx)) {
        size_t len = lua_rawlen(L, idx);
        for (size_t i = 1; i <= len; ++i) {
            lua_rawgeti(L, idx, (int)i);
            if (lua_istable(L, -1)) {
                if (renderGeneric(L, -1, html)) any = true;
            } else {
                std::string v;
                if (scalar(L, -1, v) && !v.empty()) {
                    html << "<div class=\"generic-item\"><span class=\"bullet\">❯</span> " << esc(v) << "</div>";
                    any = true;
                }
            }
            lua_pop(L, 1);
        }
    } else if (lua_istable(L, idx)) {
        for (const auto& key : sortedKeys(L, idx)) {
            lua_getfield(L, idx, key.c_str());
            std::string k = "<span class=\"key\">" + esc(key) + ":</span> ";
            std::vector<std::string> arr;
            if (lua_istable(L, -1)) {
                if (scalarArray(L, -1, arr)) {
                    if (!arr.empty()) {
                        html << "<div class=\"custom-entry\">" << k << "<div class=\"tag-group\">" << tags(arr) << "</div></div>";
                        any = true;
                    }
                } else {
                    std::stringstream sub;
                    if (renderGeneric(L, -1, sub)) {
                        html << "<div class=\"custom-entry\">" << k << "<div class=\"sub-block\">" << sub.str() << "</div></div>";
                        any = true;
                    }
                }
            } else {
                std::string v;
                if (scalar(L, -1, v) && !v.empty()) {
                    bool isBool = lua_type(L, -1) == LUA_TBOOLEAN;
                    html << "<div class=\"custom-entry\">" << k << "<span class=\"val" << (isBool ? " bool" : "")
                         << "\">" << esc(v) << "</span></div>";
                    any = true;
                }
            }
            lua_pop(L, 1);
        }
    }
    return any;
}

std::string renderPersonalInfo(lua_State* L, int idx) {
    std::string name = field(L, idx, "Name"), title = field(L, idx, "Title"),
                location = field(L, idx, "Location"), os = field(L, idx, "OS"),
                email = field(L, idx, "Email"), github = field(L, idx, "GitHub"),
                summary = field(L, idx, "Summary");

    if (name.empty() && title.empty() && location.empty() && os.empty() &&
        email.empty() && github.empty() && summary.empty())
        return "";

    std::stringstream h;
    h << "<div class=\"header-banner\"><div class=\"name-title\">";
    if (!name.empty())    h << "<h1>" << esc(name) << "</h1>";
    if (!title.empty())   h << "<div class=\"subtitle\">" << esc(title) << "</div>";
    if (!summary.empty()) h << "<div class=\"summary-text\">" << esc(summary) << "</div>";
    h << "</div>";
    if (!location.empty() || !os.empty() || !email.empty() || !github.empty()) {
        h << "<div class=\"meta-grid\">";
        if (!location.empty()) h << "<div><span class=\"prompt\">loc:</span> "  << esc(location) << "</div>";
        if (!os.empty())       h << "<div><span class=\"prompt\">env:</span> "  << esc(os) << "</div>";
        if (!email.empty())    h << "<div><span class=\"prompt\">mail:</span> " << esc(email) << "</div>";
        if (!github.empty())   h << "<div><span class=\"prompt\">git:</span> "  << esc(github) << "</div>";
        h << "</div>";
    }
    h << "</div>";
    return h.str();
}

std::string renderSkills(lua_State* L, int idx) {
    idx = lua_absindex(L, idx);
    std::stringstream rows;
    bool any = false;
    for (const auto& cat : sortedKeys(L, idx)) {
        lua_getfield(L, idx, cat.c_str());
        std::vector<std::string> items;
        if (scalarArray(L, -1, items) && !items.empty()) {
            any = true;
            rows << "<div class=\"skill-row\"><span class=\"skill-cat\">" << esc(cat)
                 << ":</span><div class=\"tag-group\">" << tags(items) << "</div></div>";
        }
        lua_pop(L, 1);
    }
    return any ? sectionBlock("SKILLS", "<div class=\"skills-card\">" + rows.str() + "</div>") : "";
}

std::string renderProjects(lua_State* L, int idx) {
    idx = lua_absindex(L, idx);
    size_t len = lua_rawlen(L, idx);
    std::stringstream cards;
    bool any = false;

    for (size_t i = 1; i <= len; ++i) {
        lua_rawgeti(L, idx, (int)i);
        if (lua_istable(L, -1)) {
            int p = lua_gettop(L);
            std::string title = field(L, p, "Title"), role = field(L, p, "Role"), desc = field(L, p, "Description");
            if (!title.empty() || !desc.empty() || !role.empty()) {
                any = true;
                cards << "<div class=\"card\">";
                if (!title.empty() || !role.empty()) {
                    cards << "<div class=\"card-header\">";
                    if (!title.empty()) cards << "<span class=\"proj-title\">" << esc(title) << "</span> ";
                    if (!role.empty())  cards << "<span class=\"proj-role\">(" << esc(role) << ")</span>";
                    cards << "</div>";
                }
                if (!desc.empty()) cards << "<div class=\"proj-desc\">" << esc(desc) << "</div>";
                lua_getfield(L, p, "Tech");
                std::vector<std::string> tech;
                if (scalarArray(L, -1, tech) && !tech.empty())
                    cards << "<div class=\"tag-group\">" << tags(tech, "tag tech") << "</div>";
                lua_pop(L, 1);
                cards << "</div>";
            }
        }
        lua_pop(L, 1);
    }
    return any ? sectionBlock("PROJECTS", "<div class=\"cards-stack\">" + cards.str() + "</div>") : "";
}

std::string renderEducation(lua_State* L, int idx) {
    idx = lua_absindex(L, idx);
    size_t len = lua_rawlen(L, idx);
    std::stringstream cards;
    bool any = false;

    for (size_t i = 1; i <= len; ++i) {
        lua_rawgeti(L, idx, (int)i);
        if (lua_istable(L, -1)) {
            int e = lua_gettop(L);
            std::string inst = field(L, e, "Institute"), deg = field(L, e, "Degree"), st = field(L, e, "Status");
            if (!inst.empty() || !deg.empty() || !st.empty()) {
                any = true;
                cards << "<div class=\"card\">";
                if (!deg.empty())  cards << "<div class=\"proj-title\">" << esc(deg) << "</div>";
                if (!inst.empty()) cards << "<div class=\"proj-desc\">" << esc(inst) << "</div>";
                if (!st.empty())   cards << "<div class=\"status-tag\">Status: " << esc(st) << "</div>";
                cards << "</div>";
            }
        }
        lua_pop(L, 1);
    }
    return any ? sectionBlock("EDUCATION", "<div class=\"cards-stack\">" + cards.str() + "</div>") : "";
}

// ---------------------------------------------------------------- page

static const char* PAGE_HEAD = R"HTML(<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&display=swap');
@page { size: A4 portrait; margin: 0; }
* { box-sizing: border-box; margin: 0; padding: 0; }
html { background: #0d0d0d; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
body {
    width: 210mm; height: 296mm; overflow: hidden; background: #0d0d0d; color: #e6e6e6;
    font-family: 'JetBrains Mono', 'SF Mono', Menlo, Monaco, Consolas, monospace;
    overflow-wrap: anywhere;
}
.page { width: 210mm; height: 296mm; padding: 8mm 10mm; overflow: hidden; }

/* Everything below is in em, so the script only has to change this one font-size */
#content { font-size: 11.33px; line-height: 1.3; width: 100%; }

.header-banner {
    background: #141414; border: 1px solid #262626; border-left: .35em solid #a6e3a1;
    padding: .7em 1.05em; display: flex; justify-content: space-between; align-items: flex-start;
    gap: 1.2em; border-radius: .35em; margin-bottom: .9em;
}
.name-title { flex: 1; min-width: 0; }
.name-title h1 { font-size: 1.9em; color: #fff; font-weight: 700; line-height: 1.1; }
.subtitle { color: #89b4fa; font-size: 1.06em; margin-top: .2em; font-weight: 500; }
.summary-text { color: #b0b0b0; font-size: .92em; margin-top: .35em; line-height: 1.25; }
.meta-grid { font-size: .94em; text-align: right; line-height: 1.35; color: #a0a0a0; max-width: 45%; flex-shrink: 0; }
.prompt { color: #a6e3a1; font-weight: bold; }

.main-grid { display: grid; grid-template-columns: 1fr 1.1fr; gap: 1.2em; align-items: start; }
.main-grid.single { grid-template-columns: 1fr; }
.col { display: flex; flex-direction: column; gap: .9em; min-width: 0; }

.cards-stack { display: flex; flex-direction: column; gap: .7em; }
.section-title {
    color: #fff; font-weight: 700; border-bottom: 1px dashed #333; padding-bottom: .25em;
    margin-bottom: .65em; text-transform: uppercase; font-size: 1.04em; letter-spacing: .06em;
}
.slash { color: #89b4fa; font-weight: bold; }

.card {
    background: #121212; border: 1px solid #222; border-left: .3em solid #cba6f7;
    padding: .65em 1em; border-radius: .3em;
}
.skills-card { background: #121212; border: 1px solid #222; padding: .65em 1em; border-radius: .3em; }
.skill-row { margin-bottom: .5em; }
.skill-row:last-child { margin-bottom: 0; }
.skill-cat { color: #89b4fa; font-weight: bold; display: block; margin-bottom: .25em; font-size: .97em; }

.proj-title { color: #fff; font-weight: 700; font-size: 1.04em; }
.proj-role { color: #a0a0a0; font-size: .92em; }
.proj-desc { color: #ccc; margin: .25em 0 .45em 0; font-size: .94em; line-height: 1.25; }

.tag-group { display: flex; flex-wrap: wrap; gap: .35em; margin-top: .25em; }
.tag { background: #1a1a1a; border: 1px solid #2a2a2a; color: #e0e0e0; padding: 0 .5em; font-size: .88em; border-radius: .25em; }
.tag.tech { border-color: #89b4fa; color: #89b4fa; }
.status-tag { color: #a6e3a1; font-size: .92em; font-weight: 500; margin-top: .25em; }

.custom-entry { font-size: .94em; margin-bottom: .25em; }
.key { color: #89b4fa; font-weight: bold; }
.val { color: #ddd; }
.generic-item { color: #ccc; font-size: .94em; margin-bottom: .15em; }
.bullet { color: #a6e3a1; }
.sub-block { margin-left: .7em; border-left: 1px solid #333; padding-left: .7em; margin-top: .25em; }
</style>
</head>
<body>
<div class="page"><div id="content">
)HTML";

static const char* PAGE_FOOT = R"HTML(
</div></div>
<script>
/* Auto-fit: finds the largest scale (and best column split) that keeps everything on one A4 page. */
(function () {
    var BASE = 11.33, MIN = 0.35, MAX = 1.35;

    function fit() {
        var page = document.querySelector('.page'),
            content = document.getElementById('content'),
            grid = document.getElementById('grid'),
            L = document.getElementById('left'),
            R = document.getElementById('right');
        var cs = getComputedStyle(page);
        var avail = page.clientHeight - parseFloat(cs.paddingTop) - parseFloat(cs.paddingBottom);

        var blocks = Array.prototype.slice.call(grid.querySelectorAll('.section-block'));
        var n = blocks.length;

        function place(k) {
            blocks.forEach(function (b, i) { (i < k ? L : R).appendChild(b); });
            grid.classList.toggle('single', k === 0 || k === n);
            [L, R].forEach(function (c) { c.style.display = c.children.length ? '' : 'none'; });
        }
        function height(s, k) {
            content.style.fontSize = (BASE * s) + 'px';
            place(k);
            return content.getBoundingClientRect().height;
        }
        // candidate splits: two-column splits first, single column only if clearly better
        var ks = [];
        for (var i = 1; i < n; i++) ks.push(i);
        ks.push(0); if (n > 0) ks.push(n);

        function best(s) {
            var bk = ks[0], bh = Infinity;
            ks.forEach(function (k) {
                var h = height(s, k);
                if (h < bh - 2) { bh = h; bk = k; }
            });
            return { k: bk, h: bh };
        }

        var s;
        if (best(MAX).h <= avail) {
            s = MAX;
        } else {
            var lo = MIN, hi = MAX;
            for (var j = 0; j < 18; j++) {
                var mid = (lo + hi) / 2;
                if (best(mid).h <= avail) lo = mid; else hi = mid;
            }
            s = lo * 0.99;   // small safety margin
        }
        var r = best(s);
        height(s, r.k);
        if (r.h > avail) console.warn('CV content does not fit even at minimum scale');
        document.documentElement.setAttribute('data-scale', s.toFixed(3));
    }

    fit();
    var loads = ['400', '500', '700'].map(function (w) {
        return document.fonts.load(w + ' 12px "JetBrains Mono"', 'Aa/❯').catch(function () {});
    });
    Promise.all(loads).then(function () { return document.fonts.ready; }).then(fit, fit);
})();
</script>
</body>
</html>)HTML";

std::string generateHTML(lua_State* L) {
    std::string header, left, right;

    lua_getglobal(L, "PersonalInfo");
    if (lua_istable(L, -1)) header = renderPersonalInfo(L, lua_gettop(L));
    lua_pop(L, 1);

    lua_getglobal(L, "Skills");
    if (lua_istable(L, -1)) left += renderSkills(L, lua_gettop(L));
    lua_pop(L, 1);

    lua_getglobal(L, "Education");
    if (isArray(L, -1)) left += renderEducation(L, lua_gettop(L));
    lua_pop(L, 1);

    // Custom sections: any other global table, in the order they were defined in cv.lua
    std::vector<std::string> order;
    lua_getglobal(L, "__cv_order");
    if (lua_istable(L, -1)) {
        size_t n = lua_rawlen(L, -1);
        for (size_t i = 1; i <= n; ++i) {
            lua_rawgeti(L, -1, (int)i);
            if (lua_type(L, -1) == LUA_TSTRING) order.push_back(lua_tostring(L, -1));
            lua_pop(L, 1);
        }
    }
    lua_pop(L, 1);

    std::set<std::string> skip = {"PersonalInfo", "Skills", "Projects", "Education"}, seen;
    for (const auto& key : order) {
        if (key.empty() || key[0] == '_' || skip.count(key) || !seen.insert(key).second) continue;
        lua_getglobal(L, key.c_str());
        if (lua_istable(L, -1)) {
            std::stringstream buf;
            if (renderGeneric(L, -1, buf))
                left += sectionBlock(formatCategoryTitle(key), "<div class=\"card\">" + buf.str() + "</div>");
        }
        lua_pop(L, 1);
    }

    lua_getglobal(L, "Projects");
    if (isArray(L, -1)) right += renderProjects(L, lua_gettop(L));
    lua_pop(L, 1);

    return std::string(PAGE_HEAD) + header +
           "<div class=\"main-grid\" id=\"grid\"><div class=\"col\" id=\"left\">" + left +
           "</div><div class=\"col\" id=\"right\">" + right + "</div></div>" + PAGE_FOOT;
}

// ---------------------------------------------------------------- browser

std::string findBrowserExecutable() {
    std::vector<std::string> abs = {
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        "/Applications/Chromium.app/Contents/MacOS/Chromium",
        "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
        "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
        "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"
    };
    for (auto& p : abs) if (fs::exists(p)) return shq(p);

    for (const char* name : {"google-chrome", "chromium", "chromium-browser", "chrome"}) {
        std::string c = std::string("command -v ") + name + " > /dev/null 2>&1";
        if (std::system(c.c_str()) == 0) return name;
    }
    return "";
}

int main(int argc, char* argv[]) {
    std::string luaFile = "cv.lua";
    std::string outFile = "resume.pdf";
    if (argc >= 2) luaFile = argv[1];
    if (argc >= 3) outFile = argv[2];

    if (!fs::exists(luaFile)) {
        std::cerr << "Error: Input Lua file '" << luaFile << "' not found.\n";
        return 1;
    }

    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    // Record the order in which globals are defined, so custom sections keep file order
    luaL_dostring(L,
        "__cv_order = {}\n"
        "setmetatable(_G, {__newindex = function(t, k, v)\n"
        "  rawset(t, k, v)\n"
        "  if type(k) == 'string' then __cv_order[#__cv_order + 1] = k end\n"
        "end})\n");

    if (luaL_dofile(L, luaFile.c_str()) != LUA_OK) {
        std::cerr << "Lua Runtime/Syntax Error: " << lua_tostring(L, -1) << "\n";
        lua_close(L);
        return 1;
    }

    // Support "return { PersonalInfo = ..., Skills = ... }" style files too
    if (lua_gettop(L) > 0 && lua_istable(L, -1)) {
        int t = lua_gettop(L);
        for (const auto& k : sortedKeys(L, t)) {
            lua_getfield(L, t, k.c_str());
            lua_setglobal(L, k.c_str());
        }
    }

    std::string html = generateHTML(L);
    lua_close(L);

    std::string browser = findBrowserExecutable();
    if (browser.empty()) {
        std::cerr << "Error: Chrome/Chromium (or Brave/Edge) is required for rendering.\n";
        return 1;
    }

    fs::path work = fs::temp_directory_path() / ("cvgen_" + std::to_string(getpid()));
    fs::create_directories(work);
    fs::path htmlPath = work / "cv.html";
    { std::ofstream o(htmlPath); o << html; }

    fs::path outAbs = fs::absolute(outFile);
    std::string ext = outAbs.extension().string();
    std::transform(ext.begin(), ext.end(), ext.begin(), [](unsigned char c) { return std::tolower(c); });
    bool png = (ext == ".png");

    std::string cmd = browser +
        " --headless --disable-gpu --no-sandbox --hide-scrollbars"
        " --user-data-dir=" + shq((work / "profile").string()) +
        " --virtual-time-budget=5000 --run-all-compositor-stages-before-draw";
    if (png) {
        // A4 at 96 dpi = 794 x 1123 px, rendered at 2x
        cmd += " --window-size=794,1123 --force-device-scale-factor=2 --screenshot=" + shq(outAbs.string());
    } else {
        cmd += " --no-pdf-header-footer --print-to-pdf-no-header --print-to-pdf=" + shq(outAbs.string());
    }
    cmd += " " + shq("file://" + htmlPath.string()) + " > /dev/null 2>&1";

    std::system(cmd.c_str());
    std::error_code ec;
    fs::remove_all(work, ec);

    if (fs::exists(outAbs) && fs::file_size(outAbs) > 0) {
        std::cout << "Rendered " << luaFile << " -> " << outFile << " (auto-fit, single page)\n";
        return 0;
    }
    std::cerr << "Rendering failed.\n";
    return 1;
}
