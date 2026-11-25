local chapters = {
    {id = "valley", name = "Dojo Valley", mentor = "Reed court keeper", chapter = "Find your footing",
        story = "The plaza reopens its training paths for the festival. The keeper has left three markers to teach you how to read a court.",
        survey = "Check the three reed markers near the training paths.",
        trial = "Finish a round with Juniper at Grand Dojo Ring, then report to the keeper.",
        activities = {{"reed-path", "Reed-path parkour", "route"}, {"lantern-timing", "Lantern timing drill", "timing"}},
        mastery = 1},
    {id = "coast", name = "Tideharbor Coast", mentor = "Harbor instructor", chapter = "Restore the harbor route",
        story = "A spring tide moved the harbor marks. The instructor needs the shore surveyed before the training parcels can go out.",
        survey = "Check the three shore markers along the harbor.",
        trial = "Take the harbor practice trial at the delivery start and report back.",
        activities = {{"tide-path", "Tide-path traversal", "route"}, {"harbor-delivery", "Harbor delivery route", "delivery"}},
        mastery = 1},
    {id = "cinder", name = "Cinder Terraces", mentor = "Kiln workshop keeper", chapter = "Set the workshop right",
        story = "The kilns are warm again. Inspect the vents, get the bellows back in rhythm, and carry the repaired training tile through its test.",
        survey = "Inspect the three marked vents.",
        trial = "Pass the workshop practice trial at the ascent start and bring the results to the keeper.",
        activities = {{"bellows", "Bellows timing puzzle", "timing"}, {"steam-ascent", "Steam-lift ascent", "route"}},
        mastery = 2},
    {id = "sky", name = "Skywalk Peaks", mentor = "Wind-court instructor", chapter = "Reconnect the wind courts",
        story = "The wind courts can hear each other again once the ridge signals are restored. Follow the marked approach and listen for the chimes.",
        survey = "Check the three wind markers on the marked approach.",
        trial = "Pass the temple practice trial at the chime start and report back.",
        activities = {{"wind-bridge", "Wind-bridge course", "route"}, {"chime-sequence", "Chime sequence puzzle", "sequence"}},
        mastery = 1},
    {id = "frost", name = "Frostglass Gardens", mentor = "Garden caretaker", chapter = "Bring the garden to life",
        story = "The frost has hidden the garden lights. Follow the old stone markers, then wake the reflectors to bring color back to the ponds.",
        survey = "Survey the three frost garden markers.",
        trial = "Pass the garden training trial at the reflector start and report back.",
        activities = {{"ice-slide", "Ice-slide course", "slide"}, {"reflectors", "Reflector light puzzle", "sequence"}},
        mastery = 1},
    {id = "circuit", name = "Lantern Circuit", mentor = "Circuit instructor", chapter = "Light the circuit",
        story = "The night display is waiting on three rooftop relays and one last delivery. Restore their order before the festival bell.",
        survey = "Follow the three marked points along the rooftop approach.",
        trial = "Pass the circuit practice trial at the signal start and report back to open the night display.",
        activities = {{"rooftop-delivery", "Rooftop delivery route", "delivery"}, {"signal-routing", "Signal-routing puzzle", "sequence"}},
        mastery = 1},
}

local byId, activities = {}, {}
for _, chapter in chapters do
    byId[chapter.id] = chapter
    for slot, definition in chapter.activities do
        activities[definition[1]] = {id = definition[1], name = definition[2], kind = definition[3],
            district = chapter.id, slot = slot}
    end
end

return table.freeze({chapters = chapters, byId = byId, activities = activities,
    festivalPeriod = 30 * 60, festivalDuration = 12 * 60, festivalTarget = 3,
    cloudbreakCosmetic = "cloudbreak-summit-sash"})
