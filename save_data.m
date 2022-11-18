function [] = save_data()
%% save_data saves data as an xlsx file

global info
global vals

info.analysis_selection(~contains(info.analysis_selection, 'No Plots')); %Remove 'No plots' cell if present
if any(contains(info.analysis_selection, 'Final location relative to odor'))
    info.analysis_selection(~contains(info.analysis_selection, 'Final location relative to odor')); %Remove placeholder
    info.analysis_selection = [info.analysis_selection, ...
        'Final_Location_Relative_to_Control_cm', 'Final_Location_Relative_to_Experimental_cm'];
end

if any(contains(info.analysis_selection, 'Time in Odor Zones'))
    info.analysis_selection(~contains(info.analysis_selection, 'Time in Odor Zones')); %Remove placeholder
    info.analysis_selection = [info.analysis_selection, ...
        'Time_in_Control_Zone_sec', 'Time_in_Experimental_Zone_sec'];
end

if any(contains(info.analysis_selection, 'Distance up/down gradient'))
    info.analysis_selection(~contains(info.analysis_selection, 'Distance up/down gradient')); %Remove placeholder
    info.analysis_selection = [info.analysis_selection, ...
        'Distance_up_gradient', 'Distance_down_gradient'];
end

if any(contains(info.analysis_selection, 'Time up/down gradient'))
    info.analysis_selection(~contains(info.analysis_selection, 'Time up/down gradient')); %Remove placeholder
    info.analysis_selection = [info.analysis_selection, ...
        'Time_up_gradient', 'Time_down_gradient'];
end

if any(contains(info.analysis_selection, 'Number of Worms in Zone(s)'))
    info.analysis_selection(~contains(info.analysis_selection, 'Number of Worms in Zone(s)')); %Remove placeholder
        TT=table(vals.nfinal.C, vals.nfinal.E,'VariableNames', ...
        {'number_of_worms_ending_in_Control_Zone', 'number_of_worms_ending_in_Experimenal_Zone'});
    writetable(TT,fullfile(info.pathstr,info.name, strcat(info.name,'_Ctrls_vs_Exp_count.xlsx')));
end

if any(contains(info.analysis_selection, 'Instant Speed'))
    info.analysis_selection(~contains(info.analysis_selection, 'Instant Speed')); 
    TTT=table(vals.instantspeed,'VariableNames',{'InstantSpeed'});
    writetable(TTT,fullfile(info.pathstr,info.name,strcat(info.name,'_instantspeed.xlsx'))); 
end

if any(contains(info.analysis_selection, 'Travel Path'))
    info.analysis_selection(~contains(info.analysis_selection, 'Travel Path')); 
    TTTT=table(vals.travelpath,'VariableNames',{'TravelPath'});
    writetable(TTTT,fullfile(info.pathstr,info.name,strcat(info.name,'_travelpath.xlsx')));
end

for X = 1:length(info.analysis_selection)
    switch info.analysis_selection{X}
        case 'Distance Ratio'
            T(:,X) = vals.distanceratio';
        case 'Mean Speed'
            T(:,X) = vals.meanspeed';
        case 'Pathlength'
            T(:,X) = vals.pathlength';
        case 'Final location in gradient'
            T(:,X) = vals.finalgradientval'; 
        case 'Change in gradient location'
            T(:,X) = vals.gradientdiff';
        case 'Final_Location_Relative_to_Control_cm'
            T(:,X) = vals.EndLoc.Cport';
        case 'Final_Location_Relative_to_Experimental_cm'
            T(:,X) = vals.EndLoc.Eport';
        case 'Time_in_Control_Zone_sec'
            T(:,X) = vals.zonetime.C';
        case 'Time_in_Experimental_Zone_sec'
            T(:,X) = vals.zonetime.E';   
        case 'Distance_up_gradient'
             T(:,X) = vals.sumUp'; 
        case 'Distance_down_gradient'
            T(:,X) = vals.sumDown'; 
        case 'Time_up_gradient'
            T(:,X) = vals.timeUp'; 
        case 'Time_down_gradient'
            T(:,X) = vals.timeDown'; 
    end
end


headers = strrep(info.analysis_selection, ' ', '_');    
T = array2table(T, 'VariableNames', headers);
writetable(T,fullfile(info.pathstr,info.name,strcat(info.name,'_results.xlsx')));

end