pragma solidity ^0.4.24;

contract Uber {

  address public owner;
  
  struct Driver {
    string name;
    address customerAddr;
    string license;
    uint farePerKm;
    int latitude;
    int longitude;
    uint phoneNo;
    bool valid;
  }

  mapping(uint => Driver)  driverList;
  mapping (address => uint)  mapDriver;
  
  uint public numDrivers;
  uint public regFee;

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  constructor(uint _regFee) public {
    owner = msg.sender;
    regFee = _regFee;
  }

  function registerDriver(string _name,string _license,uint _phoneno) public payable {
      require (!driverList[mapDriver[msg.sender]].valid,"Not a valid address");
      require (msg.value >= regFee,"Insufficient Registration Fee");
            
      numDrivers = numDrivers + 1;
      mapDriver[msg.sender] = numDrivers;
      driverList[numDrivers] = Driver({
        name : _name,
        customerAddr : address(0),
        license : _license,
        farePerKm : 0,
        latitude : 0,
        longitude : 0,
        phoneNo : _phoneno,
        valid  : true
      });
  }
  
  function getDriverId (address _addr) public constant returns(uint res)  {
    return mapDriver[_addr];
  }
  
  function getDriverValid (uint _id) public constant returns(bool res)  {
      return driverList[_id].valid;
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
  
  function updateDriverDetails(uint _fareperkm,int _latitude,int _longitude) public {
    require (driverList[mapDriver[msg.sender]].valid,"Not a valid address");

    driverList[mapDriver[msg.sender]].latitude = _latitude;
    driverList[mapDriver[msg.sender]].longitude = _longitude;
    driverList[mapDriver[msg.sender]].farePerKm = _fareperkm;
  }
  

  /*
  Other functions which needs to be implemented
  
  function startTrip() {
  
  }
  
  function endTrip() {
  
  }

  */


}
