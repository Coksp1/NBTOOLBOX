function [A,B,C,vcv,Qfunc] = getModelMatrices(model,iter,irf)
% Syntax:
%
% [A,B,C,vcv,Qfunc] = nb_forecast.getModelMatrices(model,iter,irf)
%
% Description:
%
% Get the model matrices of a given iterative estimation.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
    end
    
end
