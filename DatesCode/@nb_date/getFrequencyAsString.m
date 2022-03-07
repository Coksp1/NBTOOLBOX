function frequency = getFrequencyAsString(frequency) 
% Syntax:
%
% frequency = nb_date.getFrequencyAsString(frequency)
%
% Description:
% 
% A static method of the nb_date class.
%
% Get the frequency as a string given a frequency as an integer
% 
% Input:
% 
% - frequency : Frequency input as an integer
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
% Output:
% 
% - frequency : The frequency as a string
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
%   > Yearly        : 'yearly'   
% 
% Examples:
%
% frequency = nb_date.getFrequencyAsString(1);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch frequency
        case 1
            frequency = 'yearly';
        case 2
            frequency = 'semiannually';
        case 4
            frequency = 'quarterly';
        case 12
            frequency = 'monthly';
        case 52
            frequency = 'weekly';
        case 365
            frequency = 'daily';
        otherwise
            error([mfilename ':: Unsupported integer frequency ' int2str(frequency)])
    end

end
