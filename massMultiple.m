function M = massMultiple(t,q,P)

%% Extract Parameters
RhoP = P.RhoP;
%RhoF = P.RhoF;
R = P.R;
g = P.g;
ParticleNumber = P.ParticleNumber;

%% Mass matrix diaganol Vector
v1 = ones(1,ParticleNumber);
v2 = [4.*pi().*RhoP.*R.^3]';
v3 = v1;
v4 = v2;
v5 = v1;
v6 = v2;

%% Format mass matrix diaganol vector
vmat = [v1;v2;v3;v4;v5;v6];
v = vmat(:);

%% Build Mass Matrix
M = diag(v);
end