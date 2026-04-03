classdef MathGate
    % MATHGATE A floating math challenge gate on the road
    %   When the player rides through it, a math question appears.

    properties (Access = public)
        XPos    (1,1) double = 0.5
        YPos    (1,1) double = 1.0
        Width   (1,1) double = 0.2
        Active  (1,1) logical = true
        Question      string = ""
        CorrectAnswer (1,1) double = 0
        Choices       (1,4) double = [0 0 0 0]
    end

    methods
        function obj = MathGate(xPos, yPos, question, correctAnswer, choices)
            if nargin > 0
                obj.XPos = xPos;
            end
            if nargin > 1
                obj.YPos = yPos;
            end
            if nargin > 2
                obj.Question = question;
            end
            if nargin > 3
                obj.CorrectAnswer = correctAnswer;
            end
            if nargin > 4
                obj.Choices = choices;
            end
        end

        function obj = update(obj, dt, playerSpeed)
            if ~obj.Active
                return;
            end
            relativeSpeed = playerSpeed * 0.005;
            obj.YPos = obj.YPos - relativeSpeed * dt;
            if obj.YPos < -0.2
                obj.Active = false;
            end
        end

        function hitbox = getHitbox(obj)
            hitbox = [obj.XPos - obj.Width, obj.XPos + obj.Width, ...
                      obj.YPos - 0.03, obj.YPos + 0.03];
        end

        function correct = checkAnswer(obj, selectedAnswer)
            correct = (selectedAnswer == obj.CorrectAnswer);
        end
    end

    methods (Static)
        function gate = createFromChallenge(mathChallenge)
            % Creates a gate using the MathChallenge generator
            [q, ans, ch] = mathChallenge.generateProblem();
            xPos = 0.3 + rand() * 0.4;  % random lane position
            gate = MathGate(xPos, 1.1, q, ans, ch);
        end
    end
end
