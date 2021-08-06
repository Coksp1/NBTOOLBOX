function quarters = getQuarters(obj)
% Syntax:
% 
% quarters = getQuarters(obj)
%
% Description:
%    
% Get all the quarters of the given year as a cell of nb_quarter
% objects
% 
% Input:
% 
% - obj : An object of class nb_year
%  
% Output:
% 
% quarters : A cell array of nb_quarter objects
% 
% Examples:
%
% quarters = obj.getQuarters();
% 
% Written by Kenneth S. Paulsen
        
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    quarters = cell(1,4); 
    for ii = 1:4
        quarters{ii}           = nb_quarter(ii,obj.year);
        quarters{ii}.dayOfWeek = obj.dayOfWeek;
    end  

end
