function out = nb_kernelCDFBounds(type)
% Syntax:
%
% out = nb_kernelCDFBounds(type)
%
% Description:
%
% See output.
% 
% Input:
% 
% - type : 1: Lower. 0: Upper.
% 
% Output:
% 
% - out  : Upper or lower bound on CDF estimation by kernel methods.
%
% See also:
% nb_evaluateDensityForecast, nb_simulateFromDensity
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if type 
        kernelCDFLow = getenv('kernelCDFLow');
        if isempty(kernelCDFLow)
            out = 0.975;
        else
            out = str2double(kernelCDFLow);
            if isnan(out)
                error('The environment variable kernelCDFLow could not be interpreted as a number!')
            end
            if out < 0 || out > 0.99999
                error('The environment variable kernelCDFLow must be in the interval [0,0.9999]!')
            end
        end
    else
        kernelCDFHigh = getenv('kernelCDFHigh');
        if isempty(kernelCDFHigh)
            out = 1.025;
        else
            out = str2double(kernelCDFHigh);
            if isnan(out)
                error('The environment variable kernelCDFHigh could not be interpreted as a number!')
            end
            if out > 2 || out < 1.00001
                error('The environment variable kernelCDFHigh must be in the interval [1.00001,2]!')
            end
        end
    end

end
