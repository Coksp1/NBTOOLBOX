function ret = isempty(obj)
% Syntax:
%
% ret = isempty(obj)
%
% Description:
%
% Test if an nb_table_data_source object is empty. I.e. if no data is  
% stored in the object. Return 1 if true, otherwise 0.
% 
% Input:
% 
% - obj       : An object of class nb_table_data_source
% 
% Output:
% 
% - ret       : True (1) if the series isempty, false (0) if not
% 
% Examples:
%
% ret = isempty(obj);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    ret = isempty(obj.DB);

end
