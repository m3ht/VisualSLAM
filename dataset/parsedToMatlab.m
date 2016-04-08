function [outputData  ] = parsedToMatlab(  )
%PARSER Summary of this function goes here
%   Detailed explanation goes here

outputData = {};
fid = fopen('parsed.txt');
tline = fgetl(fid);
index = 1;
while ischar(tline)
    if(strfind(tline,'ODOMETRY_POSE'));
        data = parseODO(tline);
        split = strsplit(tline, ' '); 
        iscell(split(4));
        temp = struct('Time',str2double(split(1)), 'Type', split(2), 'Data',data);
        outputData{index} = temp;
    elseif(strfind(tline,'LMS_LASER_2D_'))
        data = parseLaser(tline);
        split = strsplit(tline, ' '); 
        iscell(split(4));
        temp = struct('Time',str2double(split(1)), 'Type', split(2), 'Data',data);
        outputData{index} = temp;
    end
    if index > 10000
        return;
    end
        
    index = index + 1
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
        Time = value;
        
        title = strsplit(char(dataStruct(10)),'=');
        value = title(2);
        Speed = value;

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
        data = struct('pose', Pose, 'vel',Vel,'time', Time, 'speed',Speed,...
            'pitch', Pitch, 'roll',Roll, 'pitchDot', PitchDot, 'rollDot', RollDot);
        
end

function[data] = parseLaser(tline)
        split = strsplit(tline, ' ') ;
        dataStruct = strsplit(char(split(4)),',');
        
        title = strsplit(char(dataStruct(1)),'=');
        ID = str2double(title(2));
                
        title = strsplit(char(dataStruct(2)),'=');
        time = str2double(title(2));
        
        title = strsplit(char(dataStruct(3)),'=');
        angRes = str2double(title(2));
        
        title = strsplit(char(dataStruct(4)),'=');
        offset = str2double(title(2));
        
        title = strsplit(char(dataStruct(5)),'=');
        minAngle = str2double(title(2));
        
        title = strsplit(char(dataStruct(6)),'=');
        maxAngle = str2double(title(2));
        
        title = strsplit(char(dataStruct(7)),'=');
        scanCount = str2double(title(2));
        
        title = strsplit(char(dataStruct(8)),']{');
        temp = title(1);
        temp = strsplit(char(temp),'[');
        Range = str2double(temp(2));
        
        laserScans = zeros(Range,1);
        laserScans(1) = str2double(title(2));
        
        for i=2:Range-1
            laserScans(i) = str2double(dataStruct(7+i));
        end
        finalScan = strsplit(char(dataStruct(7+Range)),'}');
        laserScans(Range) = str2double(finalScan(1));
        
        
        title = strsplit(char(dataStruct(8+Range)),']{');
        temp = title(1);
        temp = strsplit(char(temp),'[');
        Reflectance = str2double(temp(2));
        
        refl = zeros(Reflectance,1);
        refl(1) = str2double(title(2));
        
        for i=2:Reflectance-1
            refl(i) = str2double(dataStruct(7+i+Range));
        end
        finalScan = strsplit(char(dataStruct(7+Range+Reflectance)),'}');
        refl(Reflectance) = str2double(finalScan(1));
        
        data = struct('ID', ID, 'time', time, 'angRes', angRes, 'offset', offset, ...
                      'minAngle',minAngle,'maxAngle',maxAngle,'scanCount', scanCount, ...
                      'range', Range, 'laserScans', laserScans,'reflectance',Reflectance, ...
                      'reflScans', refl);
        
end
