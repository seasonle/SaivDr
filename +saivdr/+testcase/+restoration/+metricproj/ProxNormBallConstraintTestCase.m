classdef ProxNormBallConstraintTestCase < matlab.unittest.TestCase
    %TESTCASEPLGSOFTTHRESHOLDING Test caes for ProxNormBallConstraint
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
    
    properties
        target
    end
    
    methods (TestMethodTeardown)
        function deteleObject(testCase)
            delete(testCase.target);
        end
    end    
    
    methods (Test)
        
        function testConstruction(testCase)
            
            epsExpctd = Inf;
            centerExpctd = 0;
            
            import saivdr.restoration.metricproj.*
            testCase.target = ProxNormBallConstraint();
            
            epsActual = testCase.target.Eps;
            centerActual = testCase.target.Center;
            
            testCase.verifyEqual(epsActual,epsExpctd);
            testCase.verifyEqual(centerActual,centerExpctd);            
            
        end
    
        %{
        
        function testConstruction(testCase,sigma)
            
            sigmaExpctd = sigma;
            
            target = PlgGdnSfth('Sigma',sigmaExpctd);
            
            sigmaActual = target.Sigma;
            
            testCase.verifyEqual(sigmaActual,sigmaExpctd);
            
        end
               
        function testStepScalar(testCase,inputSize,sigma)
            
            x = randn(inputSize,1);
            
            v = max(abs(x)-sigma^2,0);
            yExpctd = sign(x).*v;
            
            target = PlgGdnSfth('Sigma',sigma);
            
            yActual = target.step(x);
            
            testCase.verifyEqual(yActual,yExpctd);
            
        end
        
        function testSetSigma(testCase,inputSize,sigma)
            
            x = randn(inputSize,1);
            
            v = max(abs(x)-sigma^2,0);
            yExpctd = sign(x).*v;
            
            target = PlgGdnSfth();
            target.Sigma = sigma;
            
            yActual = target.step(x);
            
            testCase.verifyEqual(yActual,yExpctd);
            
        end
        
        function testStepVector(testCase,inputSize,sigma)
            
            x    = sigma*randn(inputSize,1);
            svec = sigma*rand(inputSize,1);
            
            v = abs(x)-svec.^2;
            v(v<0) = 0;
            yExpctd = sign(x).*v;
            
            target = PlgGdnSfth('Sigma',svec);
            
            yActual = target.step(x);
            
            testCase.verifyEqual(yActual,yExpctd);
            
        end
       %} 
    end
    
end

