
local speed = 0
local strafespeed = 0
local rotX,rotY = 0,0
local velocityX,velocityY,velocityZ = 0,0,0
local airbrakeFreeze = false
local airBrakeStartPosX,airBrakeStartPosY,airBrakeStartPosZ = 0,0,0

function checkActiveWindows()
	if isCursorShowing() or isMainMenuActive() or isConsoleActive() then
		return true
	end
	return false
end

function AirbrakeRender()
	if not airbrakeFreeze and checkActiveWindows() then
		setElementFrozen(localPlayer,true)
		airbrakeFreeze = true
	elseif airbrakeFreeze then
		setElementFrozen(localPlayer,false)
		airbrakeFreeze = false
	end
	if isElementFrozen(localPlayer) then return end
    local cameraAngleX = rotX
    local cameraAngleY = rotY
    local airbrakeAngleZ = math.sin(cameraAngleY)
    local airbrakeAngleY = math.cos(cameraAngleY) * math.cos(cameraAngleX)
    local airbrakeAngleX = math.cos(cameraAngleY) * math.sin(cameraAngleX)
    local camPosX,camPosY,camPosZ = getCameraMatrix()
    local camTargetX = camPosX + airbrakeAngleX * 100
    local camTargetY = camPosY + airbrakeAngleY * 100
    local camTargetZ = camPosZ + airbrakeAngleZ * 100
	local speedKeyPressed = false
	local strafeSpeedKeyPressed = false
	local acceleration = 0.3
	local decceleration = 0.15
    local mspeed = 2
    if getKeyState("num_9") or getKeyState("lshift") then
        mspeed = 12
	elseif getKeyState("num_7") or getKeyState("lctrl") then
		mspeed = 0.2
    end
	if getKeyState("num_8") or getKeyState("w") or getKeyState("arrow_u") then
		speed = speed + acceleration 
	    speedKeyPressed = true
	elseif getKeyState("num_2") or getKeyState("s") or getKeyState("arrow_d") then
		speed = speed - acceleration 
	    speedKeyPressed = true
	end
	if getKeyState("num_4") or getKeyState("a") or getKeyState("arrow_l") then
	    if (strafespeed < 0) then
	        strafespeed = 0
	    end
	    strafespeed = strafespeed + acceleration / 2
	    strafeSpeedKeyPressed = true
	elseif getKeyState("num_6") or getKeyState("d") or getKeyState("arrow_r") then
	    if (strafespeed > 0) then
	        strafespeed = 0
	    end
	    strafespeed = strafespeed - acceleration / 2
	    strafeSpeedKeyPressed = true
	end
	if not speedKeyPressed then
		if (speed > 0) then
			speed = speed - decceleration
		elseif (speed < 0) then
			speed = speed + decceleration
		end
	end
	if not strafeSpeedKeyPressed then
		if (strafespeed > 0) then
			strafespeed = strafespeed - decceleration
		elseif (strafespeed < 0) then
			strafespeed = strafespeed + decceleration
		end
	end
	if (speed > -decceleration) and (speed < decceleration) then
		speed = 0
	elseif (speed > mspeed) then
		speed = mspeed
	elseif (speed < -mspeed) then
		speed = -mspeed
	end
	if (strafespeed > -(acceleration / 2)) and (strafespeed < (acceleration / 2)) then
		strafespeed = 0
	elseif (strafespeed > mspeed) then
		strafespeed = mspeed
	elseif (strafespeed < -mspeed) then
		strafespeed = -mspeed
	end
    local camAngleX = camPosX - camTargetX
    local camAngleY = camPosY - camTargetY
    local camAngleZ = 0
    local angleLength = math.sqrt(camAngleX*camAngleX+camAngleY*camAngleY+camAngleZ*camAngleZ)
    local camNormalizedAngleX = camAngleX / angleLength
    local camNormalizedAngleY = camAngleY / angleLength
    local camNormalizedAngleZ = 0
    local normalAngleX = 0
    local normalAngleY = 0
    local normalAngleZ = 1
    local normalX = (camNormalizedAngleY * normalAngleZ - camNormalizedAngleZ * normalAngleY)
    local normalY = (camNormalizedAngleZ * normalAngleX - camNormalizedAngleX * normalAngleZ)
    local normalZ = (camNormalizedAngleX * normalAngleY - camNormalizedAngleY * normalAngleX)
    camPosX = camPosX + airbrakeAngleX * speed
    camPosY = camPosY + airbrakeAngleY * speed
    camPosZ = camPosZ + airbrakeAngleZ * speed
    camPosX = camPosX + normalX * strafespeed
    camPosY = camPosY + normalY * strafespeed
    camPosZ = camPosZ + normalZ * strafespeed
	velocityX = (airbrakeAngleX * speed) + (normalX * strafespeed)
	velocityY = (airbrakeAngleY * speed) + (normalY * strafespeed)
	velocityZ = (airbrakeAngleZ * speed) + (normalZ * strafespeed)
    camTargetX = camPosX + airbrakeAngleX * 100
    camTargetY = camPosY + airbrakeAngleY * 100
    camTargetZ = camPosZ + airbrakeAngleZ * 100
	if getKeyState("q") or getKeyState("num_add") then
		camPosZ = camPosZ+(mspeed/2)
	elseif getKeyState("e") or getKeyState("num_sub") then
		camPosZ = camPosZ-(mspeed/2)
	end
	setElementPosition(localPlayer,camPosX,camPosY,camPosZ)
	setCameraMatrix(camPosX,camPosY,camPosZ,camTargetX,camTargetY,camTargetZ)
end

function AirbrakeMouse(cX,cY,aX,aY)
	if checkActiveWindows() then return end
	if isElementFrozen(localPlayer) then return end
    local width,height = guiGetScreenSize()
    aX = aX - width / 2 
    aY = aY - height / 2
    rotX = rotX + aX * 0.3 * 0.01745
    rotY = rotY - aY * 0.3 * 0.01745
	local PI = math.pi
	if (rotX > PI) then
		rotX = rotX - 2 * PI
	elseif (rotX < -PI) then
		rotX = rotX + 2 * PI
	end
	if (rotY > PI) then
		rotY = rotY - 2 * PI
	elseif (rotY < -PI) then
		rotY = rotY + 2 * PI
	end
    if (rotY < -PI / 2.05) then
       rotY = -PI / 2.05
    elseif (rotY > PI / 2.05) then
        rotY = PI / 2.05
    end
end

function undoAirBrake()
	if getElementData(localPlayer,"ADMIN") and not (airBrakeStartPosX == 0) and not (airBrakeStartPosY == 0) and not (airBrakeStartPosZ == 0) then
		if getElementData(localPlayer,"airbraking") then
			stopAirBrake()
		end
		setElementPosition(localPlayer,airBrakeStartPosX,airBrakeStartPosY,airBrakeStartPosZ)
	end
end
addCommandHandler("undoairbrake",undoAirBrake)

function stopAirBrake(fromServer)
	if fromServer then
		if checkActiveWindows() then return end
	end
	if airbrakeFreeze then
		setElementFrozen(localPlayer,false)
	end
	triggerServerEvent("onUpdateAirbrakePlayer",resourceRoot,"stop")
	outputChatBox("Airbrake is now disabled.",255,50,50)
	removeEventHandler("onClientRender",root,AirbrakeRender)
	removeEventHandler("onClientCursorMove",root,AirbrakeMouse)
	rotX,rotY = 0,0
	velocityX,velocityY,velocityZ = 0,0,0
	speed = 0
	strafespeed = 0
	setCameraTarget(localPlayer)
end
addEvent("onAirBrakeStop",true)
addEventHandler("onAirBrakeStop",localPlayer,stopAirBrake)

function startAirbrake(fromServer)
	if fromServer then
		if checkActiveWindows() then return end
	end
	triggerServerEvent("onUpdateAirbrakePlayer",resourceRoot,"start")
	outputChatBox("Airbrake is now enabled.",0,255,0)
	airBrakeStartPosX,airBrakeStartPosY,airBrakeStartPosZ = getElementPosition(localPlayer)
	rotX,rotY = 0,0
	velocityX,velocityY,velocityZ = 0,0,0
	speed = 0
	strafespeed = 0
	local px,py,pz = getElementPosition(localPlayer)
	setCameraMatrix(px,py,pz)
	addEventHandler("onClientRender",root,AirbrakeRender)
	addEventHandler("onClientCursorMove",root,AirbrakeMouse)
end
addEvent("onAirBrakeStart",true)
addEventHandler("onAirBrakeStart",localPlayer,startAirbrake)

function stopAirBrakeOnGameModeUnloaded()
	stopAirBrake()
end
addEvent("onPlayerUnloaded",true)
addEventHandler("onPlayerUnloaded",localPlayer,stopAirBrakeOnGameModeUnloaded)

addEventHandler("onClientResourceStop",resourceRoot,function()
	if getElementData(localPlayer,"airbraking") then
		stopAirBrake()
	end
end)

fileDelete("airbrake_client.lua")