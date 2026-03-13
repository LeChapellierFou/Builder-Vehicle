
local flt = {}
local selParam = 1
local doAdjustEntity = false
local TestEntity = nil
local TestEntityModel = nil

-- Check if string is a number.
local function isNumber(str)
	local num = tonumber(str)
	if not num then return false
	else return true
	end
end

LoadModels = function(model)
    
    local hash
    if isNumber(model) then 
        hash = model
    else
        hash = Game.GetHashKey(model)
    end
    
    if(Game.IsModelInCdimage(hash)) then 
        Game.RequestModel(hash)
        Game.LoadAllObjectsNow()
        while not Game.HasModelLoaded(hash) do
            Game.RequestModel(hash)
            Thread.Pause(0)
        end

        return true
    else
        return false
    end
end

local function SpawnEntity(model)
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)
	
	if (Game.IsCharInAnyCar(playerChar)) then 
		
		local playerVehicle = Game.GetCarCharIsUsing(playerChar);
		local tcarX, tcarY, tcarZ = Game.GetCarCoordinates(playerVehicle);
		
		local isExist = LoadModels(model)	
		if isExist then 
			local hash
			if isNumber(model) then 
				hash = model
			else
				hash = Game.GetHashKey(model)
			end
			
			if (not Game.IsThisModelAVehicle(hash)) then 
				TestEntity = Game.CreateObjectNoOffset(hash, tcarX, tcarY, tcarZ + 10.0, true);
				Game.FreezeObjectPosition(TestEntity, true);
				Game.SetObjectVisible(TestEntity, true); 
				Game.SetObjectCollision(TestEntity, false);
				Game.AttachObjectToCar(TestEntity, playerVehicle, 0, flt[1], flt[2], flt[3], flt[4], flt[5], flt[6]);
				doAdjustEntity = true;
			else
				TestEntity = Game.CreateCar(hash, tcarX, tcarY, tcarZ + 10.0, true);
				Game.FreezeCarPosition(TestEntity, true);
				Game.SetCarVisible(TestEntity, true); 
				Game.SetCarCollision(TestEntity, false);
				Game.AttachCarToCar(TestEntity, playerVehicle, 0, flt[1], flt[2], flt[3], flt[4], flt[5], flt[6]);
				doAdjustEntity = true;
			end
			TestEntityModel = hash
		else
			Game.PrintStringWithLiteralStringNow("STRING", "~y~Hash Error! ~s~Model not in cdimage", 5000, 1);
		end
		
	else
		Game.PrintStringWithLiteralStringNow("STRING", "You need to have a car", 5000, 1);
	end
	
end

local function KillEntity()
	if (not Game.IsThisModelAVehicle(TestEntityModel)) then -- obj
		if (TestEntity ~= nil and Game.DoesObjectExist(TestEntity)) then 
			doAdjustEntity = false
			Game.DeleteObject(TestEntity)
			Game.MarkObjectAsNoLongerNeeded(TestEntity);
			Game.PrintStringWithLiteralStringNow("STRING", "Last object deleted", 5000, 1);
			TestEntity = nil
			TestEntityModel = nil
			Game.ClearHelp()
		end
	else -- car 
		if (TestEntity ~= nil and Game.DoesVehicleExist(TestEntity)) then 
			doAdjustEntity = false
			Game.DeleteCar(TestEntity)
			Game.MarkCarAsNoLongerNeeded(TestEntity);
			Game.PrintStringWithLiteralStringNow("STRING", "Last car deleted", 5000, 1);
			TestEntity = nil
			TestEntityModel = nil
			Game.ClearHelp()
		end
	end
end

local function AdjustEntity(vehicle)
	
	if TestEntity ~= nil then 
		if (not Game.IsThisModelAVehicle(TestEntityModel)) then
			Game.DetachObject(TestEntity, true);
		else
			Game.DetachCar(TestEntity);
		end
		
		Game.DrawCurvedWindow(0.3730, 0.0411, 0.09, 0.153, 200);
		
		if (Game.IsGameKeyboardNavLeftPressed(true) and not Chat.IsInputActive()) then 
			flt[selParam] = flt[selParam] - 0.01;
		elseif (Game.IsGameKeyboardNavRightPressed(true) and not Chat.IsInputActive()) then 
			flt[selParam] = flt[selParam] + 0.01;
		end
		
		for I = 1, 6, 1 do
			Game.SetTextDropshadow(1, 0, 0, 0, 255);
			Game.SetTextScale(0.3, 0.3);
			if (I == selParam) then 
				Game.SetTextColour(255, 255, 0, 255);
			else
				Game.SetTextColour(255, 255, 255, 255);
			end
			
			Game.DisplayTextWithFloat(0.3890, (I * 0.02) + 0.0380, "NUMBR", flt[I], 4);
		end
		
		if (not Game.IsThisModelAVehicle(TestEntityModel)) then
			Game.AttachObjectToCar(TestEntity, vehicle, 0, flt[1], flt[2], flt[3], flt[4], flt[5], flt[6]);
		else
			Game.AttachCarToCar(TestEntity, vehicle, 0, flt[1], flt[2], flt[3], flt[4], flt[5], flt[6]);
		end
	end
end

local function SelectParam(incr_s)
	if (incr_s) then 
		if (selParam < 6) then
			selParam = selParam + 1
		else
			selParam = 1;
		end
	else
		if (selParam > 1) then
			selParam = selParam - 1
		else
			selParam = 6;
		end
	end
end

local function ResetParams()
	flt[1] = 0.0;
	flt[2] = 0.0;
	flt[3] = 1.0;
	flt[4] = 0.0;
	flt[5] = 0.0;
	flt[6] = 0.0;
end

local function ResetSingleParam()
	if (selParam == 3) then 
		flt[selParam] = 1.0;
	else
		flt[selParam] = 0.0;
	end
end

local function ButtonInput()
	local KEY_R = 19
	local KEY_B = 48
	local KEY_K = 37
	local DOWN_ARROW = 208
	local UP_ARROW = 200

	if (Game.IsGameKeyboardKeyJustPressed(KEY_B) and not Chat.IsInputActive()) then  -- copy obj
		--ResetParams();
		SpawnEntity(TestEntityModel);
		Game.PrintStringWithLiteralStringNow("STRING", "Last entity copied", 5000, 1);
	end
	
	if (Game.IsGameKeyboardKeyJustPressed(KEY_K) and not Chat.IsInputActive()) then -- delete obj
		KillEntity();
	end
	
	if (Game.IsGameKeyboardKeyJustPressed(KEY_R) and not Chat.IsInputActive()) then 
		ResetSingleParam();
	end
	
	if (Game.IsGameKeyboardKeyJustPressed(UP_ARROW) and not Chat.IsInputActive()) then 
		SelectParam(false);
	end
	
	if (Game.IsGameKeyboardKeyJustPressed(DOWN_ARROW) and not Chat.IsInputActive()) then 
		SelectParam(true);
	end
end

local function UnlockPlayerCar()
	local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)
	if (Game.IsCharInAnyCar(playerChar)) then 
		local playerVehicle = Game.GetCarCharIsUsing(playerChar);
		Game.FreezeCarPosition(playerVehicle, false)
		Game.LockCarDoors(playerVehicle, 1)
		Game.DisplayRadar(true)
	end
end

Events.Subscribe("chatCommand", function(fullcommand)
	local command = stringsplit(fullcommand, ' ')
	
	if command[1] == "/builder" then
        if command[2] == nil then 
			Chat.AddMessage("Usage: /builder [model]")
        else
			ResetParams()		
			SpawnEntity(command[2])
        end
	elseif command[1] == "/builderoff" then
		if doAdjustEntity then 
			doAdjustEntity = false
			UnlockPlayerCar()
			Game.ClearHelp()
		end
    elseif command[1] == "/builderon" then
		if TestEntity ~= nil and TestEntityModel ~= nil then 
			doAdjustEntity = true
		else
			Game.PrintStringWithLiteralStringNow("STRING", "Not Entity Existed", 5000, 1);
		end
	end
	
end)

Events.Subscribe("scriptInit", function()

	Thread.Create(function()
		while true do
			Thread.Pause(0)
			local playerId = Game.GetPlayerId()
			local playerChar = Game.GetPlayerChar(playerId)
	
            if doAdjustEntity then 
				if TestEntity ~= nil and TestEntityModel ~= nil then 
					if (Game.IsCharInAnyCar(playerChar)) then 
						local playerVehicle = Game.GetCarCharIsUsing(playerChar);
						Game.PrintHelpForeverWithStringNoSound( "BUILDER_HLP", "" );
						Game.SetTextBackground(false)
						Game.DisplayRadar(false)
						
						Game.FreezeCarPosition(playerVehicle, true)
						Game.LockCarDoors(playerVehicle, 4)
		
						ButtonInput();
						AdjustEntity(playerVehicle);
					end
				end
			end
		end
	end)
end)

Events.Subscribe("scriptInit", function()
    Text.AddEntry(
        "BUILDER_HLP",
        "Select Params: ~PAD_DPAD_UP~/~PAD_DPAD_DOWN~ ~PAD_DPAD_LEFT~/~PAD_DPAD_RIGHT~ ~n~Key B: Copy Entity ~n~Key R: Reset current params ~n~Key K: Delete Entity"
    )
end)