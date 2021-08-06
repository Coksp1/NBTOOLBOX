function estimatorCallback(gui,~,~)
% Syntax:
%
% estimatorCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    value = get(gui.pop1,'value');
    if value == 1
        enable = 'on';
        string = {'Asymmetric student-t','Beta','Chi-squared','Exponential','F','Gamma','Inverse gamma','Logistic','Lognormal','Normal','Student-t','Uniform','Wald'};
        lookUp = {'ast','beta','chis','exp','f','gamma','invgamma','logistic','lognormal','normal','t','uniform','wald'};
    elseif value == 2
        enable = 'on';
        string = {'Beta','Chi-squared','Exponential','F','Gamma','Inverse gamma','Logistic','Lognormal','Normal','Student-t','Uniform','Wald'};
        lookUp = {'beta','chis','exp','f','gamma','invgamma','logistic','lognormal','normal','t','uniform','wald'};
    else
        enable = 'off';
        string = {''};
        lookUp = {''};
    end
    set(gui.pop2,'enable',enable,'string',string,'value',1,'userData',lookUp);
    
    
end
