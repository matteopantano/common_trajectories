% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab


close all

% Poly for more points, I want to define a poly able to pass for some
% points, to do that I need to define the passage points and at what time
% I will have the passage on the point

rpm = 600;
Fs = 10000;
dt = 1/Fs;
% period of one round knowing thr rpm of the motor
T = 60/rpm;
t = 0:dt:T+dt;


syms t0 t1 t2 t3 t4 p0 p1 p2 p3 p4 a0 a1 a2 a3 a4;
A = [1 t0 t0^2 t0^3 t0^4; 1 t1 t1^2 t1^3 t1^4; 1 t2 t2^2 t2^3 t2^4; 1 t3 t3^2 t3^3 t3^4; 1 t4 t4^2 t4^3 t4^4];
B = [a0; a1; a2; a3; a4];
C = [p0; p1; p2; p3; p4];
solB = solve(A*B==C, B)

time = t;

% constraints due to the synchronization between cams
t0=0; t4=T+dt;

% Pol evaluation (boarder limitations)
p0=0; p1=200; p2=-100; p3=100; p4=360; t1=0.02; t2=0.06; t3=0.07;
p_coeffB = [eval(solB.a4) eval(solB.a3) eval(solB.a2) eval(solB.a1) eval(solB.a0)];

% Position
positionB = polyval(p_coeffB, time);
figure('Name','Position','NumberTitle','off')
%subplot(3,1,1)
plot(time, positionB)
title('Position')
grid

% Velocity
v_coeffB = polyder(p_coeffB);
velocityB = polyval(v_coeffB, time);
figure('Name','Trajectories','NumberTitle','off')
subplot(3,1,2)
plot(time, velocityB)
title('Velocity')
grid

% Accelleration
a_coeffB = polyder(v_coeffB);
accellerationB = polyval(a_coeffB, time);
subplot(3,1,3)
plot(time, accellerationB)
title('Acceleration')
grid

% % spectrogram
% figure('Name','Spectrogram','NumberTitle', 'off')
% spectrogram(positionB,'yaxis')
% title('Spectrogram')
% 
% % fourier transform
% B = fft(positionB);  
% mB = abs(B);
% pB = angle(B);
% fB = (0:length(B)-1)*50/length(B);
% figure('Name', 'FFT', 'NumberTitle','off')
% subplot(2,1,1)
% plot(fB,mB)
% title('Magnitude')
% grid
% 
% subplot(2,1,2)
% plot(fB,rad2deg(pB))
% title('Phase')
% grid

% % Saves position into an excel file
% filename = 'Multi_point_pol_POSITION.xlsx';
% sheet = 1;
% xlswrite(filename,positionB,sheet,'A1')
% xlswrite(filename,time,sheet,'A2')