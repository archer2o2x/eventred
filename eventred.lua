function on(self, name, callback)

    local record = { name = name, func = callback }

    table.insert(self.rednetCallbacks, record)

end

function remove(self, name)

    for i, name in ipairs(self.rednetCallbacks) do

        if name == event then

            table.remove(self.rednetCallbacks, i)

        end

    end

end

function onEvent(self, name, callback)

    local record = { name = name, func = callback }

    table.insert(self.eventCallbacks, record)

end

function removeEvent(self, name)

    for i, name in ipairs(self.eventCallbacks) do

        if name == event then

            table.remove(self.eventCallbacks, i)

        end

    end

end

function send(self, name, data)

    local payload = {name = name, value = data}

    rednet.broadcast(payload)

end

function handle_rednet(self, id, data)

    for _, callback in ipairs(self.rednetCallbacks) do

        if callback.name == data.name then

            callback.func(data.value, data.name, id)

        end

    end

end

function handle_event(self, name, args)

    for i, record in ipairs(self.eventCallbacks) do

        if record.name == name then

            if record.func(table.unpack(args)) == self.unsubscribe then

                table.remove(self.eventCallbacks, i)

            end

        end

    end

end

function listen(self, pullRaw)

    self.running = true

    while self.running do

        local eventPull = os.pullEvent

        if pullRaw then eventPull = os.pullEventRaw end

        local args = {eventPull()}

        local eventName = args[1]

        table.remove(args, 1)

        self:handle_event(eventName, args)

        if eventName == "rednet_message" then

            self:handle_rednet(args[1], args[2])

        end

    end

end

function stopListening(self)

    self.running = false

end

function create()

    if not rednet.isOpen() then peripheral.find("modem", rednet.open) end
    if not rednet.isOpen() then return false end

    return {
        rednetCallbacks = {},
        eventCallbacks = {},

        handle_rednet = handle_rednet,
        handle_event = handle_event,

        unsubscribe = {unsubscribe=true},

        on = on,
        remove = remove,
        onEvent = onEvent,
        removeEvent = removeEvent,

        send = send,

        listen = listen,
        stopListening = stopListening
    }

end

return { create = create }