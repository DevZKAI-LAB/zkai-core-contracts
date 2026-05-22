// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ZkaiPresale is Ownable {
    IERC20 public zkaiToken;
    address public treasury;
    uint256 public rate; // Cuántos ZKAI se dan por cada 1 tBNB

    uint256 public totalRaised;

    event TokensPurchased(address indexed buyer, uint256 amountPaid, uint256 amountReceived);

    constructor(
        address _zkaiToken,
        address _treasury,
        uint256 _rate
    ) Ownable(msg.sender) {
        require(_zkaiToken != address(0), "Direccion del token invalida");
        require(_treasury != address(0), "Direccion de tesoreria invalida");
        require(_rate > 0, "La tasa debe ser mayor a cero");

        zkaiToken = IERC20(_zkaiToken);
        treasury = _treasury;
        rate = _rate;
    }

    // Función para comprar tokens enviando tBNB directamente al contrato
    receive() external payable {
        buyTokens();
    }

    function buyTokens() public payable {
        uint256 bnbAmount = msg.value;
        require(bnbAmount > 0, "Debes enviar BNB para comprar");

        // Calcular la cantidad de tokens a entregar (bnbAmount ya viene con 18 decimales)
        uint256 tokenAmount = bnbAmount * rate;

        // Verificar que la tienda tenga suficientes tokens para vender
        require(zkaiToken.balanceOf(address(this)) >= tokenAmount, "No hay suficientes tokens en la preventa");

        totalRaised += bnbAmount;

        // Enviar el tBNB recaudado directamente a tu billetera de tesorería (Método moderno)
        (bool success, ) = payable(treasury).call{value: bnbAmount}("");
        require(success, "Fallo el envio de BNB a tesoreria");

        // Enviar los tokens ZKAI al comprador
        require(zkaiToken.transfer(msg.sender, tokenAmount), "Fallo la transferencia de tokens");

        emit TokensPurchased(msg.sender, bnbAmount, tokenAmount);
    }

    // Permite al dueño retirar cualquier token ZKAI sobrante de la preventa
    function withdrawRemainingTokens(uint256 amount) external onlyOwner {
        require(zkaiToken.transfer(msg.sender, amount), "Fallo el retiro");
    }

    // Permite cambiar la tasa de precio en el futuro si el BNB sube o baja
    function setRate(uint256 _newRate) external onlyOwner {
        require(_newRate > 0, "La tasa debe ser mayor a cero");
        rate = _newRate;
    }
}
