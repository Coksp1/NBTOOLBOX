function help = help(~,option)
% Syntax:
%
% help = help(~,option)
%
% Description:
%
% A method to give some basic instructions regarding input to
% nb_durbinWuHausmanStatistic
% 
% Input:
% 
% - obj    : A nb_archTestStatistic object
%
% - option : A string with the property to look up.
% 
% Output:
% 
% - help : A string with the help text.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        option = 'all';
    end

    % Genereate help for the different options
    endogenousHelp = sprintf([...
        '-endogenous: Select the possible endogenous variables. Must be a \n',...
        '1 x K cellstr. All the selected endogenous variables must be included \n',...
        'in the data proberty of the nb_model_generic object. This option is \n',...
        'not valid if the model is estimated by TSLS, because then the endogenous\n',...
        'variables are already selected.']);

    instrumentsHelp = sprintf([...
        '-instruments: Select the instruments to use for each possible endogenous \n',...
        'variables. Must be a 1 x K cell. Each element must be a cellstr with \n',...
        'names of the instruments to use for each possible endogenous variable.\n',...
        'Can be more than one for each. All the selected instruments must be \n',...
        'included in the data proberty of the nb_model_generic object. This option \n',...
        'is not valid if the model is estimated by TSLS, because then the instruments\n',...
        'are already selected.']);

    switch lower(option)
        case 'all'
            help = [aHelp,char(10),char(10),cHelp,char(10),char(10),dependentHelp];
        case 'endogenous'
            help = endogenousHelp;
        case 'instruments'
            help = instrumentsHelp;
    end
    
end

