% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab


% Poly for more points, I want to define a poly able to pass for some
% points, as exercise pg 25, as long I want also the velocity I am trying
% to obtain it with merge of cubic poly

syms t1 t0 a0 a1 a2 a3 q0 v0 q1 v1;
syms t1 t0 b0 b1 b2 b3 q0 v0 q1 v1;
syms t1 t0 c0 c1 c2 c3 q0 v0 q1 v1;
syms t1 t0 d0 d1 d2 d3 q0 v0 q1 v1;
A = [1 0 0 0; 0 1 0 0; 1 (t1-t0) (t1-t0)^2 (t1-t0)^3; 0 1 2*(t1-t0) 3*(t1-t0)^2];
C = [q0; v0; q1; v1];
B = [a0; a1; a2; a3];
D = [b0; b1; b2; b3];
E = [c0; c1; c2; c3];
F = [d0; d1; d2; d3];
solB = solve(A*B==C, B);
solD = solve(A*D==C, D);
solE = solve(A*E==C, E);
solF = solve(A*F==C, F);

% pol evaluation (boarder limitations) B
timeB = 0:0.1:2;
q0=10; q1=20; t0=0; t1=2; v0=0; v1=-10;
p_coeffB = [eval(solB.a3) eval(solB.a2) eval(solB.a1) eval(solB.a0)];
positionB = polyval(p_coeffB, (timeB-0));

% pol evaluation (boarder limitations) D
timeD = 2:0.1:4;
q0=20; q1=0; t0=2; t1=4; v0=-10; v1=10;
p_coeffD = [eval(solD.b3) eval(solD.b2) eval(solD.b1) eval(solD.b0)];
positionD = polyval(p_coeffD, (timeD-2));

% pol evaluation (boarder limitations) E
timeE = 4:0.1:8;
q0=0; q1=30; t0=4; t1=8; v0=10; v1=3;
p_coeffE = [eval(solE.c3) eval(solE.c2) eval(solE.c1) eval(solE.c0)];
positionE = polyval(p_coeffE, (timeE-4));

% pol evaluation (boarder limitations) F
timeF = 8:0.1:10;
q0=30; q1=40; t0=8; t1=10; v0=3; v1=0;
p_coeffF = [eval(solF.d3) eval(solF.d2) eval(solF.d1) eval(solF.d0)];
positionF = polyval(p_coeffF, (timeF-8));

% position
figure('Name','Position','NumberTitle','off')
hold on
grid
time = [timeB timeD timeE timeF];
position = [positionB positionD positionE positionF];
plot(time, position)
legend('Position','Location','southwest')
hold off

% velocity
velocityB = polyval(polyder(p_coeffB), (timeB-0));
velocityD = polyval(polyder(p_coeffD), (timeD-2));
velocityE = polyval(polyder(p_coeffE), (timeE-4));
velocityF = polyval(polyder(p_coeffF), (timeF-8));
figure('Name','Velocity','NumberTitle','off')
hold on
grid
time = [timeB timeD timeE timeF];
velocity = [velocityB velocityD velocityE velocityF];
plot(time, velocity)
legend('Velocity','Location','southwest')
hold off

% acceleration
accelerationB = polyval(polyder(polyder(p_coeffB)), (timeB-0));
accelerationD = polyval(polyder(polyder(p_coeffD)), (timeD-2));
accelerationE = polyval(polyder(polyder(p_coeffE)), (timeE-4));
accelerationF = polyval(polyder(polyder(p_coeffF)), (timeF-8));
figure('Name','Acceleration','NumberTitle','off')
hold on
grid
time = [timeB timeD timeE timeF];
acceleration = [accelerationB accelerationD accelerationE accelerationF];
plot(time, acceleration)
legend('Acceleration','Location','southwest')
hold off