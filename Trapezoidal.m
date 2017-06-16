% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab

close all

% Generation of trapezoidal velocity trajectory
syms t t1 t0 Ta q0 q1 Vv f1 f2 f3

% position
f1 = q0 + Vv / (2*Ta)*(t-t0)^2;
f2 = q0 + Vv * (t - t0 - Ta/2);
f3 = q1 - Vv / (2*Ta)*(t1 - t)^2;

% velocity
g1 = diff(f1, t);
g2 = diff(f2, t);
g3 = diff(f3, t);

% acceleration
h1 = diff(g1, t);
h2 = diff(g2, t);
h3 = diff(g3, t);

% constraints on the trajectory
t = 0:.01:4;
t0 = 0; t1 = 4; Ta = 1; q0 = 0; q1 = 30; Vv = 10;

% position w/ values
outline_1 = eval(f1);
outline_2 = eval(f2);
outline_3 = eval(f3);
traj_position = outline_1.*(t>= 0 & t<1) + outline_2.*(t>=1 & t<3) + outline_3.*(t>= 3 & t<=4);
figure('Name','Position','NumberTitle','off')
hold on
plot(t, traj_position)
grid
hold off

% velocity w/ values
outline_1 = eval(g1);
outline_2 = eval(g2);
outline_3 = eval(g3);
traj_velocity = outline_1.*(t>= 0 & t<1) + outline_2.*(t>=1 & t<3) + outline_3.*(t>= 3 & t<=4);
figure('Name','Velocity','NumberTitle','off')
hold on
plot(t, traj_velocity)
grid
hold off

% acceleration w/ values
outline_1 = eval(h1);
outline_2 = eval(h2);
outline_3 = eval(h3);
traj_acceleration = outline_1.*(t>= 0 & t<1) + outline_2.*(t>=1 & t<3) + outline_3.*(t>= 3 & t<=4);
figure('Name','Acceleration','NumberTitle','off')
hold on
plot(t, traj_acceleration)
grid
hold off