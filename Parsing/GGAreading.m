classdef GGAreading
    properties
        breakoututc;
        latitude;
        latdir;
        long;
        longdir;
        quality;
        numberofsvs;
        hdop;
        orthoheight;
        geoidseparation;
        age;
        refid;
    end
    methods
        function reading = GGAreading(arr)
            if ((nargin > 0)&&(length(arr)>14))
                reading.breakoututc = arr(2);
                reading.latitude = arr(3);
                reading.latdir = arr(4);
                reading.long = arr(5);
                reading.longdir = arr(6);
                reading.quality = arr(7);
                reading.numberofsvs = arr(8);
                reading.hdop = arr(9);
                reading.orthoheight = arr(10);
                reading.geoidseparation = arr(12);
                reading.age = arr(14);
                reading.refid = arr(15);
            end
        end
    end
end

