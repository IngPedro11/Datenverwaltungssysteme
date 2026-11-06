function CodeBlock(block)
  -- SQL-Dateien einbinden
  if block.classes:includes("include-sql") then

    local path = block.text:match("^%s*(.-)%s*$")
    local file = io.open(path, "r")

    if not file then
      error("SQL-Datei nicht gefunden: " .. path)
    end

    local content = file:read("*a")
    file:close()

    return pandoc.CodeBlock(content, pandoc.Attr("", {"sql"}))

  end

end