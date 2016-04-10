clear all;
close all;
clc;

addpath('../data/matlab');

base_dir = '../data/2011_09_26_drive_0018/';

frames = 1:175;

% load oxts data
oxts = loadOxtsliteData(base_dir,frames);

u = zeros(length(frames),2);

for t = 1:length(frames)
	u(t,1) = oxts{t}(9);
	u(t,2) = oxts{t}(23);
end

mu = mean(u);
disp(mu);

Sigma = cov(u);
disp(Sigma);