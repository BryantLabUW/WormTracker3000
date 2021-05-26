function [] = path_statistics ()
%%path_statistics (tracks.xvalscm, tracks.yvalscm, tracks)
%   This function calculates pathlength, max displacement, distance ratio,
%   and displacement relative to user provided reference ROIs

global tracks
global vals

%% Calculate path and max displacement for generating a distance ratio, in combination with the maximum distance moved.
% I currently don't need the travelpath and pathlength data, but it might
% come in handy later. Since these values are already relative, I'm using
% the ones that aren't adjusted relative to the input ports.
[vals.maxdisplacement vals.pathlength vals.meanspeed vals.instantspeed]= displace([tracks.xvalscm(1,:);tracks.yvalscm(1,:)], tracks.xvalscm, tracks.yvalscm);
vals.distanceratio=vals.pathlength./vals.maxdisplacement; %Calculation of distance ratio, as defined in Castelletto et al 2014. Total distance traveled/maximum displacement.

%% Calculating final resting place of each worm relative to the left and right alignment locations.

%Calculating final displacement relative to left alignment mark
displacement.L =sqrt((tracks.Lx-0).^2 + (tracks.Ly-0).^2);
B= ~isnan(displacement.L);
Indices = arrayfun(@(x) find(B(:,x),1,'last'), 1:size(displacement.L,2));
vals.finaldisp.L = arrayfun(@(x,y) displacement.L(x,y), Indices, 1:size(displacement.L,2));

%Calculating final displacement relative to right alignment mark
displacement.R =sqrt((tracks.Rx).^2 + (tracks.Ry).^2);
B= ~isnan(displacement.R);
Indices = arrayfun(@(x) find(B(:,x),1,'last'), 1:size(displacement.R,2));
vals.finaldisp.R = arrayfun(@(x,y) displacement.R(x,y), Indices, 1:size(displacement.R,2));
end