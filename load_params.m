function [] = load_params
%%load_params: Load parameters for assays

global info

%% Import experimental information for thermotaxis assays

if contains(info.assaytype, 'OdorThermo_22') || contains(info.assaytype, 'Odor_22') ...
        || contains(info.assaytype, 'Iso_22') || contains(info.assaytype, 'Thermo_22')
    disp('Reading data from file....');
    [~, info.sheets] = xlsfinfo(info.calledfile); % Detect names of tabs in excel spreadsheet
    
    alphabet = ['A':'Z'];
    
    [~, headers, ~] = xlsread(info.calledfile, 'Index');
    
    % Number of worm tracks to analyze
    [I, J] = find(contains(headers, 'Number of Worms'));
    if ~isempty(I) && ~isempty(J)
        info.numworms = importfileXLS(info.calledfile, 'Index', strcat(alphabet(J), num2str(I+1)));
    end
    
    % Length of track (number of frames)
    [I, J] = find(contains(headers, 'Number of Images'));
    if ~isempty(I) && ~isempty(J)
        info.tracklength = importfileXLS(info.calledfile, 'Index', strcat(alphabet(J), num2str(I+1)));
    end
    
    if info.numworms == 0 || isempty(info.numworms) || isempty(info.tracklength)
        error('User Error. The Index tab in your .xlsx file contains missing/incorrect values in column A.');
    end
    
    % Unique IDs for worms
    [I, J] = find(contains(headers, {'UID', 'ID'}));
    if ~isempty(I) && ~isempty(J)
        [~, info.wormUIDs] = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
    end
    
    % Camera sizing parameter (pixels per cm)
    refstr = {'pixels per cm', 'ppcm', 'pixelspercm'};
    [I, J] = find(contains(headers, refstr));
    info.pixelspercm(:,1) = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    
    if ~isequal(numel(info.wormUIDs),numel(info.pixelspercm(:,1)))
        error('User Error. There are missing values in required columns.');
    end
    
    % Gradient reference, generally the starting location of worms in the
    % gradient (e.g. T(start))
    refstr = {'T(start)', 'T(ref)', 'T(odor)', 'Gradient(start)', 'Gradient(ref)'};
    [I, J] = find(contains(headers, refstr));
    if ~isempty(I) && ~isempty(J)
        info.gradient.ref = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
    end
    
     % Gradient min value
    refstr = {'Gradient low', 'gradient low', 'Low','min', 'Min'};
    [I, J] = find(contains(headers, refstr));
    if ~isempty(I) && ~isempty(J)
        info.gradient.min = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
    end
    
     % Gradient max value
    refstr = {'Gradient High', 'gradient high', 'High', 'max', 'Max'};
    [I, J] = find(contains(headers, refstr));
    if ~isempty(I) && ~isempty(J)
        info.gradient.max = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
    end
    
    % Gradient steepness
    refstr = {'cmperdeg', 'Gradient slope', 'gradient slope'};
    [I, J] = find(contains(headers, refstr));
    if ~isempty(I) && ~isempty(J)
        info.gradient.rate = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
    end
end
%% Import assay-specific parameters for thermotaxis assays
%   Assigns a landmark camera, which is either the Camera on which an odor
%   is placed, or the Tstart camera, for non-odor experiments.
%
%   Contains hardwired alignment values for the two cameras found in the
%   Hallem Lab Thermotaxis Rig (the Collection Epoch name/value pairs). The
%   specific values used depend on how the cameras were aligned, which can
%   change over time. When it does change, users should add a new case.

if contains(info.assaytype, 'OdorThermo_22') || contains(info.assaytype, 'Odor_22') ...
        || contains(info.assaytype, 'Iso_22') || contains(info.assaytype, 'Thermo_22')
    
    
    % If the assay type selected is Multisensory or Isothermal + Odor
    if contains(info.assaytype, 'OdorThermo_22') || contains(info.assaytype, 'Odor_22')
        
        % Import Landmark Coodinates/Camera
        info.ref.x = xlsread(info.calledfile, 'Index', strcat('I2:I', num2str(1+info.numworms)))';
        info.ref.y = xlsread(info.calledfile, 'Index', strcat('J2:J', num2str(1+info.numworms)))';
        
        
        % Quality Checks of Landmark Coordinates
        if ~isequal(numel(info.ref.x),numel(info.ref.y),numel(info.wormUIDs))
            error('User Error. The Index tab in your .xlsx file contains missing values in columns H-I.');
        end
        
        
        % Odor Scoring Region
        [~, info.SR.shape] = xlsread(info.calledfile, 'Index', 'A14');
        
        if info.SR.shape{1} == 'C' % scoring region shape is a circle
            info.SR.w = 2; % width, in cm
            info.SR.h = 2; % height, in cm
        elseif info.SR.shape{1} == 'S' %scoring region shape is square-ish aka a rectangle (staying away from using 'R' as anything but 'Right')
            info.SR.w = 2; % width, in cm
            info.SR.h = 3; % height, in cm
        else
            error('User Error. The Odor Arena shape value does not match expected values. It should be S (square-ish) or C (circle)');
        end
    end
    
    % If the assay type is a Pure isothermal (4) or Pure thermotaxis (1)
    if contains(info.assaytype, 'Iso_22') || contains(info.assaytype, 'Thermo_22')
        
        % Import Landmark Coodinates/Camera
        [info.ref.x,info.ref.y] = deal(NaN(1,info.numworms)); %Will populate this later.
        
    end
end

%% Import experimental information for chemotaxis assays
if contains(info.assaytype, 'Bact_4.9') || contains(info.assaytype, 'C02_3.75') ...
        || contains(info.assaytype, 'Pher_5') || contains(info.assaytype, 'Odor_5')
    disp('Reading data from file....');
    [~, info.sheets] = xlsfinfo(info.calledfile); % Detect names of tabs in excel spreadsheet
    
    alphabet = ['A':'Z'];
    
    [~, headers, ~] = xlsread(info.calledfile, 'Index');
    
    % Number of worm tracks to analyze
    [I, J] = find(contains(headers, 'Number of Worms'));
    if ~isempty(I) && ~isempty(J)
        info.numworms = importfileXLS(info.calledfile, 'Index', strcat(alphabet(J), num2str(I+1)));
    end
    
    % Length of track (number of frames)
    [I, J] = find(contains(headers, 'Number of Images'));
    if ~isempty(I) && ~isempty(J)
        info.tracklength = importfileXLS(info.calledfile, 'Index', strcat(alphabet(J), num2str(I+1)));
    end
    
    if info.numworms == 0 || isempty(info.numworms) || isempty(info.tracklength)
        error('User Error. The Index tab in your .xlsx file contains missing/incorrect values in column A.');
    end
    
    % Unique IDs for worms
    [I, J] = find(contains(headers, {'UID', 'ID'}));
    if ~isempty(I) && ~isempty(J)
        [~, info.wormUIDs] = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
    end
    
    % Orientation for non-thermotaxis assays
    [I, J] = find(contains(headers, {'Orientation', 'orientation'}));
    if ~isempty(I) && ~isempty(J)
        [~, info.plateorient] = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
        
        if isempty(info.plateorient)
            [info.plateorient] = xlsread(info.calledfile, 'Index', strcat(...
                alphabet(J), num2str(I+1),...
                ':',alphabet(J), num2str(info.numworms+1)));
        end
    end
    
    % Alignment ROIs for rotation - usually the gas ports or odor regions
    [I, J] = find(contains(headers, 'XL'));
    info.ref.Lx = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    [I, J] = find(contains(headers, 'YL'));
    info.ref.Ly = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    [I, J] = find(contains(headers, 'XR'));
    info.ref.Rx = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    [I, J] = find(contains(headers, 'YR'));
    info.ref.Ry = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    
    % Camera sizing parameter (pixels per cm)
    refstr = {'pixels per cm', 'ppcm', 'pixelspercm'};
    [I, J] = find(contains(headers, refstr));
    info.pixelspercm(:,1) = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    
    if any(info.pixelspercm<10)
        error('The Index sheet appears to have at least one pixels per cm column value that is are smaller than expected. Please make sure that column H contains the correct information. Then restart the tracker code.');
    end
    
    if size(info.pixelspercm,1)<info.numworms % If the number of imported pixels per cm values doesn't match the expected number of worms, pad with NaN, they're probably slopes
        info.pixelspercm((size(info.pixelspercm,1)+1):info.numworms,1)=NaN;
    end
    
end

%% Import assay-specific parameters for chemotaxis assays
if contains(info.assaytype, 'Bact_4.9') || contains(info.assaytype, 'C02_3.75') ...
        || contains(info.assaytype, 'Pher_5') || contains(info.assaytype, 'Odor_5')
    
    if contains(info.assaytype, 'Bact_4.9')
        info.radius = 4.9/2; % radius of bacterial chemotaxis assay circle
        info.scoringradius = 2/2; % radius of scoring circles
        info.inter_port_interval = (info.radius*2)-(info.scoringradius*2); % calculate distance between centers of two ports
        info.inter_port_interval = repmat(info.inter_port_interval, info.numworms,1);
        disp('Bacterial Chemotaxis Assay Parameters Loaded');
    end
    
    if contains(info.assaytype, 'C02_3.75')
        info.radius = 3.75/2; % radius of CO2 assay circle
        info.portradius = 0.3175/2; % inner radius of CO2/Air ports
        info.inter_port_interval = 4.75; % NB measured this distance for ASB on 9/24/19
        info.inter_port_interval = repmat(info.inter_port_interval, info.numworms,1);
        disp('CO2 Assay Parameters Loaded');
        
    end
    
    if contains(info.assaytype, 'Pher_5')
        info.radius = 5/2; % radius of pheromone chemotaxis assay circle; provided to ASB on 12/2/19
        info.scoringradius = 2/2; % radius of scoring circles
        info.inter_port_interval = (info.radius*2)-(info.scoringradius*2); % calculate distance between centers of two ports
        info.inter_port_interval = repmat(info.inter_port_interval, info.numworms,1);
        disp('Pheromone Assay Parameters Loaded');
    end
    
    if contains(info.assaytype, 'Odor_5')
        info.radius = 5/2; % radius of odor chemotaxis assay circle
        info.scoringradius = 1/2; % radius of scoring circles
        info.inter_port_interval = repmat(2, info.numworms,1); % MLC gave ASB this distance on 12/4/19
        disp('Odor Assay Parameters Loaded');
    end
    
end

%% Import experimental information for custom linear assays
if contains(info.assaytype, 'Custom_linear')
    disp('Reading data from file....');
    [~, info.sheets] = xlsfinfo(info.calledfile); % Detect names of tabs in excel spreadsheet
    
    alphabet = ['A':'Z'];
    
    [~, headers, ~] = xlsread(info.calledfile, 'Index');
    
    % Number of worm tracks to analyze
    [I, J] = find(contains(headers, 'Number of Worms'));
    if ~isempty(I) && ~isempty(J)
        info.numworms = importfileXLS(info.calledfile, 'Index', strcat(alphabet(J), num2str(I+1)));
    end
    
    % Length of track (number of frames)
    [I, J] = find(contains(headers, 'Number of Images'));
    if ~isempty(I) && ~isempty(J)
        info.tracklength = importfileXLS(info.calledfile, 'Index', strcat(alphabet(J), num2str(I+1)));
    end
    
    if info.numworms == 0 || isempty(info.numworms) || isempty(info.tracklength)
        error('User Error. The Index tab in your .xlsx file contains missing/incorrect values in column A.');
    end
    
    % Unique IDs for worms
    [I, J] = find(contains(headers, {'UID', 'ID'}));
    if ~isempty(I) && ~isempty(J)
        [~, info.wormUIDs] = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
    end
    
    % Orientation for non-thermotaxis assays
    [I, J] = find(contains(headers, {'Orientation', 'orientation'}));
    if ~isempty(I) && ~isempty(J)
        [~, info.plateorient] = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
        
        if isempty(info.plateorient)
            [info.plateorient] = xlsread(info.calledfile, 'Index', strcat(...
                alphabet(J), num2str(I+1),...
                ':',alphabet(J), num2str(info.numworms+1)));
        end
    end
    
    % Alignment ROIs for rotation - usually the gas ports or odor regions
    [I, J] = find(contains(headers, 'XL'));
    info.ref.Lx = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    [I, J] = find(contains(headers, 'YL'));
    info.ref.Ly = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    [I, J] = find(contains(headers, 'XR'));
    info.ref.Rx = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    [I, J] = find(contains(headers, 'YR'));
    info.ref.Ry = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    
    % Distance between alignment ROIs
    refstr = {'alignment distance', 'Alignment distance', 'inter-port interval', 'Inter-alignment distance'};
    [I, J] = find(contains(headers, refstr));
    if ~isempty(I) && ~isempty(J)
    info.inter_port_interval = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    end
             
    % Camera sizing parameter (pixels per cm)
    refstr = {'pixels per cm', 'ppcm', 'pixelspercm'};
    [I, J] = find(contains(headers, refstr));
    info.pixelspercm = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    
    if any(info.pixelspercm<10)
        error('The Index sheet appears to have at least one pixels per cm column value that is are smaller than expected. Please make sure that column H contains the correct information. Then restart the tracker code.');
    end
    
    if size(info.pixelspercm,1)<info.numworms % If the number of imported pixels per cm values doesn't match the expected number of worms, pad with NaN, they're probably slopes
        info.pixelspercm((size(info.pixelspercm,1)+1):info.numworms,1)=NaN;
    end
   
     % Gradient min value
    refstr = {'Gradient low', 'gradient low', 'Low','min', 'Min'};
    [I, J] = find(contains(headers, refstr));
    if ~isempty(I) && ~isempty(J)
        info.gradient.min = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
    end
    
     % Gradient max value
    refstr = {'Gradient High', 'gradient high', 'High', 'max', 'Max'};
    [I, J] = find(contains(headers, refstr));
    if ~isempty(I) && ~isempty(J)
        info.gradient.max = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
    end
    
    % Gradient steepness
    refstr = {'cmperdeg', 'Gradient slope', 'gradient slope'};
    [I, J] = find(contains(headers, refstr));
    if ~isempty(I) && ~isempty(J)
        info.gradient.rate = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
    end

    
end


%% Import experimental information for basic information about worm tracks, ignoring gradients
if contains(info.assaytype, 'Basic_info') || contains(info.assaytype, 'GasShift')
    disp('Reading data from file....');
    [~, info.sheets] = xlsfinfo(info.calledfile); % Detect names of tabs in excel spreadsheet
    
    alphabet = ['A':'Z'];
    
    [~, headers, ~] = xlsread(info.calledfile, 'Index');
    
    % Number of worm tracks to analyze
    [I, J] = find(contains(headers, 'Number of Worms'));
    if ~isempty(I) && ~isempty(J)
        info.numworms = importfileXLS(info.calledfile, 'Index', strcat(alphabet(J), num2str(I+1)));
    end
    
    % Length of track (number of frames)
    [I, J] = find(contains(headers, 'Number of Images'));
    if ~isempty(I) && ~isempty(J)
        info.tracklength = importfileXLS(info.calledfile, 'Index', strcat(alphabet(J), num2str(I+1)));
    end
    
    if info.numworms == 0 || isempty(info.numworms) || isempty(info.tracklength)
        error('User Error. The Index tab in your .xlsx file contains missing/incorrect values in column A.');
    end
    
    % Unique IDs for worms
    [I, J] = find(contains(headers, {'UID', 'ID'}));
    if ~isempty(I) && ~isempty(J)
        [~, info.wormUIDs] = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
    end
    
    % Alignment ROIs for rotation - usually the gas ports or odor regions
    [I, J] = find(contains(headers, 'XL'));
    info.ref.Lx = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    [I, J] = find(contains(headers, 'YL'));
    info.ref.Ly = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    [I, J] = find(contains(headers, 'XR'));
    info.ref.Rx = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    [I, J] = find(contains(headers, 'YR'));
    info.ref.Ry = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    
    % Distance between alignment ROIs
    refstr = {'alignment distance', 'Alignment distance', 'inter-port interval', 'Inter-alignment distance'};
    [I, J] = find(contains(headers, refstr));
    if ~isempty(I) && ~isempty(J)
    info.inter_port_interval = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    end
             
    % Camera sizing parameter (pixels per cm)
    refstr = {'pixels per cm', 'ppcm', 'pixelspercm'};
    [I, J] = find(contains(headers, refstr));
    info.pixelspercm = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1),...
        ':',alphabet(J), num2str(info.numworms+1)));
    
    if any(info.pixelspercm<10)
        error('The Index sheet appears to have at least one pixels per cm column value that is are smaller than expected. Please make sure that column H contains the correct information. Then restart the tracker code.');
    end
    
    if size(info.pixelspercm,1)<info.numworms % If the number of imported pixels per cm values doesn't match the expected number of worms, pad with NaN, they're probably slopes
        info.pixelspercm((size(info.pixelspercm,1)+1):info.numworms,1)=NaN;
    end
      
end

%% Import timing information when assays involve sequential presentation of stimuli
if contains(info.assaytype, 'GasShift')
    
    % Timing of stimulus presentation
    refstr = {'Stimulus Timing'};
    [I, J] = find(contains(headers, refstr));
    if ~isempty(I) && ~isempty(J)
    [~,~,info.stim_timing] = xlsread(info.calledfile, 'Index', strcat(...
        alphabet(J), num2str(I+1)));
    
    info.stim_timing = str2double(split(info.stim_timing, {',',';'}));
    end
    
end

end