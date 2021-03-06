classdef NsoltDesignerFrq < saivdr.dictionary.nsolt.design.AbstNsoltDesigner %#~codegen
    %NSOLTDESIGNERFRQ NSOLT design class with frequency specification
    %
    % SVN identifier:
    % $Id: NsoltDesignerFrq.m 683 2015-05-29 08:22:13Z sho $
    %
    % Requirements: MATLAB R2015b
    %
    % Copyright (c) 2014-2015, Shogo MURAMATSU
    %
    % All rights reserved.
    %
    % Contact address: Shogo MURAMATSU,
    %                Faculty of Engineering, Niigata University,
    %                8050 2-no-cho Ikarashi, Nishi-ku,
    %                Niigata, 950-2181, JAPAN
    %
    % http://msiplab.eng.niigata-u.ac.jp/    
    %
 
    properties (Nontunable)
        AmplitudeSpecs
    end
    
    properties
    end
    
    properties (Access = protected)
        pbErrSbEng
    end
      
    methods
        
        function obj = NsoltDesignerFrq(varargin)
            import saivdr.dictionary.nsolt.design.PassBandErrorStopBandEnergy
            obj = obj@saivdr.dictionary.nsolt.design.AbstNsoltDesigner(...
                varargin{:});
            obj.pbErrSbEng = PassBandErrorStopBandEnergy(...
                'AmplitudeSpecs',obj.AmplitudeSpecs,...
                'EvaluationMode','All');
        end
        
        function value = costFcnAng(obj, lppufb, angles)
            clnlppufb = clone(lppufb);
            clnpbesbe = clone(obj.pbErrSbEng);
            angles = reshape(angles,obj.sizeAngles);
            set(clnlppufb,'Angles',angles);
            value = step(clnpbesbe,clnlppufb);
        end
        
        function value = costFcnMus(obj, lppufb, mus)
            clnlppufb = clone(lppufb);
            clnpbesbe = clone(obj.pbErrSbEng);
            mus = 2*(reshape(mus,obj.sizeMus))-1;
            set(clnlppufb,'Mus',mus);
            value = step(clnpbesbe,clnlppufb);
        end
        
        function value = isConstrained(~,~)
            value = false;
        end
        
        function [c,ce] = nonlconFcn(~,~,~)
            c  = [];
            ce = [];
        end
        
    end
    
    methods (Access = protected)
        
        function s = saveObjectImpl(obj)
            s = saveObjectImpl@saivdr.dictionary.nsolt.design.AbstNsoltDesigner(obj);
            s.pbErrSbEng = matlab.System.saveObject(obj.pbErrSbEng);
        end
        
        function loadObjectImpl(obj,s,wasLocked)
            obj.pbErrSbEng = matlab.System.loadObject(s.pbErrSbEng);
            loadObjectImpl@saivdr.dictionary.nsolt.design.AbstNsoltDesigner(obj,s,wasLocked);
        end
        
    end

end
