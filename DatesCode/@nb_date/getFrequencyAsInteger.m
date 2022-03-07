function frequency = getFrequencyAsInteger(frequency) 
% Syntax:
%
% frequency = nb_date.getFrequencyAsInteger(frequency)
%
% Description:
% 
% A static method of the nb_date class.
%
% Get the frequency as an integer given a frequency as a string
% 
% Input:
% 
% - frequency : Frequency input as a string
%
%   > Daily         : 'daily'
%
%   > Weekly        : 'weekly'
%
%   > Monthly       : 'monthly'
%
%   > Quarterly     : 'quarterly'
%
%   > Semiannually  : 'semiannually'
%
%   > Yearly        : 'yearly', 'annual'   
%  
% Output:
% 
% - frequency : The frequency as an integer
%
%   > Daily         : 365
%
%   > Weekly        : 52
%
%   > Monthly       : 12
%
%   > Quarterly     : 4
%
%   > Semiannually  : 2
%
%   > Yearly        : 1   
%  
% Examples:
%
% frequency = nb_date.getFrequencyAsInteger('yearly')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch lower(frequency)
        case {'yearly','annual'}
            frequency = 1;
        case 'semiannually'
            frequency = 2;
        case 'quarterly'
            frequency = 4;
        case 'monthly'
            frequency = 12;
        case {'weekly','weekly(thursday)'}
            frequency = 52;
        case 'daily'
            frequency = 365;
        otherwise
            error([mfilename ':: Unsupported string frequency ' frequency])
    end

end
