function plotter = plotForecastDensity(obj,date,variable)
% Syntax:
%
% plotter = plotForecastDensity(obj,date,variable)
%
% Description:
%
% Plot the density forecast at a given date for a given variable. It will
% be compared to the normal distribution with the same mean and std.
% 
% Caution : If the model produce nowcast this nowcast will start before the
%           provided date. See the dataNames property of the DB
%           property of the returned plotter object. If the model has 
%           produced nowcast the names will 'horizon0' (a variable lag one 
%           period), 'horizon-1' (a variable lag two periods), etc.
%
% Input:
% 
% - obj      : A 1x1 nb_model_forecast object.
%
% - date     : A string or nb_date object with the date of the wanted
%              forecast.
%
% - variable : A string with the variable of interest.
%
% Output:
% 
% plotter = A nb_graph_data object. Use the graph method to produce the
%           figure, or the nb_graphPagesGUI class.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(date,'nb_date')
        date = toString(date);
    end

    if numel(obj) > 1
        error([mfilename ':: This function is only supported for a single nb_model_forecast as input'])
    else

        if nb_isempty(obj.forecastOutput)
            error([mfilename ':: Noe forecast of this model is produced'])
        end
        start = obj.forecastOutput.start;
        ind   = find(strcmpi(date,start),1);
        if isempty(ind)
            error([mfilename ':: The selected date is outside the recursive forecast periods.'])
        end
        
        vars = obj.forecastOutput.variables;
        indV = find(strcmpi(variable,vars),1);
        if isempty(indV)
            error([mfilename ':: The selected model does not forecast the variable ' variable])
        end
            
        % Get the domain and density
        try
            domain  = obj.forecastOutput.evaluation(ind).int;
            density = obj.forecastOutput.evaluation(ind).density;
        catch %#ok<CTCH>
            error([mfilename ':: No density forecast has been produced, or at least no kernel estimates of the densities has been estimated.'])
        end
        
        nowcast = false;
        if isfield(obj.forecastOutput,'nowcast')
            nowcast = obj.forecastOutput.nowcast;
        end
        if nowcast
            nMiss     = sum(obj.forecastOutput.missing(:,indV));
            nStepsInd = obj.forecastOutput.nowcast - nMiss + 1;
            horNames  = nb_appendIndexes('Horizon',1-nMiss:obj.forecastOutput.nSteps)';
        else
            nStepsInd = 1;
            horNames  = nb_appendIndexes('Horizon',1:obj.forecastOutput.nSteps)';
        end
        
        if ischar(domain) % If it is saved to a file
            loaded  = load(domain);
            density = loaded.density{ind};
            domain  = loaded.domain{ind};
        end
        density = density{indV};
        density = permute(density(nStepsInd:end,:),[2,3,1]);
        domain  = domain{indV};
        nSteps  = size(density,3);
        if size(domain,1) == 1 % Old version
            domain = domain(ones(1,nSteps),:);
        else
            domain = domain(nStepsInd:end,:);
        end
        domain = permute(domain,[2,3,1]);
        
        % Get the normal distribution with same mean and std
        normDensity = nan(size(density));
        for ii = 1:nSteps
            draws               = nb_distribution.kernel_rand(1000,1,domain(:,:,ii),density(:,:,ii));
            mDist               = mean(draws,1);
            stdDist             = std(draws,0,1);
            normDensity(:,:,ii) = nb_distribution.normal_pdf(domain(:,:,ii),mDist,stdDist);
        end
        
        % Make graph
        normName = ['N(' num2str(mDist) ',' num2str(stdDist) ')'];
        data     = nb_data([domain,density,normDensity],horNames,1,{'domain',variable,normName});
        plotter  = nb_graph_data(data);
        plotter.set('variablesToPlot',{variable,normName},...
                    'variableToPlotX', 'domain');
        
    end
    
end
