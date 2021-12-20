function [dist,dates,vars] = nb_estimateDensityForrecast(model,start,hor,vars)
% Syntax:
%
% [vars,dist,dates] = nb_estimateDensityForrecast(model,start,hor)
%
% Description:
%
% Estimate distribution of the density forecast at a given period (date).
% 
% Input:
% 
% - model : A scalar nb_model_generic or nb_model_group object.
%
% - start : The start date of the forecast of interest. As a string or a
%           nb_date object. Default is the last forecast data.
%
% - hor   : Max horizon of interest. Default is as many as the model has
%           forecasted.
%
% - vars  : A cellstr with variables of interest. Default is all the
%           variables that has been forecast by the model.
% 
% Output:
% 
% - dist  : A hor x nVars nb_distribution object.
%
% - dates : A hor x 1 cellstr with the dates of the forecast. 
%
% - vars  : A 1 x nVars cellstr with the variables of the forecast.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        vars = {};
        if nargin < 3
            hor = [];
            if nargin < 2
                start = '';
            end
        end
    end

    % Check inputs
    %--------------
    if not(isa(model,'nb_model_generic') || isa(model,'nb_model_group'))
        error([mfilename ':: The model input must be an object of class nb_model_generic or nb_model_group'])
    end
    if ~isscalar(model)
        error([mfilename ':: The model input must be a scalar input.'])
    end
    
    fcst = model.forecastOutput;
    if nb_isempty(fcst)
        error([mfilename ':: THe model input must have produced forecast.'])
    end
    draws  = fcst.draws;
    pDraws = fcst.parameterDraws;
    if isempty(draws)
        draws = 1;
    end
    if isempty(pDraws)
        pDraws = 1;
    end
    if draws*pDraws < 500
        error([mfilename ':: To use this method density forecast must have been produced with at least 500 draws!'])
    end
    
    if isempty(start)
        start = fcst.start{end};
        indS  = length(fcst.start);
    else
        if isa(start,'nb_date')
            start = toString(start);
        end
        fstart = fcst.start;
        indS   = find(strcmpi(start,fstart),1);
        if isempty(indS)
            error([mfilename ':: The selected date is outside the recursive forecast periods; '  fstart{1} ' - ' fstart{end}])
        end
    end

    if isempty(vars)
        vars = fcst.variables;
        locV = 1:length(vars);
    else
        fvars       = fcst.variables;
        [indV,locV] = ismember(vars,fvars);
        if any(~indV)
            error([mfilename ':: The selected model does not forecast the variables; ' toString(vars(~ind))])
        end
    end
    
    if isempty(hor)
        hor = fcst.nSteps;
    else
        if ~nb_iswholenumber(hor)
            error([mfilename ':: The hor input must be an integer.'])
        end
        if hor > fcst.nSteps
            error([mfilename ':: The hor input must be less then the number of forecasting steps produced by the model input.'])
        end
    end
    
    % Create output
    %---------------------------------
    start = nb_date.date2freq(start);
    dates = start.toDates(0:hor-1);
    if size(fcst.data,3) == fcst.draws + 1
        
        % Using simulations to estimate densities
        fcstData = fcst.data(1:hor,locV,1:end,indS);
        dist     = nb_distribution.sim2KernelDist(fcstData);
        
    else
        
        % Get the domain and density
        try
            domain  = obj.forecastOutput.evaluation(ind).int;
            density = obj.forecastOutput.evaluation(ind).density;
        catch %#ok<CTCH>
            error([mfilename ':: No density forecast has been produced. (At least no kernel estimates of the densities '...
                             'has been estimated or all the simulations of the forecast has bee stored.).'])
        end
        if ischar(domain) % If it is saved to a file
            load(domain);
            density = density(ind);
            domain  = domain(ind);
            density = density{1};
            domain  = domain{1};
        end
        density = density(locV);
        domain  = domain(indV);
        
        % Create nb_distribution objects
        dist(hor,length(vars)) = nb_dsitribution;
        for ii = 1:length(vars)        
            densityV = density{ii};
            domainV  = domain{ii};
            for jj = 1:hor
                dist(jj,ii).parameters = {domainV,densityV(jj,:)};
                dist(jj,ii).type       = 'kernel';
            end
        end
        
    end
      
end
