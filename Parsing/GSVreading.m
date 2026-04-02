classdef GSVreading
    properties
        numberofmsgs;
        msgnmbr;
        numberofsats;
        prn1;
        elevation1;
        azimuth1;
        snr1 = "0";
        prn2;
        elevation2;
        azimuth2;
        snr2 = "0";
        prn3;
        elevation3;
        azimuth3;
        snr3 = "0";
        prn4;
        elevation4;
        azimuth4;
        snr4 = "0";
    end
    methods
        function reading = GSVreading(arr)
            if(nargin > 0)
                if(length(arr) >=4)
                    reading.numberofmsgs = arr(2);
                    reading.msgnmbr = arr(3);
                    reading.numberofsats = arr(4);
                    if(length(arr) >= 8)
                        reading.prn1 = arr(5);
                        reading.elevation1 = arr(6);
                        reading.azimuth1 = arr(7);
                        reading.snr1 = arr(8);
                        if(length(arr) >= 12)
                            reading.prn2 = arr(9);
                            reading.elevation2 = arr(10);
                            reading.azimuth2 = arr(11);
                            reading.snr2 = arr(12);
                            if(length(arr) >=16)
                                reading.prn3 = arr(13);
                                reading.elevation3 = arr(14);
                                reading.azimuth3 = arr(15);
                                reading.snr3 = arr(16);
                                if(length(arr) >= 20)
                                    reading.prn4 = arr(17);
                                    reading.elevation4 = arr(18);
                                    reading.azimuth4 = arr(19);
                                    reading.snr4 = arr(20);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
