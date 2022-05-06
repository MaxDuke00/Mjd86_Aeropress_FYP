%Script to plot the trajactory of particles

%Extract X,Y & Z positions of each particle
x =  qlog(:,1:6:end);
y =  qlog(:,3:6:end);
z =  qlog(:,5:6:end);

figure(7)

plot3(x,y,z)            %Plot Trajectories

hold on
viscircles([0,0],0.028,'Color','k')%Plot domain circle

axis equal
xlim([-60e-3/2 56e-3/2])
ylim([-60e-3/2 56e-3/2])
zlim([-130e-3 0])
axis on
                
hold off



% figure(9)
% P3d1 = plot3(x(:,1),y(:,1),z(:,1),'Marker','*')
% 
% hold on
% P3d2 = plot3(x(:,2),y(:,2),z(:,2),'Marker','square')
% viscircles([0,0],0.028,'Color','k')%Plot domain circle
% 
% P3d1.MarkerIndices = floor(linspace(1,length(t),20))
% P3d2.MarkerIndices = floor(linspace(1,length(t),20))
% 
% P3d1.Color = '#D95319' %Orange
% P3d2.Color = '#77AC30' %Green
% 
% axis equal
% xlim([-60e-3/2 56e-3/2])
% ylim([-60e-3/2 56e-3/2])
% zlim([-130e-3 0])
% axis on
%                 
% hold off