function [evalFcst,saveToFile] = saveToFile(evalFcst,inputs)
% Syntax:
%
% [evalFcst,saveToFile] = nb_forecast.saveToFile(evalFcst,inputs)
%
% Description:
%
% Save forecast evaluation to file.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    saveToFile = true;
    density    = {evalFcst.density}; %#ok<NASGU>
    domain     = {evalFcst.int}; %#ok<NASGU>
    pathToSave = nb_userpath('gui');
    if exist(pathToSave,'dir') ~= 7
        try
            mkdir(pathToSave)
        catch %#ok<CTCH>
            error(['You are standing in a folder you do not have writing access to (' pathToSave '). Please switch user path!'])
        end
    end

    if isfield(inputs,'index')
        saveND  = ['\density_model_' int2str(inputs.index) '_' nb_clock('vintagelong')];
    else
        saveND  = ['density_' nb_clock('vintagelong')];
    end
    saveND = [pathToSave '\' saveND];
    save(saveND,'domain','density')

    % Assign output the filename (I think this is the fastest way to 
    % do it)
    nPer                  = size(evalFcst,2);
    saveND                = cellstr(saveND);
    saveND                = saveND(:,ones(1,nPer));
    [evalFcst(:).int]     = saveND{:};
    [evalFcst(:).density] = saveND{:};
    
end
