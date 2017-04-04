% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab


% Sawtooth function having rpm of motor

% rpm of our motor
rpm = 200;
Fs = 10000;
dt = 1/Fs;
% period of one round knowing thr rpm of the motor
T = 60/rpm;
t = 0:dt:T+dt;
%x =  180 * sawtooth(2*pi*50*t, 1) + 180;

% sawtooth in radiant that goes from 0 to 0.1 seconds [one period]
%x =  pi * sawtooth((rpm/30)*pi*t,1) + pi;

% sawtooth in deg that goes from 0 to 0.1 seconds [one period]
x =  180 * sawtooth((rpm/30)*pi*t,1) + 180;

figure('Name','Synchronization','NumberTitle','off')
subplot(2,1,1)
plot(t,x)
title('Master')
grid

%syms t1 t0 a0 a1 a2 a3 q0 v0 q1 v1;
%A = [1 0 0 0; 0 1 0 0; 1 (t1-t0) (t1-t0)^2 (t1-t0)^3; 0 1 2*(t1-t0) 3*(t1-t0)^2];
%B = [a0; a1; a2; a3];
%C = [q0; v0; q1; v1];
%solB = solve(A*B==C, B);

time = 0:dt:T+dt;

% constraints due to the synchronization between cams
t0=0; t1=T+dt;

% pol evaluation (boarder limitations) 
q0=0; q1=360; v0=3; v1=-10;
a0 = q0;
a1 = v0;
a2 = -(3*q0 - 3*q1 - 2*t0*v0 - t0*v1 + 2*t1*v0 + t1*v1)/(t0 - t1)^2;
a3 = -(2*q0 - 2*q1 - t0*v0 - t0*v1 + t1*v0 + t1*v1)/((t0 - t1)*(t0^2 - 2*t0*t1 + t1^2));
p_coeffB = [a3 a2 a1 a0];

% position
positionB = polyval(p_coeffB, t);
%figure('Name','Position','NumberTitle','off')
subplot(2,1,2)
plot(t, positionB)
title('Slave #1')
grid


