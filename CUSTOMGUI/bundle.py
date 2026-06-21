import os
import re

# Normalize require path function
def normalize_require_path(current_module_path, require_path):
    parts = current_module_path.split('/')
    dir_parts = parts[:-1]
    
    req_parts = require_path.split('/')
    for part in req_parts:
        if part == '.':
            continue
        elif part == '..':
            if dir_parts:
                dir_parts.pop()
        else:
            dir_parts.append(part)
            
    return '/'.join(dir_parts)

def get_module_name(file_path):
    # Normalize path separators
    normalized_path = file_path.replace("\\", "/")
    if normalized_path.startswith("src/"):
        return normalized_path[4:-4]
    elif normalized_path.startswith("build/"):
        return normalized_path[:-4]
    return normalized_path[:-4]

def bundle():
    base_dir = r"C:\Users\User\OneDrive\Desktop\Scripts\DemonfallSources\PLUTONIUMDEMONFALLSCRIPT\CUSTOMGUI"
    src_dir = os.path.join(base_dir, "src")
    build_dir = os.path.join(base_dir, "build")
    output_file = os.path.join(base_dir, r"dist\main.lua")
    
    # Normalizing paths
    src_files = []
    for root, _, files in os.walk(src_dir):
        for f in files:
            if f.endswith(".lua"):
                src_files.append(os.path.relpath(os.path.join(root, f), base_dir))
                
    # Add package.lua
    src_files.append(r"build\package.lua")
    
    modules = {}
    require_re = re.compile(r'require\s*\(\s*["\']([^"\']+)["\']\s*\)|require\s*["\']([^"\']+)["\']')
    
    for rel_path in src_files:
        normalized_rel_path = rel_path.replace("\\", "/")
        mod_name = get_module_name(normalized_rel_path)
        
        full_path = os.path.join(base_dir, rel_path)
        with open(full_path, "r", encoding="utf-8") as f:
            content = f.read()
            
        # Replace require statements
        def repl(match):
            req_path = match.group(1) or match.group(2)
            resolved = normalize_require_path(mod_name, req_path)
            return f'require("{resolved}")'
            
        content_replaced = require_re.sub(repl, content)
        modules[mod_name] = content_replaced
 
    # Ensure output dir exists
    out_dir = os.path.dirname(output_file)
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

    # Write bundle
    with open(output_file, "w", encoding="utf-8") as out:
        out.write("-- [[ CUSTOMGUI Custom Bundle ]]\n")
        out.write("local modules = {}\n")
        out.write("local cache = {}\n\n")
        
        out.write("local function require(path)\n")
        out.write("    if cache[path] ~= nil then\n")
        out.write("        return cache[path]\n")
        out.write("    end\n")
        out.write("    local f = modules[path]\n")
        out.write("    if not f then\n")
        out.write("        error(\"module '\" .. tostring(path) .. \"' not found in bundle\")\n")
        out.write("    end\n")
        out.write("    local res = f()\n")
        out.write("    if res == nil then\n")
        out.write("        res = true\n") # cache true if module returns nothing
        out.write("    end\n")
        out.write("    cache[path] = res\n")
        out.write("    return res\n")
        out.write("end\n\n")
        
        for mod_name, code in modules.items():
            out.write(f'modules["{mod_name}"] = function()\n')
            # Indent code lines for readability
            indented_code = "\n".join("    " + line for line in code.splitlines())
            out.write(indented_code + "\n")
            out.write("end\n\n")
            
        out.write("return require(\"Init\")\n")
        
    print(f"Bundle written to {output_file}")
 
if __name__ == "__main__":
    bundle()
