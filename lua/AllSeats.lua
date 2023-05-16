function AllSeats(train)
    if not IsValid(train) then return {} end
    local drv = train:GetDriver()
    seats = {}
    for k,v in pairs(train.Seats) do 
        local psg = v.entity:GetDriver()
        if IsValid(psg) and psg ~= drv then 
            table.insert(seats,psg:GetName()) 
        end
    end
    return seats
end