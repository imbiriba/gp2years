
dth=10;
dr=.25;
[nn rr tt] = histcounts2(wdir, wspd, [0:dth:(360+dth)],[0:dr:(5+dr)]);

% dir   geo  xy
% N   = 0  = 90
% E   = 90 = 0 
%           xy = 90-geo 
X = ((1+[0:dr:5])'*cosd(90-[0:dth:360]))';
Y = ((1+[0:dr:5])'*sind(90-[0:dth:360]))';

rev = @(x) x(end:-1:1,:);
%figure
%pcolor(X,Y,nn);shading flat
%set(gca,'DataAspectRatio',[1 1 1]);
%nmax = max(nn(:));
%colormap([1 1 1; rev(parula(nmax))]);
%hold on

ntot = sum(nn(:));
nmax = max(nn(:));
fmax = max(2.5,100*(floor(40*(nmax./ntot))/40));
figure;
pcolor(X,Y,nn./ntot*100);shading flat
set(gca,'DataAspectRatio',[1 1 1]);
caxis([-.09.*fmax fmax]);
caxis([-.09.*10 10]);
ccmap = gray(12); ccmap=ccmap(1:11,:);
colormap([1 1 1; rev(ccmap)]); %parula(31))]);
colorbar
hold on

R=(1+[0:dr:5]);
sR=[1 2 3 4 5];
for ii=1:numel(sR)
  ir=find(R==sR(ii));
  plot(X(:,ir),Y(:,ir),'k')
  text(X(5,ir)+.1,Y(5,ir)+.1,num2str(R(ir)-1));
end

text(5.*cosd(90) ,5.*sind(90),'N');
text(5.*cosd(00) ,5.*sind(00),'E');
text(5.*cosd(-90),5.*sind(-90),'S');
text(5.*cosd(180),5.*sind(180),'W');
for th=[0:45:135]
  r=[-5 -1 NaN 1 5];
  plot(r.*cosd(th),r.*sind(th),'k')
end
%T=[0:dth:360];
%sT=[0 90 180 270];
%ir=find(R==5);
%for ii=1:numel(sT)
%  it=find(T==sT(ii));
%  plot(X(it,1:ir),Y(it,1:ir),'k')
%  text(X(it,ir),Y(it,ir),[num2str(T(it)) '°']);
%end
set(gca,'Visible','off');
set(gca,'FontSize',12);

text(0,6,tit,'FontSize',12,'HorizontalAlignment','center');

saveas(gcf, sfn,'png');

