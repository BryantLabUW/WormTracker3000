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
    'ListString',{'Basic track info'; ...
    'Custom linear assay'; ...
    'Pure Thermotaxis'; ...
    %'Thermotaxis + Odor (not supported)'; ...
    %'Isothermal Odor (22 cm arena - not supported)'; ...
    %'Pure Isothermal (22 cm arena - not supported)';...
    'Bacterial Assay (4.9 cm arena)'; ...
    'CO2 Gradient (3.75 cm arena)';...
    'Pheromone Assay (5 cm arena)'; ...
    'Odor Assay (5 cm arena)'; ...
    %'Gas Shift Chamber'; ...
    %'Sweat Accumulation' ...
    }, ...
    'SelectionMode','single','ListSize',[200 150]);
% Handle response
if ok < 1
    error('User canceled analysis session');
end

switch selection
    case 1
        info.assaytype = 'Basic_info'; % Basic information about distances moved, no gradient information
        info.presets = 'Basic info';
    case 2
        info.assaytype = 'Custom_linear'; % Custom assay with a linear gradient
        info.presets = 'Thermotaxis';
    case 3
        info.assaytype = 'Thermo_22'; % Pure Thermotaxis Gradient
        info.presets = 'Thermotaxis';
    case 4
        info.assaytype = 'Bact_4.9'; % Bacterial Assay (4.9 cm arena)
        info.presets = 'Odors/Gas/Bacteria';
    case 5
        info.assaytype = 'C02_3.75'; % C02 Assay (3.75 cm arena)
        info.presets = 'Odors/Gas/Bacteria';
    case 6
        info.assaytype = 'Pher_5'; % Pheromone Assay (5 cm arena)
        info.presets = 'Odors/Gas/Bacteria';
    case 7
        info.assaytype = 'Odor_5'; % Odor Assay (5 cm arena)
        info.presets = 'Odors/Gas/Bacteria';
        %     case 8
        %         info.assaytype = 'GasShift'; % Chamber for sequential presentation of gases
        %         info.presets = 'Basic info';
        %     case 9
        %         info.assaytype = 'SweatAccumulation'; % Sweat accumulation assay
        %         info.presets = 'Basic info';
        %     case 3
        %         info.assaytype = 'Odor_22'; % Pure Odor Experiment 22 cm arena, i.e. Odor on isothermal plate
        %         info.presets = 'Odors/Gas/Bacteria';
        %     case 4
        %         info.assaytype = 'Iso_22'; % Isothermal 22cm arena, i.e. unstimulated experiment
        %         info.presets = 'Basic info';
        %     case 12
        %         info.assaytype = 'Custom_circle'; % Custom circular assay
end


end