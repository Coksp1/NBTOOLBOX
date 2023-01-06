function [JPB,plotter] = jointPredictionBands(obj,varargin)
% Syntax:
%
% [bands,plotter] = jointPredictionBands(obj,varargin)
%
% Description:
%
% Calculate joint predication bands.
% 
% Input:
% 
% obj : An scalar nb_model_generic object
%
% Optional inputs:
%
% - 'vars'   : A cellstr with the variables to return 
%              the calculated joint prediction bands of. 
%
% - 'perc'   : Error band percentiles. As a 1 x numErrorBand 
%              double. E.g. [0.3,0.5,0.7,0.9] (default) or 
%              0.9. Cannot be empty!
%
% - 'date'   : If recursive forecast has been produced,  
%              you can use this option to choose which of 
%              the recursive forecast to construct the 
%              joint prediction bands of. Default is empty, 
%              i.e. use the last forecast.
%
% - 'method' : Choose between: 
%
%              > 'kolsrud' : See Akram et al (2016), Joint 
%                            prediction bands for 
%                            macroeconomic risk management
%
%              > 'copula'  : Using a copula likelihood approach.
%
%              > 'mostlik' : Group the paths based on how 
%                            likely they are.
%
% - 'nSteps' : Number of forecasting steps to use when constructing the
%              error bands. If empty (default) all forecasting steps stored
%              in the object is used.
%
% Output:
% 
% - JPB     : An nb_ts object storing the joint prediction bands. 
%             The percentiles are stored as datasets. See the 
%             dataNames property for which page represent which 
%             percentile.
%
%             The data of the nb_ts object has size nSteps x nVars
%             x nPerc.
%
% - plotter : A nb_graph_ts object. Use the graphSubPlots method
%             to produce the graphs.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    default = {'perc',           [0.3,0.5,0.7,0.9],  {@isnumeric,'&&',@(x)not(isempty(x))};...
               'vars',           {},                 {@iscellstr,'||',@isempty};...
               'method',         'kolsrud',          {{@nb_ismemberi,{'kolsrud','mostlik','copula'}}};...
               'nSteps',         [],                 {@nb_iswholenumber,'||',@isempty};...
               'date',           '',                 {@ischar,'&&',@isrow,'||',@(x)isa(x,'nb_date'),'||',@isempty}};
           
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end

    % Transform percentiles to upper and lower bounds
    perc = inputs.perc(:);
    if any(perc == 0 | perc > 1)
        error([mfilename ':: The ''perc'' input must in the interval (0,1]'])
    end
    perc   = sort(perc);
    low    = flipud(abs(perc/2 - 0.5));
    up     = perc/2 + 0.5;
    percUL = unique([low;up])*100;
    
    % Get the density forecast
    forecastOutput = obj.forecastOutput;   
    assert(forecastOutput.draws > 1, 'No density forecast produced.');
    assert(isempty(forecastOutput.perc), 'All simulations were not returned.');
    
    startDate = inputs.date;
    if isempty(startDate)
        fcst      = forecastOutput.data(:, :, 1:end-1, end); % nSteps x nvar x ndraws
        startDate = forecastOutput.start{end};
        ind       = length(forecastOutput.start);
    else
        ind = strcmpi(toString(startDate),forecastOutput.start);
        if ~any(ind)
            error([mfilename ':: The ''date'' input provided is not found in forecastOutput.start'])
        end
        fcst = forecastOutput.data(:, :, 1:end-1, ind); % nSteps x nvar x ndraws
    end
    variables     = forecastOutput.variables; 
    exo           = obj.solution.res;
    [test,indExo] = ismember(exo,variables);
    if any(~test)
        error([mfilename ':: When producing the forecast you need to return the residuals/shocks. '...
                         'See the option ''output'' of the forecast method.'])
    end
    
    if ~isempty(inputs.nSteps)
        try
            fcst = fcst(1:inputs.nSteps,:,:);
        catch %#ok<CTCH>
            error([mfilename ':: The ''nSteps'' input is outside bounds.'])
        end
    end
    
    % Check that the shocks of the model are uncorrelated with 
    % variance 1
    vcv = obj.solution.vcv - eye(size(obj.solution.vcv,1));
    if any(vcv(:)~=0)
        error([mfilename ':: The shocks of the model must be uncorrelated and have unit variance.'])
    end
    
    switch lower(inputs.method)
        
        case 'kolsrud'
            
            vars        = inputs.vars;
            [test,indV] = ismember(vars,variables); 
            if any(~test)
                error([mfilename ':: The variables ' toString(vars(~ind)) ' is not part of the model.'])
            end
            fcst = fcst(:,indV,:);
            JPB  = nb_kolsrudJointPredictionBands(fcst,percUL);
            
        case 'copula'
            
            % Get the simulated paths
            vars        = inputs.vars;
            [test,indV] = ismember(vars,variables); 
            if any(~test)
                error([mfilename ':: The variables ' toString(vars(~ind)) ' is not part of the model.'])
            end
            fcst = fcst(:,indV,:);
            
            [nSteps,nVars,nDraws] = size(fcst);
            
            % Get the correlation matrix
            [sigmaObj,retcode] = nb_selectConditionalDistributionsGUI.constructSigma(obj,size(fcst,1),0,vars,'theoretical');
            if retcode
                return
            end
            sigma  = sigmaObj.data;
            
            % Get the kernel density estimation of each variable
            % at each horizon
            distY  = nb_distribution.sim2KernelDist(fcst); % nSteps x nvar nb_distribution object
            distY  = distY';                               % nvar x nSteps nb_distribution object
            distY  = distY(:);                             % nvar*nSteps x 1 nb_distribution object
            copula = nb_copula(distY','sigma',sigma);
            
            % Calculate the probability of each simulation, and
            % sort
            fcstT = permute(fcst,[3,2,1]);             % nDraws x nvar x nSteps
            fcstT = reshape(fcstT,nDraws,nVars*nSteps); % nDraws x nvar*nSteps
            p     = pdf(copula,fcstT,'log');      
            [~,i] = sort(p);

            % Find the bounds
            JPB = findBounds(fcst,percUL,i);
            
        case 'mostlik'
            
            % Get the probability of each path
            data                 = fcst(:,indExo,:);
            [nSteps,nExo,nDraws] = size(data);
            data  = reshape(data,nSteps*nExo,nDraws);     % ndraws x nvar*nSteps 
            p     = nb_distribution.normal_pdf(data,0,1); % Probability of each observation
            p     = prod(p,1);                            % Total probability of mulitvariate path
            p     = p(:);
            [~,i] = sort(p);

            % Find the bounds
            vars     = inputs.vars;
            [~,indV] = ismember(vars,variables); 
            fcst     = fcst(:,indV,:);
            JPB      = findBounds(fcst,percUL,i);
            
    end
    
    % Construct outputs
    names         = strtrim(cellstr(num2str(percUL)));
    names         = strcat('Percentiles',names);
    JPB           = nb_ts(JPB,'',startDate,vars,false);
    JPB           = window(JPB,'','',inputs.vars);
    JPB.dataNames = names;

    % Construct graph
    if nargout > 1
       
        fcst     = obj.forecastOutput.data(:,indV,end,ind); % Mean fcst
        fcst     = permute(fcst,[1,2,3]);
        fcstData = nb_ts(fcst,'Mean',startDate,vars);
        histData = getHistory(obj,vars,startDate);
        histData = window(histData,'',fcstData.startDate-1);
        data     = merge(histData,fcstData);
        JPB      = merge(window(histData,fcstData.startDate-1),JPB);
        plotter  = nb_graph_ts(data);
        plotter.set('dashedLine',startDate,'fanDatasets',JPB,'fanPercentiles',inputs.perc)
        
    end
    
end

function JPB = findBounds(fcst,percUL,i)

    [nSteps,nVars,nDraws] = size(fcst);

    % Find the bounds
    nPerc   = size(percUL,1);
    percInd = ceil(percUL*nDraws/100);
    low     = percInd(1:nPerc/2);
    up      = flipud(percInd(nPerc/2+1:end));
    JPBU    = nan(nSteps,nVars,nPerc/2);
    JPBL    = nan(nSteps,nVars,nPerc/2);
    JPB     = nan(nSteps,nVars,nPerc);
    for ii = 1:nPerc/2   
        succes             = i(low(ii):up(ii));
        sData              = fcst(:,:,succes);
        JPBU(:,:,end-ii+1) = max(sData,[],3);
        JPBL(:,:,ii)       = min(sData,[],3);
    end
    JPB(:,:,1:nPerc/2)     = JPBL;
    JPB(:,:,nPerc/2+1:end) = JPBU;

end
