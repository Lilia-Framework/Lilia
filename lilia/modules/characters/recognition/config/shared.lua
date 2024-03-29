﻿--[[ Is character recognition enabled? ]]
MODULE.RecognitionEnabled = true
--[[ Do members from the same faction always auto-recognize each other? ]]
MODULE.FactionAutoRecognize = false
--[[ Are fake names enabled? ]]
MODULE.FakeNamesEnabled = false
--[[ Variables to hide from a non-recognized character in the scoreboard ]]
MODULE.ScoreboardHiddenVars = {"name", "model", "desc"}
--[[ Chat types that are recognized ]]
MODULE.ChatIsRecognized = {"ic", "y", "w", "me"}
--[[ Factions that auto-recognize members between each other ]]
MODULE.MemberToMemberAutoRecognition = {
    [FACTION_STAFF] = true,
}
