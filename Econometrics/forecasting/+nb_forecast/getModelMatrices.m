function model = getModelMatrices(model,iter,irf,options,nSteps)
% Syntax:
%
% model = nb_forecast.getModelMatrices(model,iter,irf,options,nSteps)
%
% Description:
%
% Get the model matrices of a given iterative estimation.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        irf = 0;
    end

    if strcmpi(iter,'end')
        A = model.A;
        if iscell(A)
            A = A{1};
        end
        iter = size(A,3);
    end
    
    H      = [];
    G      = [];
    R      = [];
    F      = [];
    S      = [];
    P      = [];
    RCalib = [];
    if iscell(model.A)
        A   = model.A;
        B   = model.B;
        if isfield(model,'CE') && ~irf
            C = model.CE;
        else
            C = model.C;
        end
        vcv = model.vcv;
        if ~isfield(model,'CE')
            for ii = 1:length(A)
                A{ii}   = A{ii}(:,:,iter);
                B{ii}   = B{ii}(:,:,iter);
                C{ii}   = C{ii}(:,:,iter);
                vcv{ii} = vcv{ii}(:,:,iter);
            end
        end
        if isfield(model,'Qfunc')
            Qfunc = model.Qfunc;
        else
            Qfunc = [];
        end
    else
        A = model.A(:,:,iter);
        B = model.B(:,:,iter);
        if isfield(model,'CE') && ~irf
            C = model.CE(:,:,:); % No iterated forecast with anticipation supported yet!!!!!!
        else
            C = model.C(:,:,iter);
        end
        vcv   = model.vcv(:,:,iter);
        Qfunc = [];
        
        if isfield(model,'G')
            if size(model.G,4) > 1
                
                % Here we are dealing with time-varying measurement 
                % equation!
                if options.recursive_estim
                    endHist = options.recursive_estim_start_ind - options.estim_start_ind + iter;
                else
                    endHist = options.estim_end_ind - options.estim_start_ind + 1;
                end
                
                opt                 = options;
                opt.estim_start_ind = endHist + 1;
                opt.estim_end_ind   = endHist + nSteps;
                if isfield(opt,'measurementEqRestriction') && ...
                    ~nb_isempty(opt.measurementEqRestriction)
                    
                    if strcmpi(opt.class,'nb_mfvar')
                        opt.indObservedOnly = opt.indObservedOnly(1:size(opt.frequency,2));
                        numObs              = size(opt.indObservedOnly,2);
                    else
                        if isfield(opt,'indObservedOnly')
                            numObs = sum(~opt.indObservedOnly);
                        else
                            numObs = size(model.res,2);
                        end
                    end
                    
                end
                if strcmpi(opt.class,'nb_mfvar')
                    H = nb_mlEstimator.getMeasurementEqMFVAR(opt);
                else
                    nLags   = size(model.A,2)/numObs;
                    numRows = (nLags - 1)*numObs;
                    H       = [eye(numObs),zeros(numObs,numRows)];
                end
                if isfield(opt,'measurementEqRestriction') && ...
                    ~nb_isempty(opt.measurementEqRestriction)
                
                    % Random walk assumption on restrictions!
                    HRest  = model.G(numObs+1:end,:,:,endHist);
                    HRest  = HRest(:,:,ones(1,size(H,3)));
                    if size(H,2) < size(HRest,2)
                        H = [H,zeros(size(H,1),size(HRest,2)-size(H,2),size(H,3))];
                    end
                    H = [H;HRest];
                    
                end
                G = permute(model.G(:,:,:,1:endHist),[1,2,4,3]);
                
            else
                if size(model.G,3) == 1
                    G = model.G(:,:,1);
                    H = model.G(:,:,1);
                else
                    G = model.G(:,:,iter);
                    H = model.G(:,:,iter);
                end
            end
            if isfield(model,'R')
                R = model.R(:,:,iter);
            end 
            if isfield(model,'RCalib')
                RCalib = model.RCalib(:,:,iter);
            end 
            if isfield(model,'S')
                S = model.S(:,:,iter);
            end
            if isfield(model,'F')
                F = model.F(:,:,iter);
            end
            if isfield(model,'P')
                P = model.P(:,:,iter);
            end
            if size(H,3) == 1
                H = H(:,:,ones(1,nSteps));
            end
            
        end
        
    end
    
    model.A      = A;
    model.B      = B;
    model.C      = C;
    model.vcv    = vcv;
    model.Qfunc  = Qfunc;
    model.G      = G;
    model.H      = H;
    model.R      = R;
    model.RCalib = RCalib;
    model.S      = S;
    model.F      = F;
    model.P      = P;
    
end
