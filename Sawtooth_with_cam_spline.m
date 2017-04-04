% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab


% Sawtooth function having rpm of motor

% rpm of our motor
rpm = 600;
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

x = [0 0.05 0.07 T]; 
y = [0 1.2 1.5 0]; 
xq1 = 0:.001:T;
s = spline(x,y,xq1);
subplot(2,1,2)
plot(x,y,'o',xq1,s,'-')
title('Slave #1')
grid on,

