classdef ScoreManager
    % SCOREMANAGER Manages game scoring, level progression, and statistics

    properties (Access = public)
        TotalScore       (1,1) double = 0
        DistanceScore    (1,1) double = 0
        MathScore        (1,1) double = 0
        OpponentsPassedCount (1,1) double = 0
        CurrentLevel     (1,1) double = 1
        LevelDistanceTarget (1,1) double = 1000
        LevelComplete    (1,1) logical = false
        GameComplete     (1,1) logical = false
        MaxLevel         (1,1) double = 10
    end

    properties (Constant)
        POINTS_PER_OPPONENT = 50
        POINTS_PER_DISTANCE = 0.1  % per unit distance
        DISTANCE_PER_LEVEL = 1000
    end

    methods
        function obj = ScoreManager(maxLevel)
            if nargin > 0
                obj.MaxLevel = maxLevel;
            end
        end

        function obj = addMathScore(obj, points)
            obj.MathScore = obj.MathScore + points;
            obj = obj.recalculate();
        end

        function obj = addOpponentPassed(obj)
            obj.OpponentsPassedCount = obj.OpponentsPassedCount + 1;
            obj = obj.recalculate();
        end

        function obj = updateDistance(obj, distance)
            obj.DistanceScore = floor(distance * obj.POINTS_PER_DISTANCE);
            obj = obj.recalculate();
            obj = obj.checkLevelProgress(distance);
        end

        function obj = recalculate(obj)
            obj.TotalScore = obj.MathScore + obj.DistanceScore + ...
                             obj.OpponentsPassedCount * obj.POINTS_PER_OPPONENT;
        end

        function obj = checkLevelProgress(obj, distance)
            target = obj.CurrentLevel * obj.DISTANCE_PER_LEVEL;
            if distance >= target
                obj.LevelComplete = true;
                if obj.CurrentLevel >= obj.MaxLevel
                    obj.GameComplete = true;
                end
            end
        end

        function obj = advanceLevel(obj)
            if obj.LevelComplete && obj.CurrentLevel < obj.MaxLevel
                obj.CurrentLevel = obj.CurrentLevel + 1;
                obj.LevelComplete = false;
                obj.LevelDistanceTarget = obj.CurrentLevel * obj.DISTANCE_PER_LEVEL;
            end
        end

        function pct = getLevelProgress(obj, distance)
            target = obj.CurrentLevel * obj.DISTANCE_PER_LEVEL;
            pct = min(100, (distance / target) * 100);
        end

        function report = getReport(obj)
            report = struct();
            report.TotalScore = obj.TotalScore;
            report.MathScore = obj.MathScore;
            report.DistanceScore = obj.DistanceScore;
            report.OpponentsPassed = obj.OpponentsPassedCount;
            report.Level = obj.CurrentLevel;
            report.GameComplete = obj.GameComplete;
        end
    end
end
