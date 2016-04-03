function state = prediction(state, motion)
% Predicts the new state given the current state
% and motion with form: [drot1, dtrans, drot2].

state(3) = state(3) + motion(1);
state(1) = state(1) + motion(2)*cos(state(3));
state(2) = state(2) + motion(2)*sin(state(3));
state(3) = state(3) + motion(3);
state(3) = minimizedAngle(state(3));
