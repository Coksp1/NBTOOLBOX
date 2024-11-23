function helpText = priorHelp(option,maxChars)
% Syntax:
%
% helpText = nb_arima.priorHelp()
% helpText = nb_arima.priorHelp(option,maxChars)
%
% Description:
%
% Get the help on the different prior options.
% 
% Input:
%
% - option   : Either 'all' or the name of the option you want to get the
%              help on. Default is 'all'.
%
% - maxChars : The max number of chars in the printout of (approx). This
%              applies to the second column of the printout. Default is
%              40.
%
% Output:
% 
% - helpText : A char with the help.
%
% See also:
% nb_arima.priorTemplate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        maxChars = [];
        if nargin < 1
            option = 'all';
        end
    end

    % Genereate help for the different options
    helper   = nb_writeHelp('nb_arima.priorTemplate',option,'nwishart','timeSeries');
    helper   = set(helper,'max',maxChars);
    helpText = help(helper);
    
end
