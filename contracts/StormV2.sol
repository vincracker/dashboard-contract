// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract StormV2 is Initializable, ERC20PausableUpgradeable, AccessControlUpgradeable {

    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");
    bytes32 public constant ONBOARDING_ROLE = keccak256("ONBOARDING_ROLE");
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");

    event freezeAccountEvent(address account);
    event unfreezeAccountEvent(address account);

    mapping(address => bool) private _frozen;

    address[] private _frozenAddresses;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC20_init("Storm","STRM");
        __ERC20Pausable_init();
        __AccessControl_init();
        __Context_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(USER_ROLE, ONBOARDING_ROLE);
    }

    function mint(address to, uint256 amount) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Can not mint: you are not an ADMIN.");
        require(hasRole(USER_ROLE, to), "Can not mint: recipient is not a USER.");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Can not burn: you are not an ADMIN.");
        _burn(from, amount);
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(hasRole(USER_ROLE, to), "Can not transfer: recipient is not a USER.");
        require(!_frozen[msg.sender], "Can not transfer: your funds are currently frozen.");
        require(!_frozen[to], "Can not transfer: the recipient's STORM account is frozen.");
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(hasRole(USER_ROLE, to), "Can not transfer: recipient is not a USER.");
        require(hasRole(USER_ROLE, msg.sender), "You must hold USER status to send tokens.");
        require(!_frozen[msg.sender], "Can not transfer: your account is currently frozen.");
        require(!_frozen[to], "Can not transfer: the recipient's STORM account is frozen.");
        require(!_frozen[from], "Can not transfer: the sender's STORM account is frozen.");
        return super.transferFrom(from, to, value);
    }

    function revokeRole(bytes32 role, address account) public override {
        require(!((role == USER_ROLE) && (balanceOf(account) > 0)), "Onboarding officer cannot revoke USER_ROLE if that user has a positive STORM balance.");
        super.revokeRole(role, account);
    }

    function freeze(address account) public {
        require(hasRole(COMPLIANCE_ROLE, msg.sender), "Only compliance officers may freeze funds.");
        // check duplicate freeze, prevent insert two same address to the array
        if(_frozen[account] != true){
            _frozen[account] = true;
            _frozenAddresses.push(account);
        }
        emit freezeAccountEvent(account);
    }

    function unfreeze(address account) public {
        require(hasRole(COMPLIANCE_ROLE, msg.sender), "Only compliance officers may unfreeze funds.");
        _frozen[account] = false;

        // get the index of unfreeze address, and delete the address in array
        for(uint16 i = 0; i < _frozenAddresses.length; i++){
            if(account == _frozenAddresses[i]){
                delete _frozenAddresses[i];
                break;
            }
        }
        emit unfreezeAccountEvent(account);
    }

    function isAccountFrozen(address account) public view returns (bool) {
        return _frozen[account];
    }

    function getFrozenList() public view returns(address[] memory ){
        return _frozenAddresses;
    }

    function pause() public whenNotPaused {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Can not pause: you are not an ADMIN.");
        _pause();
    }

    function unpause() public whenPaused {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Can not unpause: you are not an ADMIN.");
        _unpause();
    }

}

