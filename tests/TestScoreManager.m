classdef TestScoreManager < matlab.unittest.TestCase
    % TESTSCOREMANAGER Unit tests for ScoreManager

    properties
        SM
    end

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.SM = ScoreManager(10);
        end
    end

    methods (Test)
        %% Initialization
        function testDefaultValues(testCase)
            sm = testCase.SM;
            testCase.verifyEqual(sm.TotalScore, 0);
            testCase.verifyEqual(sm.CurrentLevel, 1);
            testCase.verifyFalse(sm.LevelComplete);
            testCase.verifyFalse(sm.GameComplete);
        end

        %% Scoring
        function testAddMathScore(testCase)
            sm = testCase.SM;
            sm = sm.addMathScore(100);
            testCase.verifyEqual(sm.MathScore, 100);
            testCase.verifyEqual(sm.TotalScore, 100);
        end

        function testAddOpponentPassed(testCase)
            sm = testCase.SM;
            sm = sm.addOpponentPassed();
            testCase.verifyEqual(sm.OpponentsPassedCount, 1);
            testCase.verifyEqual(sm.TotalScore, 50);
        end

        function testUpdateDistance(testCase)
            sm = testCase.SM;
            sm = sm.updateDistance(500);
            testCase.verifyEqual(sm.DistanceScore, floor(500 * 0.1));
        end

        function testCombinedScoring(testCase)
            sm = testCase.SM;
            sm = sm.addMathScore(100);
            sm = sm.addOpponentPassed();
            sm = sm.updateDistance(200);
            expected = 100 + 50 + floor(200 * 0.1);
            testCase.verifyEqual(sm.TotalScore, expected);
        end

        %% Level progression
        function testLevelCompleteAtTarget(testCase)
            sm = testCase.SM;
            sm = sm.updateDistance(1000);
            testCase.verifyTrue(sm.LevelComplete);
        end

        function testLevelNotCompleteBeforeTarget(testCase)
            sm = testCase.SM;
            sm = sm.updateDistance(999);
            testCase.verifyFalse(sm.LevelComplete);
        end

        function testAdvanceLevel(testCase)
            sm = testCase.SM;
            sm = sm.updateDistance(1000);
            sm = sm.advanceLevel();
            testCase.verifyEqual(sm.CurrentLevel, 2);
            testCase.verifyFalse(sm.LevelComplete);
        end

        function testNoAdvanceBeyondMax(testCase)
            sm = ScoreManager(2);
            sm.CurrentLevel = 2;
            sm.LevelComplete = true;
            sm = sm.advanceLevel();
            testCase.verifyEqual(sm.CurrentLevel, 2);
        end

        function testGameCompleteAtMaxLevel(testCase)
            sm = ScoreManager(1);
            sm = sm.updateDistance(1000);
            testCase.verifyTrue(sm.GameComplete);
        end

        %% Progress
        function testGetLevelProgress(testCase)
            sm = testCase.SM;
            pct = sm.getLevelProgress(500);
            testCase.verifyEqual(pct, 50);
        end

        function testProgressCappedAt100(testCase)
            sm = testCase.SM;
            pct = sm.getLevelProgress(2000);
            testCase.verifyEqual(pct, 100);
        end

        %% Report
        function testGetReport(testCase)
            sm = testCase.SM;
            sm = sm.addMathScore(200);
            sm = sm.addOpponentPassed();
            report = sm.getReport();
            testCase.verifyTrue(isstruct(report));
            testCase.verifyEqual(report.MathScore, 200);
            testCase.verifyEqual(report.OpponentsPassed, 1);
            testCase.verifyEqual(report.Level, 1);
        end
    end
end
