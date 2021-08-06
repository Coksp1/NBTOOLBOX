function obj = bkfilter(obj,low,high)
% Syntax:
%
% obj = bkfilter(obj,low,high)
%
% Description:
%
% Do band pass filtering of all the dataseries of the object. 
% (Returns the gap). Will strip nan values when calculating the 
% filter 
% 
% Input:
% 
% - obj  : An object of class nb_data
% 
% - low  : Lowest frequency. > 2
%
% - high : Highest frequency. > low
%   
% Output:
% 
% - obj : An object of class nb_data with the band pass filtered 
%         data.
% 
% Examples:
%
% obj = bkfilter(obj,8,32);
% obj = obj.bkfilter(8,32);
% 
% See also:
% bkfilter1s
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = nb_bkfilter(obj.data,low,high);  
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@bkfilter,{low,high});
        
    end

end
