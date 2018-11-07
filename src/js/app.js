App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("Uber.json", function(uber) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Uber = TruffleContract(uber);
      // Connect provider to interact with contract
      App.contracts.Uber.setProvider(App.web3Provider);

      // App.listenForEvents();

      return App.render();
    });
  },
  render: async function() {
    var loader = $("#loader");  
    var content = $("#searchride");
    var ridedetails = $("#ridedetails");
    
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });
    var uberInstance = await App.contracts.Uber.deployed();
    try {
      var driverId = await uberInstance.getDriverId(App.account);
      var isValid = await uberInstance.getDriverValid(driverId);
      var custaddr = await uberInstance.getCustomer();
      if(custaddr!=0){
        ridedetails.append("<p>Assigned driver "+custaddr+"</p>")
        ridedetails.show();
      }
      else if(!isValid){
        loader.hide();
        content.show();
      }
      else{
        alert('Login from user account');
      }

    }
    catch(err){
      alert('Connect to Metamask');
    }
    // Load account data
  },

  estimateFare : async function(){
    var ridedetails = $("#ridedetails");
    var content = $("#searchride");
    var loader = $("#loader");  
    var curlat = $("#fromlat").val();
    var curlon = $("#fromlon").val();
    var tolat = $("#tolat").val();
    var tolon = $("#tolon").val();
    
    var uberInstance = await App.contracts.Uber.deployed();
    var fare = await uberInstance.getEstimatedFare(curlat,curlon,{from:App.account});
    var estimatedcost = (Math.pow(tolat-curlat,2)+Math.pow(tolon-curlon,2))*fare.toNumber();
    loader.empty();
    if(fare.toNumber()==0)
      loader.append("<center><h2>Could not find estimate.No cabs available right now</h2></center>");
    else
      loader.append("<center><h2>Your estimated cost : "+estimatedcost+" wei</h2></center>");
    loader.show();
  },

  searchDriver : async function(){
    var ridedetails = $("#ridedetails")
    var content = $("#searchride");
    var loader = $("#loader");  
    var curlat = $("#fromlat").val();
    var curlon = $("#fromlon").val();
    var tolat = $("#tolat").val();
    var tolon = $("#tolon").val();

    var uberInstance = await App.contracts.Uber.deployed();
    loader.hide();
    loader.empty();
    loader.append("<center><h2>Searching For Nearby Cabs...</h2></center>");
    loader.append("<center><div class='loading'></div></center>");

    content.hide();
    loader.show();
    const delay = ms => new Promise(res => setTimeout(res, ms));
    await delay(3000);
    var id = await uberInstance.searchDrivers(curlat,curlon,{from:App.account});
    if(id[0]==0){
      loader.empty();
      loader.append("<center><h2>Sorry No Cabs available now.Please try gain later</h2></center>");
    }
    else{
      loader.hide();
      //send request message to all driver id's
      ridedetails.append("<p>Sorry all drivers are busy right now.Please try again later.</p>");

      for(var i=0;i<id.length;i++){
        if(id[i]==0)
          break;
        //send req to available driver
        try{
        await uberInstance.sendRequest(id[i],curlat,curlon,tolat,tolon,{from:App.account});
        }
        //If req cannot be send then send to next driver 
        catch(err){
          console.log(err);
          continue;
        }
        //       wait for response from driver id[i]
        var timerId = await setInterval(async function(){
         // call your function here
         try{
         let res = await uberInstance.getResponse(id[i],{from:App.account});
              clearInterval(timerId);
              if(result){
                  ridedetails.empty();
                  ridedetails.append("<p>Assigned driver "+id[i]+"</p>");
                  alert("Cab Booked");
                  App.render();
                }
                else{
                  console.log("False");
                }
              uberInstance.removeRequest(id[i],{from:App.account});
         }
         catch(err){
            console.log("No response");
         }
        }, 500);

        setTimeout(() => {clearInterval(timerId);},60000);

      }

      //show driver details
      await delay(id.length*60000);
      alert("No cabs available");
      ridedetails.show();
    }
  },
  
  
};

$(function() {
  $(window).load(function() {
      App.init();
  });
});