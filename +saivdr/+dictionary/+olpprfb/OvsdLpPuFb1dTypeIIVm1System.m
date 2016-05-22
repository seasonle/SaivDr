classdef OvsdLpPuFb1dTypeIIVm1System < ...
        saivdr.dictionary.olpprfb.AbstOvsdLpPuFb1dTypeIISystem %#codegen
    %OVSDLPPUFB1dTYPEIIVM1SYSTEM 2-D Type-II Oversampled LPPUFB with one VM
    %
    % SVN identifier:
    % $Id: OvsdLpPuFb1dTypeIIVm1System.m 653 2015-02-04 05:21:08Z sho $
    %
    % Requirements: MATLAB R2013b
    %
    % Copyright (c) 2014, Shogo MURAMATSU
    %
    % All rights reserved.
    %
    % Contact address: Shogo MURAMATSU,
    %                Faculty of Engineering, Niigata University,
    %                8050 2-no-cho Ikarashi, Nishi-ku,
    %                Niigata, 950-2181, JAPAN
    %
    % LinedIn: http://www.linkedin.com/pub/shogo-muramatsu/4b/b08/627    
    % 
   
    properties (Access = private, Nontunable)
        omgsW_
        omgsU_
        omfs_
    end
      
    methods        
        function obj = OvsdLpPuFb1dTypeIIVm1System(varargin)
            import saivdr.dictionary.utility.OrthonormalMatrixFactorizationSystem
            import saivdr.dictionary.utility.OrthonormalMatrixGenerationSystem
            obj = obj@saivdr.dictionary.olpprfb.AbstOvsdLpPuFb1dTypeIISystem(...
                varargin{:});
            obj.omfs_  = OrthonormalMatrixFactorizationSystem();
            obj.omgsW_ = OrthonormalMatrixGenerationSystem();
            obj.omgsU_ = OrthonormalMatrixGenerationSystem();
        end
    end
    
    methods (Access = protected)
            
        function s = saveObjectImpl(obj)
            s = saveObjectImpl@saivdr.dictionary.olpprfb.AbstOvsdLpPuFb1dTypeIISystem(obj);
            s.omfs_  = matlab.System.saveObject(obj.omfs_);            
            s.omgsW_ = matlab.System.saveObject(obj.omgsW_);            
            s.omgsU_ = matlab.System.saveObject(obj.omgsU_);            
        end
        
        function loadObjectImpl(obj,s,wasLocked)
            loadObjectImpl@saivdr.dictionary.olpprfb.AbstOvsdLpPuFb1dTypeIISystem(obj,s,wasLocked);
            obj.omfs_ = matlab.System.loadObject(s.omfs_);
            obj.omgsW_ = matlab.System.loadObject(s.omgsW_);            
            obj.omgsU_ = matlab.System.loadObject(s.omgsU_);            
        end        
        
        function updateParameterMatrixSet_(obj)
            import saivdr.dictionary.nsoltx.ChannelGroup
            nChs = obj.NumberOfChannels;
            angles = obj.Angles;
            mus    = obj.Mus;
            nSts   = obj.nStages;
            nAngsW = ceil(nChs/2)*(ceil(nChs/2)-1)/2;
            nMusW  = ceil(nChs/2);
            
            % No-DC-Leackage condition
            W_ = eye(ceil(nChs/2)); 
            omgsW = obj.omgsW_;
            omgsU = obj.omgsU_;
            pmMtxSet = obj.ParameterMatrixSet;
            for iParamMtx = uint32(1):nSts-1
                % W
                mtx = step(omgsW,angles(1:nAngsW,iParamMtx),...
                    mus(1:nMusW,iParamMtx));                  
                step(pmMtxSet,mtx,2*iParamMtx-1);
                % U
                mtx = step(omgsU,angles(nAngsW+1:end,iParamMtx),...
                        mus(nMusW+1:end,iParamMtx));
                step(pmMtxSet,mtx,2*iParamMtx);

                W_ = step(pmMtxSet,[],2*iParamMtx-1)*W_;
            end
            [angles_,mus_] = step(obj.omfs_,W_.');
            angles(1:ceil(nChs/2)-1,nSts) = ...
                angles_(1:ceil(nChs/2)-1);
            mus(1,nSts) = mus_(1);
            % W
            mtx = step(omgsW,angles(1:nAngsW,nSts),...
                mus(1:nMusW,nSts));            
            step(pmMtxSet,mtx,2*nSts-1); 
            % U
            mtx = step(omgsU,angles(nAngsW+1:end,nSts),...
                mus(nMusW+1:end,nSts));
            step(pmMtxSet,mtx,2*nSts);
            %
            obj.Angles = angles;
            obj.Mus    = mus;
        end
        
    end
    
    methods (Access = protected, Static = true)
        function value = getDefaultPolyPhaseOrder_()
            value = 0;
        end
    end
end
