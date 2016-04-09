clear all;
close all;
clc;

addpath('../data/matlab');

base_dir = '../data/2011_09_26_drive_0018/';

frames = 1:175;

% load oxts data
oxts = loadOxtsliteData(base_dir,frames);

x = zeros(length(frames),6);

for t = 1:length(frames)
	x(t,1:3) = oxts{t}(9:11);
	% mu(t,2) = oxts{t}.vl;
	% mu(t,3) = oxts{t}.vu;
	x(t,4:6) = oxts{t}(21:23);
	% mu(t,5) = oxts{t}.wl;
	% mu(t,6) - oxts{t}.wu;
end

mu = mean(x);
disp(mu);

Sigma = cov(x);
disp(Sigma);