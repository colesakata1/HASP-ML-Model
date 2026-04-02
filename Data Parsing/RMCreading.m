classdef RMCreading
    properties
        %$GNRMC,005911.000,A,4221.2926,N,07108.7096,W,2.48,118.75,261125,,,A*65
        breakoututc; %hhmmss.000
        situation char; %A valid V not valid
        lat;
        latdir char;
        long;
        longdir char;
        speed;
        track;
        breakoututcepoch;
        style char; %{N (no fix),
        % E (dead-reckoning)
        % F (RTK-float)
        % R (RTK-fixed)
        % A (autonomous)
        % D (differential not used)
        % P (precise not used)
        % M (manual input not used)
        % S (simulator not used)}%
    end
    methods
        function reading = RMCreading(arr)
            if(nargin > 0)
                reading.breakoututc = arr(2); %hhmmss.000
                reading.situation = arr(3);
                reading.lat = arr(4);
                reading.latdir = arr(5);
                reading.long = arr(6);
                reading.longdir = arr(7);
                reading.speed = arr(8);
                reading.track = arr(9);
                reading.breakoututcepoch = arr(10);
                if(size(arr,1)>12)
                    reading.style = arr(13);
                end
            end
        end
    end
end

       

   