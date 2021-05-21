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

for i=1:numworms
    [~, sheets]=xlsfinfo(info.calledfile);
    sheet = [wormUIDs{i}];
    if ~isempty(find(strcmp(sheets,sheet),1))
        testexists = importfileXLS(info.calledfile, sheet, strcat('D1:D',num2str(tracklength)));
        if ~isempty(testexists)
            tempx(:,1) = importfileXLS(info.calledfile, sheet, strcat('D1:D',num2str(tracklength)));
            tempy(:,1) = importfileXLS(info.calledfile, sheet, strcat('E1:E',num2str(tracklength)));
            tempf(:,1) = importfileXLS(info.calledfile, sheet, strcat('C1:C',num2str(tracklength)));
            xvals(1:length(tempx),i)=tempx;
            yvals(1:length(tempy),i)=tempy;
            frame(1:length(tempf),i)=tempf;
        end
        clear tempx tempy tempf
    end
    
end
end