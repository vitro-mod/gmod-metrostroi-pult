function AllSeats(train)
    if not IsValid(train) then return {} end

    local drv = train:GetDriver()
    local seats = {}

    for k, seat in pairs(train.Seats) do
        if not IsValid(seat) then continue end

        local psg = seat.entity:GetDriver()
        if not IsValid(psg) then continue end;
        if psg == drv then continue end;

        table.insert(seats, psg:GetName())
    end

    return seats
end