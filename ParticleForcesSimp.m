function [Fx,Fy,Fz,Ground,TouchNearGround,CentreNearGround,P1P2] = ParticleForcesSimp(X,Y,Z,r,Eeqpw,Eeqpp,Reqpp,CentreNearGrounded)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%% Initialisation
Knpw = zeros(length(r),1);
Fnpw = Knpw;
Kznpw = Knpw;
Fznpw = Knpw;
ZeroVec = Knpw;

%% Convert Cartesian Coordinates to Cylindrical
[th,R,Z] = cart2pol(X,Y,Z);

% Instability Check
if sum(R>1) > 1
    1
end

%% Particle---Wall Calculations
%Establish Which Particles hit the wall
deltaN = -(27.9e-3 - R - r);
deltaN(deltaN<0) = 0;
deltaNFind = find(deltaN ~= 0);

%Check if particles hit the wall. Pause the 1 for debugging
if length(deltaNFind) > 1
    1
end

%Calculate Normal Forces
Knpw = (4/3) .* Eeqpw .* (r).^0.5;
Fnpw = Knpw .* (deltaN).^(3/2);

%Calcuulate Extra wall force (To Tncrease Computational efficiency)
Fwall = 1e-4*40.^(90.*(((R-0.0270)./0.028)));

%Collect Wall forces
Fx = cos(pi()-th) .* (Fnpw + Fwall);
Fy = -sin(pi()-th) .* (Fnpw + Fwall);








%% Particle---Base

%Identify Grounded Particles
deltaZN = (-122.5e-3 - Z - r);
deltaZN(deltaZN<0) = 0;
deltaZNFind = find(deltaZN ~= 0);

GroundedZ = (122e-3 + Z);
Ground = deltaZNFind;
NearGround = find(GroundedZ<10e-3);

%Calculate Normal Forces
Kznpw(deltaZNFind) = (4/3) .* Eeqpw .* (r(deltaZNFind)).^0.5;
Fznpw(deltaZNFind) = Kznpw(deltaZNFind) .* (deltaZN(deltaZNFind)).^(3/2);

%Calculate Extra base force (To Tncrease Computational efficiency)
FBottomWall = 1e-5*40.^(150.*(((-Z-0.124)./0.124)));

%Collect Base Forces
Fz = Fznpw + FBottomWall;

%Check if Particles exit domain. Pause 1 for for debugging
if sum(Z<-0.123) > 0
    1;
end


%% Particle-Particle
%Initialise Coordinates
Xi = X;
Yi = Y;
Zi = Z;

%Remove Values for Particles swirling (Improve computational Efficiency
ParticleNames = [1:length(Xi)];
ParticleNames(NearGround) = [];

Xi(ParticleNames) = NaN;
Yi(ParticleNames) = NaN;
Zi(ParticleNames) = NaN;


%Calculate Particle---Particle distances
ParticleParticleDis =  pdist2([Xi,Yi,Zi],[Xi,Yi,Zi]);
radius1 = meshgrid(r);
radius2 = radius1';
ParticleContact = ParticleParticleDis < (radius1 + radius2);
DeltaParticle =  ((radius1 + radius2) - ParticleParticleDis) .* (1-eye(length(r)));

%Calculate Particle---Particle Normal Forces
Knpp = (4/3) .* Eeqpp .* (Reqpp).^0.5;
Fnpp = Knpp .* (DeltaParticle.*ParticleContact) .^(3/2);

%Log Which Particles Contact
[P1,P2] = find(Fnpp > 0);
P1P2 = [P1,P2];

%Remove need for calculations when particles are on the ground 
P1Common = intersect(P1,CentreNearGrounded);
P1 = setxor(CentreNearGrounded,P1Common);

P2Common = intersect(P2,CentreNearGrounded);
P2 = setxor(CentreNearGrounded,P2Common);


%Pause 1 for debugging
if ~isempty(P1)
    1;
end

%Calculate Force Direction and Magnitude for each particle
FnppDir = [X(P1) , Y(P1) , Z(P1)] - [X(P2) , Y(P2) , Z(P2)];
FnppMag = sum(Fnpp(P1,P2))';
FnppDirNorm = vecnorm(FnppDir')';
Fpp = zeros(length(r),3);

%Particle Particle Force Vector
Fpp(P1,:) = FnppMag .* FnppDir./ FnppDirNorm;

%Update particle force Vector
Fx = Fx;% + Fpp(:,1);
Fy = Fy;% + Fpp(:,2);
Fz = Fz;% + Fpp(:,3);

%% Extract Particle data for efficiency purposes
Touch = find(sum(ParticleContact)-1)';
NearCentre = find(R< 1e-3);

[CentreNearGround] = intersect(NearCentre,NearGround);

[TouchNearGround] = intersect(Touch,NearGround);

end