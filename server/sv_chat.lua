RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

AddEventHandler('_chat:messageEntered', function(author, color, message)
    if not message or not author then
        return
    end

    local function_check, msg = chatblacklist(message)
    if not function_check then
        TriggerEvent('chatMessage', source, author, message)
    
        if not WasEventCanceled() then
            TriggerClientEvent('chatMessage', -1, author,  { 255, 255, 255 }, message)
        end
        print(author .. '^7: ' .. message .. '^7')
    else 
        TriggerClientEvent('chatMessage', author, string.format(config.retrun_message, msg))
    end  
end)

AddEventHandler('__cfx_internal:commandFallback', function(command)
    local name = GetPlayerName(source)

    TriggerEvent('chatMessage', source, name, '/' .. command)

    if not WasEventCanceled() then
        TriggerClientEvent('chatMessage', -1, name, { 255, 255, 255 }, '/' .. command) 
    end

    CancelEvent()
end)


RegisterCommand('say', function(source, args, rawCommand)
    TriggerClientEvent('chatMessage', -1, (source == 0) and 'console' or GetPlayerName(source), { 255, 255, 255 }, rawCommand:sub(5))
end)

-- command suggestions for clients
local function refreshCommands(player)
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()

        local suggestions = {}

        for _, command in ipairs(registeredCommands) do
            if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then
                table.insert(suggestions, {
                    name = '/' .. command.name,
                    help = ''
                })
            end
        end

        TriggerClientEvent('chat:addSuggestions', player, suggestions)
    end
end

AddEventHandler('chat:init', function()
    refreshCommands(source)
end)

AddEventHandler('onServerResourceStart', function(resName)
    Wait(500)

    for _, player in ipairs(GetPlayers()) do
        refreshCommands(player)
    end
end)


-- function --
function chatblacklist(str)
    local blacklist = false;
    local word = nil
    for badword in ipairs(config.words) do
        if string.match(string.lower(str), config.words[badword]) then
          blacklist = true
          word = config.words[badword]
        else 
            if(blacklist == true) then
              blacklist = true
            else 
              blacklist = false;
            end
        end
    end
    return blacklist, word
end
