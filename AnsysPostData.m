function [LocVel,Fu,Fv,Fw] = AnsysPostData(filename)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
location = 'C:\Users\maxdu\OneDrive\Documents\University\Year 4\Final Year Project\Final Year Report\AeropressAnsys_files\user_files\';

filenameLocation = append(location,filename);

CSVFile = readtable(filenameLocation);


z = CSVFile.X_M_ - max(CSVFile.X_M_);
x = CSVFile.Y_M_;
y = CSVFile.Z_M_ * 0;
w = CSVFile.VelocityU_MS__1_;
u = CSVFile.VelocityV_MS__1_;
v = CSVFile.VelocityW_MS__1_;

LocVel = table(x,y,z,u,v,w);
save('LocalVelocity.mat' , 'LocVel');
% figure(22)
% quiver3(x,y,z,u,v,w,10)
% axis equal

Fu = scatteredInterpolant(x,z,u);%
Fv = scatteredInterpolant(x,z,v);%
Fw = scatteredInterpolant(x,z,w);%,'linear','none'
save('VelocityInterp.mat','Fu','Fv','Fw')




end