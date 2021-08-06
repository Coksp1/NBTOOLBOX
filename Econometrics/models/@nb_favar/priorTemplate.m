function prior = priorTemplate(type,num)
% Syntax:
%
% prior = nb_favar.priorTemplate()
% prior = nb_favar.priorTemplate(type)
% prior = nb_favar.priorTemplate(type,num)
%
% Description:
%
% Not yet finished!!
%
% Construct a struct which can be given to the method setPrior.
%
% The structure provided the user the possibility to set different
% prior options.
% 
% Input:
%
% - type : A string;
%
% - num  : Number of prior templates to make.
%
% Output:
% 
% - options : A struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    error([mfilename ':: There are no supported priors for the nb_favar class yet!'])

    if nargin < 2
        num = 1; 
        if nargin < 1
            type = 'jeffrey';
        end
    end

    if num == 1
        prior = struct();
    else
        prior = nb_struct(num,{'constant'}); % Make it possible to initalize many objects
    end
    
    prior.type = type;
    switch lower(type)

        case 'jeffrey'

            % Do nothing

        case 'minnesota'

            prior.a_bar_1 = 0.5;
            prior.a_bar_2 = 0.5;
            prior.a_bar_3 = 100;
            prior.ARcoeff = 0.9;

        case 'nwishart'

            error('Normal-Wishart is not yet supported')

        case 'inwishart' 

            error('Independent Normal-Wishart is not yet supported')  

        otherwise

            error([mfilename ':: Unsupported prior type ' type])

    end

end
