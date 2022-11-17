function [] = load_overlay ()
%%load_overlay: Load overlay information

global info
global dat

[~, headers, ~] = xlsread(info.calledfile, 'Overlay');
alphabet = ['A':'Z'];

% Determine number of overlay events
[I, J] = find(contains(headers, {'Behavior', 'Event', 'Category', 'Type'}));
info.overlay.Num = size(headers(:,J), 1)-1;

% Behavior Type/Category for each event
dat.overlay.Event = categorical(headers(2:end,J));
info.overlay.CatNum = size(categories(dat.overlay.Event),1);

% UniqueIDs for each overlay event
[I, J] = find(contains(headers, {'UID', 'ID'}));
dat.overlay.UIDs = headers(2:end, J);

% Frames for each overlay event
[I, J] = find(contains(headers, {'Frame'}));
if ~isempty(I) && ~isempty(J)
dat.overlay.Frame = xlsread(info.calledfile, 'Overlay', strcat(...
    alphabet(J), num2str(I+1),...
    ':',alphabet(J), num2str(info.overlay.Num+1)));
end


