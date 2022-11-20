function [finalgradientval, gradientdiff, sum_down, sum_up, count_down, count_up] = quant_specific_linear(xvals)
%% quant_specific_linear includes additional analyses for single-worm linear assays.
global info
global vals

B = ~isnan(xvals);
Indices = arrayfun(@(x) find(B(:, x), 1, 'last'), 1:info.numworms);

% Calculate final location of worm along the gradient
finalgradientval = arrayfun(@(x,y) xvals(x,y), Indices, 1:info.numworms);

% Implement floor and ceiling to the gradient location value, i.e. if calculated
% values are above Gradient(max) or below Gradient(min), then set those
% values equal to Gradient(max) and Gradient(min). This adjustment fixes an
% issue if the gradient doesn't extend linearly to the very edges of the
% assay plate, but instead include plateaus at min and max values.
finalgradientval(finalgradientval>info.gradient.max') = info.gradient.max(finalgradientval>info.gradient.max');
finalgradientval(finalgradientval<info.gradient.min') = info.gradient.min(finalgradientval<info.gradient.min');

% Where did the worm start (with floor/ceiling)?
startgradientval=xvals(1,:);
startgradientval(startgradientval>info.gradient.max') = info.gradient.max(startgradientval>info.gradient.max');
startgradientval(startgradientval<info.gradient.min') = info.gradient.max(startgradientval<info.gradient.min');


% Calculate change location of worm along the gradient
gradientdiff=finalgradientval-startgradientval;

%% Calculate amount of distance traveled either up or down gradient, and time spent traveling
osx = xvals(2:end,:); %x vals offset by one time point
diffx = osx - xvals(1:(size(xvals,1)-1),:);

Indices = arrayfun(@(x) find(diffx(:, x) < 0), 1:info.numworms, 'UniformOutput', false);
sum_down = arrayfun(@(x) sum(diffx(Indices{x}, x)), 1:info.numworms);
count_down = arrayfun(@(x) numel(diffx(Indices{x}, x)), 1:info.numworms).* info.samplefreq'; % number of frames spent traveling down gradient * sample frequency (sec per frame)

Indices = arrayfun(@(x) find(diffx(:, x) > 0), 1:info.numworms, 'UniformOutput', false);
sum_up = arrayfun(@(x) sum(diffx(Indices{x}, x)), 1:info.numworms);
count_up = arrayfun(@(x) numel(diffx(Indices{x}, x)), 1:info.numworms) .* info.samplefreq'; % number of frames spent traveling up gradient * sample frequency (sec per frame)

%% Number of animals that ended up lower versus higher on the gradient

threshold = 0.1; % nominal threshold of distance for categories, in gradient values (i.e. temperature)

% For how many worms is the final x position higher/lower on the gradient, thresholded?

vals.fP = nnz(find(gradientdiff > threshold));
vals.fN = nnz(find(gradientdiff < -threshold));
vals.fE = info.numworms - (vals.fP + vals.fN);


end