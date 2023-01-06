function [condDB,shockProps] = constructCondDB(data,exo,endo,horizon,shocks,activeShocks,shockHorizon)
% Syntax:
%
% condDB              = nb_model_generic.constructCondDB(data,exo)
% [condDB,shockProps] = nb_model_generic.constructCondDB(data,exo,endo,...
%                                 horizon,shocks,activeShocks,shockHorizon)
%
% Description:
%
% Restrict conditional information.
%
% Static method.
% 
% Input:
% 
% - data         : An nb_ts object.
%
% - exo          : The exogneous variables to condition on. As a 
%                  cellstr. Must be included as a variable of the 
%                  data input.
%
% - endo         : The endogneous variables to condition on. As a 
%                  cellstr. Must be included as a variable of the 
%                  data input.
%
% - horizon      : The number of periods to condition on the endo
%                  variables. Either as a scalar or a vector of size
%                  1 x nEndo. Default is to use the number of observations
%                  of the data input.
%
% - shocks       : The shocks to condition on. As a cellstr. Must be
%                  included as a variable of the data input.
%
% - activeShocks : A cellstr with the shocks to match your endogenous
%                  restrictions. Size 1 x nActiveShock.
%
% - shockHorizon : The number of periods to activate the given shock.
%                  Either as a scalar or a vector of size
%                  1 x nActiveShock. Be aware that you must at least have
%                  as many periods of active shocks as you have endogenous
%                  restrictions. (It may also be important which shock(s)
%                  to meet your restrictions!). 
%
%                  Caution: This option will overrun the restrictions you
%                           make with the shocks input when you call the 
%                           forecast method!
%                  
% Output:
% 
% - condDB : The restricted conditional database, which can be 
%            given as input to the forecast method.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 7
        shockHorizon = [];
        if nargin < 6
            activeShocks = {};
            if nargin < 5
                shocks = {};
                if nargin < 4
                    horizon = [];
                    if nargin < 3
                        endo = {};
                    end
                end
            end
        end
    end
    
    if isempty(horizon)
        horizon = data.numberOfObservations;
    end
    
    % Get the exogenous and shocks restrictions
    allExo = [exo,shocks];
    if isempty(allExo)
        condDB = nb_ts();
    else
        condDB = data.window('','',allExo);
    end
    
    if isempty(endo)
        return
    end
    
    % Get the endogenous restrictions
    if isscalar(horizon)
        
        shortTerm = data.startDate + (horizon - 1);
        dataEndo  = data.window('',shortTerm,endo);
        condDB    = merge(condDB,dataEndo);
        
    else
        
        numEndo = length(endo);
        if length(horizon) ~= numEndo
            error([mfilename ':: The inputs horizon and endo must have same length.'])
        end
        
        dataEndo = data.window('','',endo);
        condDB   = merge(condDB,dataEndo);
        start    = data.startDate;
        for ii = 1:numEndo
            finish  = start + (horizon(ii) - 1);
            periods = finish - start + 1;
            condDB  = setValue(condDB,endo{ii},nan(periods,1),start,finish);
        end
            
    end
    
    % Get the active shocks
    if ~isempty(activeShocks)
        
        sas = size(activeShocks,2);
        ssh = size(shockHorizon,2);
        
        if ssh == 1
            shockHorizon = shockHorizon(1,ones(1,sas));
        else
            if sas ~= ssh
                error([mfilename ':: The activeShocks and shockHorizon must have same size.'])
            end
        end
        
        shockProps(sas) = struct('Name','','Periods','');
        for ii = 1:sas
            shockProps(ii).Name    = activeShocks{ii};
            shockProps(ii).Periods = shockHorizon(ii);
        end
        
    end
    
end
