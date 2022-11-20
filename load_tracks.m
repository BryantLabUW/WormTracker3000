function [] = load_tracks()
%load_tracks Load X/Y tracking data
%   Function that imports manual worm coordinates generated in FIJI and
%   collated in a series of .xslx tabs. Tab names must match info.wormUIDs.

global info
global dat

%% Import tracks
% Updated for single camera configuration

[dat.Xvals.Pixels, dat.Yvals.Pixels, dat.frame]=pull_coords(info.wormUIDs, info.tracklength, info.numworms);
disp('...done.');

end

function [xvals, yvals, frame] = pull_coords(wormUIDs, tracklength, numworms)
%%pull_coords imports the x and y coordinates of individual worm tracking data from an excel spreadsheet.

%   Required Inputs:
%       wormUIDs = names of the tabs containing the tracking data for import
%       tracklength = expected number of images, usually 300 for a 10 min
%           tracking session and 450 for a 15 min session.
%       numworms = number of tracks (i.e. individual worm data) to import
%   Outputs:
%       xvals = x-coordinates of the worm location, in pixels
%       yvals = y-coordinates of the worm location, in pixels
%       frame = frame numbers of the x/y coordinates

global info

[xvals,yvals,frame] = deal(NaN(tracklength,numworms));
[~, sheets]=xlsfinfo(info.calledfile);

for i=1:numworms
    disp(['loading file ', num2str(i), ' of ', num2str(numworms)]);
    sheet = [wormUIDs{i}];
    if ~isempty(find(strcmp(sheets,sheet),1))
        temp(:,:) = xlsread(info.calledfile, sheet, strcat('C1:E',num2str(tracklength)));
        if ~isempty(temp)
            xvals(1:length(temp),i)=temp(:,2);
            yvals(1:length(temp),i)=temp(:,3);
            frame(1:length(temp),i)=temp(:,1);
        end
        clear temp
    end
    
end
end