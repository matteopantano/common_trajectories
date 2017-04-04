% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab 


% Poly for more points, I want to define a poly able to pass for some
% points, as exercise pg 29, as long I want smoothe profiles so I opt to
% use a fifth poly merge

syms t1 t0 a0 a1 a2 a3 a4 a5 q0 v0 acc0 q1 v1 acc1;
syms t1 t0 b0 b1 b2 b3 b4 b5 q0 v0 acc0 q1 v1 acc1;
syms t1 t0 c0 c1 c2 c3 c4 c5 q0 v0 acc0 q1 v1 acc1;
syms t1 t0 d0 d1 d2 d3 d4 d5 q0 v0 acc0 q1 v1 acc1;
A = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 2 0 0 0; 1 (t1-t0) (t1-t0)^2 (t1-t0)^3 (t1-t0)^4 (t1-t0)^5; 0 1 2*(t1-t0) 3*(t1-t0)^2 4*(t1-t0)^3 5*(t1-t0)^4; 0 0 2 6*(t1-t0) 12*(t1-t0)^2 20*(t1-t0)^3];
C = [q0; v0; acc0; q1; v1; acc1];
B = [a0; a1; a2; a3; a4; a5];
D = [b0; b1; b2; b3; b4; b5];
E = [c0; c1; c2; c3; c4; c5];
F = [d0; d1; d2; d3; d4; d5];
solB = solve(A*B==C, B);
solD = solve(A*D==C, D);
solE = solve(A*E==C, E);
solF = solve(A*F==C, F);

% Pol evaluation (boarder limitations) B
timeB = 0:0.1:2;
q0=10; q1=20; v0=3; v1=-10; acc0=0; acc1=0; t0=0; t1=2; 
p_coeffB = [eval(solB.a5) eval(solB.a4) eval(solB.a3) eval(solB.a2) eval(solB.a1) eval(solB.a0)]; %contrallare valori parametri
positionB = polyval(p_coeffB, (timeB-0));
syms t;
fB = p_coeffB(6) + p_coeffB(5) * (t-2) + p_coeffB(4) * (t-2)^2 + p_coeffB(3) * (t-2)^3 + p_coeffB(2) * (t-2)^4 + p_coeffB(1) * (t-2)^5;

% Pol evaluation (boarder limitations) D
timeD = 2:0.1:4;
q0=20; q1=0; v0=-10; v1=10; acc0=0; acc1=0; t0=2; t1=4; 
p_coeffD = [eval(solD.b5) eval(solD.b4) eval(solD.b3) eval(solD.b2) eval(solD.b1) eval(solD.b0)];
fD = p_coeffD(6) + p_coeffD(5) * (t-2) + p_coeffD(4) * (t-2)^2 + p_coeffD(3) * (t-2)^3 + p_coeffD(2) * (t-2)^4 + p_coeffD(1) * (t-2)^5;
dk = [subs(fB,2)-subs(fB,1.9)]/(2-1.9); 
dk1= [subs(fD,2.1)-subs(fD,2)]/(2.1-2);
if sign(dk) == sign (dk1) 
   vk = double(1/2 * (dk+dk1));
   q0=10; q1=20; v0=0; v1=vk; acc0=0; acc1=0; t0=0; t1=2; 
   p_coeffB = [eval(solB.a5) eval(solB.a4) eval(solB.a3) eval(solB.a2) eval(solB.a1) eval(solB.a0)];
   positionB = polyval(p_coeffB, (timeB-0));
   v_coeffB = polyder(p_coeffB);
   velocityB = polyval(polyder(p_coeffB), (timeB-0));
   q0=20; q1=0; v0=vk; v1=10; acc0=0; acc1=0; t0=2; t1=4;
   p_coeffD = [eval(solD.b5) eval(solD.b4) eval(solD.b3) eval(solD.b2) eval(solD.b1) eval(solD.b0)];
   positionD = polyval(p_coeffD, (timeD-2));
else
   vk=0;
   q0=10; q1=20; v0=0; v1=vk; acc0=0; acc1=0; t0=0; t1=2; 
   p_coeffB = [eval(solB.a5) eval(solB.a4) eval(solB.a3) eval(solB.a2) eval(solB.a1) eval(solB.a0)];
   positionB = polyval(p_coeffB, (timeB-0));
   v_coeffB = polyder(p_coeffB);
   velocityB = polyval(polyder(p_coeffB), (timeB-0));
   q0=20; q1=0; v0=vk; v1=10; acc0=0; acc1=0; t0=2; t1=4;
   p_coeffD = [eval(solD.b5) eval(solD.b4) eval(solD.b3) eval(solD.b2) eval(solD.b1) eval(solD.b0)];
   positionD = polyval(p_coeffD, (timeD-2));
end

% Pol evaluation (boarder limitations) E
timeE = 4:0.1:8;
q0=0; q1=30; v0=10; v1=3; acc0=0; acc1=0; t0=4; t1=8; 
p_coeffE = [eval(solE.c5) eval(solE.c4) eval(solE.c3) eval(solE.c2) eval(solE.c1) eval(solE.c0)];
fE = p_coeffE(6) + p_coeffE(5) * (t-4) + p_coeffE(4) * (t-4)^2 + p_coeffE(3) * (t-4)^3 + p_coeffE(2) * (t-4)^4 + p_coeffE(1) * (t-4)^5;
fD = p_coeffD(6) + p_coeffD(5) * (t-2) + p_coeffD(4) * (t-2)^2 + p_coeffD(3) * (t-2)^3 + p_coeffD(2) * (t-2)^4 + p_coeffD(1) * (t-2)^5;
dk = double([subs(fD,4)-subs(fD,3.9)]/(4-3.9));
dk1= double([subs(fE,4.1)-subs(fE,4)]/(4.1-4));
if sign(dk) == sign (dk1) 
   vk1 = double(1/2 * (dk+dk1));
   q0=20; q1=0; v0=vk; v1=vk1; acc0=0; acc1=0; t0=2; t1=4;
   p_coeffD = [eval(solD.b5) eval(solD.b4) eval(solD.b3) eval(solD.b2) eval(solD.b1) eval(solD.b0)];
   positionD = polyval(p_coeffD, (timeD-2));
   q0=0; q1=30; v0=vk1; v1=3; acc0=0; acc1=0; t0=4; t1=8;
   p_coeffE = [eval(solE.c5) eval(solE.c4) eval(solE.c3) eval(solE.c2) eval(solE.c1) eval(solE.c0)];
   positionE = polyval(p_coeffE, (timeE-4));
else
   vk1=0;
   q0=20; q1=0; v0=vk; v1=vk1; acc0=0; acc1=0; t0=2; t1=4;
   p_coeffD = [eval(solD.b5) eval(solD.b4) eval(solD.b3) eval(solD.b2) eval(solD.b1) eval(solD.b0)];
   positionD = polyval(p_coeffD, (timeD-2));
%    q0=0; q1=30; v0=vk1; v1=3; acc0=0; acc1=0; t0=4; t1=8;
%    p_coeffE = [eval(solE.c5) eval(solE.c4) eval(solE.c3) eval(solE.c2) eval(solE.c1) eval(solE.c0)];
%    positionE = polyval(p_coeffE, (timeE-4));
end

% Pol evaluation (boarder limitations) F
timeF = 8:0.1:10;
q0=30; q1=40; v0=3; v1=0; acc0=0; acc1=0; t0=8; t1=10;  
p_coeffF = [eval(solF.d5) eval(solF.d4) eval(solF.d3) eval(solF.d2) eval(solF.d1) eval(solF.d0)];
fF = p_coeffF(6) + p_coeffF(5) * (t-8) + p_coeffF(4) * (t-8)^2 + p_coeffF(3) * (t-8)^3 + p_coeffF(2) * (t-8)^4 + p_coeffF(1) * (t-8)^5;
dk = double([subs(fE,8)-subs(fE,7.9)]/(8-7.9));
dk1= double([subs(fF,8.1)-subs(fE,8)]/(8.1-8));
if sign(dk) == sign (dk1) 
   vk2 = double(1/2 * (dk+dk1));
   q0=0; q1=30; v0=vk1; v1=vk2; acc0=0; acc1=0; t0=4; t1=8;
   p_coeffE = [eval(solE.c5) eval(solE.c4) eval(solE.c3) eval(solE.c2) eval(solE.c1) eval(solE.c0)];
   positionE = polyval(p_coeffE, (timeE-4));
   q0=30; q1=40; v0=vk2; v1=0; acc0=0; acc1=0; t0=8; t1=10;
   p_coeffF = [eval(solF.d5) eval(solF.d4) eval(solF.d3) eval(solF.d2) eval(solF.d1) eval(solF.d0)];
   positionF = polyval(p_coeffF, (timeF-8));
else
   vk2=0;
   q0=0; q1=30; v0=vk1; v1=vk2; acc0=0; acc1=0; t0=4; t1=8;
   p_coeffE = [eval(solE.c5) eval(solE.c4) eval(solE.c3) eval(solE.c2) eval(solE.c1) eval(solE.c0)];
   positionE = polyval(p_coeffE, (timeE-4));
   q0=30; q1=40; v0=vk2; v1=0; acc0=0; acc1=0; t0=8; t1=10;
   p_coeffF = [eval(solF.d5) eval(solF.d4) eval(solF.d3) eval(solF.d2) eval(solF.d1) eval(solF.d0)];
   positionF = polyval(p_coeffF, (timeF-8));
end


% Position
figure('Name','Position','NumberTitle','off')
hold on
grid
time = [timeB timeD timeE timeF];
position = [positionB positionD positionE positionF];
plot(time, position)
legend('PositionB','Location','southwest')
hold off

% Velocity
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
legend('VelocityB','Location','southwest')
hold off

% Accelleration
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