close all
clear
sunriseidx = 0;
function [datatable] = CreateDataTable(filename,timestamp, begintime, ...
    transitionflag, transitiontime)
    transitionidx = 0;
    GPSdat = readlines(filename);
    
    GSVct = 0; RMCct = 0; GGAct = 0; GSAct=0;
    if(timestamp == "yes")
        timestampoffset = 26;
    else
        timestampoffset = 0;
    end
    length(GPSdat)
    for i = 1:(length(GPSdat))
        curline = convertStringsToChars(GPSdat(i));
        if (((size(curline,2) >1) && (timestamp=="no")) ||...
                ((timestamp=="yes") && (size(curline,2)>28)))
           
            if((curline(1+timestampoffset:6+timestampoffset) == "$GPGSV")||...
                    (curline(1+timestampoffset:6+timestampoffset) == "$GLGSV"))
                GSVct = GSVct+1;
            elseif(curline(1+timestampoffset:6+timestampoffset) == "$GNGGA")
                GGAct = GGAct+1;
            elseif(curline(1+timestampoffset:6+timestampoffset) == "$GNRMC")
                RMCct = RMCct+1;
            elseif(curline(1+timestampoffset:6+timestampoffset) == "$GNGSA")
                GSAct = GSAct+1;
            end
        end
    end

    GSVdat = createArray(GSVct,1,"GSVreading");
    RMCdat = createArray(RMCct,1,"RMCreading");
    GGAdat = createArray(GGAct,1,"GGAreading");
    GSAdat = createArray(GSVct,1,"GSAreading");
    
    x = 1; y = 1; z = 1; w = 1;
    swapflag = 0;
    for i = 1:(length(GPSdat))
        curline = convertStringsToChars(GPSdat(i));
        splitline = split(GPSdat(i),[",","*"]);
        if (((size(curline,2) >1) & (timestamp=="no")) ||...
                ((timestamp=="yes") & (size(curline,2)>28)))
            if((curline(1+timestampoffset:6+timestampoffset) == "$GPGSV")||...
                    (curline(1+timestampoffset:6+timestampoffset) == "$GLGSV"))
                GSVdat(x) = GSVreading(splitline);
                x = x+1;
            elseif(curline(1+timestampoffset:6+timestampoffset) == "$GNGGA")
                GGAdat(y) = GGAreading(splitline);
                y = y+1;
            elseif((curline(1+timestampoffset:6+timestampoffset) == "$GPGSA")|| ...
                    (curline(1+timestampoffset:6+timestampoffset) == "$GLGSA"))
                GSAdat(w) = GSAreading(splitline);
                w = w+1;
            elseif(curline(1+timestampoffset:6+timestampoffset) == "$GNRMC")
                RMCdat(z) = RMCreading(splitline);
                if(transitionflag == "yes")
                    if(RMCdat(z).breakoututc >= transitiontime)
                        if(swapflag == 0)
                            transitionidx = z
                            swapflag = 1;
                        end
                    end
                end
                z = z+1;
            end
        end
    end
    
    
    latarr = double(zeros(z-1,1));
    latdirarr = double(zeros(z-1,1));
    latarr(1) = RMCdat(1).lat;
    latdirarr(1) = RMCdat(1).latdir;

    longarr = double(zeros(z-1,1));
    longdirarr = double(zeros(z-1,1));
    longarr(1) = RMCdat(1).long;
    longdirarr(1) = RMCdat(1).longdir;
    
    %latdelta = double(zeros(1,z-1));
    %longdelta = double(zeros(1,z-1));
    %wgs84 = wgs84Ellipsoid("m");
    
    %distancearr = double(zeros(z-1,1));
    trackarr = double(zeros(z-1,1));
    elevationarr = double(zeros(z-1,1));
    speedarr = double(zeros(z-1,1));
    qualityarr = double(zeros(z-1,1));

    pdoparr = double(zeros(z-1,1));
    hdoparr = double(zeros(z-1,1));
    vdoparr = double(zeros(z-1,1));

    for i = 1:z-51
        assignVal(RMCdat(i).lat, latarr,i);
        assignVal(RMCdat(i).long, longarr,i)
        if(RMCdat(i).longdir == 'E')
            longdirarr(i) = 1;
        elseif(RMCdat(i).longdir == 'W')
            longdirarr(i) = 0;
        else
            longdirarr(i) = -1;
        end

        if(RMCdat(i).latdir == 'N')
            latdirarr(i) = 1;
        elseif(RMCdat(i).latdir == 'S')
            latdirarr(i) = 0;
        else
            latdirarr(i) = -1;
        end

        %[distresult, ~] = distance(latarr(i)/100,longarr(i)/100,latarr(i-1)/100,longarr(i-1)/100,wgs84);
        %distancearr(i) = distresult;
        %latdelta(i-1) = latarr(i) - latarr(i-1);
        %longdelta(i-1) = longarr(i) - longarr(i-1);
        assignVal(RMCdat(i).track, trackarr, i);
        assignVal(RMCdat(i).speed, speedarr,i);

        if(class(GGAdat(i).quality) == 'string')
            if(str2num(GGAdat(i).quality) >= 0)
                qualityarr(i) = GGAdat(i).quality;
            else
                qualityarr(i) = -1;
            end
        else
            if(GGAdat(i).quality >= 0)
                qualityarr(i) = GGAdat(i).quality;
            else
                qualityarr(i) = 1e-7;
            end
        end

        if(class(GGAdat(i).orthoheight) == 'string')
            if(str2num(GGAdat(i).orthoheight) >= 0)
                elevationarr(i) = GGAdat(i).orthoheight;
            else
                elevationarr(i) = 1e-7;
            end
        else
            if(GGAdat(i).orthoheight >= 0)
                elevationarr(i) = GGAdat(i).orthoheight;
            else
                elevationarr(i) = 1e-7;
            end
        end

    end
    %isnandist = isnan(distancearr);
    %for i = 1:z-1
        %if(isnandist(i))
            %distancearr(i) = 10;
       % end
    %end
    % 
    % locationerrorarr = double(zeros(z-1,1));
    % for i = 1:z-1
    %     %sensor = 42.21.2967,N,71.08.6881,W
    % 
    %     [distresult, ~] = distance(latarr(i)/100,longarr(i)/100,42.21175,71.08426,wgs84);
    %     locationerrorarr(i) = distresult;
    % end
    % isnanerr = isnan(locationerrorarr);
    % for i = 1:z-1
    %     if(isnanerr(i))
    %         locationerrorarr(i) = 0;
    %     end
    % end
    snrarr = double(zeros(z-1,1));
    gsvpointer = 1;
    for j = 1:z-1
        snrsum = 0;
        for f = 1:str2double(GSVdat(gsvpointer).numberofmsgs)
            snrstr = [str2double(GSVdat(gsvpointer+f-1).snr1)...
                str2double(GSVdat(gsvpointer+f-1).snr2)...
                str2double(GSVdat(gsvpointer+f-1).snr3)...
                str2double(GSVdat(gsvpointer+f-1).snr4)];
            isnotnansnr = ~isnan(snrstr);
            for v = 1:4
                if(isnotnansnr(v))
                    snrsum = snrsum+snrstr(v);
                end
            end
        end
        if(snrsum > 0)
            snrarr(j) = snrsum / str2double(GSVdat(gsvpointer).numberofsats);
        else
            snrarr(j) = 0;
        end
        gsvpointer = gsvpointer+str2double(GSVdat(gsvpointer).numberofmsgs);
    end
    
    satctarr = double(zeros(z-1,1));
    gsvpointer2 = 1;
    for k = 1:z-1
        satctarr(k) = str2double(GSVdat(gsvpointer2).numberofsats);
        gsvpointer2 = gsvpointer2 + str2double(GSVdat(gsvpointer2).numberofmsgs);
    end
    u = 1;
    for v = 1:2:w-1
        pdoparr(u) = (str2double(GSAdat(v).pdop) + str2double(GSAdat(v+1).pdop)) / 2;
        hdoparr(u) = (str2double(GSAdat(v).hdop) + str2double(GSAdat(v+1).hdop)) / 2;
        vdoparr(u) = (str2double(GSAdat(v).vdop) + str2double(GSAdat(v+1).vdop)) / 2;
        u = u+1;
    end

    % size(latarr,1)
    % size(longarr,1)
    % size(snrarr,1)
    % size(trackarr,1)
    % size(elevationarr,1)
    % size(satctarr,1)
    % size(speedarr,1)

    %RemoveNaN(distancearr);
    RemoveNaN(latarr);
    RemoveNaN(longarr);
    RemoveNaN(snrarr);
    RemoveNaN(trackarr);
    RemoveNaN(elevationarr);
    RemoveNaN(satctarr);
    RemoveNaN(speedarr);
    RemoveNaN(qualityarr);
    RemoveNaN(hdoparr);
    RemoveNaN(vdoparr);
    RemoveNaN(pdoparr);
    % 
    % size(latarr,1)
    % size(longarr,1)
    % size(snrarr,1)
    % size(trackarr,1)
    % size(elevationarr,1)
    % size(satctarr,1)
    % size(speedarr,1)
    % [Sat Ct, Avg SNR, Altitude, Long., Long. Dir, Lat., Lat. Dir, Speed]
    datatable = table; 

    satctarr(isnan(satctarr)) = 1e-6;
    datatable.SatCt = satctarr;

    snrarr(isnan(snrarr)) = 1e-6;
    datatable.avgSNR = snrarr;

    %elevationarr(isnan(elevationarr)) = 1e-6;
    %datatable.Elevation = elevationarr;

    %longarr(isnan(longarr)) = 1e-6;
    %datatable.Long = longarr;

    %longdirarr(isnan(longdirarr)) = 1e-6;
    %datatable.LongDir = longdirarr;

    %latarr(isnan(latarr)) = 1e-6;
    %datatable.Lat = latarr;

    %latdirarr(isnan(latdirarr)) = 1e-6;
    %datatable.LatDir = latdirarr;

    %datatable.Quality = qualityarr;
    size(datatable)
    size(pdoparr)
    datatable.PDOP = pdoparr;
    datatable.HDOP = hdoparr;
    datatable.VDOP = vdoparr;
    
    if(transitionflag == "yes")
        if(begintime == "day")
            labelarr = [-ones(transitionidx,1); ones((z-1)-transitionidx,1)];
        else
            labelarr = [ones(transitionidx,1); -ones((z-1)-transitionidx,1)];
        end
    else
        if(begintime == "day")
            labelarr = ones(z-1,1);
        else
            labelarr = -ones(z-1,1);
        end
    end
    datatable.Label = labelarr;
    
end


    
function [] = RemoveNaN(arr)
    nanarr = isnan(arr);
    for i=1:length(arr)-1
        if(nanarr)
            arr(i) = 1e-6;
        end
    end
end

function [] = assignVal(gpsReading, arr, i)
        if(gpsReading ~= "")
            arr(i) = gpsReading;
        else
            arr(i) = 1e-7;
        end
end


%filename,timestamp, begintime,transitionflag, transitiontime
% table1 = CreateDataTable("1-8-26 Day to Midnight DL.txt", "yes","day","yes","112900.00");
% table2 = CreateDataTable("1-9-26 Day to Sunset DL.txt", "yes","day","no","113000.00");
% table3 = CreateDataTable("1-12-26 Day to Night DL.txt", "yes","day","yes","113300.00");
% table4 = CreateDataTable("1-13-26 Day to Midnight.txt", "yes","day","yes","113400.00");
% table5 = CreateDataTable("1-14-26 Midnight to Day.txt", "yes","night","yes","021100.00");
% table6 = CreateDataTable("1-14-26 noon to Night.txt", "yes","day","yes","113600.00");
% table7 = CreateDataTable("1-15-26 Morning Sunrise idk.txt", "yes","night","yes","021100.00");
% table8 = CreateDataTable("1-15-26 noon to sunset.txt", "yes","day","yes","113800.00");
% %table9 = CreateDataTable("Jan4th_11am6pm.txt", "no","day","no","112900.00");
% table10 = CreateDataTable("1_6_sunset.txt", "no", "day","yes","095100.00");
% table11 = CreateDataTable("1_7_sunriseCO.txt", "no", "night", "yes","142100.00");
% table12 = CreateDataTable("1_7_sunset.txt", "no", "night", "no", "095200.00");
%table13 = CreateDataTable("2-13-26 Noon to Night with ANT.txt", "yes", "day", "yes", "121400.00");
%table14 = CreateDataTable("2-14-26 midday - night ANT.txt", "yes", "day", "yes", "121500.00");
%table15 = CreateDataTable("gps11_24_day_7.10.13am 2.txt", "no", "day", "no", "114600.00");
%table16 = CreateDataTable("gps11_25_night(3).txt", "yes", "night", "no", "211500.00");
%table17 = CreateDataTable("3-10-26 Afternoon to Night ANT.txt", "yes", "day", "no", "214500.00");
%table18 = CreateDataTable("3-10-26 Midnight to Morning ANT.txt", "yes", "night", "yes", "100500.00");
table19 = CreateDataTable("3-27-26 Sunset to Midnight ANT+GSA DL.txt", "yes", "day", "yes", "230500.00");
table20 = CreateDataTable("3-28-26 Afternoon to Night ANT+GSA DL.txt", "yes", "day", "yes", "230600.00");
table21 = CreateDataTable("3-29-26 Midnight - Noon GSA+ANT DL.txt", "yes", "night", "yes", "103200.00");


% sizes1 = [size(table1,1) size(table2,1) size(table3,1) size(table4,1)...
%     size(table5,1) size(table6,1) size(table7,1) size(table8,1)];
% sizes2 = [size(table10,1) size(table11,1), size(table12,1)];
% sizes3 = [size(table13,1) size(table14,1)];
%sizes4 = [size(table15,1) size(table16,1)];

% minsize = min(sizes1);
% minsize2 = min(sizes2);
% minsize3 = min(sizes3);
%minsize4 = min(sizes4);

% randIndices = randperm(minsize, 5000);
% randIndices2 = randperm(minsize2, 1000);
% randIndices3 = randperm(minsize3, 10000);
%randIndices4 = randperm(minsize4, 5000);

% t1r = table1(randIndices,:);
% t2r = table2(randIndices,:);
% t3r = table3(randIndices,:);
% t4r = table4(randIndices,:);
% t5r = table5(randIndices,:);
% t6r = table6(randIndices,:);
% t7r = table7(randIndices,:);
% t8r = table8(randIndices,:);
% t10r = table10(randIndices2,:);
% t11r = table11(randIndices2,:);
% t12r = table12(randIndices2,:);
% t13r = table13(randIndices3,:);
% t14r = table14(randIndices3,:);
%t15r = table15(randIndices4,:);
%t16r = table16(randIndices4,:);

%t9r = table9(:,randIndices);
%fulltable = [table1;table2;table3;table4;table5;table6;table7;table8];
fulltable = [table19; table20; table21];
writetable(fulltable,"mldata_ANT_GSA3.xlsx");
% fulltable = [t1r; t2r; t3r; t4r; t5r; t6r; t7r; t8r;...
%     t10r; t11r; t12r; t13r; t14r; t15r; t16r];
% writetable(fulltable, "mldata_ardmatch5.xlsx");
%fulltable = [daytable1(1:size(nighttable1,1),:); nighttable1; daytable2; nighttable]