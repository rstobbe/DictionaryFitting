%==================================================================
% (V1a)
%      
%==================================================================

classdef CreateDictionary_NaFingerPrint_v1a < handle

properties (SetAccess = private)                   
    FileObj
    Sim = TripleS;
    NumSeqs;

    DictArray
    Name 
    Panel = cell(0);
    PanelOutput
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = CreateDictionary_NaFingerPrint_v1a()    
end

%==================================================================
% BuildTruth
%==================================================================  
function err = CreateDictionary(obj)     
    err.flag = 0;  
    if ~isvalid(obj.Sim)
        obj.Sim = TripleS;
    end

    obj.NumSeqs = length(obj.FileObj.Files); 

    obj.RelB1Vals = logspace(log10(obj.RelB1Min),log10(obj.RelB1Max),obj.RelB1Steps);

    T2s = (5:0.5:30);
    obj.J12 = (1./(2*T2s));
    T2f = [(0.02:0.005:0.2) (0.21:0.01:0.3) (0.32:0.02:0.8)];
    obj.J0 = (1./T2f);
    
    %---------------------------------------------------
    % General Setup
    %---------------------------------------------------
    Gave = 1;
    PCave = 1;
    RfSpoil = 0;
    SS = 1;
    obj.Sim.SetGeneralSequence(Gave,PCave,RfSpoil,SS);


    obj.Sim.InitializeModel(3);
    obj.DictSize = [length(obj.J0),length(obj.J12),length(obj.RelB1),length(file)];
    obj.DictArray = zeros(obj.DictSize);
    
    %--
    Draw = 0;   % this is slow
    %--
    for a = 1:length(file)
        LoadSequenceSpecify(TRPLS,[obj.FileObj.Files{a}.path,obj.FileObj.Files{a}.file]);             
        for b = 1:length(obj.RelB1)
            obj.Sim.SetRelB1(obj.RelB1(b));
            obj.Sim.DisplayRelB1(TRPLS);
            obj.Sim.BuildSequence; 
            if Draw == 1
                DrawSequence(TRPLS);
            end
            for c = 1:length(obj.J12)            
                for d = 1:length(obj.J0)
                    obj.Sim.MOD(1).SetModel(obj.J0(d),obj.J12(c),obj.J12(c),'None',0,0,1);
                    obj.Sim.MOD(1).DisplayModel(TRPLS);
                    obj.Sim.Simulate;
                    Vals0 = obj.Sim.TeMxy;
                    if Draw == 1
                        obj.Sim.DispTeMxy(TRPLS,Vals0);
                        drawnow;
                    end
                    obj.DictArray(d,c,b,a) = Vals0(1);
                end
            end
            b
        end
        a
    end    

    % 
    % obj.Name = 'DictVarFaPlusB1';
    % obj.Panel(1,:) = {'','','Output'};
    % obj.Panel(2,:) = {'Method',class(obj),'Output'};
    % obj.Panel(3,:) = {'TR',obj.TR,'Output'};
    % obj.Panel(4,:) = {'FlipArray',obj.FlipArray,'Output'};
    % obj.Panel(5,:) = {'RelB1AddScale',obj.RelB1AddScale,'Output'};
    % obj.PanelOutput = cell2struct(obj.Panel,{'label','value','type'},2);
end

%=================================================================
% InitViaCompass
%==================================================================  
function err = InitViaCompass(obj,CompassInput)    
    [obj.FileObj,err] = CompassSubFuncInit(CompassInput,'SequenceSelect');
    if err.flag
        return
    end
    obj.RelB1Min = str2double(CompassInput.('RelB1Min'));
    obj.RelB1Max = str2double(CompassInput.('RelB1Max'));
    obj.RelB1Steps = str2double(CompassInput.('RelB1Steps'));
    obj.Name = '';
end

%==================================================================
% CompassInterface
%==================================================================  
function [Interface] = CompassInterface(obj,Paths)    
    m = 1;
    Interface{m,1}.entrytype = 'ScrptFunc';
    Interface{m,1}.labelstr = 'SequenceSelect';
    Interface{m,1}.entrystr = 'MultiGenericFileSelect_v2a';
    Interface{m,1}.path = 'MultiGenericFileSelect_v2a';
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'RelB1Min';
    Interface{m,1}.entrystr = 0.5;
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'RelB1Max';
    Interface{m,1}.entrystr = 2;
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'RelB1Steps';
    Interface{m,1}.entrystr = 20;
end 

end
end