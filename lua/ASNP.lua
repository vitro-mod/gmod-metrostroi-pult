VitroMod.Pult.ASNP = {
    ApplyList = function(list)
        rcASNP = rcASNP or {}
        for _, v in pairs(list) do
            rcASNP[v] = rcASNP[v] or true
        end
    end,
}
