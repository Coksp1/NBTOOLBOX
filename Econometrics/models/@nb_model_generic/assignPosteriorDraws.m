function obj = assignPosteriorDraws(obj,varargin)
% Syntax:
%
% obj = assignPosteriorDraws(obj,varargin)
%
% Description:
%
% Assign posterior draws made outside the NB Toolbox. 
% 
% Input:
%
% Either
%
% > Two input pairs:
%
%   - 'param' : The names of the assign parameters. As a cellstr vector.
%
%   - 'value' : The values of the assign parameters. As a double nParam x
%               nReg x nDraws vector.
%
% > Optional number of input pairs:
%
%   - 'beta'   : Assign all the posterior draws of the parameters of the 
%                main equation. Must be of same size as obj.results.beta.
%                The draws must come in the third dimension.
%
%   - 'sigma'  : Assign all the posterior draws of the parameters of the 
%                covariance matrix of the main equation. Must be of same 
%                size as obj.results.sigma. The draws must come in the 
%                third dimension.
%
%   - 'lambda' : Assign all the posterior draws of the parameters of the  
%                observation equation. Must be of same size as 
%                obj.results.lambda. Only for factor models. The draws 
%                must come in the third dimension.
%
%   - 'R'      : Assign all the posterior draws of the parameters of the 
%                covariance matrix of the observation equation. Must be of  
%                same size as obj.results.R. Only for factor models. The 
%                draws must come in the third dimension.
%
%   - 'period' : When the model is recursivly estimated, you can choose
%                which period your current posterior draws are to be assign
%                to. Default is the last period. 
% 
% Output:
% 
% - obj : An object of class nb_model_generic, where the parameters of the
%         underlying model has been changed. See solve to get the solution
%         of the model with the updated parameters.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: Can only assign posterior draws to one model at the time.'])
    end
    
    if nb_isempty(obj.results)
        error([mfilename 'The model is not estimated, and therefore no posterior draws can be assign.'])
    end
    
    default = {'param',     {}, @iscell;...
               'value',     [], @isnumeric
               'beta',      [], @isnumeric;...
               'sigma',     [], @isnumeric;...
               'lambda',    [], @isnumeric;...
               'R',         [], @isnumeric;
               'period',    [], {@nb_iswholenumber,'&&',@isscalar,'&&',{@ge,1}}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    period = inputs.period;
    if isempty(period)
        period = size(obj.results.beta,3);
    else
        if period > size(obj.results.beta,3)
            error([mfilename ':: The ''period'' input is outside bound.'])
        end
    end
    
    if isempty(inputs.param)
    
        if ~isempty(inputs.beta)

            [s1,s2,~] = size(inputs.beta);
            [t1,t2,~] = size(obj.results.beta);
            if s1 ~= t1 || s2 ~= t2
                error([mfilename ':: The ''beta'' input has not the correct size. See the field beta of the result property.'])
            end

        end

        if ~isempty(inputs.sigma)

            [s1,s2,~] = size(inputs.sigma);
            [t1,t2,~] = size(obj.results.sigma);
            if s1 ~= t1 || s2 ~= t2
                error([mfilename ':: The ''sigma'' input has not the correct size. See the field sigma of the result property.'])
            end

        end

        if ~isempty(inputs.lambda)

            if ~isfield(obj.results,'lambda')
                error([mfilename ':: The model is not a factor model, so it does not have estimated parameters saved in the field '...
                                 'lambda of the results property. I.e. the coefficients of the observation equation.'])
            end
            [s1,s2,~] = size(inputs.lambda);
            [t1,t2,~] = size(obj.results.lambda);
            if s1 ~= t1 || s2 ~= t2
                error([mfilename ':: The ''lambda'' input has not the correct size. See the field lambda of the result property.'])
            end

        end

        if ~isempty(inputs.R)

            if ~isfield(obj.results,'R')
                error([mfilename ':: The model is not a factor model, so it does not have estimated parameters saved in the field '...
                                 'R of the results property. I.e. the covariance matrix of the observation equation.'])
            end
            [s1,s2,~] = size(inputs.R);
            [t1,t2,~] = size(obj.results.R);
            if s1 ~= t1 || s2 ~= t2
                error([mfilename ':: The ''R'' input has not the correct size. See the field R of the result property.'])
            end

        end
        
        % Assign to the posterior struct
        posterior = struct('betaD',  inputs.beta,...
                           'sigmaD', inputs.sigma,...
                           'lambdaD',inputs.lambda,...
                           'RD',     inputs.R,...
                           'type',   'assign');

    else % Using param and value input pair
        
        if size(inputs.value,2) > 1 && size(inputs.value,1) == 1
            inputs.value = permute(values,[2,1,3]);
        end
        
        oldParam       = obj.parameters;
        [obj,newParam] = getNewParam(obj,inputs,oldParam);
        [ind,loc]      = ismember(newParam.name,oldParam.name);
        loc            = loc(ind);
        if any(~ind)
            warning('nb_model_generic:assignParameters:notPartOfModel',...
                    [mfilename ':: The following parameter are not part of the model; ' nb_cellstr2String(newParam.name(~ind),', ',' and ')])
        end
        
        draws  = size(newParam.value,3);
        sigma  = nan(0,0,draws);
        lambda = nan(0,0,draws);
        R      = nan(0,0,draws);
        
        old = obj.results.beta(:,:,period);
        if ~isa(obj,'nb_dsge')
            old = reshape(old,[size(old,1)*size(old,2),1]);
            sig = obj.results.sigma(:,:,period);
            sig = reshape(sig,[size(sig,1)*size(sig,2),1]);
            old = [old; sig];
            if isfield(obj.results,'lambda')
                lam = obj.results.lambda(:,:,period);
                lam = reshape(lam,[size(lam,1)*size(lam,2),1]);
                old = [old; lam];
            end
            if isfield(obj.results,'R')
                R   = obj.results.R(:,:,period);
                R   = reshape(R,[size(R,1)*size(R,2),1]);
                old = [old; R];
            end
        end
        
        old   = old(:,:,ones(1,draws));
        try
            old(loc,:,:) = newParam.value(ind,:,:);
        catch %#ok<CTCH>
            error([mfilename ':: The ''value'' input does not match the ''param'' input.'])
        end
        
        if ~isa(obj,'nb_dsge') 
            [s1,s2] = size(obj.results.beta);
            sTot    = s1*s2;
            beta    = reshape(old(1:sTot,:,:),[s1,s2,draws]);
            [s1,s2] = size(obj.results.sigma);
            sStart  = sTot + 1;
            sTot    = sTot + s1*s2;
            sigma   = reshape(old(sStart:sTot,:),[s1,s2,draws]);
        else
            beta = old;
        end
        
        if isfield(obj.results,'lambda')      
            [s1,s2] = size(obj.results.lambda);
            sStart  = sTot + 1;
            sTot    = sTot + s1 + s2;
            lambda  = reshape(old(sStart:sTot,:),[s1,s2,draws]);
        end 
        
        if isfield(obj.results,'R')   
            [s1,s2] = size(obj.results.R);
            sStart  = sTot + 1;
            sTot    = sTot + s1 + s2;
            R       = reshape(old(sStart:sTot,:),[s1,s2,draws]);
        end 
        
        % Assign to the posterior struct
        posterior = struct('betaD',  beta,...
                           'sigmaD', sigma,...
                           'lambdaD',lambda,...
                           'RD',     R,...
                           'type',   'assign');
        
    end
    
    % Assign posterior draws
    if ~isfield(obj.estOptions(end),'pathToSave')
        pathToSave = nb_saveDraws(obj.name,posterior);
        [obj.estOptions.pathToSave] = deal(pathToSave);     
    else

        if isempty(obj.estOptions.pathToSave)
            pathToSave = nb_saveDraws(obj.name,posterior);
            [obj.estOptions.pathToSave] = deal(pathToSave);
        else
            posteriorT                  = nb_loadDraws(obj.estOptions(end).pathToSave);
            posteriorT(period)          = posterior;
            pathToSave                  = nb_saveDraws(obj.name,posteriorT);
            [obj.estOptions.pathToSave] = deal(pathToSave);
        end

    end
    
end

%==========================================================================
function [obj,newParam] = getNewParam(obj,inputs,oldParam)

    newParam = struct('name',{inputs.param(:)},'value',inputs.value);
    if isa(obj,'nb_dsge')
        
        if isRise(obj)
        
            if obj.estOptions.riseObject.markov_chains.regimes_number > 1 % Is MS

                regimes = obj.estOptions.riseObject.markov_chains.regimes;
                regimes = [regimes(:,1),regimes(:,3:end)];
                states  = obj.estOptions.riseObject.markov_chains.state_names(2:end);
                chaines = regimes(1,2:end);
                nChain  = length(chaines);
                numReg  = size(regimes,1) - 1;
                if size(inputs.value,2) ~= numReg

                    ind          = ismember(inputs.param,oldParam.name);
                    notMSNames   = inputs.param(ind);
                    notMSValues  = inputs.value(ind,:,:);
                    posMSNames   = inputs.param(~ind);
                    posMSValues  = inputs.value(~ind,:,:);
                    store        = struct;
                    msNames      = {}; 
                    for ss = 1:length(states)   
                        indSS              = ~cellfun(@isempty,regexp(posMSNames,['_' states{ss} '$']));
                        namesSS            = strrep(posMSNames(indSS),['_' states{ss}],'');
                        msNames            = [msNames,namesSS]; %#ok<AGROW>
                        namesSS            = struct('names',{namesSS},'values',posMSValues(indSS,:,:));
                        store.(states{ss}) = namesSS;
                    end
                    msNames  = unique(msNames);
                    msValues = nan(length(msNames),numReg,size(inputs.value,3));
                    for reg = 1:numReg
                        for ch = 1:nChain
                            temp                  = store.([chaines{ch},'_',int2str(regimes{reg+1,ch+1})]);
                            [~,indCh]             = ismember(temp.names,msNames);
                            msValues(indCh,reg,:) = temp.values;
                        end
                    end
                    value    = [notMSValues(:,ones(1,numReg),:);msValues];
                    newParam = struct('name',{[notMSNames;msNames(:)]},'value',value);

                end

            end
            
        elseif isNB(obj)
            
            % We parse out the breakpoint parameters here
            parser = obj.estOptions.parser;
            if parser.nBreaks > 0
                error([mfilename ':: To assign posterior draws to a break-point model is not yet possible.'])
%                 params   = inputs.param(:);
%                 values   = inputs.value;
%                 breaks   = parser.breakPoints;
%                 breakInd = false(size(params));
%                 for ii = 1:length(breaks)
%                     paramDate              = strcat(breaks(ii).parameters,'_',toString(breaks(ii).date)); 
%                     [ind,loc]              = ismember(paramDate,params);
%                     loc                    = loc(ind);
%                     breakInd(loc)          = true;
%                     breaks(ii).values(ind) = values(loc,:,:);
%                 end
%                 obj.estOptions.parser.breakPoints = breaks;
%                 
%                 % Remove the break points parameters and then assign the
%                 % rest later.
%                 newParam = struct('name',{params(~breakInd)},'value',values(~breakInd));
                
            end
               
        end
       
    end

end
