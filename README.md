# MathRash - Race & Learn Math!

A Road Rash-inspired motorcycle racing game built in MATLAB that teaches kids addition, subtraction, multiplication, and division through gameplay.

## How to Play

### Quick Start
```matlab
cd src
MathRash()
```

### Controls
| Key | Action |
|-----|--------|
| Arrow Keys | Steer left/right |
| 1-4 | Answer math questions / Select starting level |
| SPACE | Start game |
| P | Pause/Resume |
| R | Restart (from game over) |
| Q | Quit |

### Gameplay
- **Ride** your motorcycle down the road and avoid opponents
- **Math Gates** (purple `?` markers) appear on the road — ride through them!
- **Correct answer** = Speed Boost + Shield + Points
- **Wrong answer** = Slow down
- **5 correct in a row** = Level up!
- **3 lives** — colliding with opponents costs a life

### Level Progression
| Level | Math Operation | Number Range |
|-------|---------------|-------------|
| 1-2 | Addition | 1-20 |
| 3-4 | Subtraction | 1-20 |
| 5-6 | Multiplication | 1-10 |
| 7-8 | Division | 1-10 |
| 9-10 | Mixed Operations | 1-20 |

## Project Structure
```
MathRash/
├── src/
│   ├── MathRash.m          # Main entry point
│   ├── GameEngine.m        # Core game loop & state management
│   ├── Player.m            # Player motorcycle
│   ├── Opponent.m          # AI opponents
│   ├── Road.m              # Road rendering & scrolling
│   ├── MathChallenge.m     # Math problem generator
│   ├── MathGate.m          # In-game math challenge gates
│   ├── CollisionDetector.m # AABB collision detection
│   ├── ScoreManager.m      # Scoring & level progression
│   └── UIManager.m         # All UI rendering
├── tests/
│   ├── TestMathChallenge.m     # Math generation tests
│   ├── TestPlayer.m            # Player mechanics tests
│   ├── TestCollisionDetector.m # Collision logic tests
│   ├── TestScoreManager.m      # Scoring tests
│   ├── TestGameEngine.m        # Integration tests
│   └── TestResourceLeaks.m     # Memory/resource leak tests
├── runTests.m              # Test runner script
└── README.md
```

## Running Tests
```matlab
runTests
```

This runs all unit tests, integration tests, and resource leak checks.

## Requirements
- MATLAB R2020b or later
- No additional toolboxes required

## License
MIT
