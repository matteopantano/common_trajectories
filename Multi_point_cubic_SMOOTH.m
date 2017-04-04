% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab


% Poly for more points, I want to define a poly able to pass for some
% points, as exercise pg 25, as long I want also the velocity I am trying
% to obtain it with merge of cubic poly to obtain a smoother velocity I
% also compute velocity sign 

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
syms t;
fB = p_coeffB(4) + p_coeffB(3) * (t-2) + p_coeffB(2) * (t-2)^2 + p_coeffB(1) * (t-2)^3;
% vB = v_coeffB(3) + p_coeffB(2) * (t-0) + p_coeffB(1) * (t-0)^2;
% subs(fB, 2)

% pol evaluation (boarder limitations) D
timeD = 2:0.1:4;
q0=20; q1=0; t0=2; t1=4; v0=-10; v1=10;
p_coeffD = [eval(solD.b3) eval(solD.b2) eval(solD.b1) eval(solD.b0)];
fD = p_coeffD(4) + p_coeffD(3) * (t-2) + p_coeffD(2) * (t-2)^2 + p_coeffD(1) * (t-2)^3;
dk = [subs(fB,2)-subs(fB,1.9)]/(2-1.9);  %check values of dk and vk with calculator
dk1= [subs(fD,2.1)-subs(fD,2)]/(2.1-2);
if sign(dk) == sign (dk1) 
   vk = double(1/2 * (dk+dk1));
   q0=10; q1=20; t0=0; t1=2; v0=0; v1=vk;
   p_coeffB = [eval(solB.a3) eval(solB.a2) eval(solB.a1) eval(solB.a0)];
   positionB = polyval(p_coeffB, (timeB-0));
   v_coeffB = polyder(p_coeffB);
   velocityB = polyval(polyder(p_coeffB), (timeB-0));
%    q0=20; q1=0; t0=2; t1=4; v0=vk; v1=10;
%    p_coeffD = [eval(solD.b3) eval(solD.b2) eval(solD.b1) eval(solD.b0)];
%    positionD = polyval(p_coeffD, (timeD-2));
%    velocityD = polyval(polyder(p_coeffD), (timeD-2));
else
   vk=0;
   q0=10; q1=20; t0=0; t1=2; v0=0; v1=vk;
   p_coeffB = [eval(solB.a3) eval(solB.a2) eval(solB.a1) eval(solB.a0)];
   positionB = polyval(p_coeffB, (timeB-0));
   v_coeffB = polyder(p_coeffB);
   velocityB = polyval(polyder(p_coeffB), (timeB-0));
%    q0=20; q1=0; t0=2; t1=4; v0=vk; v1=10;
%    p_coeffD = [eval(solD.b3) eval(solD.b2) eval(solD.b1) eval(solD.b0)];
%    positionD = polyval(p_coeffD, (timeD-2));
%    velocityD = polyval(polyder(p_coeffD), (timeD-2));
end

% pol evaluation (boarder limitations) E
timeE = 4:0.1:8;
q0=0; q1=30; t0=4; t1=8; v0=10; v1=3;
p_coeffE = [eval(solE.c3) eval(solE.c2) eval(solE.c1) eval(solE.c0)];
fE = p_coeffE(4) + p_coeffE(3) * (t-4) + p_coeffE(2) * (t-4)^2 + p_coeffE(1) * (t-4)^3;
dk = [subs(fD,4)-subs(fD,3.9)]/(4-4.9);  %check values of dk and vk with calculator
dk1= [subs(fE,4.1)-subs(fD,4)]/(4.1-4);
if sign(dk) == sign (dk1) 
   vk1 = double(1/2 * (dk+dk1));
   q0=20; q1=0; t0=2; t1=4; v0=vk; v1=vk1;
   p_coeffD = [eval(solD.b3) eval(solD.b2) eval(solD.b1) eval(solD.b0)];
   positionD = polyval(p_coeffD, (timeD-2));
   v_coeffD = polyder(p_coeffD);
   velocityD = polyval(polyder(p_coeffD), (timeD-2));
   q0=0; q1=30; t0=4; t1=8; v0=vk1; v1=3;
   p_coeffE = [eval(solE.c3) eval(solE.c2) eval(solE.c1) eval(solE.c0)];
   positionE = polyval(p_coeffE, (timeE-4));
   velocityE = polyval(polyder(p_coeffE), (timeE-4));
else
   vk1=0;
   q0=20; q1=0; t0=2; t1=4; v0=vk; v1=vk1;
   p_coeffD = [eval(solD.b3) eval(solD.b2) eval(solD.b1) eval(solD.b0)];
   positionD = polyval(p_coeffD, (timeD-2));
   velocityD = polyval(polyder(p_coeffD), (timeD-2));
   q0=0; q1=30; t0=4; t1=8; v0=vk1; v1=3;
   p_coeffE = [eval(solE.c3) eval(solE.c2) eval(solE.c1) eval(solE.c0)];
   positionE = polyval(p_coeffE, (timeE-4));
   velocityE = polyval(polyder(p_coeffE), (timeE-4));
end

% pol evaluation (boarder limitations) F
timeF = 8:0.1:10;
q0=30; q1=40; t0=8; t1=10; v0=3; v1=0;
p_coeffF = [eval(solF.d3) eval(solF.d2) eval(solF.d1) eval(solF.d0)];
fF = p_coeffF(4) + p_coeffF(3) * (t-8) + p_coeffF(2) * (t-8)^2 + p_coeffF(1) * (t-8)^3;
dk = double([subs(fE,8)-subs(fE,7.9)]/(8-7.9));  %check values of dk and vk with calculator
dk1= double([subs(fF,8.1)-subs(fF,8)]/(8.1-8));
if sign(dk) == sign (dk1) 
   vk2 = double(1/2 * (dk+dk1));
   q0=0; q1=30; t0=4; t1=8; v0=vk1; v1=vk2;
   p_coeffE = [eval(solE.c3) eval(solE.c2) eval(solE.c1) eval(solE.c0)];
   positionE = polyval(p_coeffE, (timeE-4));
   velocityE = polyval(polyder(p_coeffE), (timeE-4));
   q0=30; q1=40; t0=8; t1=10; v0=vk2; v1=0;
   p_coeffF = [eval(solF.d3) eval(solF.d2) eval(solF.d1) eval(solF.d0)];
   positionF = polyval(p_coeffF, (timeF-8));
   velocityF = polyval(polyder(p_coeffF), (timeF-8));
else
   vk2=0;
   q0=0; q1=30; t0=4; t1=8; v0=vk1; v1=vk2;
   p_coeffE = [eval(solE.c3) eval(solE.c2) eval(solE.c1) eval(solE.c0)];
   positionE = polyval(p_coeffE, (timeE-4));
   velocityE = polyval(polyder(p_coeffE), (timeE-4));
   q0=30; q1=40; t0=8; t1=10; v0=vk2; v1=0;
   p_coeffF = [eval(solF.d3) eval(solF.d2) eval(solF.d1) eval(solF.d0)];
   positionF = polyval(p_coeffF, (timeF-8));
   velocityF = polyval(polyder(p_coeffF), (timeF-8));
end

% % position
% figure('Name','Position','NumberTitle','off')
% hold on
% grid
% time = [timeB timeD timeE timeF];
% position = [positionB positionD positionE positionF];
% plot(time, position)
% legend('Position','Location','southwest')
% hold off
%  
% % velocity
% figure('Name','Velocity','NumberTitle','off')
% hold on
% grid
% time = [timeB timeD timeE timeF];
% velocity = [velocityB velocityD velocityE velocityF];
% plot(time, velocity)
% legend('Velocity','Location','southwest')
% hold off
 
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