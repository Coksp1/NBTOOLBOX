%--------------------------------------------------------------------------
% This is a input file to the nb_graph_ts class
%--------------------------------------------------------------------------
% Must be a cell on the format:
%   - first column  : The expression (variable) to look up
%   - second column : The english text to match the given expression
%   - third column  : The norwegian text to match the given expression
%--------------------------------------------------------------------------
obj.lookUpMatrix = {
'C_NW',             'Consumption gap',                  'Konsumgap';
'DPQ_P_NW',         'Inflation',                        'Inflasjon';
'DPQ_W_NW',         'Wage inflation',                   'Lønnsinflasjon';
'I_NW',             'Investment gap',                   'Investeringsgap';   
'K_NW',             'Capital gap',                      'Kapitalgap';
'L_NW',             'Hours worked',                     'Timeverk';
'NAT_Y_NW',         'Output gap',                       'Produksjonsgap';
'RN3M_NW',          'Money market interest rate',       'Pengemarkedsrenten';
'C_NW_LEVEL',       'Consumption',                      'Konsum';
'I_NW_LEVEL',       'Investment',                       'Investeringer';
'K_NW_LEVEL',       'Capital',                          'Kapital';
'Y_NW_LEVEL',       'Output',                           'Produksjon';
};