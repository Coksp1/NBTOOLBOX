function condDB = getCondDB(options,endInd,variables,description)
% Syntax:
%
% condDB = nb_manualEstimator.getData(options,endInd,variables,optionName)
%
% Description:
%
% Helper function to get conditional data on a set of variables.
% 
% Input:
% 
% - options     : A struct, see nb_manualEstimator.estimate.
%
% - endInd      : End index of history relative to start date of the data.
%                 As a scalar integer.
%
% - variables   : A 1 x nVar cellstr with the names of the variables to
%                 fetch conditional information on.
% 
% - description : A one line char with the description of the variables.
%                 Used in error messages. Default is ''.
%
% Output:
% 
% - X : A T x nVar double. The ordering of the variables is preserved.
%
% See also:
% nb_manualEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Prepare conditional information
    if isempty(variables)
        condDB = zeros(options.nFcstSteps,0);
    else
        [test,loc] = ismember(variables,options.condDBVariables);
        if any(~test)
            description = [description, ' '];
            error(['The condDB option does not contain conditional information ',...
                'on the following ' description 'variables; ' toString(variables(~test))]);
        end
        condDB = options.condDB(:,loc);
        if size(condDB,1) < options.nFcstSteps
            if strcmpi(description,'dependent')
                nExtra = options.nFcstSteps - size(condDB,1);
                condDB = [condDB; nan(nExtra,size(condDB,2),size(condDB,3))];
            else
                error(['The nFcstSteps option is greater than the number of ',...
                    'observations of the condDB option (' int2str(options.nFcstSteps),...
                    ' vs ' int2str(size(condDB,1)) ')'])
            end
        elseif size(condDB,1) > options.nFcstSteps
            condDB = condDB(1:options.nFcstSteps,:,:);
        end
        if isfield(options,'exoProj') && ~isempty(options.exoProj)
            
            isNaN = isnan(condDB);
            if any(isNaN(:))
                restr.class           = 'nb_manualModel';
                restr.X               = condDB;
                restr.Y               = nan(size(condDB,1),0);
                restr.exo             = options.condDBVariables(loc);
                restr.index           = 1;
                restr.indExo          = true(1,length(restr.exo));
                inputs                = nb_keepFields(options,{'exoProj',...
                    'exoProjHist','exoProjAR','exoProjDummies','exoProjCalib'});
                inputs.parameterDraws = 1;
                condDB                = nb_forecast.estimateAndBootstrapX(options,restr,1,endInd,inputs,'X')';
            end
        end
    end
 
end
