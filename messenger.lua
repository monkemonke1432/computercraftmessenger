local modem = peripheral.find("modem") or error("No modem attached", 0)

-- Configuration
local SEND_CHANNEL = 15
local RECEIVE_CHANNEL = 43

-- User settings
local nickname = "Computer_" .. os.getComputerID()

-- Open our receiving channel
modem.open(RECEIVE_CHANNEL)

print("=== ComputerCraft Chat ===")
print("Your nickname: " .. nickname)
print("Commands: /setnick <name>, /exit")
print("Type messages and press Enter to send")
print("--------------------------")

-- Function to handle incoming messages
local function receiveMessages()
  while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    if channel == RECEIVE_CHANNEL and type(message) == "table" then
      -- Clear current line and print received message
      term.clearLine()
      term.setCursorPos(1, select(2, term.getCursorPos()))
      print("[" .. message.nick .. "]: " .. message.text)
      write("> ") -- Redraw input prompt
    end
  end
end

-- Function to handle user input and sending
local function sendMessages()
  while true do
    write("> ")
    local input = read()
    
    -- Handle commands
    if input:lower() == "/exit" then
      print("Closing chat...")
      modem.close(RECEIVE_CHANNEL)
      return
    elseif input:sub(1, 9):lower() == "/setnick " then
      local newNick = input:sub(10):match("^%s*(.-)%s*$") -- Trim whitespace
      if newNick ~= "" then
        nickname = newNick
        print("Nickname changed to: " .. nickname)
      else
        print("Usage: /setnick <nickname>")
      end
    elseif input ~= "" then
      -- Send message with nickname
      local messageData = {
        nick = nickname,
        text = input
      }
      modem.transmit(SEND_CHANNEL, RECEIVE_CHANNEL, messageData)
      
      -- Move up one line and show our message
      local x, y = term.getCursorPos()
      term.setCursorPos(1, y - 1)
      term.clearLine()
      print("[You]: " .. input)
    end
  end
end

-- Run both functions in parallel
parallel.waitForAny(receiveMessages, sendMessages)