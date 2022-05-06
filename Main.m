%%Define Simulation Parameters
Omega = 18;
Diameter = 56e-3;
Height = 123e-3;

%%Fluid Properties @ 95degC
mu = 2.9640e-04;
rhow = 961.62;

%%Saturated Coffee Properties
ParticleMean = 2.5e-3;
ParticleSd = 5e-5;

Dose = 10e-3;%kg
ParticleMeanMass = (4/3) *pi * ParticleMean^3 * 0.99e3;
ParticleNumber = floor(Dose/ParticleMeanMass);

ParticleNumber = 5;


R = normrnd(ParticleMean,ParticleSd,[ParticleNumber,1]);

% Rmin = 0.5*   300e-6;
% Rmax = 0.5*   900e-6;
%R = rand(ParticleNumber,1)*(Rmax-Rmin)+Rmin;
Reqpp = 1./(1./meshgrid(R) + 1./(meshgrid(R)'));

ParticleMass = sum(0.99e3*(4/3)*pi.*R.^3);

%% Ensure No Particles Overlap at t=0

dmin = 0;
%Initial Conditions
zsection = linspace(-120e-3,0,100);

while dmin < ParticleMean*4
    thrand = rand(1,ParticleNumber)*2*pi;
    rrand = rand(1,ParticleNumber)*26e-3+ 0
    1e-3;
    zrand = -rand(1,ParticleNumber)*0.05;

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
x0dot = Omega * rrand .*cos(thrand);
y0 = cos(thrand) .* rrand;
y0dot = -Omega * rrand .*sin(thrand);
z0 = zrand;
z0dot = ones(1,ParticleNumber)*0;

ICsMat = [x0 ; x0dot ; y0 ; y0dot ; z0 ; z0dot];
ICs = ICsMat(:);


%% Load Flow Data
filename = '18.csv';%Attempt
[LocVel,Fu,Fv,Fw] = AnsysPostData(filename);

%% Input Material Properties for Coffee Ground(1) & Aeropress(2)
E1 = 1.82e7;
E2 = 1.4e9;
v1 = 0.3;
v2 = 0.3;

%% Calculate Effective Youngs Modulus for Contact Mechanics
Eeqpw = 1/((1-v1^2)/E1 + (1-v2^2)/E2);
Eeqpp = 1/((1-v1^2)/E1 + (1-v1^2)/E1);


%% Set ODE Parameters
P.RhoP = 0.980e3;%1054;% 
P.RhoF = 0.970e3;
P.R = R;
P.Reqpp = Reqpp;
P.g = 9.81;
P.mu = 3.537e-04;
P.Omega = Omega;
P.ParticleNumber = ParticleNumber;
P.LocVel = LocVel;
P.Fu = Fu;
P.Fv = Fv;
P.Fw = Fw;
P.Eeqpw = Eeqpw;
P.Eeqpp = Eeqpp;

%% Setup ODE
tspan = 0:0.01:10;
tend = tspan(end);


opts = odeset('Mass',@(t,q) massMultiple(t,q,P),'Stats','on');

[t,qout] = ode23(@(t,q) ftest(t,q,P),tspan,ICs,opts);

%ParticlePlotMultiple



%% Loop ODE solver to calculate multiple Particles      
qlog = [qout];
    for sim = 1:1

    Particles2Add = ParticleNumber - (width(qlog)/6 - length(CentreNearGrounded));

    ICqs = [qout(end,:)' ;ICs(1:Particles2Add*6)];



    P.R = [P.R;R(1:Particles2Add)];
    Reqpp = 1./(1./meshgrid([P.R]) + 1./(meshgrid([P.R])'));

    Reqpp(CentreNearGrounded,CentreNearGrounded) = NaN;

    P.Reqpp = Reqpp;
    P.ParticleNumber = P.ParticleNumber + Particles2Add;

    tspan = tspan + tend;


    opts = odeset('Mass',@(t,q) massMultiple(t,q,P),'Stats','on');

    [t,qout] = ode23(@(t,q) fsimp ...
        (t,q,P),tspan,ICqs,opts);

    qlog = [qlog  zeros(height(qlog),Particles2Add*6)];
    qlog = [qlog ; qout];

end




%save('AeropressResults','q','R')

