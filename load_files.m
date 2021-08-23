function [] = load_files ()
%%load_files Input experimental files and analysis parameters to WormTracker3000.
%   Users can:
%       Select an XSLX file containing an index/parameter tab and an XY coordinate tabs
%       Select an XSLX file containing XY coordinates and input parameters
%       using a GUI
%       <Future update>Select a series of image z-stacks for automated
%       tracking/analysis


%% Define global variables
global info

%% Get user to select the file to be analyzed.
[name, pathstr] = uigetfile('*.xlsx');
if isequal(name,0)
    error('User canceled analysis session');
else
    disp(['User selected ', fullfile(pathstr,name)]);
end

info.calledfile = fullfile(pathstr,name);

%% Determine the type of assay being analyzed
[selection, ok] = listdlg('Name','Select Assay Type',...
    'PromptString','Pick an assay type',...
    'ListString',{'Pure Thermotaxis'; 'Thermotaxis + Odor'; ...
    'Isothermal Odor (22 cm arena)'; 'Pure Isothermal (22 cm arena)';...
    'Bacterial Assay (4.9 cm arena)'; 'CO2 Assay (3.75 cm arena)';...
    'Pheromone Assay (5 cm arena)'; 'Odor Assay (5 cm arena)';
    'Custom linear assay'; 'Basic track info'},...
    'SelectionMode','single','ListSize',[200 150]);
% Handle response
if ok < 1
    error('User canceled analysis session');
end

switch selection
    case 1
        info.assaytype = 'Thermo_22'; % Pure Thermotaxis Gradient
    case 2
        info.assaytype = 'OdorThermo_22'; % Multisensory Experiment, i.e. Odor + Thermal Gradient
    case 3
        info.assaytype = 'Odor_22'; % Pure Odor Experiment 22 cm arena, i.e. Odor on isothermal plate
    case 4
        info.assaytype = 'Iso_22'; % Isothermal 22cm arena, i.e. unstimulated experiment
    case 5
        info.assaytype = 'Bact_4.9'; % Bacterial Assay (4.9 cm arena)
    case 6
        info.assaytype = 'C02_3.75'; % C02 Assay (3.75 cm arena)
    case 7
        info.assaytype = 'Pher_5'; % Pheromone Assay (5 cm arena)
    case 8
        info.assaytype = 'Odor_5'; % Odor Assay (5 cm arena)
    case 9
        info.assaytype = 'Custom_linear'; % Custom assay with a linear gradient
    case 11
        info.assaytype = 'Custom_circle'; % Custom circular assay
    case 10
        info.assaytype = 'Basic_info'; % Basic information about distances moved, no gradient information
end


end