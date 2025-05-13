%=========================================================
% 
%=========================================================

function [default] = CreateDictionary_v1a_Default2(SCRPTPATHS)

func = 'CreateDictionary_SteadyStateT1_v1a';

m = 1;
default{m,1}.entrytype = 'OutputName';
default{m,1}.labelstr = 'Dictionary_Name';
default{m,1}.entrystr = '';

m = m+1;
default{m,1}.entrytype = 'ScriptName';
default{m,1}.labelstr = 'Script_Name';
default{m,1}.entrystr = '';

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'CreateDictionaryfunc';
default{m,1}.entrystr = func;
default{m,1}.searchpath = [];
default{m,1}.path = [];

m = m+1;
default{m,1}.entrytype = 'RunScrptFunc';
default{m,1}.scrpttype = 'Proc';
default{m,1}.labelstr = 'CreateDictionary';
default{m,1}.entrystr = '';
default{m,1}.buttonname = 'Run';

