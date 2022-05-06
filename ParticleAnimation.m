%Save Options



x =  qlog(:,1:6:end);
y =  qlog(:,3:6:end);
z =  qlog(:,5:6:end);


%Press Domain
rad = linspace(0,2*pi,20);
xcirc = 0.028*sin(rad);
ycirc = 0.028*cos(rad);
circtop = ones(1,length(rad))*0;
circbot = ones(1,length(rad))*-123e-3;

%Format Data
%R = P.R(1:width(x))

fpsin   = 1/(t(2) - t(1));
fpsout  = 30;

MovieVec = []
clear MovieVec

%MovieVec = struct;


f = figure(12)
%f.Position(3:4) = [1200 1600]/1.5;
tj = 1
for ti = 1 : floor(fpsin/fpsout) : length(x)
    plot3(xcirc,ycirc,circtop)
    axis equal
    hold on
    plot3(xcirc,ycirc,circbot)
    scatter3(x(ti,:)',y(ti,:)',z(ti,:)',(R)*10^5,'MarkerEdgeColor','k','MarkerFaceColor',[0 .75 .75])
    hold off
%view(90,0)
    MovieVec(tj) = getframe(gcf)
    tj = tj+1;

end

toSave = input('Would You Like to Save? (yes=1, no=0)      ')

if toSave == 1

    name = input('Enter a Name For This Data        (write in quotes)')

    mkdir(['MatlabSimulation-',num2str(name)])
    save([num2str(name),'Files'],'qlog','R','t')

    myWriter = VideoWriter(num2str(name),'MPEG-4');
    myWriter.FrameRate = fpsout

    open(myWriter);
    writeVideo(myWriter,MovieVec);
    close(myWriter)

end