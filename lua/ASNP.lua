VitroMod.Pult.ASNP = {
    ApplyList = function(list)
        rcASNP = rcASNP or {}
        for _, v in pairs(list) do
            rcASNP[v] = true
        end
    end,
}
