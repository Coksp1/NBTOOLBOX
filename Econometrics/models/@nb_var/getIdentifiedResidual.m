function residual = getIdentifiedResidual(obj)
% Syntax:
%
% residual = getIdentifiedResidual(obj)
%
% Description:
%
% Get identified residual from a estimated nb_var object
%
% If we have a VAR it can be written as (dropping exogenous variables):
%
% y_t = A*y_t-1 + e_t
%
% A identified VAR can be written as:
%
% y_t = A*y_t-1 + C*d_t
%
% Therefore the identified residuals/shocks can be found as:
% d_t = inv(C)*e_t
% 
% Caution: Will only return the residual that uses the full sample. I.e. 
%          when recursive estimation is done, only the residuals from the
%          last estimation will be returned.
%
% Input:
% 
% - obj : An object of class nb_var
% 
% Output:
% 
% - residual : A nb_ts object with the identified residual(s) stored.
%              As a nobs x nEq x nIdent. Where nIdent is the number of
%              identified C matrices, i.e. when the user have asked to
%              identify more than one matrix (underidentification).
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function is only supported for a single nb_var object as input'])
    else
        
        if nb_isempty(obj.results)
            error([mfilename ':: The model is not estimated'])
        end
        residual = obj.results.residual;
        
        if nb_isempty(obj.solution.identification)
            error([mfilename ':: The model is not identified'])
        end
        
        try
            C       = obj.solution.C;
            resName = obj.solution.res;
        catch %#ok<CTCH>
            error([mfilename ':: The model is not solved'])
        end
        
        % Then we convert to the identified shocks
        [T,nRes,~] = size(residual);
        C          = C(1:nRes,1:nRes,end,:);
        CT         = permute(C,[2,1,4,3]); % Transpose
        nIdent     = size(CT,3);
        res        = nan(T,nRes,nIdent);
        for ii = 1:nIdent
            res(:,:,ii) = residual(:,:,end)/CT(:,:,ii); % Same as residual(:,:,ii)*inv(CT(:,:,ii))
        end
        
        % Convert the residuals to a nb_ts object
        startInd = obj.estOptions(end).estim_start_ind;
        if isempty(startInd)
            start = obj.options.data.startDate;
        else
            start = obj.options.data.startDate + (startInd - 1);
        end
        residual = nb_ts(res, 'Identified residuals', start, resName); 
        
    end

end
