function [U,V,W] = VelProfile(X,Y,Z,Fu,Fv,Fw,t)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

[th,R,Z] = cart2pol(X,Y,Z);



Ux = Fu(R,Z)*(100-t)/100;
Vy = Fv(R,Z)*(100-t)/100;%    
Wz = Fw(R,Z)*(100-t)/100  - 4.1e-3;% ;%   

U = Ux.*cos(th) + Vy.*sin(th);
V = Ux.*sin(th) - Vy.*cos(th);
W = Wz;



end