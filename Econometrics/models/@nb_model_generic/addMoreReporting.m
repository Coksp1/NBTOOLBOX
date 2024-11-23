function obj = addMoreReporting(obj,repNew)
% Syntax:
%
% obj = addMoreReporting(obj,newReporting)
%
% Description:
%
% Add more reported variables to the model after estimation is done.
% 
% Input:
% 
% - obj    : A scalar nb_model_generic object.
%
% - repNew : A N x 3 cell array. For more on this input see help
%            on the reporting property.
% 
% Output:
% 
% - obj    : A scalar nb_model_generic object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~iscellstr(repNew)
        error('The repNew input must be a cellstr')
    end
    if size(repNew,2) ~= 3
        error('The repNew input must be a cellstr with 3 columns.')
    end
    repOld = obj.reporting;
    if isempty(repOld)
        repOld = cell(0,3);
    end
    repAll = [repOld;repNew];
    obj    = set(obj,'reporting',repAll);
    obj    = checkReporting(obj);

    % be careful also assign the data in the estOptions property
    newVars              = repNew(:,1)';
    newData              = double(keepVariables(obj.options.data ,newVars));
    estOpt               = obj.estOptions;
    estOpt.dataVariables = [estOpt.dataVariables, newVars];
    estOpt.data          = [estOpt.data, newData];
    obj.estOptions       = estOpt;

end
