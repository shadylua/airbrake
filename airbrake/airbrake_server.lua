
function updateAirbrakePlayer(updateType)
	if not isElement(client) or not updateType then return end
	if updateType == "start" then
		local clientAccount = getPlayerAccount(client)
		if isGuestAccount(clientAccount) then return end
		local clientAccountName = getAccountName(clientAccount)
		if not clientAccountName then return end
		if not isObjectInACLGroup("user."..clientAccountName,aclGetGroup("Admin")) and not isObjectInACLGroup("user."..clientAccountName,aclGetGroup("Console")) then return end
		setElementData(client,"airbraking",true)
		setElementData(client,"disabledamage",true)
		setElementAlpha(client,0)
	elseif updateType == "stop" then
		removeElementData(client,"airbraking")
		removeElementData(client,"disabledamage")
		setElementAlpha(client,255)
	end
end
addEvent("onUpdateAirbrakePlayer",true)
addEventHandler("onUpdateAirbrakePlayer",resourceRoot,updateAirbrakePlayer)


function stopAirBrakingServer(playerSource)
	if not isElement(playerSource) then return end
	triggerClientEvent(playerSource,"onAirBrakeStop",playerSource,true)
end

function startAirBrakingServer(playerSource)
	if not isElement(playerSource) then return end
	triggerClientEvent(playerSource,"onAirBrakeStart",playerSource,true)
end

function toggleAirbrakingServer(playerSource)
	local player = false
	if isElement(playerSource) then
		player = playerSource
	elseif isElement(client) then
		player = client
	end
	if not isElement(player) then return end
	if isGuestAccount(getPlayerAccount(player)) then return end
	local accountname = getAccountName(getPlayerAccount(player))
	if isObjectInACLGroup("user."..accountname,aclGetGroup("Admin")) or isObjectInACLGroup("user."..accountname,aclGetGroup("Console")) then
		if not getElementData(player,"airbraking") then
			startAirBrakingServer(player)
		else
			stopAirBrakingServer(player)
		end
	end
end

for key,player in pairs(getElementsByType("player")) do
	if isElement(player) then
		if not isGuestAccount(getPlayerAccount(player)) then
			if not isKeyBound(player,"num_0","down",toggleAirbrakingServer) then
				bindKey(player,"num_0","down",toggleAirbrakingServer)
			end
		end
	end
end

addEventHandler("onPlayerLogin",root,function()
	if not isKeyBound(source,"num_0","down",toggleAirbrakingServer) then
		bindKey(source,"num_0","down",toggleAirbrakingServer)
	end
end)

addEventHandler("onResourceStop",resourceRoot,function()
	for key,player in pairs(getElementsByType("player")) do
		if isElement(player) then
			unbindKey(player,"num_0","down",toggleAirbrakingServer)
			if getElementData(player,"airbraking") then
				removeElementData(player,"airbraking")
				removeElementData(player,"disabledamage")
				setElementAlpha(player,255)
			end
		end
	end
end)