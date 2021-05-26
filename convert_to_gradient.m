function[xvalsgradient] = convert_to_gradient(xvalscm, yvalscm)
%% convert_to_gradient transforms track data (in cm) to values of the given
%   gradient. 
%   Requires a gradient slope (value-per-cm), and the min/max values of the gradient.
%   It assumes that the alignment spots used to orient that tracks are 
%   located equidistantly from the center of the gradient, such that
%   halfway between the alignment locations == halfway between the min/max
%   gradient values

global info
global vals

% Conversion to gradient values
gradient_rate = repmat(info.gradient.rate', info.tracklength, 1);

% Find middle position/value between alignment locations, which we assume is the
% halfway point in the gradient. Remember that the tracks are set up so
% 0,0 is the alignment location closest to the lowest part of the gradient
gradient_midloc = vals.HighStdLoc.x / 2;
gradient_midloc = repmat(gradient_midloc, info.tracklength,1);

gradient_midval = (info.gradient.max' - info.gradient.min') /2;
gradient_midval = repmat(gradient_midval, info.tracklength,1);

shiftedX = xvalscm - gradient_midloc;
xvalsgradient = gradient_midval + (shiftedX.*gradient_rate);

end