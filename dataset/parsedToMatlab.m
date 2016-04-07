function [outputData  ] = parsedToMatlab(  )
%PARSER Summary of this function goes here
%   Detailed explanation goes here

outputData = [];
fid = fopen('parsed.txt');
tline = fgetl(fid);
index = 1;
while ischar(tline)
    if(strfind(tline,'ODOMETRY_POSE'));
        data = parseODO(tline);
        split = strsplit(tline, ' '); 
        iscell(split(4));
        temp = struct('Time',str2double(split(1)), 'Type', split(2), 'Data',data)
        outputData(index).struct = temp
        index = index + 1;
        
    end

%     elseif(strfind(tline,'LMS_LASER_2D_'))
%         fprintf(fileID,tline);
%         fprintf(fileID,'\n');
% 
%         disp(tline)
%         
%     end

    tline = fgetl(fid);
end

fclose(fid);


end


function[data] = parseODO(tline)
        split = strsplit(tline, ' ') ;
        iscell(split(4));
        dataStruct = strsplit(char(split(4)),',');
        title = strsplit(char(dataStruct(1)),'=[3x1]{');
        value = zeros(3,1);
        value(1,1) = str2double(title(2));
        value(2,1) = str2double(dataStruct(2));
        temp = strsplit(char(dataStruct(3)),'}');
        value(3,1) = str2double(temp(1));
        Pose = value;
                
        title = strsplit(char(dataStruct(4)),'=[3x1]{');
        value = zeros(3,1);
        value(1,1) = str2double(title(2));
        value(2,1) = str2double(dataStruct(5));
        temp = strsplit(char(dataStruct(6)),'}');
        value(3,1) = str2double(temp(1));
        Vel = value;
        
        title = strsplit(char(dataStruct(7)),'=[2x1]{');
        value = zeros(2,1);
        value(1,1) = str2double(title(2));
        temp = strsplit(char(dataStruct(8)),'}');
        value(2,1) = str2double(temp(1));
        Raw = value;
        
        title = strsplit(char(dataStruct(9)),'=');
        value = title(2);
        Time = value;;
        
        title = strsplit(char(dataStruct(10)),'=');
        value = title(2);
        Speed = value;;

        title = strsplit(char(dataStruct(11)),'=');
        value = title(2);
        Pitch = value;
        
         title = strsplit(char(dataStruct(12)),'=');
        value = title(2);
        Roll = value;
        
         title = strsplit(char(dataStruct(13)),'=');
        value = title(2);
        PitchDot = value;
        
         title = strsplit(char(dataStruct(14)),'=');
        value = title(2);
        RollDot = value;
        
        value = {Pose, Vel, Raw, Time, Speed, Pitch, Roll, PitchDot, RollDot}';
        data = struct('Pose', Pose, 'Vel',Vel,'Time', Time, 'Speed',Speed,...
            'Pitch', Pitch, 'Roll',Roll, 'PitchDot', PitchDot, 'RollDot', RollDot);
        
end
