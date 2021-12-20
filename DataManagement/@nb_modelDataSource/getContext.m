function dataTS = getContext(obj,context)
% Syntax:
%
% dataTS = getContext(obj,context)
%
% Description:
%
% Get a spesific context of the object as a nb_ts object.
% 
% Input:
% 
% - obj     : An object of class nb_modelDataSource.
%
% - context : A one line char on the format 'yyyymmdd' or a nb_day object.
% 
% Output:
% 
% - dataTS : An object of class nb_ts.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(context)
        indPage = obj.data.numberOfDatasets;
    elseif nb_isScalarInteger(context)
        indPage = context;
    else
        if ischar(context)
            context = nb_day(context);
        elseif ~isa(context,'nb_day')
            error([mfilename ':: The context input is not correct.'])
        end
        context     = str2double(nb_date.format2string(context,'yyyymmdd'));
        vintageDays = nb_convertContexts(obj.data.dataNames);
        indPage     = find(vintageDays <= context,1,'last');
        if isempty(indPage)
            indPage = 1;
        end
    end
    dataTS = keepPages(obj.data,indPage);
    if hasConditionalInfo(obj)
        if ~isempty(dataTS.userData)
            dataTS.userData = dataTS.userData(indPage,:);
        end
    end

end
