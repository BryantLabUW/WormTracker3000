function [] = plot_basic(xvals, yvals, name, pathstr)
%% plot_linear plots worm tracks as cm values without any gradient information

%% Make a plot with all the tracks, then save it.
global info
fig = DrawThePlot(xvals, yvals, name);
movegui('northeast');

ax=get(fig,'CurrentAxes');
set(ax,'XLim',[min(round(min(xvals)))-1 max(round(max(xvals)))+1]);

setaxes = 1;
while setaxes>0 % loop through the axes selection until you're happy
    answer = questdlg('Adjust X/Y Axes?', 'Axis adjustment', 'Yes');
    switch answer
        case 'Yes'
            setaxes=1;
            vals=inputdlg({'Plot title','X Min','X Max',...
                'X-axis label', 'Y Min', 'Y Max', 'Y-axis label'},...
                'New X/Y Axes',[1 35; 1 35; 1 35; 1 35;1 35; 1 35;1 35],...
                {ax.Title.String num2str(ax.XLim(1)) num2str(ax.XLim(2))  ...
                ax.XLabel.String ...
                num2str(ax.YLim(1)) num2str(ax.YLim(2)) ...
                ax.YLabel.String});
            if isempty(vals)
                setaxes = -1;
            else
                ax.Title.String = vals{1};
                ax.XLim(1) = str2double(vals{2});
                ax.XLim(2) = str2double(vals{3});
                ax.XLabel.String = vals{4};
                ax.YLim(1) = str2double(vals{5});
                ax.YLim(2) = str2double(vals{6});
                ax.YLabel.String = vals{7};
            end
        case 'No'
            setaxes=-1;
        case 'Cancel'
            setaxes=-1;
    end   
end
saveas(gcf, fullfile(pathstr,[name,'/', name, '-all.eps']),'epsc');
saveas(gcf, fullfile(pathstr,[name,'/', name,'-all.png']));


%% Make a plot with a random subset of the tracks
if size(xvals,2)>10
    
    plotit = 1;
    movegui('northeast');
    
    while plotit>0 % Loop through the subset plotter until you get one you like.
        n = 10; % number of tracks to plot
        rng('shuffle'); % Seeding the random number generator to it's random.
        p = randperm(size(xvals,2),n);
        
        fig2=DrawThePlot(xvals(:,p),yvals(:,p),strcat(ax.Title.String, ' subset'));
        movegui('northeast');
        % Set axes for subplot equal to axes for full plot
        ax2=get(fig2,'CurrentAxes');
        set(ax2,'XLim',ax.XLim);
        set(ax2,'YLim',ax.YLim);
        set(ax2,'XLabel',ax.XLabel);
        set(ax2,'YLabel',ax.YLabel);
        
        answer = questdlg('Plot it again?', 'Subset Plot', 'Yes');
        switch answer
            case 'Yes'
                plotit=1;
            case 'No'
                plotit=-1;
            case 'Cancel'
                plotit=-1;
        end
    end
    
    saveas(gcf, fullfile(pathstr,[name,'/', name, '- subset.eps']),'epsc');
    saveas(gcf, fullfile(pathstr,[name,'/', name,'- subset.png']));
end


end

%% The bit that makes the figure
% Oh look, an inline script!

function [fig] = DrawThePlot(xvals, yvals, name)

fig=figure;
C=brewermap(size(xvals,2),'Dark2'); % set color scheme
set(groot,'defaultAxesColorOrder',C);  % apply color scheme. Comment this out if you'd rather use matlabs default colors.
hold on;

% Drawing Tracks
plot(xvals, yvals, 'LineWidth',1);
plot(xvals(1,:),yvals(1,:),'k+'); % plotting starting locations

hold off

% Labeling the figure and saving
ylabel('Distance (cm)'); xlabel('Distance (cm)');
title(name,'Interpreter','none');
set(gcf, 'renderer', 'Painters');

end

