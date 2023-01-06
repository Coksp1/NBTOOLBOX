function options = template()
% Syntax:
%
% options = nb_baiPerronTestStatistic.template()
%
% Description:
%
% Construct a struct which must be provided to the 
% nb_baiPerronTestStatistic class constructor.
%
% This structure provided the user the possibility to set different
% test options.
% 
% Output:
% 
% - options : A struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    options = struct(...
        'constant',     false,...
        'criterion',    'bic',...
        'critical',     0.05,...
        'dependent',    '',...
        'endDate',      '',...
        'eps',          eps,...
        'estimrep',     0,...
        'estimseq',     0,...
        'exogenous',    {{}},...
        'fixed',        {{}},...
        'hetdat',       1,...
        'hetvar',       1,...
        'hetomega',     1,...
        'hetq',         1,...
        'initBeta',     [],...
        'maxi',         20,...
        'maxNumBreaks', 2,...
        'minSegment',   [],...
        'prewhit',      1,...
        'printd',       0,...
        'robust',       1,...
        'startDate',    '',...
        'time_trend',   false);

end
