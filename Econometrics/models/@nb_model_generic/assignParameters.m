function obj = assignParameters(obj,varargin)
% Syntax:
%
% obj = assignParameters(obj,varargin)
%
% Description:
%
% Assign calibrated parameters of underlying model. 
% 
% Input:
% 
% Either:
%
% > One input:
%
%   - A struct with the fieldnames as the parameter names and the fields
%     as the parameter values.
%
% > Two input pairs:
%
%   - 'param' : The names of the assign parameters. As a cellstr vector.
%
%   - 'value' : The values of the assign parameters. As a double vector.
%
% > Optional number of input pairs:
%
%   - 'beta'   : Assign all the estimated parameters of the main equation.
%                Must be of same size as obj.results.beta.
%
%   - 'sigma'  : Assign all the estimated parameters of the covariance
%                matrix of the main equation. Must be of same size as
%                obj.results.sigma.
%
%   - 'lambda' : Assign all the estimated parameters of the observation 
%                equation. Must be of same size as obj.results.lambda. Only
%                for factor models.
%
%   - 'R'      : Assign all the estimated parameters of the covariance
%                matrix of the observation equation. Must be of same size 
%                as obj.results.R. Only for factor models.
% 
% Output:
% 
% - obj : An object of class nb_model_generic, where the parameters of the
%         underlying model has been changed. See solve to get the solution
%         of the model with the updated parameters.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        obj = nb_callMethod(obj,@assignParameters,str2func(class(obj)),varargin{:});
        return
    end
    
    if nargin == 2
        if isstruct(varargin{1})
            p        = varargin{1};
            v        = struct2cell(p);
            v        = [v{:}];
            varargin = {'param',fieldnames(p),'value',v};
        end
    end

    default = {'beta',      [], @isnumeric;...
               'sigma',     [], @isnumeric;...
               'lambda',    [], @isnumeric;...
               'R',         [], @isnumeric;...
               'param',     {}, @iscell;...
               'value',     [], @isnumeric};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if ~isfield(obj.results,'beta')
        error([mfilename ':: The model is not estimated, and no parameters can be assign.'])
    end
    
    if isempty(inputs.param)
        
        if ~isempty(inputs.beta)
            
            if size(inputs.beta) ~= size(obj.results.beta)
                error([mfilename ':: The beta input has not the same size as results.beta.'])
            else
                obj.results.beta = inputs.beta;
            end
            
        end
        
        if ~isempty(inputs.sigma)
            
            if size(inputs.sigma) ~= size(obj.results.sigma)
                error([mfilename ':: The sigma input has not the same size as results.sigma.'])
            else
                obj.results.sigma = inputs.sigma;
            end
            
        end
        
        if ~isempty(inputs.lambda)
            
            if ~isfield(obj.results,'lambda')
                error([mfilename ':: Only factor models has the option lambda.'])
            end
            if size(inputs.lambda) ~= size(obj.results.lambda)
                error([mfilename ':: The lambda input has not the same size as results.lambda.'])
            else
                obj.results.lambda = inputs.lambda;
            end
            
        end
        
        if ~isempty(inputs.R)
            
            if ~isfield(obj.results,'R')
                error([mfilename ':: Only factor models has the option R.'])
            end
            if size(inputs.R) ~= size(obj.results.R)
                error([mfilename ':: The R input has not the same size as results.R.'])
            else
                obj.results.R = inputs.R;
            end
            
        end
        
    else
        
        oldParam       = obj.parameters;
        [obj,newParam] = getNewParam(obj,inputs,oldParam);
        [ind,loc]      = ismember(newParam.name,oldParam.name);
        loc            = loc(ind);
        if any(~ind)
            warning('nb_model_generic:assignParameters:notPartOfModel',...
                    [mfilename ':: The following parameter are not part of the model; ' nb_cellstr2String(newParam.name(~ind),', ',' and ')])
        end
        
        old = obj.results.beta;
        if ~isa(obj,'nb_dsge')
            old = reshape(old,[size(old,1)*size(old,2),size(old,3)]);
            sig = obj.results.sigma;
            sig = reshape(sig,[size(sig,1)*size(sig,2),size(sig,3)]);
            old = [old; sig];
            if isfield(obj.results,'lambda')
                lam = obj.results.lambda;
                lam = reshape(lam,[size(lam,1)*size(lam,2),size(lam,3)]);
                old = [old; lam];
            end
            if isfield(obj.results,'R')
                R   = obj.results.R;
                R   = reshape(R,[size(R,1)*size(R,2),size(R,3)]);
                old = [old; R];
            end
        end
        
        try
            old(loc,:) = newParam.value(ind,:);
        catch %#ok<CTCH>
            if size(old,3) ~= size(newParam.value,3)
                error([mfilename ':: The ''value'' input must have dimension 3 equal to ' int2str(size(old,3)) ...
                                 ', but is ' int2str(size(newParam.value,3)) '.'])
            else
                error([mfilename ':: The ''value'' input does not match the ''param'' input.'])
            end
        end
        
        if ~isa(obj,'nb_dsge') 
            [s1,s2,s3]        = size(obj.results.beta);
            sTot              = s1*s2;
            obj.results.beta  = reshape(old(1:sTot,:),[s1,s2,s3]);
            [s1,s2,s3]        = size(obj.results.sigma);
            sStart            = sTot + 1;
            sTot              = sTot + s1*s2;
            obj.results.sigma = reshape(old(sStart:sTot,:),[s1,s2,s3]);
        else
            obj.results.beta  = old;
        end
        
        if isfield(obj.results,'lambda')      
            [s1,s2,s3]         = size(obj.results.lambda);
            sStart             = sTot + 1;
            sTot               = sTot + s1 + s2;
            obj.results.lambda = reshape(old(sStart:sTot,:),[s1,s2,s3]);
        end 
        
        if isfield(obj.results,'R')   
            [s1,s2,s3]    = size(obj.results.R);
            sStart        = sTot + 1;
            sTot          = sTot + s1 + s2;
            obj.results.R = reshape(old(sStart:sTot,:),[s1,s2,s3]);
        end 
        
    end
    
    if isa(obj,'nb_dsge')
        obj = indicateResolve(obj);
    end
    
end

%==========================================================================
function [obj,newParam] = getNewParam(obj,inputs,oldParam)

    
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
                    notMSValues  = inputs.value(ind);
                    posMSNames   = inputs.param(~ind);
                    posMSValues  = inputs.value(~ind);
                    store        = struct;
                    msNames      = {}; 
                    for ss = 1:length(states)   
                        indSS              = ~cellfun(@isempty,regexp(posMSNames,['_' states{ss} '$']));
                        namesSS            = strrep(posMSNames(indSS),['_' states{ss}],'');
                        msNames            = [msNames,namesSS]; %#ok<AGROW>
                        namesSS            = struct('names',{namesSS},'values',posMSValues(indSS));
                        store.(states{ss}) = namesSS;
                    end
                    msNames  = unique(msNames);
                    msValues = nan(length(msNames),numReg);
                    for reg = 1:numReg
                        for ch = 1:nChain
                            temp                = store.([chaines{ch},'_',int2str(regimes{reg+1,ch+1})]);
                            [~,indCh]           = ismember(temp.names,msNames);
                            msValues(indCh,reg) = temp.values;
                        end
                    end
                    value    = [notMSValues(:,ones(1,numReg));msValues];
                    newParam = struct('name',{[notMSNames;msNames(:)]},'value',value);

                end
                
            else
                newParam = struct('name',{inputs.param(:)},'value',inputs.value(:));
            end
            
        elseif isNB(obj)
            
            % We parse out the breakpoint parameters here
            parser = obj.estOptions.parser;
            if parser.nBreaks > 0
            
                params   = inputs.param(:);
                values   = inputs.value(:);
                breaks   = parser.breakPoints;
                breakInd = false(size(params));
                for ii = 1:length(breaks)
                    paramDate              = strcat(breaks(ii).parameters,'_',toString(breaks(ii).date)); 
                    [ind,loc]              = ismember(paramDate,params);
                    loc                    = loc(ind);
                    breakInd(loc)          = true;
                    breaks(ii).values(ind) = values(loc);
                end
                obj.estOptions.parser.breakPoints = breaks;
                
                % Remove the break points parameters and then assign the
                % rest later.
                newParam = struct('name',{params(~breakInd)},'value',values(~breakInd));
                
            else
                newParam = struct('name',{inputs.param(:)},'value',inputs.value(:));
            end
            
        else
            newParam = struct('name',{inputs.param(:)},'value',inputs.value(:));
        end
        
    else % Not a DSGE model
        [s1,s2,s3]   = size(inputs.value);
        inputs.value = reshape(inputs.value,[s1*s2,s3,1]); 
        newParam     = struct('name',{inputs.param(:)},'value',inputs.value);
    end

end
