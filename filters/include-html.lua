function CodeBlock(block)
  if block.classes:includes("include-html") then

    --[[local handle = io.popen("pwd")
    local cwd = handle:read("*a")
    handle:close()

    print("Aktuelles Arbeitsverzeichnis: " .. cwd)]]

    local path = block.text:match("^%s*(.-)%s*$")
    local file = io.open(path, "r")

    if not file then
      error("HTML-Datei nicht gefunden: " .. path)
    end

    local content = file:read("*a")
    file:close()

    return pandoc.RawBlock("html", content)
  end
end