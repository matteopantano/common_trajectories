% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab

close all

% Fifth pol trajectory: I can define 6 constraints of my trajectory, in
% this case: initial/final position, initial/final velocity and
% initial/final accelleration

syms t1 t0 b0 b1 b2 b3 b4 b5 q0 v0 a0 q1 v1 a1;
A = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 2 0 0 0; 1 (t1-t0) (t1-t0)^2 (t1-t0)^3 (t1-t0)^4 (t1-t0)^5; 0 1 2*(t1-t0) 3*(t1-t0)^2 4*(t1-t0)^3 5*(t1-t0)^4; 0 0 2 6*(t1-t0) 12*(t1-t0)^2 20*(t1-t0)^3];
B = [b0; b1; b2; b3; b4; b5];
C = [q0; v0; a0; q1; v1; a1];
solB = solve(A*B==C, B);

time = 0:0.001:0.25;

% Pol evaluation (boarder limitations)
q0=1.225; q1=0.00; v0=0; v1=0; a0=0; a1=0; t0=0; t1=0.25; 
p_coeffB = [eval(solB.b5) eval(solB.b4) eval(solB.b3) eval(solB.b2) eval(solB.b1) eval(solB.b0)]

% Position
positionB = polyval(p_coeffB, time);
figure('Name','Position','NumberTitle','off')
%subplot(3,1,1)
hold on
plot(time, positionB)
grid
hold off

% Velocity
v_coeffB = polyder(p_coeffB);
velocityB = polyval(v_coeffB, time);
figure('Name','Velocity','NumberTitle','off')
%subplot(3,1,2)
plot(time, velocityB)
title('Velocity')
grid

% Accelleration
a_coeffB = polyder(v_coeffB);
accellerationB = polyval(a_coeffB, time);
figure('Name','Acceleration','NumberTitle','off')
%subplot(3,1,3)
plot(time, accellerationB)
title('Acceleration')
grid

% jerk
j_coeffB = polyder(a_coeffB);
jerkB = polyval(j_coeffB, time);
figure('Name','Jerk','NumberTitle','off')
%subplot(3,1,3)
hold on
plot(time, jerkB)
%plot(time, accellerationD)
grid
title('Jerk')
hold off


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

% Saves position into an excel file
% filename = 'Fifth_pol_POSITION.xlsx';
% sheet = 1;
% xlswrite(filename,positionB,sheet,'A1')
% xlswrite(filename,time,sheet,'A2')
