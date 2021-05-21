function [] = orient_to_odorant (CTorient)
%% orient_to_odorant adjusts x/y coordinates of tracked worms (in cm) in relation to the location of a given odorant

global info
global tracks
global vals


CTorient(CTorient>0)=-1; %Value = 1, experimental port = L
CTorient(CTorient>-1)=1; %Value = 0, experimental port = R
CTorient=CTorient';
CTorient=repmat(CTorient, info.tracklength,1);

xvalsStd=zeros(size(tracks.Lx)); %preallocating arrays to save time
yvalsStd=zeros(size(tracks.Ly)); %preallocating arrays to save time

%Collating tracks oriented to the experimental port, also collating control
%port location.
for i=1:size(CTorient,2);
    if CTorient(1,i)<0 % if experimental port = L
        xvalsStd (:,i)= tracks.Lx(:,i);
        yvalsStd (:,i)= tracks.Ly(:,i);
        CportStd.x (:,i)= abs(info.refcm.Rx(i,:)); % then the control port is the Right port
        CportStd.y (:,i)= abs(info.refcm.Ry(i,:));
        vals.EndLoc.Eport (:,i)= vals.finaldisp.L(:,i); % final displacements in cm relative to the experimental and control ports
        vals.EndLoc.Cport (:,i)= vals.finaldisp.R(:,i);
     
    else % if the experimental port is Right
        xvalsStd(:,i) = tracks.Rx(:,i);
        yvalsStd(:,i) = tracks.Ry(:,i);
        CportStd.x(:,i) = abs(info.refcm.Lx(i,:)); % then the control port is the left port
        CportStd.y (:,i)= abs(info.refcm.Ly(i,:));
        vals.EndLoc.Eport (:,i)= vals.finaldisp.R(:,i); % final displacements in cm relative to the experimental and control ports
        vals.EndLoc.Cport (:,i)= vals.finaldisp.L(:,i);
    end
end



%% Orient tracks depending on the location of the odorant
% This some of this code is based on older code, from when there was no port
% information.

tracks.plotxvals = xvalsStd; % This used to involve multiplying with the CTorient, but it doesn't any longer b/c the calculation of distance from the port already does this.
tracks.plotyvals = yvalsStd*-1;
vals.CportStdLoc.x = CportStd.x;
vals.CportStdLoc.y = CportStd.y*-1;


end