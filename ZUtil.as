namespace ZUtil
{
    CSmPlayer@ GetLocalPlayer(CGamePlayground@ playground)
    {   
        if(playground is null) return null;
        if (playground.GameTerminals.Length < 1) return null;
        return cast<CSmPlayer>(playground.GameTerminals[0].ControlledPlayer);
    }

    uint GetEffectiveCpCount(CSmArenaClient@ playground)
    {    
        auto arena = cast<CSmArena>(playground.Arena);
        auto map = playground.Map;

        if (arena is null || map is null) return 0;

        auto landmarks = arena.MapLandmarks;
        if (landmarks.Length == 0) return 0;

        if (map.MapType == "TrackMania\\TM_Royal") return 5;

            auto lapCount = playground.Map.TMObjective_IsLapRace ? playground.Map.TMObjective_NbLaps : uint(1);
            array<int> orders(0);
            uint _cpCount = 1; // starting at 1 because there is always a finish

            // if a cp has an order > 0, it may be a linked CP, so we increment that index and count them later
            for (uint i = 0; i < landmarks.Length; i++)
            {
                auto lm = landmarks[i];
                auto tag = lm.Tag;
                if (lm.Tag == "Checkpoint" )
                {
                    if (lm.Order == 0)
                    {
                        _cpCount++;
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
                    _cpCount++;
                }
            }
            // print(lapCount);
            return _cpCount * lapCount;

    }
}