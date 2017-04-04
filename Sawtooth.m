% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab


% Sawtooth function having rpm of motor

% rpm of our motor
rpm = 600;
Fs = 10000;
dt = 1/Fs;
% period of one round knowing thr rpm of the motor
T = 60/rpm;
t = 0:dt:0.5;
%t = 0:dt:T+dt;
%x =  180 * sawtooth(2*pi*50*t, 1) + 180;

% sawtooth in radiant that goes from 0 to 0.1 seconds [one period]
%x =  pi * sawtooth((rpm/30)*pi*t,1) + pi;

% sawtooth in deg that goes from 0 to 0.1 seconds [one period]
x =  180 * sawtooth((rpm/30)*pi*t,1) + 180;

figure
plot(t,x)
grid on

% spectrogram
figure('Name','Spectrogram','NumberTitle', 'off')
spectrogram(x,'yaxis')



