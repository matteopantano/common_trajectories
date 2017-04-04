% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab

close all

% Generation of a trigonometric function (Armonic) putting just initial
% and final position with initial and final time

syms t

% pol evaluation (boarder limitations)
q0=0; q1=10; t0=0; t1=8; T=8;

h = 2*(q1-q0)/(1-cos((pi*(t1-t0))/T));

t = 0:0.1:8;

% Trigonometric
q = h/2* (1-cos((pi*(t-t0))/T)) + q0;
q_prime = (pi*h)/(T*2)*sin((pi*t-t0)/T);
q_2_prime = (pi^2*h)/(T^2*2)*cos((pi*t-t0)/T);

% Position
figure('Name','Trajectories','NumberTitle','off')
subplot(3,1,1)
plot(t, q)
title('Position')
grid

% Velocity
subplot(3,1,2)
plot(t, q_prime)
title('Velocity')
grid

% Accelleration
subplot(3,1,3)
plot(t, q_2_prime)
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
filename = 'Harmonic_POSITION.xlsx';
sheet = 1;
xlswrite(filename,q,sheet,'A1')
xlswrite(filename,t,sheet,'A2')
