// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ZkaiToken
 * @dev Token para Zkai Lab. Incluye quema automática del 20% en servicios 
 * y gestión de tesorería para costos de infraestructura (Brevis/BNB).
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ZkaiToken is ERC20, Ownable {
    
    address public treasuryWallet;
    
    // Porcentajes fijos para el modelo económico de Zkai Lab
    uint256 public constant BURN_FEE = 20;     // 20% para reducción de suministro
    uint256 public constant TREASURY_FEE = 80; // 80% para operatividad (Brevis, Gas, Servidores)

    // Eventos para transparencia en la blockchain
    event ServicePaid(address indexed user, uint256 totalAmount, uint256 burned, uint256 treasury);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);

    /**
     * @dev Constructor que establece el nombre, símbolo y suministro inicial.
     * @param _treasury Dirección inicial que recibirá los fondos de los servicios (puedes ser tú o una Safe).
     */
    constructor(address _treasury) ERC20("Zkai Lab", "ZKAI") Ownable(msg.sender) {
        require(_treasury != address(0), "La tesoreria no puede ser la direccion cero");
        treasuryWallet = _treasury;
        
        // Emisión inicial de 1,000,000,000 tokens (con 18 decimales estándar)
        _mint(msg.sender, 1000000000 * 10**decimals());
    }

    /**
     * @dev Función principal para el pago de consultas de IA.
     * El usuario paga 'amount', el contrato quema el 20% y envía el 80% a la tesorería.
     */
    function payAIService(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Saldo insuficiente para pagar el servicio");

        uint256 burnAmount = (amount * BURN_FEE) / 100;
        uint256 treasuryAmount = amount - burnAmount;

        // 1. Quema automática: se envían a la dirección nula (mueren)
        _transfer(msg.sender, address(0), burnAmount);

        // 2. Pago de infraestructura: se envían a la billetera de tesorería
        // Desde aquí se cubrirán los costos de Brevis y el Gas de BNB para el backend
        _transfer(msg.sender, treasuryWallet, treasuryAmount);

        emit ServicePaid(msg.sender, amount, burnAmount, treasuryAmount);
    }

    /**
     * @dev Permite al desarrollador/dueño cambiar la billetera de tesorería.
     * Útil para migrar de una MetaMask personal a una Safe Multi-sig.
     */
    function setTreasuryWallet(address _newTreasury) external onlyOwner {
        require(_newTreasury != address(0), "Direccion invalida");
        address oldTreasury = treasuryWallet;
        treasuryWallet = _newTreasury;
        emit TreasuryUpdated(oldTreasury, _newTreasury);
    }

    /**
     * @dev Función de rescate/gestión. 
     * En caso de que se necesite mover fondos de la tesorería de forma administrativa.
     */
    function manageInfrastructureFunds(uint256 amount) external onlyOwner {
        _transfer(treasuryWallet, owner(), amount);
    }
}