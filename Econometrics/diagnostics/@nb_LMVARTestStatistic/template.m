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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    options = struct('lag',1);

end