function options = template()
% Syntax:
%
% options = nb_LMVARTestStatistic.template()
%
% Description:
%
% Construct a struct which must be provided to the 
% nb_LMVARTestStatistic class constructor.
%
% This structure provided the user the possibility to set different
% test options.
% 
% Output:
% 
% - options : A struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    options = struct('lag',1);

end
