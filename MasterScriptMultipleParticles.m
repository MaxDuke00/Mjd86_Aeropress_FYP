tic
%%Define Simulation Parameters      
Omega = 18;             %Rotational Velocity
Diameter = 56e-3;
Height = 123e-3;

%% Coffee Properties
ParticleMean = 2.5e-4;
ParticleSd = 5e-5;
ParticleNumber = 1000


R = normrnd(ParticleMean,ParticleSd,[ParticleNumber,1]);
Reqpp = 1./(1./meshgrid(R) + 1./(meshgrid(R)'));

%% Ensure No Particles Overlap at t=0

dmin = 0;
%Initial Conditions
zsection = linspace(-120e-3,0,100);

while dmin < ParticleMean*4
    thrand = rand(1,ParticleNumber)*2*pi;
    rrand = rand(1,ParticleNumber)*26e-3+ 1e-3;
    zrand = -rand(1,ParticleNumber)*0.1;

    [Cartx, Carty] = pol2cart(thrand',rrand');

    for zslice = 1 : (length(zsection) - 1)
        zedslice = [zsection(zslice) zsection(zslice + 1)];
        withinZslice = find(zrand > zedslice(1) & zrand < zedslice(2));
        A = [Cartx(withinZslice)' ; Carty(withinZslice)']';

        d = pdist2(A,A) ;
        % Get minimum distance
        d(d==0) = NaN;
        dminnew = min(min(d));
        if dminnew > dmin
            dmin = dminnew
        end
    end
end

%% Format Initial Conditions
x0 = sin(thrand) .* rrand;
x0dot = Omega * rrand .*cos(thrand) ;
y0 = cos(thrand) .* rrand;
y0dot = -Omega * rrand .*sin(thrand);
z0 = zrand;
z0dot = ones(1,ParticleNumber) * 0;

ICsMat = [x0 ; x0dot ; y0 ; y0dot ; z0 ; z0dot];
ICs = ICsMat(:);


%% Load Flow Data
filename = '18';%Attempt
[LocVel,Fu,Fv,Fw] = AnsysPostData(filename);

%% Input Material Properties for Coffee Ground(1) & Aeropress(2)
E1 = 1.82e7;            %Youngs Modulus
E2 = 1.4e9;             %Youngs Modulus
v1 = 0.3;               %Poisson Ratio
v2 = 0.3;               %Poisson Ratio

%% Calculate Effective Youngs Modulus for Contact Mechanics
Eeqpw = 1/((1-v1^2)/E1 + (1-v2^2)/E2);
Eeqpp = 1/((1-v1^2)/E1 + (1-v1^2)/E1);


%% Set ODE Parameters
P.RhoP = 0.980e3;           %Particle Density
P.RhoF = 0.970e3;           %Fluid Density
P.R = R;
P.Reqpp = Reqpp;
P.g = 9.81;                 %Gravity
P.mu = 3.537e-04;           %Fluid Viscosity
P.Omega = Omega;
P.ParticleNumber = ParticleNumber;
P.LocVel = LocVel;
P.Fu = Fu;
P.Fv = Fv;
P.Fw = Fw;
P.Eeqpw = Eeqpw;
P.Eeqpp = Eeqpp;

%% Clear Global Variables
clear global Grounded
clear global Walled
clear global TouchNearGrounded
clear global CentreNearGrounded
clear global CenterTouchNearGrounded



%% Setup ODE
tspan = 0:0.01:60;
tend = tspan(end);


opts = odeset('Mass',@(t,q) massMultiple(t,q,P),'Stats','on');

[t,qout] = ode23(@(t,q) fsimp(t,q,P),tspan,ICs,opts);

%ParticlePlotMultiple



%% Loop ODE solver to calculate multiple Particles      
qlog = [qout];
global CentreNearGrounded
%     for sim = 1:1
% 
%     Particles2Add = ParticleNumber - (width(qlog)/6 - length(CentreNearGrounded))
% 
%     ICqs = [qout(end,:)' ;ICs(1:Particles2Add*6)]
% 
% 
% 
%     P.R = [P.R;R(1:Particles2Add)]
%     Reqpp = 1./(1./meshgrid([P.R]) + 1./(meshgrid([P.R])'));
% 
%     Reqpp(CentreNearGrounded,CentreNearGrounded) = NaN;
% 
%     P.Reqpp = Reqpp;
%     P.ParticleNumber = P.ParticleNumber + Particles2Add;
% 
%     tspan = tspan + tend
% 
% 
%     opts = odeset('Mass',@(t,q) massMultiple(t,q,P),'Stats','on');
% 
%     [t,qout] = ode23(@(t,q) fsimp ...
%         (t,q,P),tspan,ICqs,opts);
% 
%     qlog = [qlog  zeros(height(qlog),Particles2Add*6)];
%     qlog = [qlog ; qout];
% 
% end




%save('AeropressResults','q','R')
toc
