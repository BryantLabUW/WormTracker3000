function [aPort] = align_to_ROIs(xvals, yvals, Ports, pixelpercmarray)
%%align_to_ROIs aligns tracks relative to two user-provided references
% Commonly used in single-camera chemosensory assays to scale and align
% tracks relative to gas ports or odorant point sources.
% Converts pixels to cm


global dat
global tracks

% Generate worm track values relative to Port L location (Port L at 0,0).
% CTorient input would be 1
tempx=repmat(Ports.Lx_cm',size(xvals,1),1);
tempy=repmat(Ports.Ly_cm',size(yvals,1),1);

tracks.Lxunrot=(xvals./pixelpercmarray)-tempx;
tracks.Lyunrot=(yvals./pixelpercmarray)-tempy;

aPort.Rxunrot=(Ports.Rx_cm-tempx(1,:)'); %Generating Port R location relative to Port L
aPort.Ryunrot=(Ports.Ry_cm-tempy(1,:)'); 

[tracks.Lx, tracks.Ly, aPort.Rx, aPort.Ry]=rotationmatrix(tracks.Lxunrot, tracks.Lyunrot, aPort.Rxunrot, aPort.Ryunrot);

% Generate worm track values relative to Port R location (Port R at 0,0)
% CTorient input would be 0
tempxx=repmat(Ports.Rx_cm',size(xvals,1),1);
tempyy=repmat(Ports.Ry_cm',size(yvals,1),1);

tracks.Rxunrot=(-xvals./pixelpercmarray)+tempxx;
tracks.Ryunrot=(yvals./pixelpercmarray)-tempyy;

aPort.Lxunrot=(-Ports.Lx_cm + tempxx(1,:)'); %Generating Port L location relative to Port R
aPort.Lyunrot=(Ports.Ly_cm-tempyy(1,:)');

[tracks.Rx, tracks.Ry, aPort.Lx, aPort.Ly]=rotationmatrix(tracks.Rxunrot, tracks.Ryunrot, aPort.Lxunrot, aPort.Lyunrot);

tracks.xvalscm=xvals./pixelpercmarray;
tracks.yvalscm=yvals./pixelpercmarray;


end