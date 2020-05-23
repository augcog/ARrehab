#  Minigames

Minigames are small self contained AR experiences that are triggered by stepping on certain tiles on the gameboard.

## Creating new Minigames
[Minigame.swift](Minigame.swift) provides a base class for minigames. 

1. Create a new group for your minigame
1. Extend the `Minigame` class as `[Name]Game` in a file named `[Name]Game.swift`
    1. This class is an Entity that will be attached to the ground and will serve as the spawning point of your game's 3D elements.
    1. Publish `score`
    1. Publish `progress`
    1. Implement `attach(ground: Entity, player: Entity)`
    1. Implement `run()`
    1. Implement `endGame()`
    1. Probably implement `init()`
1. Extend the `MinigameViewController` class. This will serve your 2D UI elements. Please note that these elements are overlayed over persistent UI elements from the main game.
1. Add your new minigame to the `Game` enum in [Minigame.swift](Minigame.swift)
    1. Add a case
    1. Add the default instance
    1. Add icons
    1. Add your minigame to the gameboard generation in [GameBoard.swift](../GameBoard.swift)
    
