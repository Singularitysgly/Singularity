// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesCompUpgradeable.sol";
/**
 * @dev {ERC20} token, including:
 *
 *  - Preminted initial supply
 *  - Ability for holders to burn (destroy) their tokens
 *  - No access control mechanism (for minting/pausing) and hence no governance
 *
 * This contract uses {ERC20Burnable} to include burn capabilities - head to
 * its documentation for details.
 *
 * _Available since v3.4._
 */
contract ERC20PresetFixedSupplyUpgradeable is Initializable, ERC20BurnableUpgradeable,ERC20PermitUpgradeable,ERC20VotesCompUpgradeable {
    function initialize(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address owner
    ) public virtual initializer {
        __ERC20PresetFixedSupply_init(name, symbol, initialSupply, owner);
    }
    /**
     * @dev Mints `initialSupply` amount of token and transfers them to `owner`.
     *
     * See {ERC20-constructor}.
     */
    function __ERC20PresetFixedSupply_init(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address owner
    ) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
        __ERC20Burnable_init_unchained();
        __ERC20Permit_init(name);
        __ERC20VotesComp_init_unchained();
        __ERC20PresetFixedSupply_init_unchained(name, symbol, initialSupply, owner);
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        return ERC20VotesUpgradeable._mint(account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        return ERC20VotesUpgradeable._burn(account, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        return ERC20VotesUpgradeable._afterTokenTransfer(from, to, amount);
    }

    function __ERC20PresetFixedSupply_init_unchained(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address owner
    ) internal initializer {
        _mint(owner, initialSupply);
    }
    uint256[50] private __gap;
}
