pragma solidity ^0.4.24;

contract Uber {

  address public owner;
  
  struct Driver {
    address driverAddr;
    address customerAddr;
    uint farePerKm;
    int latitude;
    int longitude;
    uint phoneNo;
    bool valid;
  }

  mapping(uint => Driver) public driverList;
  mapping (address => uint) mapDriver;
  
  uint public numDrivers;
  uint public regFee;

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  constructor(uint _regFee) public {
    owner = msg.sender;
    regFee = _regFee;
  }

  function registerDriver(uint _fareperkm,uint _phoneno) public payable {
      require (!driverList[mapDriver[msg.sender]].valid,"Not a valid address");
      require (msg.value >= regFee,"Insufficient Registration Fee");
            
      numDrivers = numDrivers + 1;
      driverList[numDrivers] = Driver({
        driverAddr : msg.sender,  
        customerAddr : address(0),
        farePerKm : _fareperkm,
        latitude : 0,
        longitude : 0,
        phoneNo : _phoneno,
        valid  : true
      });
  }

  function searchDrivers(int _latitude,int _longitude) public view returns(uint){
      // write conditions here ....
      //returns driver id
      uint id;
      for(uint i=1;i<=numDrivers;i++){
        int disLat = (_latitude - driverList[i].latitude) * (_latitude - driverList[i].latitude);
        int disLon = (_longitude - driverList[i].longitude) * (_longitude - driverList[i].longitude);
        if(disLat + disLon < 100)
          {
            id = i;
            break;     
          }
      } 
      return id;
  }
  function updateDriverLocation (int _latitude,int _longitude) public {
    require (driverList[mapDriver[msg.sender]].valid,"Not a valid address");

    driverList[mapDriver[msg.sender]].latitude = _latitude;
    driverList[mapDriver[msg.sender]].longitude = _longitude;
  }
  

  /*
  Other functions which needs to be implemented
  
  function startTrip() {
  
  }
  
  function endTrip() {
  
  }

  */


}
