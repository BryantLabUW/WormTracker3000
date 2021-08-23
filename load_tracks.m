function [] = load_tracks()
%load_tracks Load X/Y tracking data
%   Function that imports manual worm coordinates generated in FIJI and
%   collated in a series of .xslx tabs. Tab names must match info.wormUIDs.
%   Flexibly handles thermotaxis, odor tracking, and CO2 tracking assays.

global info
global dat

%% Import tracks for thermotaxis assays
if contains(info.assaytype, 'OdorThermo_22') || contains(info.assaytype, 'Odor_22') ...
        || contains(info.assaytype, 'Iso_22') || contains(info.assaytype, 'Thermo_22')
    
    % Generate list of all possible tab names, given cameras and info.wormUIDs
    if info.analyze_CL>0
        if ~any(contains(info.sheets, 'CR')) && ~any(contains(info.sheets, 'CL'))
            datatabs.CL = strcat(info.wormUIDs);
        else
            datatabs.CL = strcat(info.wormUIDs,'_CL');%intersect(strcat(info.wormUIDs,'_CL'),info.sheets); % Only try to import data tabs if they exist.
        end
    end
    if info.analyze_CR>0
        if ~any(contains(info.sheets,'CR')) && ~any(contains(info.sheets,'CL'))
            datatabs.CR = strcat(info.wormUIDs);
        else
            datatabs.CR = strcat(info.wormUIDs,'_CR'); %intersect(strcat(info.wormUIDs,'_CR'),info.sheets); % Only try to import data tabs if they exist.
        end
    end
    
    % Import tracks from the Index Sheet or generate NaN-filled variables
    % Notably, the pull_coords function does check to make sure a tab exists
    % before it tries to import data. If the tab doesn't exist, it will
    % generate a NaN column.
    if info.analyze_CL>0
        [dat.Xvals.Pixels_CL, dat.Yvals.Pixels_CL, dat.frame.CL]=pull_coords(datatabs.CL, info.tracklength, info.numworms);
    else
        [dat.Xvals.Pixels_CL, dat.Yvals.Pixels_CL, dat.frame.CL]= deal(NaN (info.tracklength, info.numworms));
    end
    
    if info.analyze_CR>0
        [dat.Xvals.Pixels_CR, dat.Yvals.Pixels_CR, dat.frame.CR]=pull_coords(datatabs.CR, info.tracklength, info.numworms);
    else
        [dat.Xvals.Pixels_CR, dat.Yvals.Pixels_CR, dat.frame.CR]= deal(NaN (info.tracklength, info.numworms));
    end
    disp('...done');
    
    % Quality check the data to make sure that there are no cases where a
    % single worm has only NaN values on both cameras. If this is true, then
    % something went wrong with the track import.
    if any(arrayfun(@(x) all(isnan(dat.Xvals.Pixels_CR(:,x))) & all(isnan(dat.Xvals.Pixels_CL(:,x))),1:info.numworms))
        errormsg = wormUIDs(arrayfun(@(x) all(isnan(dat.Xvals.Pixels_CR(:,x))) & all(isnan(dat.Xvals.Pixels_CL(:,x))),1:info.numworms));
        error(['Tracks associated with the following UIDs failed to load.' newline 'Please check correct labeling of excel tabs:' newline strjoin(errormsg,'\n')]);
    end
end

%% Import tracks for chemotaxis assays
if contains(info.assaytype, 'Bact_4.9') || contains(info.assaytype, 'C02_3.75') ...
        || contains(info.assaytype, 'Pher_5') || contains(info.assaytype, 'Odor_5')
    % Import tracks from the Index Sheet or generate NaN-filled variables
    % Notably, the pull_coords function does check to make sure a tab exists
    % before it tries to import data. If the tab doesn't exist, it will
    % generate a NaN column.
    [dat.Xvals.Pixels, dat.Yvals.Pixels, dat.frame]=pull_coords(info.wormUIDs, info.tracklength, info.numworms);
    disp('...done.');
    
end

%% Import tracks for custom linear assays
if contains(info.assaytype, 'Custom_linear') || contains(info.assaytype, 'Basic_info')
    [dat.Xvals.Pixels, dat.Yvals.Pixels, dat.frame]=pull_coords(info.wormUIDs, info.tracklength, info.numworms);
    disp('...done.');
    
end



end

