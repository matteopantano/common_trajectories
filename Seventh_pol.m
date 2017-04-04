% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab


close all

% Seventh pol trajectory: I can define 8 constraints of my trajectory, in
% this case: initial/final position, initial/final velocity,
% initial/final accelleration and initial/final jerk

syms t1 t0 b0 b1 b2 b3 b4 b5 b6 b7 q0 v0 a0 j0 q1 v1 a1 j1;
A = [1 0 0 0 0 0 0 0; 0 1 0 0 0 0 0 0; 0 0 2 0 0 0 0 0;0 0 0 6 0 0 0 0; 1 (t1-t0) (t1-t0)^2 (t1-t0)^3 (t1-t0)^4 (t1-t0)^5 (t1-t0)^6 (t1-t0)^7; 0 1 2*(t1-t0) 3*(t1-t0)^2 4*(t1-t0)^3 5*(t1-t0)^4 6*(t1-t0)^5 7*(t1-t0)^6; 0 0 2 6*(t1-t0) 12*(t1-t0)^2 20*(t1-t0)^3 30*(t1-t0)^4 42*(t1-t0)^5 ; 0 0 0 6 24*(t1-t0) 60*(t1-t0)^2 120*(t1-t0)^3 210*(t1-t0)^4];
B = [b0; b1; b2; b3; b4; b5; b6; b7];
C = [q0; v0; a0; j0; q1; v1; a1; j1];
solB = solve(A*B==C, B);

time = 0:0.1:4;

% Pol evaluation (boarder limitations)
q0=20; q1=15; v0=2; v1=0; a0=3; a1=4; j0=2; j1=5; t0=0; t1=4; 
p_coeffB = [eval(solB.b7) eval(solB.b6) eval(solB.b5) eval(solB.b4) eval(solB.b3) eval(solB.b2) eval(solB.b1) eval(solB.b0)]; %controllare valori parametri

% Position
positionB = polyval(p_coeffB, time);
figure('Name','Trajectories','NumberTitle','off')
subplot(3,1,1)
plot(time, positionB)
title('Position')
grid

% Velocity
v_coeffB = polyder(p_coeffB);
velocityB = polyval(v_coeffB, time);
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

% spectrogram
figure('Name','Spectrogram','NumberTitle', 'off')
spectrogram(positionB,'yaxis')
title('Spectrogram')

% fourier transform
B = fft(positionB);  
mB = abs(B);
pB = angle(B);
fB = (0:length(B)-1)*50/length(B);
figure('Name', 'FFT', 'NumberTitle','off')
subplot(2,1,1)
plot(fB,mB)
title('Magnitude')
grid

subplot(2,1,2)
plot(fB,rad2deg(pB))
title('Phase')
grid

% Saves position into an excel file
filename = 'Seventh_pol_POSITION.xlsx';
sheet = 1;
xlswrite(filename,positionB,sheet,'A1')
xlswrite(filename,time,sheet,'A2')