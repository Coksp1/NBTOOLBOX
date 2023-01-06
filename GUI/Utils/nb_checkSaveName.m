function [saveName,message] = nb_checkSaveName(saveName,strict)
% Syntax:
%
% [saveName,message] = nb_checkSaveName(saveName)
%
% Description:
%
% Check if the provided save/variable name is a valid save/ variable name  
% to use in the GUI.
% 
% Input:
% 
% - saveName : A string or a cellstr.
%
% - strict   : If the save name cannot include space or dot give 
%              1. Default is to replace ' ' and '.' with '_'.
%
%              If given as 3 only ' ' will be replaced by '_'
% 
% Output:
% 
% - saveName : A string which is a valid save name to use.
%
% - message  : The error message. Empty if the save name is valid.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        strict = 0;
    end

    message = '';

    if isempty(saveName)
        message = 'The save name you provided is empty. Try another one!';
    end

    if strict == 0
        saveName = strrep(saveName,' ','_');
        saveName = strrep(saveName,'.','_');
    end
    
    s = struct();
    
    if iscellstr(saveName)
        
        wrong = {};
        for ii = 1:length(saveName)
            
            temp = saveName{ii};
            try
                s.(temp) = ''; 
            catch %#ok<CTCH>
                wrong = [wrong,temp]; %#ok<AGROW>
            end
            
        end
        
        if ~isempty(wrong)
            message = ['Invalid name(s) ''' nb_cellstr2String(wrong,', ',' and ') ''' provided. The name(s) cannot contain +,-,(,),# etc.'];
        end
        
    else
    
        try
            s.(saveName) = ''; %#ok<STRNU>
        catch %#ok<CTCH>
            message = ['Invalid name ''' saveName ''' provided. The name cannot contain +,-,(,),# etc.'];
        end
        
    end
    
end
