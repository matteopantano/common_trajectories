% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab


close all

% Spline 3

x = [0 0.1 0.15 0.2]; 
y = [0 1 -3 0]; 
xq1 = 0:.001:0.2;
s = spline(x,y,xq1)
figure('Name','Spline','NumberTitle', 'off')
plot(x,y,'o',xq1,s,'-')
legend('Sample Points','spline','Location','SouthEast')
title('Position')
grid

diff(s,xq1)

% spectrogram
figure('Name','Spectrogram','NumberTitle', 'off')
spectrogram(s,'yaxis')
title('Spectrogram')

% fourier transform
B = fft(s);  
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
filename = 'Spline_POSITION.xlsx';
sheet = 1;
xlswrite(filename,s,sheet,'A1')
xlswrite(filename,xq1,sheet,'A2')