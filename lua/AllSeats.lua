function AllSeats(wagon)
    if not IsValid(wagon) then return {} end

    local train = wagon
    if MetrostroiExt and MetrostroiExt.DetectHeadWagon then
        train = MetrostroiExt.DetectHeadWagon( wagon, true )
    end

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