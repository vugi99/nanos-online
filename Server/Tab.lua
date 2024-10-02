

local testtab = false

Events.SubscribeRemote("AskTab", function(ply)
    local tbl = {}
    tbl[1] = {}
    local tblin = 1

    if not testtab then
        for i, v in pairs(Player.GetPairs()) do
            if (v:IsValid() and PLAYERS_DATA[v]) then
                local tblinsert = {}
                for i2, v2 in ipairs(TAB_BUILD) do
                    tblinsert[v2.key] = v2.get(v)
                end
                table.insert(tbl[tblin], tblinsert)

               if table_count(tbl[tblin]) > 34 then
                    tblin = tblin + 1
                    tbl[tblin] = {}
                end
            end
         end
         if table_count(tbl[1]) > 0 then
            Events.CallRemote("TabResponse", ply, tbl)
         end
    else
       for i = 1, 300 do
            local tblinsert = {}
            for i2, v2 in ipairs(TAB_BUILD) do
                tblinsert[v2.key] = i
            end
            table.insert(tbl[tblin], tblinsert)
            if table_count(tbl[tblin]) > 34 then
                tblin = tblin + 1
                tbl[tblin] = {}
            end
       end
       Events.CallRemote("TabResponse", ply, tbl)
    end
end)