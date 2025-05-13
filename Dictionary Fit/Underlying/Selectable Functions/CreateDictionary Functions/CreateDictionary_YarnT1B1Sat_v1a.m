%==================================================================
% (V1b)
%       - save 'DictArray0' & 'DictArrayMean'
%==================================================================

classdef CreateDictionary_YarnT1B1Sat_v1a < handle

properties (SetAccess = private)                   
    TR
    FlipArray
    T1Min,T1Max,T1Steps,T1Vals,T1Array
    RelB1Min,RelB1Max,RelB1Steps,RelB1Vals,RelB1Array
    SatFlip,SatTR
    RelB1AddScale
    DictArrayMean
    DictArray0
    DictArray
    Name 
    Panel = cell(0);
    PanelOutput
end

methods 
   
%==================================================================
% Constructor
%==================================================================  
function obj = CreateDictionary_YarnT1B1Sat_v1a()              
end

%==================================================================
% BuildTruth
%==================================================================  
function err = CreateDictionary(obj)     
    err.flag = 0;  

    obj.T1Vals = logspace(log10(obj.T1Min),log10(obj.T1Max),obj.T1Steps);
    obj.RelB1Vals = logspace(log10(obj.RelB1Min),log10(obj.RelB1Max),obj.RelB1Steps);

    obj.RelB1Array = zeros(obj.RelB1Steps*obj.T1Steps,1);
    obj.T1Array = zeros(obj.RelB1Steps*obj.T1Steps,1);
    obj.DictArray0 = zeros(obj.RelB1Steps*obj.T1Steps,length(obj.FlipArray));

    ind = 0;
    for n = 1:obj.RelB1Steps
        for m = 1:obj.T1Steps
            ind = ind+1;
            %--------------------------
            % Standard Steady-State
            %--------------------------
            for p = 1:(length(obj.FlipArray)-1)
                Exp = exp(-obj.TR/obj.T1Vals(m));
                SinFlip = sin(pi*obj.FlipArray(p)*obj.RelB1Vals(n)/180);
                CosFlip = cos(pi*obj.FlipArray(p)*obj.RelB1Vals(n)/180);
                obj.DictArray0(ind,p) = SinFlip*(1-Exp)/(1-CosFlip*Exp);  
                obj.RelB1Array(ind) = obj.RelB1Vals(n);
                obj.T1Array(ind) = obj.T1Vals(m);
            end
            %--------------------------
            % 'Saturated' Steady-State
            %--------------------------
            p = length(obj.FlipArray);
            SinFlip = sin(pi*obj.FlipArray(p)*obj.RelB1Vals(n)/180);
            CosFlip = cos(pi*obj.FlipArray(p)*obj.RelB1Vals(n)/180);


            %------------------------- 
        end
    end
    obj.DictArrayMean = mean(obj.DictArray0,2);
    DictArrayNorm = obj.DictArray0./repmat(obj.DictArrayMean,1,length(obj.FlipArray));
    obj.DictArray = DictArrayNorm + obj.RelB1AddScale*(obj.RelB1Array);

    obj.Name = 'DictVarFaPlusB1';
    obj.Panel(1,:) = {'','','Output'};
    obj.Panel(2,:) = {'Method',class(obj),'Output'};
    obj.Panel(3,:) = {'TR',obj.TR,'Output'};
    obj.Panel(4,:) = {'FlipArray',obj.FlipArray,'Output'};
    obj.Panel(5,:) = {'RelB1AddScale',obj.RelB1AddScale,'Output'};
    obj.PanelOutput = cell2struct(obj.Panel,{'label','value','type'},2);
end

%=================================================================
% InitViaCompass
%==================================================================  
function InitViaCompass(obj,CompassInput)    
    obj.TR = str2double(CompassInput.('TR'));
    FlipString = CompassInput.('Flip');
    ind = strfind(FlipString,' ');
    obj.FlipArray(1) = str2double(FlipString(1:ind(1)-1));
    if length(ind) > 1
        for n = 2:length(ind)
            obj.FlipArray(n) = str2double(FlipString(ind(n-1)+1:ind(n)-1));
        end
    else
        n = 1;
    end
    obj.FlipArray(n+1) = str2double(FlipString(ind(n)+1:end));
    obj.SatFlip = str2double(CompassInput.('SatFlip'));
    obj.SatTR = str2double(CompassInput.('SatTR'));
    obj.T1Min = str2double(CompassInput.('T1Min'));
    obj.T1Max = str2double(CompassInput.('T1Max'));
    obj.T1Steps = str2double(CompassInput.('T1Steps'));
    obj.RelB1Min = str2double(CompassInput.('RelB1Min'));
    obj.RelB1Max = str2double(CompassInput.('RelB1Max'));
    obj.RelB1Steps = str2double(CompassInput.('RelB1Steps'));

    obj.Name = '';
end

%==================================================================
% CompassInterface
%==================================================================  
function [Interface] = CompassInterface(obj,SCRPTPATHS)    
    m = 1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'TR (ms)';
    Interface{m,1}.entrystr = 2.0;
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'Flip (deg)';
    Interface{m,1}.entrystr = '2 2 2 2';
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'SatFlip (deg)';
    Interface{m,1}.entrystr = 30;
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'SatTR (ms)';
    Interface{m,1}.entrystr = 5.0;
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'T1Min (ms)';
    Interface{m,1}.entrystr = 300;
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'T1Max (ms)';
    Interface{m,1}.entrystr = 1600;
    m = m+1;
    Interface{m,1}.entrytype = 'Input';
    Interface{m,1}.labelstr = 'T1Steps';
    Interface{m,1}.entrystr = 50;
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