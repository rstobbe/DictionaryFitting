%==================================================================
% (V1a)
%      
%==================================================================

classdef CreateDictionary_NaFingerPrint_v1a < handle

properties (SetAccess = private)                   
    FileObj
    Sim = TripleS;
    NumSeqs;
    RelB1Min,RelB1Max,RelB1Steps,RelB1Vals,RelB1Array
    T2sMin,T2sMax,T2sSteps,T2sVals
    T2fMin,T2fMax,T2fSteps,T2fVals
    J0Vals,J12Vals
    DictSize
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

    %---------------------------------------------------
    % Testing Values
    %---------------------------------------------------    
    obj.NumSeqs = length(obj.FileObj.Files); 
    obj.RelB1Vals = logspace(log10(obj.RelB1Min),log10(obj.RelB1Max),obj.RelB1Steps);
    obj.T2sVals = logspace(log10(obj.T2sMin),log10(obj.T2sMax),obj.T2sSteps);
    obj.J12Vals = (1./(2*obj.T2sVals));
    obj.T2fVals = logspace(log10(obj.T2fMin),log10(obj.T2fMax),obj.T2fSteps);
    obj.J0Vals = (1./(2*obj.T2fVals));

    %---------------------------------------------------
    % Setup
    %---------------------------------------------------
    if ~isvalid(obj.Sim)
        obj.Sim = TripleS;
    end
    Gave = 1;
    PCave = 1;
    RfSpoil = 0;
    SS = 1;
    obj.Sim.SetGeneralSequence(Gave,PCave,RfSpoil,SS);
    obj.Sim.InitializeModel(3);
    obj.DictSize = [length(obj.J0Vals),length(obj.J12Vals),length(obj.RelB1Vals),obj.NumSeqs];
    obj.DictArray = zeros(obj.DictSize);

    %---------------------------------------------------
    % Simulate
    %---------------------------------------------------    
    %--
    Draw = 0;   % this is slow
    %--
    for a = 1:length(file)
        LoadSequenceSpecify(obj.Sim,[obj.FileObj.Files{a}.path,obj.FileObj.Files{a}.file]);             
        for b = 1:length(obj.RelB1Vals)
            obj.Sim.SetRelB1(obj.RelB1Vals(b));
            obj.Sim.DisplayRelB1(obj.Sim);
            obj.Sim.BuildSequence; 
            if Draw == 1
                DrawSequence(obj.Sim);
            end
            for c = 1:length(obj.J12Vals)            
                for d = 1:length(obj.J0Vals)
                    obj.Sim.MOD(1).SetModel(obj.J0Vals(d),obj.J12Vals(c),obj.J12Vals(c),'None',0,0,1);
                    obj.Sim.MOD(1).DisplayModel(obj.Sim);
                    obj.Sim.Simulate;
                    Vals0 = obj.Sim.TeMxy;
                    if Draw == 1
                        obj.Sim.DispTeMxy(obj.Sim,Vals0);
                        drawnow;
                    end
                    obj.DictArray(d,c,b,a) = Vals0(1);
                end
            end
            b
        end
        a
    end    
    obj.Name = 'NaFingerPrint';
    m = 1;
    obj.Panel(m,:) = {'','','Output'};
    m = m+1;
    obj.Panel(m,:) = {'Method',class(obj),'Output'};
    m = m+1;
    obj.Panel(m,:) = {'','','Output'};    
    for n = 1:obj.NumSeqs
        m = m+1;
        obj.Panel(m,:) = {['File',num2str(m)],obj.FileObj.Files{m}.file,'Output'};
    end
    m = m+1;
    obj.Panel(m,:) = {'','','Output'};    
    m = m+1;
    obj.Panel(m,:) = {'RelB1Min',obj.RelB1Min,'Output'};
    m = m+1;
    obj.Panel(m,:) = {'RelB1Max',obj.RelB1Max,'Output'};

    obj.PanelOutput = cell2struct(obj.Panel,{'label','value','type'},2);
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
    
    % continue

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

    % continue

end 

end
end