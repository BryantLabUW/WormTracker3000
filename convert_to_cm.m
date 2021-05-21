function[xvalscm, yvalscm] = convert_to_cm(xvals, yvals, ppcm)
%%convert_to_cm converts between pixels and cm
%   [xvalscm, yvalscm] = convert_to_cm(xvals, yvals, ppcm)
%   This function takes worm tracks, represented as
%   x-, y-coordinates in pixels, and turning them in to cm values.
%

%% Convert Camera Data from pixels to cm, given known converstion rate.
ppcmarray = repmat(ppcm, size(xvals,1),1);
xvalscm=xvals./ppcmarray;
yvalscm=yvals./ppcmarray;
end