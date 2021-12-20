function varargout = theoreticalMoments(obj,varargin)
% Syntax:
%
% [m,c]             = theoreticalMoments(obj,varargin)
% [m,c,ac1]         = theoreticalMoments(obj,varargin)
% [m,c,ac1,ac2]     = theoreticalMoments(obj,varargin)
% [m,c,ac1,ac2,...] = theoreticalMoments(obj,varargin)
%
% Description:
%
% Calculate theoretical moments; I.e. mean, covariance/correlation, 
% autocovariance/autocorrelation.
% 
% Caution : For recursivly estimated model only the full sample estimation
%           results is used.
%
% Caution : Only supported for models that can be solved in the following
%           way: y(t) = A*y(t-1) + B*x(t) + C*e(t).
%
% Input:
% 
% - obj : An object of class nb_model_generic.
%
% Optional inputs;
%
% - 'vars'        : Either 'dependent' or 'full'. 'dependent' will return
%                   the moment of the dependent variables of the model 
%                   without lag, while full will include all lags as well. 
%                   'dependent' is default. 
%
%                   Can also be a cellstr, with a subset of variables
%                   from 'full'.
%
% - 'maxIter'     : Maximum number of iterations to solve the lyapunov 
%                   equation. Needed to calculate the covariance matrix 
%                   of the model.
%
% - 'tol'         : The tolerance level when solving the lyapunov equation. 
%                   Needed to calculate the covariance matrix of the model.
% 
% - 'output'      : Either 'nb_cs' or 'double'. Default is 'nb_cs'.
%
% - 'stacked'     : I the output should be stacked in one matrix or 
%                   not. true or false. Default is false.
%
% - 'nLags'       : Number of lags to compute when 'stacked' is set to 
%                   true.    
%
% - 'type'        : Either 'covariance' or 'correlation'. Default is 
%                   'correlation'.
%
% - 'pDraws'      : Number of parameter draws. Default is 1. I.e. to use 
%                   the estimate parameters.
%
% - 'perc'        : Error band percentiles. As a 1 x numErrorBand double.
%                   E.g. [0.3,0.5,0.7,0.9]. Default is []. I.e. return the
%                   all draws.
%
%                   Caution: 'pDraws' must be set to a number > 1.
%
% - 'method'      : The selected method to create confidenc/probability 
%                   bands. Default is ''. See help on the method input of 
%                   the nb_model_generic.parameterDraws method for more 
%                   this input.
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
%                       getVariable(varargout{i},'y','x'), 
%                       while to get cov(x(-i),y) (== cov(x,y(+i))) you  
%                       can use getVariable(varargout{i},'x','y'). (This 
%                       example only works if the output is of class nb_cs)
%
% See also:
% nb_model_generic.graphCorrelation, nb_model_generic.parameterDraws
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargout < 1
        return
    end

    methods = {'bootstrap','wildBootstrap','blockBootstrap',...
               'mBlockBootstrap','rBlockBootstrap','wildBlockBootstrap',...
               'posterior',''};   
    default = {'tol',          eps,             @(x)nb_isScalarNumber(x,0);...
               'maxIter',      1000,            @(x)nb_isScalarInteger(x,0);...
               'method',       '',              {@ischar,'&&',{@nb_ismemberi,methods}};...
               'vars',         'dependent',     {@ischar,'&&',{@nb_ismemberi,{'dependent','full',''}},'||',@iscellstr};...
               'pDraws',       1,               @(x)nb_isScalarInteger(x,0);...
               'nLags',        1,               @(x)nb_isScalarInteger(x,0);...
               'output',       'nb_cs',         {{@nb_ismemberi,{'nb_cs','double'}}};...
               'type',         'correlation',   {{@nb_ismemberi,{'correlation','covariance'}}};...
               'perc',         [],              {@isnumeric,'&&',@isrow,'||',@isempty};...
               'stacked',      false,           @nb_isScalarLogical;....
               'foundReplic',  [],              {@isstruct,'||',@isempty}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if inputs.stacked
        if nargout > 1
            error([mfilename ':: If the stacked input is set to true, only one output can be asked for.'])
        end
    end
    
    if numel(obj) > 1
        error([mfilename ':: This method only handles scalar nb_model_generic object.'])
    end
    
    model   = obj.solution;
    options = obj.estOptions(end);
    options = nb_defaultField(options,'recursive_estim',false);
    
    if isfield(model,'G')
        error([mfilename ':: To calculate theoretical moments of this model is not yet supported. Use simulated moments instead.'])
    end
    
    try
        model.A;
    catch %#ok<CTCH>
        error([mfilename ':: The model is not solved.'])
    end
    
    % Make draws of the model if wanted
    if ~isempty(inputs.foundReplic) && inputs.pDraws > 1
        if inputs.pDraws > length(inputs.foundReplic)
            error([mfilename ':: The ''pDraws'' input cannot be greater than the length of the ''foundReplic'' input.'])
        end
        model = inputs.foundReplic;
    else
        if inputs.pDraws > 1
            if options.recursive_estim
                error([mfilename ':: Cannot produce error band for recursivly estimated models.'])
            end
            model = parameterDraws(obj,inputs.pDraws,inputs.method,'solution',true);
        end
    end
    
    if all(strcmpi(inputs.vars,'full')) || iscellstr(inputs.vars)
        dep  = obj.solution.endo;
    else
        dep  = obj.dependent.name;
    end
    nDep = length(dep);
    
    % Find the mean of the exogenous variables based on historical
    % observations
    [mX,varX,ind] = getExogenous(options,inputs,model(1).exo);    
    if inputs.stacked
        nLags = inputs.nLags;
    else
        nLags = nargout - 2;
    end

    pDraws = inputs.pDraws;
    m      = nan(1,nDep,pDraws);
    c      = nan(nDep,nDep,nLags+1,pDraws);
    for jj = 1:pDraws
    
        try
            A   = model(jj).A;
            B   = model(jj).B;
            C   = model(jj).C;
            vcv = model(jj).vcv;
        catch %#ok<CTCH>
            error([mfilename ':: Model is not solved'])
        end
        
        if isfield(model,'CE')
            C = model.CE;
        end
        
        % If we are dealing with a MS model we need to integrate over different
        % regimes
        if isfield(model(jj),'Q')
            [A,B,C] = ms.integrateOverRegime(model(jj).Q,A,B,C);
        end
        
        % Only use the full sample estimates
        if size(A,3) ~= 1 % Shocks may be excpected
            C = C(:,:,end);
        end
        A   = A(:,:,end);
        B   = B(:,:,end);
        B   = B(:,~ind);
        vcv = vcv(:,:,end);

        % Calculate the moments
        [mt,ct]     = nb_calculateMoments(A,B,C,vcv,mX,varX,nLags,inputs.type,inputs.tol,inputs.maxIter);
        m(:,:,jj)   = mt(1:nDep,:)';
        c(:,:,:,jj) = ct(1:nDep,1:nDep,:);
            
    end
    
    % Remove really small numbers
    m(abs(m)<eps^(2/3)) = 0;
    c(abs(c)<eps^(2/3)) = 0;
    
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
        m     = mTemp;
        cTemp = nan(nDep,nDep,nLags+1,nPerc);
        for ii = 1:nPerc
            cTemp(:,:,:,ii) = prctile(c,perc(ii),4);
        end
        c = cTemp;
        
        names = cell(1,nPerc);
        for ii = 1:nPerc
           names{ii} = ['Percentile' num2str(perc(ii))]; 
        end
        
    end
    
    % Reallocate stuff given the vars input.
    if iscellstr(inputs.vars)
        [test,loc] = ismember(inputs.vars,dep);
        if any(~test)
            error([mfilename ':: Some of the variables in the ''vars'' input is not part of the endogenous variables of the model; ' toString(dep(~test))])
        end
        m   = m(1,loc);
        c   = c(loc,loc,:,:);
        dep = inputs.vars;
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

%==========================================================================
function [mX,varX,ind] = getExogenous(options,inputs,exo)

    if isempty(exo)
        ind  = true(0,0);
        mX   = [];
        varX = [];
        return
    end

    ind      = nb_ismemberi(exo,{'Constant','Time-trend'});
    [~,indX] = ismember(exo(~ind),options.dataVariables);
    X        = options.data(options.estim_start_ind:options.estim_end_ind,indX);
    mX       = mean(X,1)';
    if inputs.stacked
        nLags = inputs.nLags;
    else
        nLags = nargout - 2;
    end
    
    if nLags > -1
        % Find the variance of the exogenous variables based on historical
        % observations
        varX = cov(X);
        if isempty(varX)
            varX = [];
        end
    else
        varX = [];
    end

end
