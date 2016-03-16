var App = App || {};

App.Alerts = {
  settings : {
    "closeButton": true,
    "newestOnTop": true,
    "progressBar": true,
    "positionClass": "toast-bottom-right",
    "preventDuplicates": true,
    "showDuration": "300",
    "hideDuration": "1000",
    "timeOut": "5000",
    "extendedTimeOut": "1000",
    "showEasing": "swing",
    "hideEasing": "linear",
    "showMethod": "fadeIn",
    "hideMethod": "fadeOut"
  },
  success : function(title, message){
    toastr.options = App.Alerts.settings;
    toastr["success"](message, title);
  },

  warning: function(title, message){
    toastr.options = App.Alerts.settings;
    toastr["warning"](message, title);
  },

  error: function(title, message){
    toastr.options = App.Alerts.settings;
    toastr["error"](message, title);
  },
  info: function(title, message){
    toastr.options = App.Alerts.settings;
    toastr["info"](message, title);
  }
}

App.CartItemModel = function(item){
  this.sku = ko.observable(item.sku);
  this.name = ko.observable(item.name);
  this.price = ko.computed(function(){
    return accounting.formatMoney(item.price / 100);
  });

  this.description = ko.observable(item.description);
  this.quantity = ko.observable(item.quantity);
  this.image = ko.computed(function(){
    return "/images/products/" + item.image;
  });

};

App.CartViewModel = function(data){
  var items = [];
  var self = this;

  _.each(data.items, function(item){
    items.push(new App.CartItemModel(item));
  });

  this.customer_name = ko.observable(data.customer_name);
  this.customer_email = ko.observable(data.customer_email);
  this.description = ko.observable(function(){
    return "Order for " + self.customer_name();
  })
  this.items = ko.observableArray(items);
  this.total = ko.computed(function(){
    return accounting.formatMoney(data.summary.total / 100);
  });


  //shipping address
  this.shipping_address = {};
  var addressKeys =_.keys(data.address);
  _.each(addressKeys, function(key){
    self.shipping_address[key] = ko.observable(data.address[key])
  });

  this.terms_accepted = ko.observable(false);
  this.showCheckoutForm = ko.observable(true);
  this.showProgressBar = ko.computed(function(){
    return !self.showCheckoutForm();
  });

  this.needShipping = ko.computed(function(){
    return !(self.shipping_address.street() &&
    self.shipping_address.city() &&
    self.shipping_address.state() &&
    self.shipping_address.zip());
  });

  this.needNameAndEmail = ko.computed(function(){
    return !(self.customer_name() && self.customer_email());
  });

  //paymentType
  this.processor = ko.observable("stripe");

  this.payment_ready = ko.computed(function(){
    //terms need to be accepted, shipping filled out, name and email
    var ready = (!self.needNameAndEmail() &&
    !self.needShipping() &&
    self.terms_accepted());

    return ready;
  });

  this.cartHasItems = ko.computed(function(){
    return self.items().length > 0;
  });
  this.nothingInCart = ko.computed(function(){
    return self.items().length <= 0;
  });

  this.removeItem = function(item){
    $.post("/api/v1/cart/remove_item", {sku: item.sku()})
      .done(function(data){
        self.items.remove(item);
        App.Alerts.info("Item Removed", "Removed " + item.name() + " from the cart.")
      })
      .fail(function(err){
        App.Alerts.error("Oops!", "Looks like we had a problem")
      });
  }

  this.updateQuantity = function(item){
    $.post("/api/v1/cart/update_cart_item", {sku: item.sku(), quantity: item.quantity()})
      .done(function(data){
        if(item.quantity() <= 0){
          App.Alerts.info("Item Removed", "Removed " + item.name());
          self.items.remove(item);
        }else{
          App.Alerts.info("Item Changed", "Updated " + item.name() + " to " + item.quantity())
        }
      })
      .fail(function(err){
        App.Alerts.error("Oops!", "Looks like we had a problem")
      });
  };

  this.loadStripeCheckout = function(){
    //pull from viewModel
    var processor = self.processor();

    // Close Checkout on page navigation
    $(window).on('popstate', function() {
      handler.close();
    });

    var handler = StripeCheckout.configure({
      key: "pk_iOvwBcTgalyrXBZ7joENi86h9Hv9a",
      image: '/images/logo-small.png',
      zipCode : true,
      email : self.customer_email(),
      bitcoin : true,
      allowRememberMe : true,
      address : true,
      token: function(token) {

        window.scrollTo(0,0);
        self.showCheckoutForm(false);

        //this has all of our checkout data on it
        var checkout = {
          customer_name : self.customer_name(),
          customer_email : self.customer_email(),
          token : token
        };

        $.post("/api/v1/checkout", checkout)
          .done(function(response){
            console.log(response);
          })
          .error(function(err){
            console.log(err);
          });
      }
    });


    handler.open({
      name: 'The Rocket Shop',
      description: self.description(),
      amount: self.total()
    });
  }
};
