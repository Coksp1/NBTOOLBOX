function varargout = priorPredictiveAnalysis(obj,method,draws,rmsd,varargin)
% Syntax:
%
% varargout = priorPredictiveAnalysis(obj,method,draws,rmsd,varargin)
%
% Description:
%
% Draw from the independent prior distributions and get the prior
% predictive distribution of the object of interest.      
%
% Input:
% 
% - obj        : An object of class nb_dsge.
% 
% - method     : The method of study. A string with the name of the method. 
%                One of; 'irf','calculateMultipliers', 'simulatedMoments'  
%                or 'theoreticalMoments'.
%
% - draws      : The number of draws made from the independent priors.
%
% - rmsd       : Calculate RMSD. See more under the documentation of the
%                outputs.
%
% Optional input:
%
% - The inputs that are passed to the specified method, i.e. 
%   varargout = method(obj,varargin). See also the examples.
% 
% Output:
% 
% - The optional outputs return by the specified method, i.e. 
%   varargout = method(obj,varargin). See also the examples.
%
%   Caution: If the rmsd input is set to true all the outputs are 
%            returned as structures. One field called the 'prior' contain 
%            the prior predictive analysis when all parameters are varied. 
%            The fields that have the names of a parameter, we have kept 
%            that parameter at its mean (Be aware that some simulation may 
%            fail in this case and that the simulation in this case may be
%            lower than the draws input). The corresponding RMSD is
%            reported in in the <paramName>RMSD. This only applies to
%            output that are nb_ts, nb_data, nb_cs or a struct of the
%            already mentioned classes.
%
% Examples:
%
% [irfs,~,plotter] = priorPredictiveAnalysis(obj,'irf',1000,,false,...
%                        'shocks',{'E_X'},'variables',{'X','Y'},...)
%
% mult = priorPredictiveAnalysis(obj,'calculateMultipliers',1000,true,...
%                        'variables',{'Y','Z'},'instrument','X',...
%                        'rate','R','shocks',{'E_X'})
%
% See also:
% nb_model_generic.irf, nb_model_generic.calculateMultipliers
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
       error([mfilename ':: This method only works on a scalar object.']) 
    end
    
    % Here we supply the nb_distribution objects to the posterior as the
    % model may fail to solve for certain parameter combinations, and
    % therefore we may need to draw more
    [distr,pNames] = getPriorDistributions(obj);
    distr          = distr(:);
    betaD          = permute(random(distr,draws,1),[3,2,1]);   
    sigmaD         = nan(0,1,draws);  
    posterior      = struct('type','priorPredictive','betaD',betaD,'sigmaD',sigmaD,'distr',distr);
    
    % Set some needed options   
    obj = set(obj,'silent',true);
    obj.estOptions.estimType        = 'bayesian';
    obj.estOptions.recursive_estim  = false;
    obj.estOptions.pathToSave       = nb_saveDraws(obj.name,posterior);
    obj.estOptions.parser.object    = obj; % Needed by the nb_dsge.solveNormal method
    [t,obj.results.estimationIndex] = ismember(pNames,obj.parameters.name);
    if any(~t)
        error([mfilename ':: The following parameters are not part of the model; ' toString(pNames(~t))])
    end
    
    % Solve the model at the wanted number of points from the prior 
    % distribution
    objSim = parameterDraws(obj,draws,'posterior','object');
    solSim = mergeSolution(objSim);
    
    % Produce the prior predictive density of the object of interest
    varargout = cell(1,nargout);
    if isa(method,'function_handle')
        methodStr = func2str(method);         
    else
        methodStr = method;
        method    = str2func(method);
    end
    
    switch lower(methodStr)   
        case {'irf','calculatemultipliers'}%,'variance_decomposition'
            drawsInput = 'replic';
        case {'theoreticalmoments'}
            drawsInput = 'pDraws';
        case {'simulatedmoments'}
            drawsInput = 'parameterDraws';
        otherwise
            error([mfilename ':: Unsupported value ' metodStr ' given to the method input.'])
    end
    [varargout{1:nargout}] = method(obj,varargin{:},drawsInput,draws,'foundReplic',solSim);
    
    % Holding one and one parameter at its mean
    if rmsd
        
        % Make waitbar
        h                = nb_waitbar5([],'Calculating RMSD',true,false);
        h.maxIterations1 = length(distr);
        h.lock           = 2;
        
        % Convert to struct outputs
        out = cell(1,nargout);
        for jj = 1:nargout
            s       = struct('prior',[]);
            s.prior = varargout{jj};
            out{jj} = s;
        end
        
        for ii = 1:length(distr)
            
            % Reset the given parameter to its mean for all simulations
            h.text1 = ['Assigning mean parameter of ' pNames{ii} '...'];
            objSimT = assignParameters(objSim,'param',pNames(ii),'value',mean(distr(ii)));
            
            % Get the solutions in this case
            h.text1          = ['Solving the model while keeping ' pNames{ii} ' fixed...'];
            [objSimT,solved] = solve(objSimT,'waitbar',h);
            objSimT          = objSimT(solved);
            solSimT          = mergeSolution(objSimT);
            
            % Call the method 
            h.text1                = ['Calling the objective while keeping ' pNames{ii} ' fixed...'];
            [varargout{1:nargout}] = method(obj,varargin{:},drawsInput,length(solSimT),'foundReplic',solSimT);
            
            % Calculate RMSD and create outputs
            h.text1 = ['Calculate RMSD while keeping ' pNames{ii} ' fixed...'];
            for jj = 1:nargout
                out{jj}.(pNames{ii})          = varargout{jj};
                out{jj}.([pNames{ii} 'RMSD']) = calculateRMSD(varargout{jj},out{jj}.prior,solved);
            end
            
            % Update waitbar
            h.status1 = ii;
            
        end
        
        delete(h);
        varargout = out;
        
    end

end

%==========================================================================
function solSim = mergeSolution(objSim)

    sols   = {objSim.solution};
    solSim = [sols{:}];

end

%==========================================================================
function out = calculateRMSD(input,prior,solved)

    if isa(input,'nb_dataSource')
        out = doOneDataSource(input,prior,solved);
    elseif isstruct(input)
        
        fields = fieldnames(input);
        for ii = 1:length(fields)
            if ~isa(input.(fields{ii}),'nb_dataSource')
                out = input;
                return
            end
            out.(fields{ii}) = doOneDataSource(input.(fields{ii}),prior.(fields{ii}),solved);
        end
        
    else
        out = [];     
    end

end

%==========================================================================
function out = doOneDataSource(input,prior,solved)

    in = double(input);
    pr = double(prior);
    if size(pr,3) > 1
        pr = pr(:,:,solved);
    end
    rmsd = sqrt(mean((in - pr).^2,3));
    if isa(input,'nb_ts')
        out = nb_ts(rmsd,'RMSD',input.startDate,input.variables);
    elseif isa(input,'nb_data')
        out = nb_data(rmsd,'RMSD',input.startObs,input.variables);
    else
        out = nb_cs(rmsd,'RMSD',input.types,input.variables);
    end

end
