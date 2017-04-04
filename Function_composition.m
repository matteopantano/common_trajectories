% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab

% Function Composition

% rpm of our motor
rpm = 600;
Fs = 10000;
dt = 1/Fs;
t1 = 0.1
t0 = 0
% t = 0:dt:1;
%x =  180 * sawtooth(2*pi*50*t, 1) + 180;
%syms t
%t = 0:dt:1;
% sawtooth in radiant that goes from 0 to 1 seconds 
function x =sawtooth(t)

%x =  pi * sawtooth((rpm/30)*pi*t,1) + pi;

fnval(x, 0)
end
f = x; 

plot(t,f)
grid on

% evaluate function at certain t
x0 =  pi * sawtooth((rpm/30)*pi*0,1) + pi
x1 =  pi * sawtooth((rpm/30)*pi*0.09999,1) + pi


syms t1 t0 q0 q1 a0 a1;
A = [1 0; 1 (t1-t0)];
B = [a0; a1];
C = [q0; q1];
solB = solve(A*B==C, B);

time = 0:0.1:8;

% pol evaluation (boarder limitations)
q0=0; q1=10; t0=x0; t1=x1;
p_coeffB = [eval(solB.a1) eval(solB.a0)];


% position
positionB = polyval(p_coeffB, time);
figure('Name','Position','NumberTitle','off');
hold on
grid
plot(time, positionB)
legend('PositionB','Location','southwest')
hold off

