--------------------------------------------------------------------------------------------------------------------------
function MODULE:KeyPress(client, key)
	if key == IN_RELOAD then
		timer.Create(
			"liaToggleRaise" .. client:SteamID(),
			1,
			1,
			function()
				if IsValid(client) then
					client:toggleWepRaised()
				end
			end
		)
	end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSwitchWeapon(client, oldWeapon, newWeapon)
	client:setWepRaised(false)
end
--------------------------------------------------------------------------------------------------------------------------