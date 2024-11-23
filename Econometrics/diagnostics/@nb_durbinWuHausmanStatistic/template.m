function options = template()
% Syntax:
%
% options = nb_durbinWuHausmanStatistic.template()
%
% Description:
%
% Construct a struct which must be provided to the 
% nb_durbinWuHausmanStatistic class constructor.
%
% This structure provided the user the possibility to set different
% test options.
% 
% Output:
% 
% - options : A struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    options = struct('endogenous',{{}},'instruments',{{}});

end
