pragma solidity ^0.4.26;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public isOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract TokenContract {
    
    mapping(address => uint256) balance;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );


    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balance[msg.sender] >= _value);
        balance[msg.sender] -= (_value);
        balance[_to] += (_value);
        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = (_value);
        emit Approval(msg.sender, _spender, (_value));

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balance[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balance[_from] -= (_value);
        balance[_to] += (_value);
        allowed[_from][msg.sender] -= (_value);
        emit Transfer(_from, _to, _value);

        return true;
    }

    function balanceOf(address tokenOwner) external view returns (uint256) {
        return balance[tokenOwner];
    }

    function allowance(address owner, address delegate) external view returns (uint256) {
        return allowed[owner][delegate];
    }
}

contract ERC20Token is TokenContract, Ownable {

    using SafeMath for uint256;

    string public name;
    string public symbol; 
    uint8 public decimals;
    uint16 public exchangeRate;
    uint256 totalCoin;
    
    
    event TokenNameChanged(string indexed previousName, string indexed newName);
    event TokenSymbolChanged(string indexed previousSymbol, string indexed newSymbol);
    event ExhangeRateChanged(uint16 indexed previousRate, uint16 indexed newRate);

    constructor() public {
        decimals = 18;
        totalCoin = 1 * (10 ** uint256(decimals));       // Total Supply of Coin
        balance[owner] = totalCoin;                      // Total Supply Sent to Owner's Address
        exchangeRate = 1000;                             // 1000 coins per ETH (changable)
        symbol = "CMPE";                                 // Token Symbol (changable)
        name = "CMPE 444";                               // Token Name (changable)
    }

    function totalSupply() external view returns (uint256) {
        return totalCoin;
    }

    function changeTokenName(string newName) public isOwner returns (bool success) {
        emit TokenNameChanged(name, newName);
        name = newName;
        return true;
    }

    function changeTokenSymbol(string newSymbol) public isOwner returns (bool success) {
        emit TokenSymbolChanged(symbol, newSymbol);
        symbol = newSymbol;
        return true;
    }

    function changeExhangeRate(uint16 newRate) public isOwner returns (bool success) {
        emit ExhangeRateChanged(exchangeRate, newRate);
        exchangeRate = newRate;
        return true;
    }

    function () public payable {
        fundTokens();
    }

    function fundTokens() public payable {
        require(msg.value > 0);
        uint256 tokens = msg.value.div(10 ** 18).mul(exchangeRate);
        require(balance[owner].sub(tokens) > 0);
        balance[msg.sender] = balance[msg.sender].add(tokens);
        balance[owner] = balance[owner].sub(tokens);
        emit Transfer(msg.sender, owner, msg.value);
        forwardFunds();
    }

    function forwardFunds() internal{
        owner.transfer(msg.value);
    }
}