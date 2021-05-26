function [finalgradientval, gradientdiff] = quant_specific_linear(xvals)
%% quant_specific_linear includes additional analyses for single-worm linear assays.
global info

B = ~isnan(xvals);
Indices = arrayfun(@(x) find(B(:, x), 1, 'last'), 1:info.numworms);

% Calculate final location of worm along the gradient
finalgradientval = arrayfun(@(x,y) xvals(x,y), Indices, 1:info.numworms);

% Where did the worm start?
startgradientval=xvals(1,:);

% Calculate change location of worm along the gradient
gradientdiff=finalgradientval-startgradientval;

end