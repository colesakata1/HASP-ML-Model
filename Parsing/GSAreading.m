classdef GSAreading
    properties
        mode1
        mode2
        prn1
        pdop
        hdop
        vdop
    end
    methods
        function reading = GSAreading(arr)
            if(nargin > 0)
                reading.mode1 = arr(2);
                reading.mode2 = arr(3);
                reading.prn1 = arr(4);
                reading.pdop = arr(16);
                reading.hdop = arr(17);
                reading.vdop = arr(18);
            end
        end
    end
end