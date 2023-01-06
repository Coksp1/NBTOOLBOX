function obj = cleanSolution(obj,normalize)
% Syntax:
%
% obj = cleanSolution(obj)
% obj = cleanSolution(obj,normalize)
%
% Description:
%
% Remove inactive shocks from solution.
% 
% Input:
% 
% - obj       : A scalar nb_dsge object.
% 
% - normalize : true or false. If true the shocks are normalized to 
%               be N(0,1). 
%
% Output:
% 
% - obj : A scalar nb_dsge object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin<2
        normalize = false;
    end
    
    if numel(obj) > 1
        obj = obj(:);
        for ii = 1:size(obj,1)
            obj(ii) = cleanSolution(obj(ii),normalize);
        end
        return
    end

    try
        C   = obj.solution.C;
        res = obj.solution.res;
        vcv = obj.solution.vcv;
    catch %#ok<CTCH>
        error([mfilename ':: Model is not solved.'])
    end
    
    if isNB(obj) || isRise(obj)
        if iscell(C)
            ind = any(C{1});
        else
            C   = C(:,:,1);
            ind = any(C(:,:,1));
        end
    else
        v   = diag(vcv);
        ind = v ~= 0;
    end
    if iscell(C)
        for ii = 1:length(C)
            C{ii}   = C{ii}(:,ind);
            vcv{ii} = vcv{ii}(ind,ind);   
        end
        % Already normalized!
    else
        C   = C(:,ind);
        vcv = vcv(ind,ind);
        
        % Rescale shocks to N(0,1)
        if normalize
            TS  = transpose(chol(vcv));
            C   = C*TS;
            vcv = eye(size(vcv));
        end
        
    end
    
    obj.solution.C   = C;
    obj.solution.vcv = vcv;
    obj.solution.res = res(ind);

end
