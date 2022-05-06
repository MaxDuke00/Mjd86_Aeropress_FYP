function [Fcx , Fcy] = CentrifugalBuoyancy(q,RhoF,RhoP,Fv,r,t)
%   CentrifugalBuoyancy Summary of this function goes here
%   Detailed explanation goes here


X = q(1:6:end);
Y = q(3:6:end);
Z = q(5:6:end);

[th,R,Z] = cart2pol(X,Y,Z);

%Centrifugal Pressure
V = (4/3) * pi .* (r).^3;
Fc = V * RhoF .* (Fv(R,Z)*((100-t)/100)).^2 ./ R;

Fcx = -cos(th) .* Fc;
Fcy = -sin(th) .* Fc;


end