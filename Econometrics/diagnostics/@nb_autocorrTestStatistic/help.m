function help = help(~,option)
% Syntax:
%
% help = help(~,option)
%
% Description:
%
% A method to give some basic instructions regarding input to
% nb_autocorrTestStatistic
% 
% Input:
% 
% - obj    : A nb_autocorrTestStatistic object
%
% - option : A string with the property to look up.
% 
% Output:
% 
% - help : A string with the help text.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if nargin < 2
        option = 'all';
    end

    % Genereate help for the different options
    nLagsHelp = sprintf([...
        '-nLags: Decides how many lags to include in the test. The input must \n',...
        'be a double.']);

    switch lower(option)
        case 'all'
            help = nLagsHelp;
        case 'nlags'
            help = nLagsHelp;
    end
    
end

