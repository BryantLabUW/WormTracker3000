function [finalgradientval, gradientdiff] = quant_specific_linear(xvals)
%% quant_specific_linear includes additional analyses for single-worm linear assays.
global info

B = ~isnan(xvals);
Indices = arrayfun(@(x) find(B(:, x), 1, 'last'), 1:info.numworms);

% Calculate final location of worm along the gradient
finalgradientval = arrayfun(@(x,y) xvals(x,y), Indices, 1:info.numworms);

% Implement floor and ceiling to the gradient location value, i.e. if calculated
% values are above Gradient(max) or below Gradient(min), then set those
% values equal to Gradient(max) and Gradient(min). This adjustment fixes an
% issue if the gradient doesn't extend linearly to the very edges of the
% assay plate, but instead include plateaus at min and max values.
finalgradientval(finalgradientval>info.gradient.max) = info.gradient.max(finalgradientval>info.gradient.max);
finalgradientval(finalgradientval<info.gradient.min) = info.gradient.min(finalgradientval<info.gradient.min);

% Where did the worm start (with floor/ceiling)?
startgradientval=xvals(1,:);
startgradientval(startgradientval>info.gradient.max) = info.gradient.max(startgradientval>info.gradient.max);
startgradientval(startgradientval<info.gradient.min) = info.gradient.max(startgradientval<info.gradient.min);


% Calculate change location of worm along the gradient
gradientdiff=finalgradientval-startgradientval;

end