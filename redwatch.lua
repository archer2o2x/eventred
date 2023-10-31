local eventred = require("eventred").create()

term.clear()

local width, height = term.getSize()
local message_window = window.create(term.current(), 2, 4, width - 2, height - 4)

term.setCursorPos(2, 2)
write("> ")

function writeToMessages(string)

    message_window.scroll(-1)

    message_window.setCursorPos(1, 1)

    message_window.write(string)

end

eventred:onEvent("rednet_message", function(id, data) 

    writeToMessages("[" .. data.name .. "] " .. textutils.serialise(data.value, { compact = true }))

end)

eventred:onEvent("key", function(key, isHeld) 

    if isHeld then return end

    if keys.enter == key then

        term.setCursorPos(2, 2)
        term.clearLine()
        write("> ")

        local command = read()

        local splitIndex = string.find(command, ",")

        writeToMessages("[" .. string.sub(command, 1, splitIndex - 1) .. "] " .. string.sub(command, splitIndex + 1), { compact = true })

        eventred:send(string.sub(command, 1, splitIndex - 1), textutils.unserialise(string.sub(command, splitIndex + 1)))

    end

end)

eventred:listen()