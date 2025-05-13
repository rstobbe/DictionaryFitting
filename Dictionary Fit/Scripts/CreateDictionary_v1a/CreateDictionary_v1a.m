%====================================================
% (v1a)
%    - 
%====================================================

function [SCRPTipt,SCRPTGBL,err] = CreateDictionary_v1a(SCRPTipt,SCRPTGBL)

Status('busy','Create Dictionary');
Status2('done','',2);
Status2('done','',3);

err.flag = 0;
err.msg = '';

%---------------------------------------------
% Clear Naming
%---------------------------------------------
inds = strcmp('Dictionary_Name',{SCRPTipt.labelstr});
indnum = find(inds==1);
if length(indnum) > 1
    indnum = indnum(SCRPTGBL.RWSUI.scrptnum);
end
SCRPTipt(indnum).entrystr = '';
setfunc = 1;
DispScriptParam(SCRPTipt,setfunc,SCRPTGBL.RWSUI.tab,SCRPTGBL.RWSUI.panelnum);
SCRPTipt0 = SCRPTipt;

%---------------------------------------------
% Get Panel Input
%---------------------------------------------
DATA.method = SCRPTGBL.CurrentTree.Func;
DATA.bldfunc = SCRPTGBL.CurrentTree.('CreateDictionaryfunc').Func;

%---------------------------------------------
% Initialize
%---------------------------------------------
BLDipt = SCRPTGBL.CurrentTree.('CreateDictionaryfunc');
if isfield(SCRPTGBL,('CreateDictionaryfunc_Data'))
    BLDipt.CreateDictionaryfunc_Data = SCRPTGBL.CreateDictionaryfunc_Data;
end
func = str2func(DATA.bldfunc); 
DictObj = func();
err = DictObj.InitViaCompass(BLDipt);
if err.flag
    return
end

%----------------------------------------------
% Run
%----------------------------------------------
err = DictObj.CreateDictionary;
if err.flag
    return
end
DATA.DictObj = DictObj;
DATA.name = DictObj.Name;

%--------------------------------------------
% Output to TextBox
%--------------------------------------------
DATA.ExpDisp = PanelStruct2Text(DictObj.PanelOutput);

%--------------------------------------------
% Determine if AutoSave
%--------------------------------------------
auto = 0;
RWSUI = SCRPTGBL.RWSUI;
if isfield(RWSUI,'ExtRunInfo')
    auto = 1;
    if strcmp(RWSUI.ExtRunInfo.save,'no')
        SCRPTGBL.RWSUI.SaveScript = 'no';
        SCRPTGBL.RWSUI.SaveGlobal = 'no';
    elseif strcmp(RWSUI.ExtRunInfo.save,'all')
        SCRPTGBL.RWSUI.SaveScript = 'yes';
        SCRPTGBL.RWSUI.SaveGlobal = 'yes';
    elseif strcmp(RWSUI.ExtRunInfo.save,'global')
        SCRPTGBL.RWSUI.SaveScript = 'no';
        SCRPTGBL.RWSUI.SaveGlobal = 'yes';
    end
    name = ['DATA_',RWSUI.ExtRunInfo.name];
else
    SCRPTGBL.RWSUI.SaveScriptOption = 'yes';
    SCRPTGBL.RWSUI.SaveGlobal = 'yes';
end

%--------------------------------------------
% Name
%--------------------------------------------
if auto == 0
    name = inputdlg('Name Image:','Name Data',[1 60],{DATA.name});
    name = cell2mat(name);
    if isempty(name)
        SCRPTipt = SCRPTipt0;
        setfunc = 1;
        DispScriptParam(SCRPTipt,setfunc,SCRPTGBL.RWSUI.tab,SCRPTGBL.RWSUI.panelnum);
        SCRPTGBL.RWSUI.SaveVariables = {DATA};
        SCRPTGBL.RWSUI.KeepEdit = 'yes';
        return
    end
end
DATA.name = name;
DATA.type = 'Data';   

%---------------------------------------------
% Return
%---------------------------------------------
SCRPTipt(indnum).entrystr = DATA.name;
SCRPTGBL.RWSUI.SaveVariables = DATA;
SCRPTGBL.RWSUI.SaveVariableNames = 'DATA';
SCRPTGBL.RWSUI.SaveGlobalNames = DATA.name;
SCRPTGBL.RWSUI.SaveScriptPath = 'outloc';
SCRPTGBL.RWSUI.SaveScriptName = DATA.name;

Status('done','');
Status2('done','',2);
Status2('done','',3);