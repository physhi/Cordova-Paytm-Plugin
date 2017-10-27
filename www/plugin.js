var exec = require('cordova/exec');
var PLUGIN_NAME = 'PaytmPlugin';
var PaytmPlugin = 
module.exports = {
    startPayment: function(options, successCallback, failureCallback) {
        cordova.exec(
            successCallback,
            failureCallback,
            "PaytmPlugin",
            "startPayment",
            [JSON.stringify(options)]);
    }
};
