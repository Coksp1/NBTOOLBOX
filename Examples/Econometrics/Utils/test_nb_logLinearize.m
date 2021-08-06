%% Declare some variables and parameters

eqs = {
% 'x + y'  
% 'z = x + y' 
% 'x*y'
% 'z = x*y'
% 'k + x*y'
% 'z = k + x*y'
% '1 = k + x*y'
% 'exp(y+ z)'
% 'x = exp(y+ z)'
% 'y = exp(a)*k^alpha'
% 'beta*(1+r)*c/y = 1'
'beta*(1+r)*c/c_lead = 1'
};

logLinObj = nb_logLinearize(eqs,{'x','y','z','k','a','c','r'});
logLinObj = logLinearize(logLinObj)

%% Get the equations as cellstr

logLinEq  = cellstr(logLinObj)
