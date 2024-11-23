function helpText = priorHelp(type,option,maxChars)
% Syntax:
%
% helpText = nb_var.priorHelp(type)
% helpText = nb_var.priorHelp(type,option,maxChars)
%
% Description:
%
% Get the help on the different prior options.
% 
% Input:
%
% - type     : Name of the prior, as a one line char.
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
% nb_var.priorTemplate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        maxChars = [];
        if nargin < 2
            option = 'all';
        end
    end

    % Genereate help for the different options
    helper   = nb_writeHelp('nb_var.priorTemplate',option,type,'timeSeries');
    helper   = set(helper,'max',maxChars);
    helpText = help(helper);
    
end
