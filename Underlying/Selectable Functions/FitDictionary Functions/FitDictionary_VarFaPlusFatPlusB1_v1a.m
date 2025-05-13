%==================================================================
% (V1a)
%   
%==================================================================

classdef FitDictionary_VarFaPlusFatPlusB1_v1a < handle

properties (SetAccess = private)                   
    DictObj
    B1Map
    MaskVal
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = FitDictionary_VarFaPlusFatPlusB1_v1a()              
end

%==================================================================
% BuildTruth
%==================================================================  
function [IMG,err] = FitDictionary(obj,IMG0)     
    err.flag = 0;  
    
    % do some TR and Fa tests
    
    ImSize = size(IMG0{1}.ImRam);
    if length(IMG0) > 1
        ImNum = length(IMG0);
        ImArray = zeros([ImSize length(IMG0)]);
        for n = 1:ImNum
            ImArray(:,:,:,n) = abs(IMG0{n}.ImRam);
        end
    elseif ImSize(6) > 1
        ImNum = ImSize(6);
        ImArray = zeros([ImSize(1:3) ImNum]);
        for n = 1:ImNum
            ImArray(:,:,:,n) = abs(IMG0{1}.ImRam(:,:,:,:,:,n));
        end
    end

    ImArray = ImArray(:,:,137,:);
    B1MapSub = obj.B1Map.Im(:,:,137);
    ImSize = size(ImArray);

    % B1MapSub = ones(size(B1MapSub));

    ImArray(ImArray < obj.MaskVal) = NaN;

    ImArrayMean = mean(ImArray,4);
    ImArrayNorm = ImArray./repmat(ImArrayMean,1,1,1,ImNum) + obj.DictObj.RelB1AddScale*repmat(B1MapSub,1,1,1,ImNum);
    ImArrayNorm = gpuArray(ImArrayNorm);
    % ImArrayNorm = reshape(ImArrayNorm,ImSize(1)^3,ImNum);
    ImArrayNorm = reshape(ImArrayNorm,ImSize(1)*ImSize(2)*ImSize(3),ImNum);

    DictArray = gpuArray(obj.DictObj.DictArray);
    % [ind,Dist] = knnsearch(DictArrayNorm,ImArrayNorm,'Distance','euclidean','K',1,'NSMethod','Exhaustive');
    [ind,Dist] = knnsearch(DictArray,ImArrayNorm);

    T1Map = obj.DictObj.T1Array(ind);
    T1Map = reshape(T1Map,ImSize(1:3));

    RelB1Map = obj.DictObj.RelB1Array(ind);
    RelB1Map = reshape(RelB1Map,ImSize(1:3));

    FatFracMap = obj.DictObj.FatFracArray(ind);
    FatFracMap = reshape(FatFracMap,ImSize(1:3));

    Dist = reshape(Dist,ImSize(1:3));

    Panel(1,:) = {'','','Output'};
    Panel(2,:) = {'Method',class(obj),'Output'};
    % obj.Panel(3,:) = {'TR',obj.TR,'Output'};
    % obj.Panel(4,:) = {'FlipArray',obj.FlipArray,'Output'};
    PanelOutput = cell2struct(Panel,{'label','value','type'},2);
    %obj.PanelOutput = 

    DispType = 'map';
    DispWid = [min(T1Map(:)) max(T1Map(:))];
    PixDim = IMG0{1}.IMDISP.ImInfo.pixdim;
    Vox = IMG0{1}.IMDISP.ImInfo.vox;
    IMG =  AddCompassGenericInfo(T1Map,'T1Map',obj,PanelOutput,DispType,DispWid,PixDim,Vox);     
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
    obj.MaskVal = str2double(CompassInput.('MaskVal'));
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
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'MaskVal';
    Interface{m,1}.entrystr = 0.1;
end 

end
end