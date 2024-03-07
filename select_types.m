function [] = select_types()
%% Ask user to define which plots to generate and which analyses to save

global info
plottypes = {'Plots Only', 'No Plots', ...
    'Subset Tracks', 'Distance Ratio', ...
    'Mean Speed', 'Pathlength', ...
    'Instant Speed', 'Travel Path', ...
    'Final location in gradient', 'Change in gradient location',...  
    };

if contains(info.presets, 'Basic info')
    preset_selection = [4, 5, 6, 7, 8];    
elseif contains(info.presets, 'Thermotaxis')
    preset_selection = [10, 4, 5, 7, 11, 12];
    plottypes = [plottypes ...
        {'Distance up/down gradient', 'Number of Worms Higher/Lower on Gradient'}];
elseif contains(info.presets, 'Odors/Gas/Bacteria')
    preset_selection = [4, 5, 6, 7, 11, 12, 13];
    plottypes = [plottypes ...
        {'Final location relative to odor', 'Time in Odor Zones', 'Number of Worms in Zone(s)'}];
elseif contains(info.presets, 'Custom Linear')
    preset_selection = [10, 4, 5, 6];
    plottypes = [plottypes ...
        {'Number of Worms Higher/Lower on Gradient'}];
end

[analysis_selection, OK] = listdlg('PromptString','Pick plots/analyses to generate', ...
    'ListString', plottypes, 'ListSize', [160 160], ...
    'InitialValue', preset_selection);
if OK == 0
    analysis_selection = [1];
    disp('User canceled plot/analysis selection, defaulting to plotting tracks only');
end

info.analysis_selection = plottypes(analysis_selection);
if any(contains(info.analysis_selection, 'No Plots'))
    info.plotlogic = 0;
else
    info.plotlogic = 1;
end

if any(contains(info.analysis_selection, 'Plots Only'))
    info.analysislogic = 0;
else
    info.analysislogic = 1;
end

if any(contains(info.analysis_selection, 'Subset Tracks'))
    info.subsetlogic = 1;
else
    info.subsetlogic = 0;
end


end
