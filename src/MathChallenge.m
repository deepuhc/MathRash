classdef MathChallenge
    % MATHCHALLENGE Generates math problems with progressive difficulty
    %   Supports addition, subtraction, multiplication, and division
    %   with configurable difficulty levels for kids learning math.

    properties (Access = public)
        Level       (1,1) double {mustBePositive, mustBeInteger} = 1
        MaxLevel    (1,1) double {mustBePositive, mustBeInteger} = 10
        Score       (1,1) double = 0
        Streak      (1,1) double = 0  % consecutive correct answers
        ProblemsAttempted (1,1) double = 0
        ProblemsCorrect   (1,1) double = 0
    end

    properties (Constant)
        STREAK_TO_LEVEL_UP = 5   % correct answers in a row to advance
        OPERATIONS = {'+', '-', '*', '/'}
    end

    methods
        function obj = MathChallenge(startLevel)
            if nargin > 0
                obj.Level = min(max(startLevel, 1), obj.MaxLevel);
            end
        end

        function [question, correctAnswer, choices] = generateProblem(obj)
            % GENERATEPROBLEM Creates a math problem based on current level
            %   Returns the question string, correct answer, and 4 multiple choices

            [op, range] = obj.getOperationAndRange();
            [a, b, correctAnswer] = obj.createOperands(op, range);
            question = sprintf('%d %s %d = ?', a, op, b);
            choices = obj.generateChoices(correctAnswer);
        end

        function obj = recordAnswer(obj, isCorrect)
            % RECORDANSWER Updates score and streak based on answer
            obj.ProblemsAttempted = obj.ProblemsAttempted + 1;
            if isCorrect
                obj.ProblemsCorrect = obj.ProblemsCorrect + 1;
                obj.Streak = obj.Streak + 1;
                obj.Score = obj.Score + obj.Level * 10;
                if obj.Streak >= obj.STREAK_TO_LEVEL_UP && obj.Level < obj.MaxLevel
                    obj = obj.levelUp();
                end
            else
                obj.Streak = 0;
                obj.Score = max(0, obj.Score - 5);
            end
        end

        function obj = levelUp(obj)
            if obj.Level < obj.MaxLevel
                obj.Level = obj.Level + 1;
                obj.Streak = 0;
            end
        end

        function acc = getAccuracy(obj)
            if obj.ProblemsAttempted == 0
                acc = 0;
            else
                acc = (obj.ProblemsCorrect / obj.ProblemsAttempted) * 100;
            end
        end

        function [op, range] = getOperationAndRange(obj)
            % GETOPERATIONANDRANGE Returns operation and number range for level
            switch obj.Level
                case 1  % Easy addition
                    op = '+'; range = [1, 10];
                case 2  % Harder addition
                    op = '+'; range = [5, 20];
                case 3  % Easy subtraction
                    op = '-'; range = [1, 10];
                case 4  % Harder subtraction
                    op = '-'; range = [5, 20];
                case 5  % Easy multiplication
                    op = '*'; range = [1, 5];
                case 6  % Harder multiplication
                    op = '*'; range = [2, 10];
                case 7  % Easy division
                    op = '/'; range = [1, 5];
                case 8  % Harder division
                    op = '/'; range = [2, 10];
                case 9  % Mixed easy
                    ops = {'+', '-', '*', '/'};
                    op = ops{randi(4)};
                    range = [1, 10];
                otherwise  % Mixed hard
                    ops = {'+', '-', '*', '/'};
                    op = ops{randi(4)};
                    range = [1, 20];
            end
        end

        function [a, b, result] = createOperands(~, op, range)
            % CREATEOPERANDS Generates operands ensuring kid-friendly results
            lo = range(1);
            hi = range(2);
            switch op
                case '+'
                    a = randi([lo, hi]);
                    b = randi([lo, hi]);
                    result = a + b;
                case '-'
                    a = randi([lo, hi]);
                    b = randi([lo, a]);  % ensure non-negative result
                    result = a - b;
                case '*'
                    a = randi([lo, hi]);
                    b = randi([lo, hi]);
                    result = a * b;
                case '/'
                    b = randi([max(lo,1), hi]);  % divisor > 0
                    result = randi([lo, hi]);     % quotient is a whole number
                    a = b * result;               % ensures clean division
            end
        end

        function choices = generateChoices(~, correctAnswer)
            % GENERATECHOICES Creates 4 choices including the correct one
            choices = zeros(1, 4);
            choices(1) = correctAnswer;

            offsets = [-3, -2, -1, 1, 2, 3, 5, -5];
            offsets = offsets(randperm(length(offsets)));

            idx = 2;
            usedIdx = 1;
            for i = 1:length(offsets)
                if idx > 4
                    break;
                end
                candidate = correctAnswer + offsets(i);
                if candidate >= 0 && ~any(choices(1:usedIdx) == candidate)
                    choices(idx) = candidate;
                    idx = idx + 1;
                    usedIdx = usedIdx + 1;
                end
            end

            % fill remaining with random if needed
            while idx <= 4
                candidate = max(0, correctAnswer + randi([-10, 10]));
                if ~any(choices(1:idx-1) == candidate)
                    choices(idx) = candidate;
                    idx = idx + 1;
                end
            end

            % shuffle choices
            choices = choices(randperm(4));
        end
    end
end
