% Matteo Pantano 
% Generation of Trajectories - Internship @ L.I.A.M Lab


% Gravitational trajectory (w/ constant accelleration)

syms a0 a1 a2 a3 a4 a5 t1 tf t0 q0 v0 qf vf q1;
A = [1 0 0;0 1 0;1 (tf-t0) (tf-t0)^2];
B = [a0; a1; a2];
C = [q0; v0; qf];
solB = solve(A*B==C, B);
D = [1 0 0;0 1 0;1 (t1-tf) (t1-tf)^2];
E = [a3; a4; a5];
F = [qf; vf; q1];
solE = solve(D*E==F, E);

% pol evaluation
t0=0; t1=8; q0=0; v0=0; q1=10; v1=0;
h = q1-q0;
tf=(t0+t1)/2;
T = t1-t0;
qf=(q0+q1)/2; 
vf=v0+4/T^2*(h/2-v0*T)*T;  
timeB = 0:0.1:tf;
p_coeffB = [eval(solB.a2) eval(solB.a1) eval(solB.a0)];
timeD = tf:0.1:t1;
p_coeffD = [eval(solE.a5) eval(solE.a4) eval(solE.a3)]

% position
positionB = polyval(p_coeffB, (timeB-t0));
positionD = polyval(p_coeffD, (timeD-tf)); %%%l'errore era qua
figure('Name','Position','NumberTitle','off');
hold on
grid
time = [timeB timeD];
position = [positionB positionD];
plot(time, position)
legend('Position','Location','southwest')
hold off

% velocity
v_coeffB = polyder(p_coeffB);
v_coeffD = polyder(p_coeffD);
velocityB = polyval(v_coeffB, (timeB-t0));
velocityD = polyval(v_coeffD, (timeD-tf)); %%%l'errore era qua
figure('Name','Velocity','NumberTitle','off')
hold on
grid
velocity = [velocityB velocityD];
plot(time, velocity)
legend('Velocity','Location','southwest')
hold off

% acceleration
a_coeffB = polyder(v_coeffB);
a_coeffD = polyder(v_coeffD);
accelerationB = polyval(a_coeffB, (timeB-t0));
accelerationD = polyval(a_coeffD, (timeD-t0));
figure('Name','Accelleration','NumberTitle','off')
hold on
grid
acceleration = [accelerationB accelerationD];
plot(time, acceleration)
legend('AccellerationB','Location','southwest')
hold off