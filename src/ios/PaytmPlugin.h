#import "PaymentsSDK.h"
#import <Cordova/CDV.h>

@interface PaytmPlugin : CDVPlugin <PGTransactionDelegate>

- (void)startPayment:(CDVInvokedUrlCommand*)command;

@end
