%==================================================================
% (V1a)
%   
%==================================================================

classdef FitDictionary_SteadyStateT1_v1a < handle

properties (SetAccess = private)                   
    DictObj
    B1Map
    Name 
    Panel = cell(0);
    PanelOutput
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = FitDictionary_SteadyStateT1_v1a()              
end

%==================================================================
% BuildTruth
%==================================================================  
function err = FitDictionary(obj,IMG0)     
    err.flag = 0;  
    ImSize = size(IMG0{1}.ImRam);
    ImArray = zeros([ImSize length(IMG0)]);
    ImNum = length(IMG0);
    for n = 1:ImNum
        ImArray(:,:,:,n) = abs(IMG0{n}.ImRam);
    end

    ImArrayMean = mean(ImArray,4);
    ImArrayNorm = ImArray./repmat(ImArrayMean,1,1,1,ImNum) + obj.DictObj.RelB1AddScale*repmat(obj.B1Map.Im,1,1,1,ImNum);
    ImArrayNorm = gpuArray(ImArrayNorm);
    ImArrayNorm = reshape(ImArrayNorm,ImSize(1)^3,ImNum);

    % [ind,Dist] = knnsearch(DictArrayNorm,ImArrayNorm,'Distance','euclidean','K',1,'NSMethod','Exhaustive');
    [ind,Dist] = knnsearch(obj.DictObj.DictArray,ImArrayNorm);

    T1Map = obj.DictObj.T1Array(ind);
    T1Map = reshape(T1Map,ImSize);

    RelB1Map = obj.DictObj.RelB1Array(ind);
    RelB1Map = reshape(RelB1Map,ImSize);

    Dist = reshape(Dist,ImSize);

    obj.Name = 'DictSST1';
    obj.Panel(1,:) = {'','','Output'};
    obj.Panel(2,:) = {'Method',class(obj),'Output'};
    obj.Panel(3,:) = {'TR',obj.TR,'Output'};
    obj.Panel(4,:) = {'FlipArray',obj.FlipArray,'Output'};
    obj.PanelOutput = cell2struct(obj.Panel,{'label','value','type'},2);
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,CompassInput)    
    CallingLabel = CompassInput.Struct.labelstr;
    DictionaryPresent = 0;
    B1MapPresent = 0;
    if isfield(CompassInput,[CallingLabel,'_Data'])
        if isfield(CompassInput.([CallingLabel,'_Data']),'Dictionary_File_Data')
            DictionaryPresent = 1;
        end
        if isfield(CompassInput.([CallingLabel,'_Data']),'B1Map_File_Data')
            B1MapPresent = 1;
        end
    end
    if DictionaryPresent == 0
        if isfield(CompassInput.('Dictionary_File').Struct,'selectedfile')
            file = CompassInput.('Dictionary_File').Struct.selectedfile;
            if not(exist(file,'file'))
                err.flag = 1;
                err.msg = '(Re) Load Dictionary_File';
                ErrDisp(err);
                return
            else
                load(file);
                CompassInput.([CallingLabel,'_Data']).('Dictionary_File_Data') = saveData;
            end
        else
            err.flag = 1;
            err.msg = '(Re) Load Dictionary_File';
            ErrDisp(err);
            return
        end
    end
    obj.DictObj = CompassInput.([CallingLabel,'_Data']).('Dictionary_File_Data').DATA.DictObj;
    if B1MapPresent == 0
        if isfield(CompassInput.('B1Map_File').Struct,'selectedfile')
            file = CompassInput.('B1Map_File').Struct.selectedfile;
            if not(exist(file,'file'))
                err.flag = 1;
                err.msg = '(Re) Load B1Map_File';
                ErrDisp(err);
                return
            else
                load(file);
                CompassInput.([CallingLabel,'_Data']).('B1Map_File_Data') = saveData;
            end
        else
            err.flag = 1;
            err.msg = '(Re) Load B1Map_File';
            ErrDisp(err);
            return
        end
    end
    obj.B1Map = CompassInput.([CallingLabel,'_Data']).('B1Map_File_Data').IMG;
end

%==================================================================
% CompassInterface
%==================================================================  
function [Interface] = CompassInterface(obj,SCRPTPATHS)    
    global COMPASSINFO
    m = 1;
    Interface{m, 1}.entrytype = 'RunExtFunc';
    Interface{m,1}.labelstr = 'Dictionary_File';
    Interface{m,1}.entrystr = '';
    Interface{m,1}.buttonname = 'Load';
    Interface{m,1}.runfunc1 = 'LoadScriptFileCur';
    Interface{m,1}.(Interface{m,1}.runfunc1).curloc = SCRPTPATHS.outloc;
    Interface{m,1}.runfunc2 = 'LoadScriptFileDef';
    Interface{m,1}.(Interface{m,1}.runfunc2).defloc = COMPASSINFO.USERGBL.trajreconloc;
    m = m+1;
    Interface{m,1}.entrytype = 'RunExtFunc';
    Interface{m,1}.labelstr = 'B1Map_File';
    Interface{m,1}.entrystr = '';
    Interface{m,1}.buttonname = 'Load';
    Interface{m,1}.runfunc1 = 'LoadImageCur';
    Interface{m,1}.(Interface{m,1}.runfunc1).curloc = SCRPTPATHS.outloc;
    Interface{m,1}.runfunc2 = 'LoadImageDef';
    Interface{m,1}.(Interface{m,1}.runfunc2).defloc = COMPASSINFO.USERGBL.trajreconloc;
end 

end
end