function [] = select_types()
%% Ask user to define which plots to generate and which analyses to save

global info
plottypes = {'Plots Only', 'No Plots', ...
    'Distance Ratio', ...
    'Mean Speed', 'Pathlength', ...
    'Instant Speed', 'Travel Path', ...
    'Final location in gradient', 'Change in gradient location',...  
    };

if contains(info.presets, 'Basic info')
    preset_selection = [3, 4, 5, 6, 7];    
elseif contains(info.presets, 'Thermotaxis')
    preset_selection = [2, 10, 3, 4, 5, 9, 10, 11, 12, 13, 14];
    plottypes = [plottypes ...
        {'Distance up/down gradient','Time up/down gradient', 'Min/Max value on gradient', 'Number of Worms Higher/Lower on Gradient', 'Starting Position on Gradient'}];
elseif contains(info.presets, 'Odors/Gas/Bacteria')
    preset_selection = [3, 4, 5, 6, 10, 11, 12];
    plottypes = [plottypes ...
        {'Final location relative to odor', 'Time in Odor Zones', 'Number of Worms in Zone(s)'}];
elseif contains(info.presets, 'Custom Linear')
    preset_selection = [9, 3, 4, 5];
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

end
