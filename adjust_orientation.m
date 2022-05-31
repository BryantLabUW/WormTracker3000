function [] = adjust_orientation (plate_orientation)
%% adjust_orientation adjusts x/y coordinates of tracked worms (in cm)
%  based on the direction of the gradient (to left vs to right)

global info
global tracks
global vals

plate_orientation(plate_orientation>0)=-1; %Value = 1, gradient R -> L, flip orientation
plate_orientation(plate_orientation>-1)=1; %Value = 0, gradient L -> R
plate_orientation=plate_orientation';
plate_orientation=repmat(plate_orientation, info.tracklength,1);

xvalsStd=zeros(size(tracks.Lx)); %preallocating arrays to save time
yvalsStd=zeros(size(tracks.Ly)); %preallocating arrays to save time

% Default orientation is from low->high on the L -> R axis. If not this,
% then flip the tracks
for i=1:size(plate_orientation,2) 
    if plate_orientation(1,i)<0 %Flip the tracks
        xvalsStd(:,i) = tracks.Rx(:,i);
        yvalsStd(:,i) = tracks.Ry(:,i);
        HighGradient_Std.x (:,i) = abs(info.refcm.Lx(i,:)); % then the left alignment spot is nearest to the highest gradient position
        HighGradient_Std.y (:,i)= abs(info.refcm.Ly(i,:));
        vals.EndLoc.Low (:,i)= vals.finaldisp.R(:,i); % final displacements in cm relative to the highest(L) and lowest(R) part of the gradient
        vals.EndLoc.High (:,i)= vals.finaldisp.L(:,i);

    else % Don't flip the tracks
        xvalsStd (:,i)= tracks.Lx(:,i);
        yvalsStd (:,i)= tracks.Ly(:,i);
        HighGradient_Std.x (:,i)= abs(info.refcm.Rx(i,:)); % then the right alignment spot is nearest to the highest gradient position
        HighGradient_Std.y (:,i)= abs(info.refcm.Ry(i,:));
        vals.EndLoc.Low (:,i)= vals.finaldisp.L(:,i); % final displacements in cm relative to the highest(R) and lowest(L) part of the gradient
        vals.EndLoc.High (:,i)= vals.finaldisp.R(:,i);


        
           end 
end

% Save to global variables
tracks.plotxvals = xvalsStd;
tracks.plotyvals = yvalsStd*-1;
vals.HighStdLoc.x = HighGradient_Std.x;
vals.HighStdLoc.y = HighGradient_Std.y*-1;


end