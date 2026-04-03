classdef TestMathChallenge < matlab.unittest.TestCase
    % TESTMATHCHALLENGE Unit tests for MathChallenge class

    properties
        MC
    end

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.MC = MathChallenge(1);
        end
    end

    methods (Test)
        %% Constructor tests
        function testDefaultLevel(testCase)
            mc = MathChallenge();
            testCase.verifyEqual(mc.Level, 1);
            testCase.verifyEqual(mc.Score, 0);
            testCase.verifyEqual(mc.Streak, 0);
        end

        function testCustomStartLevel(testCase)
            mc = MathChallenge(5);
            testCase.verifyEqual(mc.Level, 5);
        end

        function testLevelClampedToMax(testCase)
            mc = MathChallenge(100);
            testCase.verifyEqual(mc.Level, 10);
        end

        function testLevelClampedToMin(testCase)
            mc = MathChallenge(0);
            testCase.verifyEqual(mc.Level, 1);
        end

        %% Problem generation tests
        function testGenerateProblemReturnsValidData(testCase)
            [question, answer, choices] = testCase.MC.generateProblem();
            testCase.verifyClass(question, 'char');
            testCase.verifyTrue(isnumeric(answer));
            testCase.verifySize(choices, [1, 4]);
        end

        function testCorrectAnswerIsInChoices(testCase)
            for i = 1:50  % run multiple times due to randomness
                [~, answer, choices] = testCase.MC.generateProblem();
                testCase.verifyTrue(any(choices == answer), ...
                    sprintf('Correct answer %d not found in choices [%s]', ...
                    answer, num2str(choices)));
            end
        end

        function testChoicesAreUnique(testCase)
            for i = 1:50
                [~, ~, choices] = testCase.MC.generateProblem();
                testCase.verifyEqual(length(unique(choices)), 4, ...
                    sprintf('Choices not unique: [%s]', num2str(choices)));
            end
        end

        function testChoicesAreNonNegative(testCase)
            for i = 1:50
                [~, ~, choices] = testCase.MC.generateProblem();
                testCase.verifyTrue(all(choices >= 0), ...
                    'Choices contain negative numbers');
            end
        end

        %% Addition tests (Level 1)
        function testAdditionLevel1(testCase)
            mc = MathChallenge(1);
            for i = 1:20
                [q, ans, ~] = mc.generateProblem();
                testCase.verifySubstring(q, '+');
                testCase.verifyTrue(ans > 0);
            end
        end

        %% Subtraction tests (Level 3)
        function testSubtractionNonNegativeResult(testCase)
            mc = MathChallenge(3);
            for i = 1:30
                [~, ans, ~] = mc.generateProblem();
                testCase.verifyGreaterThanOrEqual(ans, 0, ...
                    'Subtraction produced negative result');
            end
        end

        %% Multiplication tests (Level 5)
        function testMultiplicationLevel5(testCase)
            mc = MathChallenge(5);
            for i = 1:20
                [q, ~, ~] = mc.generateProblem();
                testCase.verifySubstring(q, '*');
            end
        end

        %% Division tests (Level 7)
        function testDivisionProducesWholeNumbers(testCase)
            mc = MathChallenge(7);
            for i = 1:30
                [~, ans, ~] = mc.generateProblem();
                testCase.verifyEqual(ans, floor(ans), ...
                    'Division did not produce a whole number');
            end
        end

        %% Mixed operations (Level 9+)
        function testMixedOperationsLevel9(testCase)
            mc = MathChallenge(9);
            ops = {};
            for i = 1:50
                [q, ~, ~] = mc.generateProblem();
                if contains(q, '+')
                    ops{end+1} = '+'; %#ok<AGROW>
                elseif contains(q, '-')
                    ops{end+1} = '-'; %#ok<AGROW>
                elseif contains(q, '*')
                    ops{end+1} = '*'; %#ok<AGROW>
                elseif contains(q, '/')
                    ops{end+1} = '/'; %#ok<AGROW>
                end
            end
            testCase.verifyGreaterThan(length(unique(ops)), 1, ...
                'Mixed mode did not produce multiple operation types');
        end

        %% Scoring tests
        function testCorrectAnswerIncreasesScore(testCase)
            mc = testCase.MC;
            mc = mc.recordAnswer(true);
            testCase.verifyGreaterThan(mc.Score, 0);
            testCase.verifyEqual(mc.Streak, 1);
            testCase.verifyEqual(mc.ProblemsCorrect, 1);
        end

        function testWrongAnswerResetsStreak(testCase)
            mc = testCase.MC;
            mc = mc.recordAnswer(true);
            mc = mc.recordAnswer(true);
            mc = mc.recordAnswer(false);
            testCase.verifyEqual(mc.Streak, 0);
        end

        function testScoreNeverNegative(testCase)
            mc = MathChallenge(1);
            for i = 1:20
                mc = mc.recordAnswer(false);
            end
            testCase.verifyGreaterThanOrEqual(mc.Score, 0);
        end

        %% Level up tests
        function testLevelUpAfterStreak(testCase)
            mc = MathChallenge(1);
            for i = 1:5
                mc = mc.recordAnswer(true);
            end
            testCase.verifyEqual(mc.Level, 2);
        end

        function testNoLevelUpBeyondMax(testCase)
            mc = MathChallenge(10);
            for i = 1:10
                mc = mc.recordAnswer(true);
            end
            testCase.verifyEqual(mc.Level, 10);
        end

        %% Accuracy tests
        function testAccuracyCalculation(testCase)
            mc = MathChallenge(1);
            mc = mc.recordAnswer(true);
            mc = mc.recordAnswer(false);
            testCase.verifyEqual(mc.getAccuracy(), 50);
        end

        function testAccuracyZeroWhenNoAttempts(testCase)
            mc = MathChallenge(1);
            testCase.verifyEqual(mc.getAccuracy(), 0);
        end

        %% Operation and range tests
        function testAllLevelsReturnValidOperations(testCase)
            validOps = {'+', '-', '*', '/'};
            for level = 1:10
                mc = MathChallenge(level);
                [op, range] = mc.getOperationAndRange();
                testCase.verifyTrue(any(strcmp(op, validOps)), ...
                    sprintf('Invalid operation at level %d: %s', level, op));
                testCase.verifySize(range, [1, 2]);
                testCase.verifyGreaterThan(range(2), 0);
            end
        end
    end
end
