pragma solidity 0.4.18;

contract TicTacToe {
    address public playerOne;
    address public playerTwo;
    address public currentTurn;
    address private nextPlayer;
    address public winner;

    bool public ended;
    
    uint moves;
    uint playerOneScore;
    uint playerTwoScore;

    uint[9] squareValues = [1, 2, 4, 8, 16, 32, 64, 128, 256];
    uint[8] winningScores = [7, 56, 73, 84, 146, 273, 292, 448];
    uint[9] occupied; // in the occupied array, 1s represent occupied squares (by either player)

    event GameWon(address winner);
    event GameDrawn(string msg);
    event Error(string msg);

    modifier gameNotOver() {
        require(!ended);
        _;
    }

    modifier isPlayersTurn(address sender) {
        require(sender == currentTurn);
        _;
    }

    modifier squareIsEmpty(uint sq) {
        require(sq >= 0 && sq < 9);
        require(occupied[sq] == 0);
        _;
    }

    /// Create a new Tic-Tac-Toe Game
    function TicTacToe() public {
        playerOne = msg.sender;
        playerOneScore = 0;
        currentTurn = playerOne;
        ended = false;
    }

    /// Join game as playerTwo
    function joinGame()
    public
    gameNotOver
    returns(bool) {
        require(playerOne != 0);
        require(playerTwo == 0);
        require(playerOne != msg.sender);
        playerTwo = msg.sender;
        playerTwoScore = 0;
        return true;
    }

    /// Enter the int (0 - 8) of the square you would like to move to.
    /// The top left square is 0, the square to its right is 1, and so on.
    /// The bottom right square is 8.
    function makeMove(uint square)
    public
    gameNotOver
    isPlayersTurn(msg.sender)
    squareIsEmpty(square)
    returns(bool) {
        uint scoreToCheck;

        if (msg.sender == playerOne) {
            playerOneScore += squareValues[square];
            scoreToCheck = playerOneScore;
            nextPlayer = playerTwo;

        } else if (msg.sender == playerTwo) {
            playerTwoScore += squareValues[square];
            scoreToCheck = playerTwoScore;
            nextPlayer = playerOne;
        } else {
            Error("You are not one of the two players of this game!");
            return false;
        }

        occupied[square] = 1;
        moves += 1;

        if (checkForWin(scoreToCheck)) {
            winner = currentTurn;
            ended = true;
            GameWon(winner);
        } else if (moves == 9) {
            GameDrawn("The game is a draw!");
            ended = true;
        }
        
        currentTurn = nextPlayer;

        return true;
    }

    function checkForWin(uint score) private view returns(bool) {
        for (uint i = 0; i < winningScores.length; i += 1) {
            if ((winningScores[i] & score) == winningScores[i]) {
                return true;
            }
        }
        return false;
    }
}
