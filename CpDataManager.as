namespace ZUtil
{
    funcdef void CpChangeEvent(int);
    funcdef void CpTimeEvent(int, int);

    class CpDataManager
    {
        uint lastCount = 0;

        CpTimeEvent@ newTimeCallback = function(int i, int t) {};
        CpChangeEvent@ countChangeCallback = function(int i) {};
        
        uint GetAllCpTimes(CSmPlayer@ player, array<int>@ arr){     
            if (player is null) return 0;

            auto count = Math::Min(arr.Length, GetFinished_CpCount(player));

            for (uint i = 0; i < uint(count); i++)
            {
                arr[i] = GetCpFinTime(player,i);
            }

            return count;
        }

        void Update(CSmPlayer@ player){
            if (player is null) return;

            auto count = GetFinished_CpCount(player);       
            if (count != lastCount)
            {
                countChangeCallback(count - 1);
                if (count > lastCount){
                    newTimeCallback(count - 1, GetCpFinTime(player, count - 1));
                }
                lastCount = count;
            }

        }

        void Render(CSmPlayer@ player){
            if (player is null) return;

            UI::SetNextWindowPos(50, 200);
            UI::SetNextWindowSize(280,200);
            UI::Begin("Debug", UI::WindowFlags::NoTitleBar  | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking);
            UI::Text("has player: " + (player !is null));
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

        uint GetFinished_CpCount(const CSmPlayer@ player){   
            return Dev::GetOffsetUint16(player, 0x680);
        }

        int GetCpFinTime(CSmPlayer@ player, const uint i){

            auto CPTimesArrayPtr = Dev::GetOffsetUint64(player, 0x688 - 0x10);
            auto count = GetFinished_CpCount(player);

            if(i >= count) return 0;

            return Dev::ReadInt32(CPTimesArrayPtr + i * 0x20 + 0x3c) - player.StartTime;
        }

        
    }
}