function ret = issolved(obj)
% Syntax:
%
% ret = issolved(obj)
%
% Description:
%
% Is the nb_model_genric object solved or not.
% 
% Input:
% 
% - obj : A nb_model_genric object (matrix)
% 
% Output:
% 
% - ret : A logical with same size as obj.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [s1,s2,s3] = size(obj);
    ret        = false(s1,s2,s3);
    for ii = 1:s1
        for jj = 1:s2
            for kk = 1:s3
                if isa(obj(ii,jj,kk),'nb_dsge') 
                    if ~isfield(obj(ii,jj,kk).solution,'type')
                        ret(ii,jj,kk) = false;
                    else
                        if strcmpi(obj(ii,jj,kk).solution.type,'nb')
                            ret(ii,jj,kk) = ~obj(ii,jj,kk).needToBeSolved;
                        else
                            ret(ii,jj,kk) = isfield(obj(ii,jj,kk).solution,'A');
                        end
                    end 
                elseif isa(obj(ii,jj,kk),'nb_exprModel')
                    ret(ii,jj,kk) = isfield(obj(ii,jj,kk).solution,'fcstHandle');
                elseif isa(obj(ii,jj,kk),'nb_rfModel') || isa(obj(ii,jj,kk),'nb_manualModel')
                    ret(ii,jj,kk) = isfield(obj(ii,jj,kk).solution,'class');
                else
                    ret(ii,jj,kk) = isfield(obj(ii,jj,kk).solution,'A');
                end
            end
        end
    end

end
