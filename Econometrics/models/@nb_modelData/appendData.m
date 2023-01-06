function obj = appendData(obj,DB,interpolateDate,method,rename,append,type)
% Syntax:
%
% obj = appendData(obj,DB)
%
% Description:
%
% Append more data to existing data stored in the nb_model_generic object.
%
% Caution : If append == 1 (true) then the DB input has precedence over 
%           the existing dat of the object.
% 
% Input:
% 
% - obj : An object of class nb_model_generic
%
% - DB  : An object of class nb_ts or nb_cs
%
% Optional input:
% 
% - interpolateDate : See nb_ts.merge for more help on this input.
% 
% - method          : See nb_ts.merge for more help on this input.
% 
% - rename          : See nb_ts.merge for more help on this input.
%
% - append          : See nb_ts.merge for more help on this input.
%
% - type            : See nb_ts.merge for more help on this input.
%
% Output:
% 
% - obj : An object of class nb_model_generic
%
% See also:
% nb_ts, nb_cs, nb_ts.merge
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 7
        type = '';
        if nargin < 6
            append = 0;
            if nargin < 5
                rename = 'on';
                if nargin < 4
                    method = 'none';
                    if nargin < 3
                        interpolateDate = 'start';
                    end
                end
            end
        end
    end

    if isa(obj.options.data,'nb_ts')
        obj.dataOrig = merge(DB,obj.dataOrig,interpolateDate,method,rename,append,type);
    else
        obj.dataOrig = merge(DB,obj.dataOrig);
    end

end
