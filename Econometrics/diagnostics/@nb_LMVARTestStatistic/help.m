function help = help(~,option)
% Syntax:
%
% help = help(~,option)
%
% Description:
%
% A method to give some basic instructions regarding input to
% nb_LMVARTestStatistic
% 
% Input:
% 
% - obj    : A nb_LMVARTestStatistic object
%
% - option : A string with the property to look up.
% 
% Output:
% 
% - help : A string with the help text.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

% 

    if nargin < 2
        option = 'all';
    end

    % Genereate help for the different options
    lagHelp = sprintf([...
        '-lag: Decides the lag to include in the test. The input must \n',...
        'be a double.']);

    switch lower(option)
        case 'all'
            help = lagHelp;
        case 'lag'
            help = lagHelp;
    end
    
end

