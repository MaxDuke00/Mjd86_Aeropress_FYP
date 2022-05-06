function dydt = fsimp(t,q,P)
%% Print Time
t %#ok<NOPRT> 

%% Extract parameters
RhoP = P.RhoP;
RhoF = P.RhoF;
mu = P.mu;
R = P.R;
g = P.g;
Omega = P.Omega;
Fu = P.Fu;
Fv = P.Fv;
Fw = P.Fw;
Reqpp = P.Reqpp;
Eeqpw = P.Eeqpw;
Eeqpp = P.Eeqpp;

%% Load in Global Variables
global Grounded
global Walled
global TouchNearGrounded
global CentreNearGrounded

%% Ensure solutions are real
if isnan(sum(q)) == 1
    1
end


%% Extract flow vevtors at particle locations
[U,V,W] = VelProfile(q(1:6:end),q(3:6:end),q(5:6:end),Fu,Fv,Fw,t);

%%Calculate Extra Particle Forces
[Frx,Fry,Frz,Ground,TouchNearGround,CentreNearGround,P1P2] = ParticleForcesSimp(q(1:6:end),q(3:6:end),q(5:6:end),R,Eeqpw,Eeqpp,Reqpp,CentreNearGrounded);


%% Experimental Stuff to reduce computational requirements
% Establish when particles hit the base and lock vertical position
if ~ismember(Ground,Grounded)
    Grounded = [Grounded ; Ground];
end
q(6*(Grounded-1) + 6) = 0;


%Lock Particle Position when particle is at the bottom centre of the domain
if ~ismember(CentreNearGround,CentreNearGrounded)
    CentreNearGrounded = [CentreNearGrounded ; CentreNearGround];
end

if ~isempty(intersect(CentreNearGrounded,P1P2))
    P1Centre = intersect(CentreNearGrounded,P1P2);
    P2Centre = [];
    for i = 1:length(P1Centre)
        P2Centre = [P2Centre ; P1P2(find(P1Centre(i) == P1P2(:,1)),2)];
    end

    CentreNearGrounded = [CentreNearGrounded ; P1Centre ; P2Centre];
    CentreNearGrounded = unique(CentreNearGrounded);
end

q(6*(CentreNearGrounded-1) + 2) = 0;
q(6*(CentreNearGrounded-1) + 4) = 0;
q(6*(CentreNearGrounded-1) + 6) = 0;



%% Calculate Centrifugal 
if Omega == 0
Fcx = 0;
Fcy = 0;
else
[Fcx , Fcy] = CentrifugalBuoyancy(q,RhoF,RhoP,Fv,R,t);
end


%% Combine Forces On Particles
Fx = Frx + Fcx;
Fy = Fry + Fcy;
Fz = Frz;

%% Calculate f-vector Elements
dydt1 = q(2:6:end);
dydt2 = -18*mu*pi*R.*(q(2:6:end)-U) + 3.*Fx;
dydt3 = q(4:6:end);
dydt4 = -18*mu*pi.*R.*(q(4:6:end)-V) + 3.*Fy;
dydt5 = q(6:6:end);
dydt6 = 4*pi*R.^3*g.*(RhoF - RhoP) -18.*mu.*pi.*R.*(q(6:6:end)-W) + 3.*Fz;


%% Construct f-Vector
dydtmat = [dydt1,dydt2,dydt3,dydt4,dydt5,dydt6]';
dydt = dydtmat(:);


end