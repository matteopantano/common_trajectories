% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab


% Linear trajectory (w/ constant velocity)
 
syms t1 t0 q0 q1 a0 a1;
A = [1 0; 1 (t1-t0)];
B = [a0; a1];
C = [q0; q1];
solB = solve(A*B==C, B);
 
time = 0:0.1:8;
 
% pol evaluation (boarder limitations)
q0=0; q1=10; t0=0; t1=8;
p_coeffB = [eval(solB.a1) eval(solB.a0)];
 
 
% position
positionB = polyval(p_coeffB, time);
figure('Name','Position','NumberTitle','off');
hold on
grid
plot(time, positionB)
legend('PositionB','Location','southwest')
hold off
 
% velocity
v_coeffB = polyder(p_coeffB);
velocityB = polyval(v_coeffB, time);
figure('Name','Velocity','NumberTitle','off')
hold on
grid
plot(time, velocityB)
legend('VelocityB','Location','southwest')
hold off
 
% accelleration
a_coeffB = polyder(v_coeffB);
accellerationB = polyval(a_coeffB, time);
figure('Name','Accelleration','NumberTitle','off')
hold on
grid
plot(time, accellerationB)
legend('AccellerationB','Location','southwest')
hold off
