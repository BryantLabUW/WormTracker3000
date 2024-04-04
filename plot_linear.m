function [] = plot_linear(xvals, yvals, name, pathstr)
%% plot_linear plots worm tracks collected from a linear gradient

%% Make a plot with all the tracks, then save it.
global info

fig = DrawThePlot(xvals, yvals, name);
movegui('northeast');

ax=get(fig,'CurrentAxes');
if contains(info.assaytype, 'Thermo_22')
    set(ax,'XLim',[min(info.gradient.min) max(info.gradient.max)]);
    set(ax, 'YLim', [-22.5 0]);
elseif contains(info.assaytype,'Custom_linear')
    set(ax,'XLim',[min(info.gradient.min) max(info.gradient.max)]);
end


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

%% Make a plot with an overlay

if any(contains(info.sheets, 'Overlay'))
    global dat
    disp('Generating Overlay Plot')
    
    % Find the X/Y coordinates that match the ovelay event UID and frame
    for i = 1:info.overlay.Num
        I = find(contains(info.wormUIDs, dat.overlay.UIDs{i}));
        dat.overlay.Xvals(i,1) = xvals(dat.overlay.Frame(i), I);
        dat.overlay.Yvals(i,1) = yvals(dat.overlay.Frame(i), I);
    end
    % Drawing the Overlay
    overlayicons = ["diamond", "^", "square", "x", "*", "o"]; % Change this line of code to alter the style of overlay icons used
    disp('Warning: icon identity may change if the number of overlay category types fluctuates across assays.');
    disp('For stability, set all overlay event icons to the same marker type in the plot_basic.m file (near the code that generates this message).');
    temp = categories(dat.overlay.Event);
    hold on
    for i = 1:info.overlay.CatNum
        I = find(dat.overlay.Event == temp{i});
        plot(dat.overlay.Xvals(I), dat.overlay.Yvals(I), overlayicons(i), 'MarkerSize',10);
    end
    hold off
    
    saveas(gcf, fullfile(pathstr,[name,'/', name, '-overlay.eps']),'epsc');
    saveas(gcf, fullfile(pathstr,[name,'/', name,'-overlay.png']));
end

%% Make a plot with a random subset of the tracks
answer = questdlg('Do you want to plot a subset of tracks?', 'Subset Plotting', 'Yes');
    switch answer
        case 'Yes'
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


   


%% Make a heatmap plot where the tracks are color coded by temperature
answer = questdlg('Do you want to replot tracks as a heatmat?', 'Heatmap Plotting', 'Yes');
    switch answer
        case 'Yes'
     setaxes = 1;
     movegui('northeast');
        while setaxes>0 % loop through the axes selection until you're happy
            rangeL= min(info.gradient.min);
            rangeH = max(info.gradient.max);
            range = {num2str(rangeL), num2str(rangeH)};
                  
            answer = inputdlg({'Heatmap Range Min', 'Heatmap Range Max'}, ...
                'Heatmap Parameters', 1, range);
            range = [str2num(answer{1}), str2num(answer{2})];
            
            MakeTheHeatmap(xvals, range, name);
            
            answer = questdlg('Adjust Heatmap Params', 'Plot adjustment', 'Yes');
            switch answer
                case 'Yes'
                    setaxes=1;
                    close all
                case 'No'
                    setaxes=-1;
                case 'Cancel'
                    setaxes=-1;
            end
        end
        close all
         

    saveas(gcf, fullfile(pathstr,[name,'/', name, '- heatmap.eps']),'epsc');
    saveas(gcf, fullfile(pathstr,[name,'/', name,'- heatmap.png']));
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
ylabel('Distance (cm)'); xlabel('Gradient values');
title(name,'Interpreter','none');
set(gcf, 'renderer', 'Painters');

end

function [fig] = MakeTheHeatmap(xvals, range, name)
% for tracks where the tracking ends early, fill in remaining with the last
% number
B = ~isnan(xvals);
Indices = arrayfun(@(x) find(B(:, x), 1, 'last'), 1:info.numworms);
A = arrayfun(@(x) subsasgn(xvals(:,x), substruct('()', {isnan(xvals(:,x))}), xvals(Indices(x), x)), 1:info.numworms, 'UniformOutput', false);
A = cell2mat(A)';
% Use hierarchical clustering to determine optimal order for rows
% the method for the linkage is: Unweighted average distance (UPGMA), aka
% average linkage clustering
D = pdist(A);
tree = linkage(D, 'average');
leafOrder = optimalleaforder(tree, D);

% Reorder tracks to reflect optimal leaf order
A = A(leafOrder, :);

figure ('Units','pixels', 'Position',[100 100 350 900 ])
movegui('northeast');
colormap(inferno());

imagesc(A,range);
set(gca,'XTickLabel',[]);
ylabel('Worms');
xlabel('Time (seconds)');
colorbar

title(gcf, strcat(name,'_Heatmap'),'Interpreter','none');



saveas(gcf, fullfile(newdir,['/', n, '-heatmap.eps']),'epsc');
saveas(gcf, fullfile(newdir,['/', n, '-heatmap.jpeg']),'jpeg');

close all
end