function [] = plot_chemotaxis(xvals,yvals,CPortStdLoc, neutZone,name,pathstr, subsetplot, individualplots)
%% plot_chemotaxis: Function for plotting worm tracks in a chemotaxis setup.

%% Retrieve global variables
global info

%% Cleaning up the data for plotting
% Given the info.radius of the asasy circle, remove track elements that go
% beyond the circle. I can use displace.m for this. calculate the
% displacement of each track relative to the center of the assay.
assayorigin = [neutZone.center,0]; % Center of the assay circle
[maxdisplacement pathlength meanspeed instantspeed displacement]= displace ([(repmat(assayorigin(1),1,size(xvals,2)));(repmat(assayorigin(2),1,size(yvals,2)))],xvals, yvals);

% Trim plotting values to exclude points that fall outside the assay zone.
xvals(displacement > info.radius) = NaN;
yvals(displacement > info.radius) = NaN;

%% Make a plot with all the tracks, then save it.
DrawThePlot(xvals, yvals, neutZone, assayorigin, CPortStdLoc, name);
saveas(gcf, fullfile(pathstr,[name,'/', name, '-all.eps']),'epsc');
saveas(gcf, fullfile(pathstr,[name,'/', name,'-all.png']));


%% Make a plot with a random subset of the tracks
  answer = questdlg('Do you want to plot a subset of tracks?', 'Subset Plotting', 'Yes');
    switch answer
        case 'Yes'
        plotit = 1;
        while plotit>0 % loop through the subset plotter until you get one you like.
            n = 10; % number of tracks to plot
            rng('shuffle'); % Seeding the random number generator to it's random.
            p = randperm(size(xvals,2),n);
            
            DrawThePlot(xvals(:,p), yvals(:,p), neutZone, assayorigin, CPortStdLoc, strcat(name, ' subset'));
            
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
        
        set(gcf, 'renderer', 'Painters');
        saveas(gcf, fullfile(pathstr,[name,'/', name, '-subset.eps']),'epsc');
        saveas(gcf, fullfile(pathstr,[name,'/', name,'-subset.png']));
    end
    

% %% Make individual plots for each track
% 
% if individualplots>0
%     disp('Plotting and saving individual plots, invisibly');
%     set(0,'DefaultFigureVisible','off');
%     for i=1:size(xvals,2)
%         DrawThePlot(xvals(:,i), yvals(:,i), neutZone, assayorigin, CPortStdLoc, strcat(name, ' - Worm ',num2str(i)));
%         saveas(gcf, fullfile(pathstr,[name, '/', name, ' - Worm ',num2str(i),'.png']),'png');
%     end
%     set(0,'DefaultFigureVisible','on');
% end
 end

%% The bit that makes the figure
% Oh look, an inline script!

function DrawThePlot(xvals, yvals, neutZone, assayorigin, CPortStdLoc, name)
% Retrieve some global variables!
global info

figure;
movegui('northeast');
C=brewermap(size(xvals,2),'Dark2'); % set color scheme
set(groot,'defaultAxesColorOrder',C);
hold on;

% Drawing assay arena circle
circle(assayorigin,info.radius, 'none', 'k');

% Assay-specific things
if contains(info.assaytype, 'Bact_4.9') ...
        || contains(info.assaytype, 'Pher_5') || contains(info.assaytype, 'Odor_5')
    circle([median(CPortStdLoc.x), median(CPortStdLoc.y)],info.scoringradius,'none','k');
    circle([0,0], info.scoringradius,'none','r');
elseif contains(info.assaytype, 'C02_3.75')
    discorectangle((neutZone.upperlimit - neutZone.lowerlimit),[neutZone.center,0],info.radius,'k',0.3);
    circle([median(CPortStdLoc.x), median(CPortStdLoc.y)],info.portradius,'k','none');
    circle([0,0], info.portradius,'r','none');
end

% Drawing Tracks
plot(xvals, yvals, 'LineWidth',1);
plot(xvals(1,:),yvals(1,:),'k+'); % plotting starting locations


hold off

% Labeling the figure and saving
ylabel('Distance (cm)'); xlabel('Distance (cm)');
axis('equal');
title(name,'Interpreter','none');
set(gcf, 'renderer', 'Painters');
end
