// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {

    address owner; // Адрес владельца контракта
    string public name; // Имя токена
    string public symbol; // Краткое название
    uint8 public decimals; // Количество знаков после запятой для токена
    uint public totalSupply; // Общее количество токенов

    mapping(address => uint) balance; // Здесь храним сколько у кого токенов
    mapping(address => mapping(address => uint)) allowed; // Храним разрешения на перевод токенов

    event Transfer(address indexed _from, address indexed _to, uint _amount);
    event Approval(address indexed _from, address indexed _to, uint _amount);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, address _to, uint _totalSupply) {
        owner = msg.sender; // Запоминаем владельца контракта

        name = _name; // Запоминаем имя
        symbol = _symbol; // Краткое название
        decimals = _decimals; // Устанавливаем количество знаков после запятой

        mint(_to, _totalSupply); // Генерим _totalSupply токенов на адрес _to
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner"); // Модификатор для использования функции только владельцем контракта
        _;
    }

    function mint (address _to, uint _amount) public onlyOwner { // Функция создания новых токенов, добавлеет заданое количество токенов на заданный адрес
        balance[_to] += _amount;
        totalSupply += _amount;
    }

    function burn (address _from, uint256 _amount) public onlyOwner { // Уничтожаем указанное кол-во токенов на указанном адресе
        require(balance[_from] >= _amount, "Insufficient funds");
        balance[_from] -= _amount;
        totalSupply -= _amount;
    }

    function balanceOf(address _user) public view returns(uint) { // Возвращаем значение сколько токенов на балансе
        return balance[_user];
    }

    function transfer(address _recipient, uint _amount) public { // Переводим токены со счёта вызывающего на указанный адрес
        require(balance[msg.sender] >= _amount, "Insufficient funds");
        balance[msg.sender] -= _amount;
        balance[_recipient] += _amount;
        emit Transfer(msg.sender, _recipient,_amount);
    }

    function approve(address _spender, uint _amount) public { // Устанавливаем количество токенов которое может переводить _spendr со счета msg.sender
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
    }

    function increaseAllowance(address _spender, uint _amount) public { // Увеличиваем кол-во токенов доступных для перевода
        allowed[msg.sender][_spender] += _amount;
    }

    function decreaseAllowance(address _spender, uint _amount) public { // Уменьшаем кол-во токенов доступных для перевода
        require (allowed[msg.sender][_spender] >= _amount);
        allowed[msg.sender][_spender] -= _amount;
    }

    function transferFrom(address _sender, address _recipient, uint _amount) public { // Переводим со счёта _sender га счёт _recipient _amoun токенов
        require(balance[_sender] >= _amount && allowed[_sender][msg.sender] >= _amount, "Insufficient funds");
        balance[_sender] -= _amount;
        balance[_recipient] += _amount;
        allowed[_sender][msg.sender] -= _amount;
        emit Transfer(_sender, _recipient,_amount);
    }

    function allowance(address _owner, address _sender) public view returns(uint) { // Сколько _sender может перевести со счёта _owner
        return allowed[_owner][_sender];
    }

}