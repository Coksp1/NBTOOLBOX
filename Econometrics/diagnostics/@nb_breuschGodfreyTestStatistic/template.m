function options = template()
% Syntax:
%
% options = nb_breuschGodfreyTestStatistic.template()
%
% Description:
%
% Construct a struct which must be provided to the 
% nb_breuschGodfreyTestStatistic class constructor.
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

    options = struct('nLags','');

end
