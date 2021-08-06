function [test,pval] = jbTest(obj,dim,out)
% Syntax:
%
% [test,pval] = jbTest(obj)
%
% Description:
%
% Jargue-Bera test for normality. Null hypothesis of the test is that the 
% series y is normal.
% 
% Input:
% 
% - obj : An object of class nb_ts.
% 
% - dim : The dimension to test for normality. Either 1, 2 or 3. Default
%         is 1.
%
% - out : If given as 'pval' the pval output is returned as the first 
%         output, otherwise the order is the standrard way.
%           
% Output:
% 
% - test : The test statistics:
%          > dim == 1: An object of class nb_cs with size 1 x nVars x 
%                      nPage.
%          > dim == 2: An object of class nb_ts with size nObs x 1 x nPage.
%          > dim == 3: An object of class nb_ts with size nObs x nVars.
%
% - pval : The test p-value.
%          > dim == 1: An object of class nb_cs with size 1 x nVars x 
%                      nPage.
%          > dim == 2: An object of class nb_ts with size nObs x 1 x nPage.
%          > dim == 3: An object of class nb_ts with size nObs x nVars.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        out = '';
        if nargin < 2
            dim = 1;
        end
    end
    
    d = obj.data;
    if dim == 2
        d = permute(d,[2,1,3]);
    elseif dim == 3
        d = permute(d,[3,2,1]);
    end
    [test,pval] = nb_normalityTest(d,0);
    
    if dim == 2
        test = permute(test,[2,1,3]);
        pval = permute(pval,[2,1,3]);
    elseif dim == 3
        test = permute(test,[3,2,1]);
        pval = permute(pval,[3,2,1]);
    end
     
    if dim == 2
        test = nb_ts(test,obj.dataNames,obj.startDate,{'Test_statistics'});
        pval = nb_ts(pval,obj.dataNames,obj.startDate,{'P_value'});
    elseif dim == 3
        test = nb_ts(test,'Test_statistics',obj.startDate,obj.variables);
        pval = nb_ts(pval,'P_value',obj.startDate,obj.variables);
    else
        test = nb_cs(test,obj.dataNames,'Test_statistics',obj.variables);
        pval = nb_cs(pval,obj.dataNames,'P_value',obj.variables);
    end

    if obj.isUpdateable()
        
        if dim == 1
            obj2  = obj;
            obj   = obj.addOperation(@jbTest,{dim});
            links = obj.links;
            test  = test.setLinks(links);
            obj2  = obj2.addOperation(@jbTest,{dim,'pval'});
            links = obj2.links;
            pval  = pval.setLinks(links);
        else
            test  = test.addOperation(@jbTest,{dim});
            pval  = pval.addOperation(@jbTest,{dim,'pval'});
        end
        
    end
    
    if strcmpi(out,'pval')
        temp = test;
        test = pval;
        pval = temp;
    end
    
end
