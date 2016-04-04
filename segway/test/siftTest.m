
% Scans through current folder and loads all jpg images. 
% Loops through all the images and displays SURF features.
%use extract feautures to get 64 sized feature vector. use cell to collect
%mean and variance of these vectors. 
clear
close all
fileNames = dir('*.jpg');
numImages = length(fileNames);

imageName=cell(numImages,1);
strongestPoints=cell(numImages,1);
features=cell(numImages,1);
im=cell(numImages,1);
for i=1:numImages
    imageName{i} = fileNames(i).name;
end



%{
imageName{1} = 'img_CAMERA1_1261228969.770601_left.jpg';
imageName{2} = 'img_CAMERA1_1261228969.770601_right.jpg';

imageName{3} = 'img_CAMERA1_1261228969.820611_left.jpg';
%}
%im=zeros([size(imread(imageName{1})) 3]);

for i=1:3
img = imread(imageName{i});
im{i} = im2double(rgb2gray(img));


points = detectSURFFeatures(im{i});
strongestPoints{i} = points.selectStrongest(50);

figure()
imshow(im{i}); hold on;
 strongestPoints{i}.plot('showOrientation',true);
 features{i}=extractFeatures(im{i}, strongestPoints{i});
end



  %[features, valid_points] = 

 
