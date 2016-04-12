function H = initialize_new_landmark(k,z)
% Fast SLAM 1.0 State Augmentation Step

global Param;
global State;

if State.Fast.particles{k}.nL == 0
	H = 1;
else
	H = State.Fast.particles{k}.sL(end)+1;
end

j = State.Fast.particles{k}.nL + 1;

State.Fast.particles{k}.nL = li;
State.Fast.particles{k}.sL(end + 1) = H;
State.Fast.particles{k}.iL(end + 1) = j;

state = State.Fast.particles{k}.x;

end % function

function landmark = endPoint(state, observation)
end
