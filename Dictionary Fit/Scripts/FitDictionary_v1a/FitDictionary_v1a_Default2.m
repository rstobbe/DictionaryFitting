%=========================================================
% 
%=========================================================

function [default] = FitDictionary_v1a_Default2(SCRPTPATHS)

loadfunc = 'Im1LoadGeneric_v1c';
fitfunc = 'FitDictionary_SteadyStateT1_v1a';

m = 1;
default{m,1}.entrytype = 'OutputName';
default{m,1}.labelstr = 'Image_Name';
default{m,1}.entrystr = '';

m = m+1;
default{m,1}.entrytype = 'ScriptName';
default{m,1}.labelstr = 'Script_Name';
default{m,1}.entrystr = '';

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'ImLoadfunc';
default{m,1}.entrystr = loadfunc;
default{m,1}.searchpath = [];
default{m,1}.path = [];

m = m+1;
default{m,1}.entrytype = 'ScrptFunc';
default{m,1}.labelstr = 'FitDictionaryfunc';
default{m,1}.entrystr = fitfunc;
default{m,1}.searchpath = [];
default{m,1}.path = [];

m = m+1;
default{m,1}.entrytype = 'RunScrptFunc';
default{m,1}.scrpttype = 'Proc';
default{m,1}.labelstr = 'FitDictionary';
default{m,1}.entrystr = '';
default{m,1}.buttonname = 'Run';

