namespace ZU
{
    funcdef void CpChangeEvent(int);
    funcdef void CpTimeEvent(int, int);

    class CpDataManager
    {
        protected CSmPlayer@ player;
        protected CSmArenaClient@ playground;
        
        uint lastCount = 0;

        CpTimeEvent@ newTimeCallback = function(int i, int t) {};
        CpChangeEvent@ countChangeCallback = function(int i) {};
        
        void Update(){
            @player = GetPlayer();
            @playground = cast<CSmArenaClient>(GetApp().CurrentPlayground);
            if (player is null || playground is null) return;
            auto count = GetFinished_CpCount(player);       

            if (count != lastCount)
            {
                countChangeCallback(count - 1);
                if (count > lastCount)
                    newTimeCallback(count, GetCpFinTime(player, count - 1));
            }

            lastCount = count;
        }

        void Render(){
            UI::SetNextWindowPos(50, 200);
            UI::SetNextWindowSize(280,200);
            UI::Begin("Debug", UI::WindowFlags::NoTitleBar  | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking);
            UI::Text("has player: " + (player !is null));
            UI::Text("has playground: " + (playground !is null));
            if (player !is null)
            {

                auto count = GetFinished_CpCount(player);
                UI::Text("fin count: " + count);
                
                for (uint i = 0; i < count; i++)
                {
                    UI::Text( (i + 1) + " : " + Time::Format(GetCpFinTime(player, i)));
                }
            }

            UI::End();        
        }

        uint GetFinished_CpCount(CSmPlayer@ player){    
            return Dev::GetOffsetUint16(player, 0x680);
        }

        int GetCpFinTime(CSmPlayer@ player, uint i){
            auto CPTimesArrayPtr = Dev::GetOffsetUint64(player, 0x688 - 0x10);
            auto count = GetFinished_CpCount(player);
            if(i >= count) return -1;

            return Dev::ReadInt32(CPTimesArrayPtr + i * 0x20 + 0x3c) - player.StartTime;
        }

        uint GetEffectiveCpCount(CSmArenaClient@ playground)
        {    
            auto arena = cast<CSmArena>(playground.Arena);
            auto map = playground.Map;
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
}