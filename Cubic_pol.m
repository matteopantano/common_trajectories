% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab


close all

% Cubic pol trajectory: I can defined 4 constraints of my trajectory in
% this case initial/final position and initial/final velocity

syms t1 t0 a0 a1 a2 a3 q0 v0 q1 v1;
syms t1 t0 b0 b1 b2 b3 q0 v0 q1 v1;
A = [1 0 0 0; 0 1 0 0; 1 (t1-t0) (t1-t0)^2 (t1-t0)^3; 0 1 2*(t1-t0) 3*(t1-t0)^2];
B = [a0; a1; a2; a3];
C = [q0; v0; q1; v1];
D = [b0; b1; b2; b3];
solB = solve(A*B==C, B);
solD = solve(A*D==C, D);

time = 0:0.1:8;

% pol evaluation (boarder limitations) %problem is with v0 different from 0
q0=20; q1=0; t0=0; t1=8; v0=2; v1=-10;
p_coeffB = [eval(solB.a3) eval(solB.a2) eval(solB.a1) eval(solB.a0)];
%p_coeffB = [-0.0625 0.0625 1 20];

% pol evaluation (boarder limitations)
q0=3; q1=10; t0=0; t1=8; v0=0; v1=8;
p_coeffD = [eval(solD.b3) eval(solD.b2) eval(solD.b1) eval(solD.b0)];

% position
positionB = polyval(p_coeffB, time);
positionD = polyval(p_coeffD, time);
figure('Name','Trajectories','NumberTitle','off')
subplot(3,1,1)
hold on
plot(time, positionB)
plot(time, positionD)
title('Position')
grid
legend('PositionB','PositionD','Location','southwest')
hold off

% velocity
v_coeffB = polyder(p_coeffB);
v_coeffD = polyder(p_coeffD);
velocityB = polyval(v_coeffB, time);
velocityD = polyval(v_coeffD, time);
subplot(3,1,2)
hold on
plot(time, velocityB)
plot(time, velocityD)
title('Velocity')
grid
legend('VelocityB','VelocityD','Location','southwest')
hold off

% accelleration
a_coeffB = polyder(v_coeffB);
a_coeffD = polyder(v_coeffD);
accellerationB = polyval(a_coeffB, time);
accellerationD = polyval(a_coeffD, time);
subplot(3,1,3)
hold on
plot(time, accellerationB)
plot(time, accellerationD)
grid
legend('AccellerationB','AccellerationD','Location','southwest')
hold off

% spectrogram
figure('Name','Spectrogram','NumberTitle', 'off')
subplot(2,1,1)
spectrogram(positionB,'yaxis')
title('Spectrogram B')

subplot(2,1,2)
spectrogram(positionD,'yaxis')
title('Spectrogram D')

% fourier transform
B = fft(positionB);  
D = fft(positionD);
mB = abs(B);
mD = abs(D);
pB = angle(B);
pD = angle(D);
fB = (0:length(B)-1)*50/length(B);
fD = (0:length(D)-1)*50/length(D);
figure('Name', 'FFT', 'NumberTitle','off')
subplot(2,1,1)
hold on
plot(fB,mB)
plot(fD,mD)
legend('PositionB','PositionD','Location','southwest')
title('Magnitude')
grid
hold off

subplot(2,1,2)
hold on
plot(fB,rad2deg(pB))
plot(fD,rad2deg(pD))
legend('PositionB','PositionD','Location','southwest')
title('Phase')
grid
hold off

% % Saves position into an excel file
% filename = 'Cubic_pol_POSITION.xlsx';
% sheet = 1;
% xlswrite(filename,positionB,sheet,'A1')
% xlswrite(filename,time,sheet,'A2')
