function obj = in(obj,objIn)
% Syntax:
%
% obj = in(obj,objIn)
%
% Description:
%
% Check if the value represented by obj can be found in objIn.
%
% Caution: If you try to check if a number is part og cellstr array, or
%          a char is part of a numerical (or logical) it will not give an
%          error. Instead a nb_macro object representing false will be
%          returned.
%
% Input:
% 
% - obj   : A nb_macro object.
%
% - objIn : A nb_macro object.
% 
% Output:
% 
% - obj   : A nb_macro object representing true or false.
%
% Examples:
%
% mString  = nb_macro('var1','C');
% mString2 = nb_macro('var2','ABC');
% mLogical = mString.in(mString2)
%
% mString  = nb_macro('var1','C');
% mArray   = nb_macro('array1',{'C','D','E'});
% mLogical = mString.in(mArray) 
%
% mNum     = nb_macro('var1',2);
% mArray   = nb_macro('array1',[1,3,5]);
% mLogical = mNum.in(mArray) 
%
% mNum     = nb_macro('var1',2);
% mNum2    = nb_macro('var2',1);
% mLogical = mNum.in(mNum2) 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error('The in method is only supported for scalar nb_macro objects.')
    end
    if numel(objIn) > 1
        error('The in method is only supported for scalar nb_macro objects.')
    end
    
    % Get info from the inputs.
    [obj,name1,name2,value1,value2] = getInfo(obj,objIn);
    
    % Do the calculations
    if ischar(value1)
        
        if iscellstr(value2) || ischar(value2)
            val = ismember(value1,value2); 
        else
            val = false;
        end
        
    elseif nb_isScalarNumber(value1)
        
        if isnumeric(value2) || islogical(value2)
            val = any(value1 == value2);
        else
            val = false;
        end
        
    else
        val = false;
    end
    
    % Assign value
    obj.value = val;

    % Update the name
    obj.name  = [name1,' in ',name2];
      
end
