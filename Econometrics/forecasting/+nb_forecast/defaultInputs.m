function default = defaultInputs(convert)
% Syntax:
%
% default = nb_forecast.defaultInputs(convert)
%
% Description:
%
% Get default struct to give as the input to the inputs input of the 
% nb_forecast function.
% 
% Input:
%
% - convert : Convert to struct if set to true, otherwise not. Default is
%             true.
%
% Output:
%
% - default : A N x 3 cell matrix or a struct with N fields.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        convert = true;
    end

    methods = {'bootstrap','wildBootstrap','blockBootstrap',...
               'mBlockBootstrap','rBlockBootstrap','wildBlockBootstrap',...
               'posterior','asymptotic',''};       
    default = {'parallel',          false,      {@islogical,'||',@isnumeric};...              
               'parameterDraws',    1,          {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0}};...
               'draws',             1,          {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0}};...
               'regimeDraws',       1,          {@nb_iswholenumber,'&&',@isscalar,'&&',{@gt,0}};...
               'newDraws',          0.1,        {@isnumeric,'&&',@isscalar,'&&',{@gt,0}};...
               'method',            '',         {@ischar,'&&',{@nb_ismemberi,methods}};...
               'observables',       {},         {@iscellstr,'||',@isempty};...
               'output',            'endo',     {@ischar,'&&',{@nb_ismemberi,{'endo','full','fullendo','all',''}}};...
               'startingValues',    '',         {@ischar,'||',@isnumeric};...
               'startingProb',      '',         {@ischar,'||',@isnumeric};...
               'stabilityTest',     false,      @islogical;...
               'states',            [],         {@nb_iswholenumber,'&&',@isscalar,'||',@isempty,'||',{@isa,'nb_ts'}};...
               'fcstEval',          {},         {@iscellstr,'||',@ischar};...
               'estDensity',        'kernel'    @nb_isOneLineChar;...
               'varOfInterest',     '',         {@ischar,'||',@isempty,'||',@iscellstr};...
               'perc',              [],         {@isnumeric,'||',@isempty};...
               'bins',              [],         {@iscell,'||',@isempty};...
               'saveToFile',        false,      @islogical;...
               'seed',              2.0719e+05, @nb_isScalarNumber;...
               'shockProps',        struct,     {@isstruct,'||',@isempty};...
               'sigma',             [],         {@isnumeric,'||',@isempty};...
               'sigmaType',         'none',     {{@nb_ismemberi,{'none','spearman','kendall'}}};...
               'startIndWarning',   false,      @nb_isScalarLogical;...
               'compareToRev',      [],         {@nb_isScalarInteger,'&&',{@gt,0},'||',@isempty};...
               'compareTo',         [],         {@iscellstr,'||',@isempty};...
               'initPeriods',       0,          {@nb_iswholenumber,'&&',@isscalar,'&&',{@ge,0},'||',@isempty};...
               'estimateDensities', true,       @islogical;...
               'exoProj',           '',         {{@nb_ismemberi,{'ar','var'}},'||',@isempty};...
               'exoProjAR',         nan,        {@isnan,'||',@(x)nb_isScalarInteger(x,0)};...
               'exoProjDiff',       {},         {@iscell,'||',@isempty};...
               'exoProjDummies',    {},         {@iscellstr,'||',@isempty};...
               'exoProjHist',       false,      @nb_isScalarLogical;...
               'bounds',            [],         {@isempty,'||',@isstruct};...
               'nObj',              [],         @isnumeric;...
               'index',             [],         @isnumeric;...
               'foundReplic',       [],         {@isstruct,'||',@isempty};...
               'condAssumption',    'before',   {{@nb_ismemberi,{'','after','before'}}};...
               'condDBStart',       1,          @nb_isScalarInteger;...
               'condDBType',        'soft',     {{@nb_ismemberi,{'soft','hard'}}};...
               'kalmanFilter',      false,      @nb_isScalarLogical};
           
    if convert       
        default = nb_parseInputs(mfilename,default);
    end
    
end
