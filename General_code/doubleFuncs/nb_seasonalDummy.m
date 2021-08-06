function dummy = nb_seasonalDummy(T,frequency,type)
% Syntax:
%
% dummy = nb_seasonalDummy(T,frequency,type)
%
% Description:
%
% Create seasonal dummies
% 
% Input:
% 
% - T         : Number of periods. As an integer.
%
% - frequency : Either 4 (quarterly) or 12 (monthly)
%
% - type      : 'uncentered' or 'centered'
% 
% Output:
% 
% - dummy : The dummy variables as T x frequency-1
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'uncentered';
    end

    switch lower(type)

        case 'uncentered'

            dummy = zeros(T,frequency-1);
            for jj = 1:frequency-1
                dummy(jj:frequency:end,jj) = 1;
            end

        case 'centered'

            dummy = ones(T,frequency-1)*(-1/frequency);
            value = (frequency-1)/frequency;
            for jj = 1:frequency-1
                dummy(jj:frequency:end,jj) = value;
            end

    end

end
