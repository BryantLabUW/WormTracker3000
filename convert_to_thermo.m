function[xvalsgradient] = convert_to_thermo(xvals, yvals, ppcm)
%% convert_to_thermo transforms track data in pixels to cm data then to values of the given thermotaxis gradient. 
%   Requires a gradient slope (value-per-cm), and the min/max values of the gradient.
%   Assumes a linear gradient across the x-axis of the asay.

global info
global vals
global tracks

% Align to x-axis reference location, generally the T(start) location
refarray = repmat(info.ref.x', info.tracklength, 1);
tracks.Refx = xvals - refarray;

% Conversion from pixel to cm values, given known converstion rate.
pixelpercmarray = repmat(ppcm', info.tracklength, 1);
tracks.xvalscm=tracks.Refx./pixelpercmarray;
tracks.yvalscm=yvals./pixelpercmarray;
tracks.plotyvals = tracks.yvalscm*-1;

% Conversion to temperature values based on x-axis location of the
% reference temperature. Remember that 0 in x-axis is the reference
% temperature, which in a pure thermotaxis gradient should be t(start).
% Importantly, this assumes that the gradient is oriented in the FIJI image
% such that the warmest portion of the gradient is to the left and the
% coolest is to the right. This is accurate relative to real life, but is a
% change from previous versions.

xvalsgradient =  info.gradient.ref' - (tracks.xvalscm.*info.gradient.rate');


