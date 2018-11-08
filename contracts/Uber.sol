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

  struct Reqlist {
    address customerAddr;
    int fromLatitude;
    int fromLongitude;
    int toLatitude;
    int toLongitude;
  }
  
  mapping(uint => Driver)  driverList;
  mapping (address => uint) mapDriver;
  mapping(uint => Reqlist) reqList;

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
  //Getters
  function getDriverId (address _addr) public constant returns(uint res)  {
    return mapDriver[_addr];
  }
  
  function getDriverValid (uint _id) public constant returns(bool res)  {
    return driverList[_id].valid;
  }

  function getDriverFare () public constant returns(uint res)  {
    require (driverList[mapDriver[msg.sender]].valid,"Not a driver address");

    return driverList[mapDriver[msg.sender]].farePerKm;
  }

  function getDriverDetails (uint id) public view returns(string,uint,uint)  {
    require (id >0 && id <=numDrivers,"Invalid id of driver");

    return (driverList[id].name,driverList[id].farePerKm,driverList[id].phoneNo);
  }
  

  function getCustomer() public view returns(uint res)  {
    for(uint i=1;i<=numDrivers;i++){
      if(driverList[i].customerAddr==msg.sender){
        return i;
      }
    }
    return 0;
  }

  
  function max(uint a, uint b) private pure returns (uint) {
        return a > b ? a : b;
  }

  function getEstimatedFare (int _latitude,int _longitude) public view returns(uint res)  {
    require (!driverList[mapDriver[msg.sender]].valid,"Cannot use from driver address");
    
    uint fare;
    for(uint i=1;i<=numDrivers;i++){
        int disLat = (_latitude - driverList[i].latitude) * (_latitude - driverList[i].latitude);
        int disLon = (_longitude - driverList[i].longitude) * (_longitude - driverList[i].longitude);
        if(disLat + disLon < 100)
          {
            fare = max(fare,driverList[i].farePerKm);
          }
      }
    return fare;  
  }
  

  function searchDrivers(int _latitude,int _longitude) public view returns(uint[]){
      require (!driverList[mapDriver[msg.sender]].valid,"Cannot use from driver address");
      //returns driver id
      uint[] memory requestList = new uint[](5);
      uint count = 0;
      for(uint i=1;i<=numDrivers;i++){
        int disLat = (_latitude - driverList[i].latitude) * (_latitude - driverList[i].latitude);
        int disLon = (_longitude - driverList[i].longitude) * (_longitude - driverList[i].longitude);
        if(disLat + disLon < 100 && driverList[i].customerAddr==address(0))
          {
            requestList[count] = i;
            count++;
            if(count==3)
              break;
          }
      } 
      return requestList;
  }

  function sendRequest (uint id,int fromlat,int fromlon,int tolat,int tolon) public {
    require (!driverList[mapDriver[msg.sender]].valid,"Not a valid address");
    require (reqList[id].customerAddr==address(0),"Cannot send to this driver");
      
     reqList[id] = Reqlist({
        customerAddr : msg.sender,
        fromLatitude : fromlat,
        fromLongitude : fromlon,
        toLatitude : tolat,
        toLongitude: tolon
      });
  }

  function getResponse (uint id) public view returns(bool res)  {
    require (!driverList[mapDriver[msg.sender]].valid,"Not a valid address");
    require (reqList[id].customerAddr!=address(0),"Rejected");
    require (driverList[id].customerAddr!=address(0),"Not accepted");
    
    if(driverList[id].customerAddr==msg.sender)
      return true;
    else
      return false;  
  }

  function removeRequest (uint id) public  {
    // require (driverList[id].customerAddr!=address(0),"Not accepted");
    require (!driverList[mapDriver[msg.sender]].valid,"Not a valid address");
    
    reqList[id].customerAddr = address(0); 
  }
  

  function getRequest() public view returns(int fromlat,int fromlon,int tolat,int tolon)  {
    require (driverList[mapDriver[msg.sender]].valid,"Not a valid address");
    require (driverList[mapDriver[msg.sender]].customerAddr==address(0),"Cannot request while driving");
    require (reqList[mapDriver[msg.sender]].customerAddr!=address(0),"No requests");
    
    return (reqList[mapDriver[msg.sender]].fromLatitude,reqList[mapDriver[msg.sender]].fromLatitude,reqList[mapDriver[msg.sender]].toLatitude,reqList[mapDriver[msg.sender]].toLongitude);
  }

  function acceptRequest() public {
    require (driverList[mapDriver[msg.sender]].valid,"Not a valid address");
    require (driverList[mapDriver[msg.sender]].customerAddr==address(0),"Cannot request while driving");

    driverList[mapDriver[msg.sender]].customerAddr = reqList[mapDriver[msg.sender]].customerAddr;
  }
  function rejectRequest() public {
    require (driverList[mapDriver[msg.sender]].valid,"Not a valid address");
    require (driverList[mapDriver[msg.sender]].customerAddr==address(0),"Cannot request while driving");

    reqList[mapDriver[msg.sender]].customerAddr = address(0);
  }

  
  //setters
  
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
