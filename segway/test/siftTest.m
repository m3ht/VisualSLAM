
% Scans through current folder and loads all jpg images. 
% Loops through all the images and displays SURF features.
%use extract feautures to get 64 sized feature vector. use cell to collect
%mean and variance of these vectors. 
clear
close all
S = pwd
S = strcat(S ,'/StereoImages/*.pnm')
fileNames = dir(S);
numImages = length(fileNames);

imageName=cell(numImages,1);
strongestPoints=cell(numImages,1);
features=cell(numImages,1);
im=cell(numImages,1);
for i=1:numImages
    imageName{i} = fileNames(i).name;
end

numImages
%{
imageName{1} = 'img_CAMERA1_1261228969.770601_left.jpg';
imageName{2} = 'img_CAMERA1_1261228969.770601_right.jpg';

imageName{3} = 'img_CAMERA1_1261228969.820611_left.jpg';
%}
%im=zeros([size(imread(imageName{1})) 3]);
tic
figure
for i=1:2:numImages
left = imread(imageName{i});
im{i} = im2double(left);


points = detectSURFFeatures(im{i});
strongestPoints{i} = points.selectStrongest(50);

subplot(1,3,1)
imshow(im{i}); hold on;
strongestPoints{i}.plot('showOrientation',true);
 features{i}=extractFeatures(im{i}, strongestPoints{i});
 
 
 
right = imread(imageName{i+1});
im{i+1} = im2double(right);


points = detectSURFFeatures(im{i+1});
strongestPoints{i+1} = points.selectStrongest(50);

subplot(1,3,2)
imshow(im{i+1}); hold on;
strongestPoints{i+1}.plot('showOrientation',true);
 features{i+1}=extractFeatures(im{i+1}, strongestPoints{i+1});
 
 disparityMap = disparity(left, right);
 subplot(1,3,3)
imshow(disparityMap, [0, 64]);
title('Disparity Map');
colormap jet
colorbar
 

end
toc


