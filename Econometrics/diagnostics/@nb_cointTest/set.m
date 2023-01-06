function obj = set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Set the properties of an nb_cointTest object
% 
% Input:
% 
% - obj      : An object of class nb_cointTest
% 
% - varargin : ...,'propertyName',propertyValue,...
%
% Examples:
% 
% obj.set('propertyName',propertyValue,...)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    numberOfInputs = size(varargin,2);
    if rem(numberOfInputs,2) ~= 0
        error('The optional input must come in pairs.')
    end

    ind = true(1,numberOfInputs);
    for ii = 1:2:size(varargin,2)

        propertyName  = varargin{ii};
        propertyValue = varargin{ii + 1};

        switch lower(propertyName)

            case 'data'
                
                if isa(propertyValue,'nb_ts')
                    obj.data = propertyValue;
                else
                    error([mfilename ':: The property ' propertyName ' must be set to an nb_ts object.'])
                end
                ind(ii:ii+1) = false(1,2);
                
            case 'transformation'
                
                if ischar(propertyValue)
                    obj.transformation = propertyValue;
                else
                    error([mfilename ':: The ' propertyName ''' must be given as a string.'])
                end
                ind(ii:ii+1) = false(1,2);

            case 'type'
                
                if ischar(propertyValue)
                    obj.type = propertyValue;
                else
                    error([mfilename ':: The ' propertyName ''' must be given as a string.'])
                end
                ind(ii:ii+1) = false(1,2);
                   
        end

    end

    % The rest of the optional input are given to the nb_egcoint or 
    % nb_jcoint function at a later stage
    obj.options = varargin(ind);
    
    % Recalculate the test results
    getTestResults(obj);
    
end
