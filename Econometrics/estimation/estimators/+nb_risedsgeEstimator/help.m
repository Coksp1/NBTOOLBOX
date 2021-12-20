function helpText = help(option,maxChars)
% Syntax:
%
% helpText = nb_risedsgeEstimator.help
% helpText = nb_risedsgeEstimator.help(option)
% helpText = nb_risedsgeEstimator.help(option,maxChars)
%
% Description:
%
% Get the help on the different model options.
% 
% Input:
% 
% - option   : Either 'all' or the name of the option you want to get the
%              help on.
% 
% - maxChars : The max number of chars in the printout of (approx). This
%              applies to the second column of the printout. Default is
%              40.
% 
% Output:
% 
% - helpText : A char with the help.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        maxChars = [];
        if nargin < 1
            option = 'all';
        end
    end
    
    error([mfilename ':: No help for this package yet!'])
    
    % Genereate help for the different options
    helper   = nb_writeHelp('nb_oxEstimator',option,'package','timeSeries');
    helper   = set(helper,'max',maxChars);
    helpText = help(helper);
    
end
