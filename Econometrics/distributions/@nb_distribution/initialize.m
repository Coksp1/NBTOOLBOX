function obj = initialize(varargin)
% Syntax:
%
% obj = nb_distribution.initialize(varargin)
%
% Description:
%
% Intialize a vector of nb_distribution objects with 'propertyName',
% propertyValue pairs. The propertyValue part must be a cell with same size
% for all properties set, i.e. with the same size as the number of created 
% distributions.
%
% This is a static method
% 
% Input:
% 
% - varargin : See the description of the method
% 
% Output:
% 
% - obj      : A vector of nb_distribution objects  
%
% Examples:
%
% obj = nb_distribution.initialize('type',{'normal','gamma'},...
%       'parameters',{{6,2},{2,2}});
% plot(obj,2:0.1:16,'pdf')
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen
        
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if length(varargin) < 2
        varargin = {'type',{'normal'}};
    end
    
    if rem(length(varargin),2) ~= 0
        error([mfilename ':: The optional inputs must come in pairs.'])
    end
    
    nInputs   = length(varargin);
    nobj      = length(varargin{2});
    obj(nobj) = nb_distribution(); 
    for ii = 1:nobj
        
        inputs = cell(1,nInputs);
        for jj = 1:2:nInputs
            inputs{jj} = varargin{jj};
        end
        
        try
            for jj = 2:2:nInputs
                inputs{jj} = varargin{jj}{ii};
            end
        catch  %#ok<CTCH>
            error([mfilename ':: The propertyValues given to different propertyNames does not match'])
        end
        
        set(obj(ii),inputs{:});
        
    end

end
