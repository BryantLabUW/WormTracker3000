function [] = load_params
%%load_params: Load parameters for thermotaxis and chemotaxis assays
%   This file contains 4 code chunks:
%   1) Import experimental information from Index tab for thermotaxis
%       assays
%
%   2) Import assay specific parameters for themotaxis assays
%       Assigns a landmark camera, which is either the Camera on which an odor
%       is placed, or the Tstart camera, for non-odor experiments.
%
%       Contains hardwired alignment values for the two cameras found in the
%       Hallem Lab Thermotaxis Rig (the Collection Epoch name/value pairs). The
%       specific values used depend on how the cameras were aligned, which can
%       change over time. When it does change, users should add a new case.
%
%   3) Import experimental information from Index tab for chemotaxis
%       assays
%
%   4) Import assay specific parameters for chemotaxis assays.
%       Can be used to set various parameters associated with chemotaxis tracking assays.

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
    
    % Starting Camera (dual camera mode)
    [I, J] = find(contains(headers, 'Tstart Camera'));
    if ~isempty(I) && ~isempty(J)
        [~, info.TstartCam] = xlsread(info.calledfile, 'Index', strcat(alphabet(J), num2str(I+1)));
        
        % Determine whether there are dual camera data
        info.analyze_CL = 0;
        info.analyze_CR = 0;
        
        % The utility of this code will depend on how the user set up their excel
        % spreadsheet. If they included a named tab for every worm on ever
        % camera, irrespective of whether there is data or not, this code won't
        % actually matter. But if they didn't, this will catch that condition.
        if info.TstartCam{1} == 'L'
            info.analyze_CL = 1;
            if any(cellfun(@(x) ~isempty(x),strfind(info.sheets,'CR'))) % Do the names of any of the tabs contain the string 'CR'?
                info.analyze_CR = 1;
            end
        else
            info.analyze_CR = 1;
            if any(cellfun(@(x) ~isempty(x),strfind(info.sheets,'CL'))) % Do the names of any of the tabs contain the string 'CL'?
                info.analyze_CL = 1;
            end
        end
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
    if ~isempty(I) && ~isempty(J)
        if size(I,1) > 1
            [II, JJ] = find(contains(headers, 'CL pixels per cm'));
            info.pixelspercm(:,1) = xlsread(info.calledfile, 'Index', strcat(...
                alphabet(JJ), num2str(II+1),...
                ':',alphabet(JJ), num2str(info.numworms+1)));
            
            [II, JJ] = find(contains(headers, 'CR pixels per cm'));
            info.pixelspercm(:,2) = xlsread(info.calledfile, 'Index', strcat(...
                alphabet(JJ), num2str(II+1),...
                ':',alphabet(JJ), num2str(info.numworms+1)));
            
            if ~isequal(numel(info.pixelspercm(:,1)),numel(info.pixelspercm(:,2)))
                error('User Error. There are missing values in required pixels-per-cm columns');
            end
        else
            info.pixelspercm(:,1) = xlsread(info.calledfile, 'Index', strcat(...
                alphabet(J), num2str(I+1),...
                ':',alphabet(J), num2str(info.numworms+1)));
            
        end
    end
    
    if ~isequal(numel(info.wormUIDs),numel(info.pixelspercm(:,1)))
        error('User Error. There are missing values in required columns.');
    end
    
    % Gradient reference, generally the starting location of worms in the
    % gradient (e.g. T(start))
    refstr = {'T(start)', 'T(ref)', 'T(odor)', 'Gradient(start)', 'Gradient(ref)'};
    [I, J] = find(contains(headers, refstr));
    if ~isempty(I) && ~isempty(J)
        info.gradientref = xlsread(info.calledfile, 'Index', strcat(...
            alphabet(J), num2str(I+1),...
            ':',alphabet(J), num2str(info.numworms+1)));
    end
    
    % Gradient steepness
    refstr = {'cmperdeg', 'Gradient slope', 'gradient slope'};
    [I, J] = find(contains(headers, refstr));
    if ~isempty(I) && ~isempty(J)
        info.gradientrate = xlsread(info.calledfile, 'Index', strcat(...
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
    
    global SR; % Contains information about Odor Scoring Region
    global CL_ac; % Alignment coordinates for Left Camera
    global CR_ac; % Alignment coordinates for Right Camera
    global Landmark;
    
    % If the assay type selected is Multisensory or Isothermal + Odor
    if contains(info.assaytype, 'OdorThermo_22') || contains(info.assaytype, 'Odor_22')
        
        % Import Landmark Coodinates/Camera
        Landmark.X = xlsread(info.calledfile, 'Index', strcat('I2:I', num2str(1+info.numworms)))';
        Landmark.Y = xlsread(info.calledfile, 'Index', strcat('J2:J', num2str(1+info.numworms)))';
        [~, Landmark.Cam] = xlsread(info.calledfile, 'Index', 'A11');
        
        % Quality Checks of Landmark Coordinates
        if ~isequal(numel(Landmark.X),numel(Landmark.Y),numel(info.wormUIDs))
            error('User Error. The Index tab in your .xlsx file contains missing values in columns H-I.');
        end
        if isempty(Landmark.Cam)
            error('User Error. The Odor Camera value is missing from the Index tab in your .xlsx file.');
        end
        
        % Odor Scoring Region
        [~, SR.shape] = xlsread(info.calledfile, 'Index', 'A14');
        
        if SR.shape{1} == 'C' % scoring region shape is a circle
            SR.w = 2; % width, in cm
            SR.h = 2; % height, in cm
        elseif SR.shape{1} == 'S' %scoring region shape is square-ish aka a rectangle (staying away from using 'R' as anything but 'Right')
            SR.w = 2; % width, in cm
            SR.h = 3; % height, in cm
        else
            error('User Error. The Odor Arena shape value does not match expected values. It should be S (square-ish) or C (circle)');
        end
    end
    
    % If the assay type is a Pure isothermal (4) or Pure thermotaxis (1)
    if contains(info.assaytype, 'Iso_22') || contains(info.assaytype, 'Thermo_22')
        
        % Import Landmark Coodinates/Camera
        [Landmark.X,Landmark.Y] = deal(NaN(1,info.numworms)); %Will populate this later.
        Landmark.Cam = info.TstartCam; % Landmark Camera is the same as the T(start) Camera.
    end
    
    % Import camera alignment parameters, aka Collection Epoch Parameters
    
    % Make array of L and R camera alignment coordinates, depending on the
    % inputed identity of the track.
    [~,~,ExptEpoch] = xlsread(info.calledfile, 'Index', strcat('H2:H', num2str(1+info.numworms)));
    for i = 1:info.numworms
        if isnumeric(ExptEpoch{i})
            ExptEpoch{i} = num2str(ExptEpoch{i});
        end
    end
    
    for i = 1:info.numworms
        switch ExptEpoch{i}
            case 'late 2019'
                CL_ac(i,:,1) = [11.162, 2.444]; % X1, Y1;
                CL_ac(i,:,2) = [11.18, 4.807]; % X2, Y2
                
                CR_ac(i,:,1) = [0.045, 2.389]; % X1, Y1;
                CR_ac(i,:,2) = [0.006, 4.755]; % X2, Y2
            case '2020'
                CL_ac(i,:,1) = [12.020, 2.257]; % X1, Y1;
                CL_ac(i,:,2) = [12.109, 8.267]; % X2, Y2
                
                CR_ac(i,:,1) = [1.430, 1.808]; % X1, Y1;
                CR_ac(i,:,2) = [1.346, 7.790]; % X2, Y2
            case '2020_t'
                CL_ac(i,:,1) = [12.523, 2.260]; % X1, Y1;
                CL_ac(i,:,2) = [12.560, 8.275]; % X2, Y2
                
                CR_ac(i,:,1) = [1.428, 1.811]; % X1, Y1;
                CR_ac(i,:,2) = [1.348, 7.797]; % X2, Y2
                
            case '2018'
                CL_ac(i,:,1) = [14.45, 4.01]; % X1, Y1;
                CL_ac(i,:,2) = [14.42, 5.72]; % X2, Y2
                
                CR_ac(i,:,1) = [0.05, 2.74]; % X1, Y1;
                CR_ac(i,:,2) = [0.08, 4.37]; % X2, Y2
        end
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
if contains(info.assaytype, 'Basic_info')
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

end