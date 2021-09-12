namespace ZU
{
    CSmPlayer@ GetPlayer()
    {   
        auto pg = cast<CSmArenaClient>(GetApp().CurrentPlayground);
        if(pg is null) return null;
        if (pg.GameTerminals.Length < 1) return null;
        return cast<CSmPlayer>(pg.GameTerminals[0].ControlledPlayer);
    }

    uint GetEffectiveCpCount(){    
        auto pg = cast<CSmArenaClient>(GetApp().CurrentPlayground);
        auto arena = cast<CSmArena>(pg.Arena);
        auto map = pg.Map;
        auto landmarks = arena.MapLandmarks;

        auto lapCount = pg.Map.TMObjective_IsLapRace ? pg.Map.TMObjective_NbLaps : uint(1);

        array<int> orders(0);
        uint count = 1; // starting at 1 because there is always a finish

        // if a cp has an order > 0, it may be a linked CP, so we increment that index and count them later
        for (uint i = 0; i < landmarks.Length; i++)
        {
            auto lm = landmarks[i];
            auto tag = lm.Tag;
            if (lm.Tag == "Checkpoint" )
            {
                if (lm.Order == 0)
                {
                    count++;
                }else{
                    if (lm.Order >= orders.Length) orders.Resize(lm.Order + 1);
                    orders[lm.Order]++;
                }
            }            
        }

        for (uint i = 0; i < orders.Length; i++)
        {
            if (orders[i] > 0)
            {
                count++;
            }
        }
        // print(lapCount);
        return count * lapCount;
    }
}