local categories = {
    {"Journey", {
        {"journey-01", "First Footing", "Complete the introductory mentor quest."},
        {"journey-02", "A Chapter Begins", "Complete the three-step Dojo Valley mentor chapter."},
        {"journey-03", "Six Horizons", "Discover the arrival checkpoint in all six districts."},
        {"journey-04", "A New Form", "Complete the first server-confirmed fighter evolution."},
        {"journey-05", "Mentors Remember", "Complete all six mentor chapters."},
        {"journey-06", "Dojo Graduate", "Complete the graduation quest after the six mentor chapters."},
    }},
    {"Discovery", {
        {"discovery-valley", "Dojo Valley Explorer", "Find all three permanent seals in Dojo Valley."},
        {"discovery-coast", "Tideharbor Coast Explorer", "Find all three permanent seals in Tideharbor Coast."},
        {"discovery-cinder", "Cinder Terraces Explorer", "Find all three permanent seals in Cinder Terraces."},
        {"discovery-sky", "Skywalk Peaks Explorer", "Find all three permanent seals in Skywalk Peaks."},
        {"discovery-frost", "Frostglass Gardens Explorer", "Find all three permanent seals in Frostglass Gardens."},
        {"discovery-circuit", "Lantern Circuit Explorer", "Find all three permanent seals in Lantern Circuit."},
    }},
    {"Mastery", {
        {"mastery-valley", "Dojo Valley Master", "Complete the validated Reed-path expert course."},
        {"mastery-coast", "Tideharbor Coast Master", "Complete the validated Tide-path expert course."},
        {"mastery-cinder", "Cinder Terraces Master", "Complete the validated Steam-lift expert course."},
        {"mastery-sky", "Skywalk Peaks Master", "Finish Cloudbreak Wind Trial in Expert mode and ring the summit bell."},
        {"mastery-frost", "Frostglass Gardens Master", "Complete the validated Ice-slide expert course."},
        {"mastery-circuit", "Lantern Circuit Master", "Complete the validated Rooftop expert course."},
    }},
    {"Arena", {
        {"arena-01", "First Duel", "Win one eligible completed duel."},
        {"arena-02", "Ring Reader", "Finish in the top three of an eligible eight-player brawl."},
        {"arena-03", "Tag Partners", "Win one eligible tag-team match."},
        {"arena-04", "Ten Duels", "Win ten eligible duels. Each result counts once."},
        {"arena-05", "Steady Guard", "Perform ten validated parries across eligible completed encounters."},
        {"arena-06", "Ring Veteran", "Complete twenty eligible arena matches with participation credit."},
    }},
    {"World challenges", {
        {"world-01", "Kiln Keeper", "Earn participation credit for clearing the Kilnback Custodian encounter."},
        {"world-02", "Deepwater Team", "Earn participation credit for clearing the Abyssal Kraken encounter."},
        {"world-03", "Dawn Return", "Earn participation credit for clearing the Solar Phoenix encounter."},
        {"world-04", "Lantern Keeper", "Finish one official Lantern Relay with all seven gates validated."},
        {"world-05", "Festival Regular", "Complete three validated Training Festival activities. Each result counts once."},
        {"world-06", "World Champion", "Earn all three boss-clear trophies and both world-event trophies."},
    }},
}

local byId = {}
for group, collection in categories do
    for index, entry in collection[2] do
        byId[entry[1]] = table.freeze({
            title = entry[2], criterion = entry[3], group = group, index = index,
        })
    end
end

return table.freeze({categories = categories, byId = table.freeze(byId), slots = 18})
