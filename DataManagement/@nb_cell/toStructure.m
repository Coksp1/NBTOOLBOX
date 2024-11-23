function retStruct = toStructure(obj,old) %#ok<INUSD>
% Syntax:
%
% retStruct = toStructure(obj)
% 
% Description:
%
% Transform the obj to a structure.
% 
% Input: 
% 
% - obj     : An object of class nb_cell
%   
% - old     : Indicate if old mat file format is wanted. Default is 0 
%             (false).
% 
% Output:
% 
% - retStruct : A structure.
%                        
% See also:
% nb_cs.struct
%
% Written by Kenneth S. Paulsen                     

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        old = 0; %#ok<NASGU>
    end

    retStruct                = struct(); 
    retStruct.class          = 'nb_cell';
    retStruct.data           = obj.cdata;
    retStruct.userData       = obj.userData;
    retStruct.localVariables = obj.localVariables;
    retStruct.sorted         = obj.sorted;

end
