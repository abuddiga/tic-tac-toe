pragma solidity 0.4.18;


// contract TicTacToe {

//     // NOTE: All of the content here is just to provide some test examples

//     address owner;

//     // Storage variable must be public if we want automatically have a getter for it
//     uint256 public state;

//     event StateChanged(uint256 changedTo);
//     event Error(string msg);

//     function TicTacToe() {
//         owner = msg.sender;
//     }

//     // Function to test return value, state changes and event emission
//     function main(uint256 _newState) public returns(bool) {
//         if (msg.sender != owner) {
//             Error("You are not the owner");
//             return false;
//         }
//         state = _newState;
//         StateChanged(_newState);
//         return true;
//     }

//     // Function to test VM exception
//     function other(uint256 _newState) public returns(bool) {
//         state = _newState;
//         StateChanged(_newState);
//         // Require goes after state changes in order to demonstrate changes reversion
//         require(msg.sender != owner);
//         return true;
//     }

// }

contract TicTacToe {
    address public playerOne;
    address public playerTwo;
    address public currentTurn;
    address public nextPlayer;
    address public winner;

    bool public ended;

    uint playerOneScore;
    uint playerTwoScore;

    uint[9] squareValues = [1, 2, 4, 8, 16, 32, 64, 128, 256];
    uint[8] winningScores = [7, 56, 73, 84, 146, 273, 292, 448];
    uint[9] occupied; // in the occupied array, 1s represent occupied squares (by either player)

    event GameEnded(address winner);
    event Error(string msg);

    modifier gameNotOver() {
        assert(!ended);
        _;
    }

    modifier isPlayersTurn(address sender) {
        assert(sender == currentTurn);
        _;
    }

    modifier squareIsEmpty(uint sq) {
        require(sq >= 0 && sq < 9);
        require(occupied[sq] == 0);
        _;
    }

    /// Create a new Tic-Tac-Toe Game
    function TicTacToe() public {
        // playerOne = Player({
        //     playerId: msg.sender,
        //     score: 0
        // });
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
        // gameNotOver;
        // playerTwo = Player({
        //     playerId: msg.sender,
        //     score: 0
        // });
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

        if (checkForWin(scoreToCheck)) {
            winner = currentTurn;
            ended = true;
            GameEnded(winner);
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