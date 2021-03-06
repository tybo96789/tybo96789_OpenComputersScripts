--**********
--Simple program that displays information about TE power cells on OC Glasses Addon
--Uses Adapter: Connected to a Thermal Expansion Energy cell
--Created by tybo96789
--Version 1.1
--Requires: OC Glasses Addon
--**********


--Required Dependences
local component = require("component")
local sides = require("sides")
local os = require("os")
local keyboard = require("keyboard")

--Component proxies
local cell = component.proxy(component.list("tile_thermalexpansion_cell")())
local glasses = component.proxy(component.list("glasses")())
local rs = component.proxy(component.list("redstone")())

--Global config
local updateInterval = 30
local control = true


--Power Monitor Control Config
local status = false
local offVal = 25
local onVal = 50
local overrideTimer = 300
local startTime = os.time()

--Glasses HUD config
local xOffset = 25
local yOffset = 25
local statusID 
local scale = 10


--Code

--Check if OC Glasses Terminal is attached to the computer
if not component.isAvailable("glasses") then
print("No OC Glasses Module detected!")
os.exit()
end

--Check if a TE Cell is attached to the computer
if cell == nil then
print("No TE Energy Cell Detected!")
os.exit()
end

while true do
local glassText = glasses.addTextLabel()

glassText.setPosition(xOffset,yOffset)
glassText.setScale(scale)
glassText.setColor(1,1,1)
statusID = glassText.getID()

--Print the current percentage of power remaining in the cell
local pwrlvl = cell.getEnergyStored()/cell.getMaxEnergyStored()*100
print("[Uptime: ".. os.difftime(os.time(),startTime) .. "] ".. pwrlvl .. "%")
glassText.setText("[Uptime: ".. os.difftime(os.time(),startTime) .. "] ".. pwrlvl .. "%")

if status == true then
print("Hold \'Control\' Key until Override Message is shown to restore power")
os.sleep(5)
end


--If user is holding down the 'Control' key and it is in lower power mode, restore power and recheck status again for the specified wait period 
if (keyboard.isControlDown() and status == true) then
rs.setOutput(rsSide,0)
print("Override Requested! Resuming Automation")
print("System will recheck status in " .. overrideTimer .. " seconds")
os.sleep(overrideTimer)
pwrlvl = cell.getEnergyStored()/cell.getMaxEnergyStored()*100
print(pwrlvl .. "%")
end

--If power percentage is below the specified off value, send redstone signal
if (pwrlvl < offVal and status == false and control == true) then
rs.setOutput(rsSide,15)
print("Power Levels Critical! Pasuing Automation!")

status = true
end

--If power percentages is above the specified on value, do not continue to send redstone signal
if(pwrlvl > onVal and status == true and control == true) then
rs.setOutput(rsSide,0)
print("Power Levels Normal! Resuming Automation!")
status = false
end

--Sleep the program for the specified amount of time
os.sleep(updateInterval)

print("Hold \'Alt\' Key until Goodbye message is shown to terminate program")

--If user is holding down the 'Control' key remove the on screen status and terminate the program
if keyboard.isAltDown() then
glasses.removeObject(statusID)
os.exit()
end

glasses.removeObject(statusID)
end
