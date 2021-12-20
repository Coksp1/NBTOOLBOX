function help = help(~,option)
% Syntax:
%
% help = help(~,option)
%
% Description:
%
% A method to give some basic instructions regarding input to
% nb_chowTestStatistic
% 
% Input:
% 
% - obj    : A nb_chowTestStatistic object
%
% - option : A string with the property to look up.
% 
% Output:
% 
% - help : A string with the help text.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        option = 'all';
    end

    % Genereate help for the different options
    breakpointHelp = sprintf([...
        '-breakpoint: a date, either as a valid string input to the nb_date.toDate \n',...
        'method or as an nb_date object. The input will decide where to place the \n',...
        'breakpoint for the chow test.']);
    recursiveHelp = sprintf([...
        '-recursive: If set to true, it will do the chow test recursivly. The\n',...
        'breakepoint option is then absolete.']);

    switch lower(option)
        case 'all'
            help = [breakpointHelp,char(10),char(10),recursiveHelp];
        case 'breakpoint'
            help = breakpointHelp;
        case 'recursive'
            help = recursiveHelp;
    end
    
end

