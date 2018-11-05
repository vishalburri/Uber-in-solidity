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
  render: function() {
    var uberInstance;
    var loader = $("#loader");  
    var content = $("#updateride");
    var ridedetails = $("#requestdetails")
    
    loader.hide();
    ridedetails.hide();
    
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddr").html("Your Account: " + account);
      }
    });
    App.contracts.Uber.deployed().then(function(instance) {
        uberInstance = instance;
      });

    // Load account data
  },

  updateDriver : function(){
    var requestdetails = $("#requestdetails")
    var content = $("#updateride");
    var loader = $("#loader");  

    content.hide();
    loader.show();
    
  },

  
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});