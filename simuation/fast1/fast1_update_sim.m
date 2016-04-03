function fast1_update_sim(z)
% Fast SLAM 1.0 update step.

global Param;
global State;

switch lower(Param.dataAssociation)
case 'known'
	H = da_known(z);
case 'nn'
	H = da_nn(z);
case 'nndg'
	H = da_nndg(z);
case 'jcbb'
	H = da_jcbb(z);
end

old = find(H);
new = setdiff(1:length(H), old);
