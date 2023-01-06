function varargout = simulatedMoments(obj,varargin)
% Syntax:
%
% [m,c]             = simulatedMoments(obj,varargin)
% [m,c,ac1]         = simulatedMoments(obj,varargin)
% [m,c,ac1,ac2]     = simulatedMoments(obj,varargin)
% [m,c,ac1,ac2,...] = simulatedMoments(obj,varargin)
%
% Description:
%
% Calculate simulated moments; I.e. mean, covariance/correlation, 
% autocovariance/autocorrelation.
% 
% Input:
% 
% - obj : An object of class nb_model_generic.
%
% Optional inputs;
%
% - 'output'      : Either 'nb_cs' or 'double'. Default is 'nb_cs'.
%
% - 'stacked'     : I the output should be stacked in one matrix or 
%                   not. true or false. Default is false.
%
% - 'nLags'       : Number of lags to compute when 'stacked' is set to 
%                   true.    
%
% - 'vars'        : A cellstr, with a subset of dependent variables
%                   of the model. If empty (default), all dependent
%                   variables are returned.
%
% - 'type'        : Either 'covariance' or 'correlation'. Default is 
%                   'correlation'.
%
% - 'draws'       : Number of simulations per parameter draw. Default is  
%                   1000. Must at least be 1.
%
% - 'pDraws'      : Number of parameter draws. Default is 1. I.e. to use the
%                   estimate parameters.
%
% - 'perc'        : Error band percentiles. As a 1 x numErrorBand double.
%                   E.g. [0.3,0.5,0.7,0.9]. Default is []. I.e. return
%                   all draws.
%
%                   Caution: 'pDraws' or 'draws' must be set to a number 
%                            > 1.
%
% - 'nSteps'      : Number of simulation steps. As a 1x1 double. Default
%                   is 100.
%
% - 'burn'        : The number of periods to remove at start of the
%                   simulations. This is to randomize the starting
%                   values of the simulation. Default is 0.
%
% - 'method'      : The selected method to create confidenc/probability 
%                   bands. Default is ''. See help on the method input of 
%                   the nb_model_generic.parameterDraws method for more 
%                   this input.
%
% - 'demean'      : true (demean simulation during estimation of the 
%                   autocovariance matrix), false (do not). Defualt is 
%                   true.
%
% - 'foundReplic' : A struct with size 1 x pDraws. Each element
%                   must be on the same format as obj.solution. I.e.
%                   each element must be the solution of the model
%                   given a set of drawn parameters. See the 
%                   parameterDraws method of the nb_model_generic class.
%
%                   Caution: You still need to set 'parameterDraws'
%                            to the number of draws you want to do.
%
% Output:
% 
% - varargout{1} : The mean, as a 1 x nVar x draws nb_cs object or double.
%
% - varargout{2} : The contemporanous covariances/correlations, as a nVar 
%                  x nVar nb_cs object or double. The variance is along 
%                  the diagonal. (Will be symmetric)
%
% - varargout{i} : i > 2. The auto-covariances/correlations, as a nVar 
%                  x nVar nb_cs object or double. Along the diagonal is the
%                  auto-covariance/correlation with the variable itself. In
%                  the upper triangular part the you can find cov(x,y(-i)),
%                  where x is the variable along the first dimension. In
%                  the lower triangular part the you can find cov(x(-i),y),
%                  where x is the variable along the first dimension.
%
%                  E.g: You have two variables x and y, then to find
%                       cov(x,y(-i)) you can use 
%                       getVariable(varargin{i},'y','x'), 
%                       while to get cov(x(-i),y) (== cov(x,y(+i))) you  
%                       can use getVariable(varargin{i},'x','y'). (This 
%                       example only works if the output is of class nb_cs)
%
% See also:
% nb_model_generic.graphCorrelation, nb_model_generic.parameterDraws
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargout < 1
        return
    end

    methods = {'bootstrap','wildBootstrap','blockBootstrap',...
               'mBlockBootstrap','rBlockBootstrap','wildBlockBootstrap',...
               'posterior',''};   
    default = {'demean',       false,           {@islogical,'&&',@isscalar};...
               'method',       '',              {@ischar,'&&',{@nb_ismemberi,methods}};...
               'nSteps',       100,             {@nb_iswholenumber,'&&',@isscalar,'&&',{@ge,1}};...
               'pDraws',       1,               {@nb_iswholenumber,'&&',@isscalar,'&&',{@ge,1}};...
               'vars',         {},              {@iscellstr,'||',@isempty};...
               'draws',        1000,            {@nb_iswholenumber,'&&',@isscalar,'&&',{@ge,1}};...
               'nLags',        1,               {@nb_iswholenumber,'&&',@isscalar,'&&',{@ge,1}};...
               'output',       'nb_cs',         {{@nb_ismemberi,{'nb_cs','double'}}};...
               'type',         'correlation',   {{@nb_ismemberi,{'correlation','covariance'}}};...
               'perc',         [],              {@isnumeric,'&&',@isrow,'||',@isempty};...
               'burn',         0,               {@nb_iswholenumber,'&&',@isscalar,'&&',{@ge,0}};...
               'stacked',      false,           {@islogical,'&&',@isscalar};...
               'foundReplic',  [],              {@isstruct,'||',@isempty}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if numel(obj) > 1
        error([mfilename ':: This method only handles scalar nb_model_generic object.'])
    end
    
    % Simulate the model
    sim = simulate(obj,inputs.nSteps,...
            'method',           inputs.method,...
            'draws',            inputs.draws,...
            'parameterDraws',   inputs.pDraws,...
            'burn',             inputs.burn,...
            'foundReplic',      inputs.foundReplic);
    field   = fieldnames(sim);
    sim     = sim.(field{1});
    sDep    = sim.variables;
    sim     = double(sim);
    if iscellstr(inputs.vars) && ~isempty(inputs.vars)
        dep = inputs.vars; 
    else
        dep = obj.dependent.name;
    end
    [~,ind] = ismember(dep,sDep);    
    sim     = sim(:,ind,:);
    
    % Calculate moments
    nDep   = length(dep);
    draws  = inputs.draws;
    pDraws = inputs.pDraws;
    if inputs.stacked
        nLags = inputs.nLags;
    else
        nLags = nargout - 2;
    end
    m      = nan(1,nDep,pDraws);
    for jj = 1:pDraws
        indDraws    = draws*(jj-1)+1:draws*jj;
        m(:,:,jj)   = mean(mean(sim(:,:,indDraws),3),1);       
    end
    
    if nLags > -1
        
        c = nan(nDep,nDep,nLags+1,pDraws);
        if strcmpi(inputs.type,'correlation')
            
            for jj = 1:pDraws
                indDraws    = draws*(jj-1)+1:draws*jj;
                c(:,:,:,jj) = mean(nb_autocorrMat(sim(:,:,indDraws),nLags,inputs.demean),4);
            end
        
        else
            
            for jj = 1:pDraws
                indDraws    = draws*(jj-1)+1:draws*jj;
                c(:,:,:,jj) = mean(nb_autocovMat(sim(:,:,indDraws),nLags,inputs.demean),4);
            end
            
        end
        
    end
    
    % Return in the wanted format
    if isempty(inputs.perc)
        if pDraws == 1
            names = {'Model'};
        else
            names = cell(1,pDraws);
            for ii = 1:pDraws
               names{ii} = ['Parameter draw ' int2str(ii)]; 
            end
        end
    else
        perc  = nb_interpretPerc(inputs.perc,false);
        nPerc = size(perc,2);
        mTemp = nan(1,nDep,nPerc);
        for ii = 1:nPerc
            mTemp(:,:,ii) = prctile(m,perc(ii),3);
        end
        m = mTemp;
        
        if nargout > 1
            cTemp = nan(nDep,nDep,nLags+1,nPerc);
            for ii = 1:nPerc
                cTemp(:,:,:,ii) = prctile(c,perc(ii),4);
            end
            c = cTemp;
        end
        
        names = cell(1,nPerc);
        for ii = 1:nPerc
           names{ii} = ['Percentile' num2str(perc(ii))]; 
        end
        
    end
    
    if inputs.stacked
        
        % Construct stacked autocorrelation matrix
        sigmaF = nb_constructStackedCorrelationMatrix(c);
        
        % Construct object
        if strcmpi(inputs.output,'nb_cs')
            if size(dep,1) > 1
                dep = dep';
            end
            autoVars     = [strcat(dep,'_lag0'),nb_cellstrlag(dep,nLags,'varFast')];
            autoVars     = strrep(autoVars,'_lag','_period');
            varargout{1} = nb_cs(sigmaF,'',autoVars,autoVars,false);
        else
            varargout{1} = sigmaF;
        end

    else
    
        varargout = cell(1,nargout);
        if strcmpi(inputs.output,'nb_cs')
            varargout{1} = nb_cs(m,'',{'Mean'},dep,false);
        else
            varargout{1} = m;
        end

        for jj = 2:nLags+2

            if strcmpi(inputs.output,'nb_cs')
                varargout{jj} = nb_cs(permute(c(:,:,jj-1,:),[1,2,4,3]),'',dep,dep,false);
            else
                varargout{jj} = permute(c(:,:,jj-1,:),[1,2,4,3]);
            end

        end

        if strcmpi(inputs.output,'nb_cs')
            for ii = 1:nargout
                varargout{ii}.dataNames = names;
            end
        end
    
    end
    
end
