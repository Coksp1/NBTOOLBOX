function parameters = defaultParameters(type)
% Syntax:
%
% parameters = defaultParameters(type)
%
% Description:
%
% Get default parameters of a given distribution type.
% 
% Input:
% 
% - type       : The type of distribution.
% 
% Output:
% 
% - parameters : A cell with the default parameters.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch type  
        
        case 'ast'
            parameters = {0,1,0,1000,1000};
        
        case 'beta' 
            parameters = {2,2};
            
        case 'cauchy'     
            parameters = {2,2};  
            
        case 'chis'  
            parameters = {2};
            
        case 'constant'
            parameters = {0};
             
        case 'exp'
            parameters = {2};
            
        case 'f' 
            parameters = {10,10};
            
        case {'fgamma','gamma'}
            parameters = {2,2};
            
        case 'hist'
            parameters = {randn(100,1)};
            
        case {'invgamma','finvgamma'}
            parameters = {4,2};
            
        case {'kernel','empirical'}
            f          = 1/1000;
            parameters = {0:1/999:1,f(:,ones(1,1000))};
           
        case 'laplace'
            parameters = {0,1};    
            
        case 'logistic'
            parameters = {0,2};
            
        case 'lognormal'
            parameters = {1,1};
            
        case 'normal'
            parameters = {0,1};
            
        case 'skewedt'
            parameters = {0,1.291,0,2.5}; % Same as 't'
            
        case 't'
            parameters = {5};
              
        case 'tri'
            parameters = {0,1,0.5};
            
        case 'uniform'
            parameters = {0,1};
            
        case 'wald'
            parameters = {1,1}; 
            
    end

end
