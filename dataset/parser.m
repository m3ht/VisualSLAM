function [  ] = parser(  )
%PARSER Summary of this function goes here
%   Detailed explanation goes here

fid = fopen('NewCollege.alog');
fileID = fopen('parsed.txt','w');
tline = fgetl(fid);
while ischar(tline)
    if(strfind(tline,'ODOMETRY_POSE'))
        if(strfind(tline,'PLOGGER_STATUS'))
        elseif(strfind(tline,'OdometryName'))
        else 
            fprintf(fileID,tline);
            fprintf(fileID,'\n');

            disp(tline)
        end
    elseif(strfind(tline,'LMS_LASER_2D_'))
        if(strfind(tline,'AppErrorFlag'))
        else
            fprintf(fileID,tline);
            fprintf(fileID,'\n');

            disp(tline)
        end
    end
    tline = fgetl(fid);
end

fclose(fid);


end

