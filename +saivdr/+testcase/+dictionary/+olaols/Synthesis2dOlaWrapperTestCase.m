classdef Synthesis2dOlaWrapperTestCase < matlab.unittest.TestCase
    %SYNTHESIS2DOLASYSTEMTESTCASE Test case for Synthesis2dOlaWrapper
    %
    % Requirements: MATLAB R2018a
    %
    % Copyright (c) 2018, Shogo MURAMATSU
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
    
    properties (TestParameter)
        width = struct('small', 64, 'medium', 96, 'large', 128);
        height = struct('small', 64, 'medium', 96, 'large', 128);
        level = struct('flat',1, 'sharrow',3,'deep', 5);
    end
    
    properties
        synthesizer
    end
    
    methods (TestMethodTeardown)
        function deleteObject(testCase)
            delete(testCase.synthesizer);
        end
    end
    
    methods (Test)

        % Test
        function testDefaultConstruction(testCase)
            
            % Expected values
            import saivdr.dictionary.olaols.*
            synthesizerExpctd = [];
            boundaryOperationExpctd = [];
            
            % Instantiation
            testCase.synthesizer = Synthesis2dOlaWrapper();
            
            % Actual value
            synthesizerActual = testCase.synthesizer.Synthesizer;
            boundaryOperationActual = testCase.synthesizer.BoundaryOperation;
            
            % Evaluation
            testCase.assertEqual(synthesizerActual,synthesizerExpctd);
            testCase.assertEqual(boundaryOperationActual,boundaryOperationExpctd);                
        end
        
        % Test
        function testSynthesizer(testCase)
            
            % Expected values
            import saivdr.dictionary.udhaar.*
            synthesizerExpctd = UdHaarSynthesis2dSystem();
            
            % Instantiation
            import saivdr.dictionary.olaols.*
            testCase.synthesizer = Synthesis2dOlaWrapper(...
                'Synthesizer',synthesizerExpctd);
            
            % Actual value
            synthesizerActual = get(testCase.synthesizer,'Synthesizer');
            
            % Evaluation
            testCase.assertEqual(synthesizerActual, synthesizerExpctd);

        end
        
  
        % Test
        function testUdHaarLevel1(testCase,width,height)
            
            nLevels = 1;
            ca  = rand(height,width);
            ch  = rand(height,width);
            cv  = rand(height,width);
            cd  = rand(height,width);
            subCoefs = [ ca(:).' ch(:).' cv(:).' cd(:).' ];
            scales= repmat([ height width ],[3*nLevels+1, 1]);
            
            % Expected values
            import saivdr.dictionary.udhaar.*
            refSynthesizer = UdHaarSynthesis2dSystem();
            imgExpctd = step(refSynthesizer,subCoefs,scales);
            dimExpctd = [ height width ];
            
            % Instantiation of target class
            import saivdr.dictionary.olaols.*
            testCase.synthesizer = Synthesis2dOlaWrapper(...
                'Synthesizer',refSynthesizer);
            
            % Actual values
            imgActual = step(testCase.synthesizer,subCoefs,scales);
            
            % Evaluation
            testCase.verifySize(imgActual,dimExpctd);
            diff = max(abs(imgExpctd(:) - imgActual(:))./abs(imgExpctd(:)));
            testCase.verifyEqual(imgActual,imgExpctd,'RelTol',1e-7,sprintf('%g',diff));
        end
        
        
        % Test
        function testUdHaarLevel2(testCase,width,height)
            
            % Parameters
            nLevels = 2;
            ca1  = rand(height,width);
            ch1  = rand(height,width);
            cv1  = rand(height,width);
            cd1  = rand(height,width);
            ch2  = rand(height,width);
            cv2  = rand(height,width);
            cd2  = rand(height,width);            
            subCoefs = [ ca1(:).' ch1(:).' cv1(:).' cd1(:).' ...
                ch2(:).' cv2(:).' cd2(:).' ];
            scales = repmat([ height width ],[3*nLevels+1, 1]);

           
            % Expected values
            import saivdr.dictionary.udhaar.*
            refSynthesizer = UdHaarSynthesis2dSystem();
            imgExpctd = step(refSynthesizer,subCoefs,scales);
            
            % Instantiation of target class
            import saivdr.dictionary.olaols.*
            testCase.synthesizer = Synthesis2dOlaWrapper(...
                'Synthesizer',refSynthesizer);
            
            % Actual values
            imgActual = step(testCase.synthesizer,subCoefs,scales);
            
            % Evaluation
            testCase.verifySize(imgActual,size(imgExpctd),...
                'Actual image size is different from the expected one.');
            diff = max(abs(imgExpctd(:) - imgActual(:)));
            testCase.verifyEqual(imgActual,imgExpctd,'AbsTol',1e-10,sprintf('%g',diff));
        end
        
        % Test
        function testUdHaarLevel3(testCase,width,height,level)
            % Parameters
            nChs = 3*level+1;
            subCoefs = repmat(rand(1,height*width),[1 nChs]);
            scales = repmat([ height width ],[3*level+1, 1]);
            
            % Preparation
            % Expected values
            import saivdr.dictionary.udhaar.*
            refSynthesizer = UdHaarSynthesis2dSystem();
            imgExpctd = step(refSynthesizer,subCoefs,scales);
            
            % Instantiation of target class
            import saivdr.dictionary.olaols.*
            testCase.synthesizer = Synthesis2dOlaWrapper(...
                'Synthesizer',refSynthesizer);
            
            % Actual values
            imgActual = step(testCase.synthesizer,subCoefs,scales);
            
            % Evaluation
            testCase.verifySize(imgActual,size(imgExpctd),...
                'Actual image size is different from the expected one.');
            diff = max(abs(imgExpctd(:) - imgActual(:)));
            testCase.verifyEqual(imgActual,imgExpctd,'AbsTol',1e-10,sprintf('%g',diff));
        end
        
         % Test
        function testUdHaarSplitting(testCase,width,height,level)
            
            % Parameters
            nVerSplit = 2;
            nHorSplit = 2;
            nVerPad = 2^(level-1)-1;
            nHorPad = 2^(level-1)-1;
            nChs = 3*level+1;
            subCoefs = repmat(rand(1,height*width),[1 nChs]);
            scales = repmat([ height width ],[3*level+1, 1]);
            
            % Preparation
            % Expected values
            import saivdr.dictionary.udhaar.*
            refSynthesizer = UdHaarSynthesis2dSystem();
            imgExpctd = step(refSynthesizer,subCoefs,scales);
            
            % Instantiation of target class
            import saivdr.dictionary.olaols.*
            testCase.synthesizer = Synthesis2dOlaWrapper(...
                'Synthesizer',clone(refSynthesizer),...
                'VerticalSplitFactor',nVerSplit,...
                'HorizontalSplitFactor',nHorSplit,...
                'PadSize',[nVerPad,nHorPad],...
                'UseParallel',false);
            
            % Actual values
            imgActual = step(testCase.synthesizer,subCoefs,scales);
            
            % Evaluation
            %testCase.assertFail('TODO: Check for split');            
            testCase.verifySize(imgActual,size(imgExpctd),...
                'Actual image size is different from the expected one.');
            diff = max(abs(imgExpctd(:) - imgActual(:)));
            testCase.verifyEqual(imgActual,imgExpctd,'AbsTol',1e-10,sprintf('%g',diff));
        end
        
         % Test
        function testUdHaarSplittingUseParallel(testCase,width,height,level)
            
            % Parameters
            nVerSplit = 2;
            nHorSplit = 2;
            nVerPad = 2^(level-1)-1;
            nHorPad = 2^(level-1)-1;
            nChs = 3*level+1;
            subCoefs = repmat(rand(1,height*width),[1 nChs]);
            scales = repmat([ height width ],[3*level+1, 1]);
            useParallel = true;
            
            % Preparation
            % Expected values
            import saivdr.dictionary.udhaar.*
            refSynthesizer = UdHaarSynthesis2dSystem();
            imgExpctd = step(refSynthesizer,subCoefs,scales);
            
            % Instantiation of target class
            import saivdr.dictionary.olaols.*
            testCase.synthesizer = Synthesis2dOlaWrapper(...
                'Synthesizer',refSynthesizer,...
                'VerticalSplitFactor',nVerSplit,...
                'HorizontalSplitFactor',nHorSplit,...
                'PadSize',[nVerPad,nHorPad],...
                'UseParallel',useParallel);
            
            % Actual values
            imgActual = step(testCase.synthesizer,subCoefs,scales);
            
            % Evaluation
            %testCase.assertFail('TODO: Check for split');            
            testCase.verifySize(imgActual,size(imgExpctd),...
                'Actual image size is different from the expected one.');
            diff = max(abs(imgExpctd(:) - imgActual(:)));
            testCase.verifyEqual(imgActual,imgExpctd,'AbsTol',1e-10,sprintf('%g',diff));
        end        
        
        % Test
        function testUdHaarSplittingWarningReconstruction(testCase,width,height)
            
            % Parameters
            level_ = 2;
            nVerSplit = 2;
            nHorSplit = 2;
            nVerPad = 2^(level_-1)-2;
            nHorPad = 2^(level_-1)-2;
            nChs = 3*level_+1;
            subCoefs = repmat(rand(1,height*width),[1 nChs]);
            scales = repmat([ height width ],[3*level_+1, 1]);
            
            % Expected values
            exceptionIdExpctd = 'SaivDr:ReconstructionFailureException';
            messageExpctd = 'Failure occurs in reconstruction. Please check the split and padding size.';
            
            % Preparation
            import saivdr.dictionary.udhaar.*
            refSynthesizer = UdHaarSynthesis2dSystem();
            
            % Instantiation of target class
            import saivdr.dictionary.olaols.*
            testCase.synthesizer = Synthesis2dOlaWrapper(...
                'Synthesizer',refSynthesizer,...
                'VerticalSplitFactor',nVerSplit,...
                'HorizontalSplitFactor',nHorSplit,...
                'PadSize',[nVerPad,nHorPad],...
                'UseParallel',false);
            
            % Actual values
            try
                step(testCase.synthesizer,subCoefs,scales);
                testCase.verifyFail(sprintf('%s must be thrown.',...
                    exceptionIdExpctd));
            catch me
                switch me.identifier
                    case exceptionIdExpctd
                        messageActual = me.message;
                        testCase.verifyEqual(messageActual, messageExpctd);
                    otherwise
                        testCase.verifyFail(sprintf('%s must be thrown.',...
                            exceptionIdExpctd));
                end
            end
        end
        
        % Test
        function testUdHaarSplittingWarningFactor(testCase,width,height,level)
            
            % Parameters
            nVerSplit = 3;
            nHorSplit = 3;
            nVerPad = 2^(level-1)-1;
            nHorPad = 2^(level-1)-1;
            nChs = 3*level+1;
            subCoefs = repmat(rand(1,height*width),[1 nChs]);
            scales = repmat([ height width ],[3*level+1, 1]);
            
            % Expected values
            exceptionIdExpctd = 'SaivDr:IllegalSplitFactorException';
            messageExpctd = 'Split factor must be a divisor of array size.';
            
            % Preparation
            import saivdr.dictionary.udhaar.*
            refSynthesizer = UdHaarSynthesis2dSystem();
            
            % Instantiation of target class
            import saivdr.dictionary.olaols.*
            testCase.synthesizer = Synthesis2dOlaWrapper(...
                'Synthesizer',refSynthesizer,...
                'VerticalSplitFactor',nVerSplit,...
                'HorizontalSplitFactor',nHorSplit,...
                'PadSize',[nVerPad,nHorPad],...
                'UseParallel',false);
            
            % Actual values
            try
                step(testCase.synthesizer,subCoefs,scales);
                if mod(width,nHorSplit) ~=0 || mod(height,nVerSplit) ~= 0
                    testCase.verifyFail(sprintf('%s must be thrown.',...
                        exceptionIdExpctd));
                end
            catch me
                switch me.identifier
                    case exceptionIdExpctd
                        messageActual = me.message;
                        testCase.verifyEqual(messageActual, messageExpctd);
                    otherwise
                        testCase.verifyFail(sprintf('%s must be thrown.',...
                            exceptionIdExpctd));
                end
            end
        end

    end
end