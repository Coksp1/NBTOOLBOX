function Y = undiffARIMA(options,start,Y)
% Syntax:
%
% Y = nb_forecast.undiffARIMA(options,start,Y)
%
% Description:
%
% Undiff the forecast to the original level of integration.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    Y    = [nan(1,1,size(Y,3));Y];
    var  = options.dependent{1};
    uInd = strfind(var,'_');
    if ~isempty(uInd)
        var  = var(uInd(1) + 1:end);
        for i = options.integration:-1:1

            if i == 1
                init = var;
            else
                init = ['diff' int2str(i-1) '_' var];
            end
            indI  = strcmpi(init,options.dataVariables);
            initD = options.data(start,indI);
            Y     = nb_undiff(Y,initD,1);

        end
    end
    Y = Y(2:end,:,:);

end
