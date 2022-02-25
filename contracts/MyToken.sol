// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {

    using SafeMath for uint;

    address owner; // Адрес владельца контракта
    string public constant name = "MyToken";
    string public constant symbol = "MTK";
    uint8 public constant decimals = 2; // Количество знаков после запятой для токена
    uint public totalSupply; // Общее количество токенов
    mapping(address => uint) balance; // Здесь храним сколько у кого токенов
    mapping(address => mapping(address => uint)) allowed; // Храним разрешения на перевод токенов

    constructor() {
        owner = msg.sender; // Запоминаем владельца контракта
    }

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner"); // Модификатор для использования функции только владельцем контракта
        _;
    }

    function mint (address _to, uint _amount) public isOwner { // Функция создания новых токенов, добавлеет заданое количество токенов на заданный адрес
        balance[_to] = balance[_to].add(_amount);
        totalSupply = totalSupply.add(_amount);
    }

    function burn (address _from, uint256 _amount) public isOwner { // Уничтожаем указанное кол-во токенов на указанном адресе
        require(balance[_from] >= _amount, "Insufficient funds");
        balance[_from] = balance[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
    }

    function balanceOf(address _user) public view returns(uint) { // Возвращаем значение сколько токенов на балансе
        return balance[_user];
    }

    function transfer(address _recipient, uint _amount) public { // Переводим токены со счёта вызывающего на указанный адрес
        require(balance[msg.sender] >= _amount, "Insufficient funds");
        balance[msg.sender] = balance[msg.sender].sub(_amount);
        balance[_recipient] += balance[_recipient].add(_amount);
    }

    function approve(address _spender, uint _amount) public { // Устанавливаем количество токенов которое может переводить _spendr со счета msg.sender
        allowed[msg.sender][_spender] = _amount;
    }

    function increaseAllowance(address _spender, uint _amount) public { // Увеличиваем кол-во токенов доступных для перевода
        allowed[msg.sender][_spender] += _amount;
    }

    function decreaseAllowance(address _spender, uint _amount) public { // Уменьшаем кол-во токенов доступных для перевода
        require (allowed[msg.sender][_spender] >= _amount, "Insufficient funds");
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].sub(_amount);
    }

    function transferFrom(address _sender, address _recipient, uint _amount) public { // Переводим со счёта _sender на счёт _recipient _amoun токенов
        require(balance[_sender] >= _amount && allowed[_sender][msg.sender] >= _amount, "Insufficient funds");
        balance[_sender] = balance[_sender].sub(_amount);
        balance[_recipient] = balance[_recipient].add(_amount);
        allowed[_sender][msg.sender] = allowed[_sender][msg.sender].sub(_amount);
    }

    function allowance(address _owner, address _sender) public view returns(uint) { // Сколько _sender может перевести со счёта _owner
        return allowed[_owner][_sender];
    }

}