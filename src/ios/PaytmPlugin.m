#import "PaytmPlugin.h"

#import <Cordova/CDVAvailability.h>

@implementation PaytmPlugin {
    
    NSString* callbackId;
    PGTransactionViewController* txnController;
}

- (void)payWithPaytm:(CDVInvokedUrlCommand *)command {
    
    callbackId = command.callbackId;
    
    // //orderid, cust_id, email, phone,txn_amt,callback_url,checksum_hash,environment
    NSString *merchantId  = [command.arguments objectAtIndex:0];
    NSString *industryTypeId  = [command.arguments objectAtIndex:1];
    NSString *channelId  = [command.arguments objectAtIndex:2];
    NSString *website  = [command.arguments objectAtIndex:3];
    NSString *orderId  = [command.arguments objectAtIndex:4];
    NSString *customerId = [command.arguments objectAtIndex:5];
    NSString *email = [command.arguments objectAtIndex:6];
    NSString *phone = [command.arguments objectAtIndex:7];
    NSString *amount = [command.arguments objectAtIndex:8];
    NSString *callbackURl = [command.arguments objectAtIndex:9];
    NSString *checksumHash = [command.arguments objectAtIndex:10];
    NSString *environment = [command.arguments objectAtIndex:11];

    NSBundle* mainBundle;
    mainBundle = [NSBundle mainBundle];

    //Step 1: Create a default merchant config object
    PGMerchantConfiguration *merchant = [PGMerchantConfiguration defaultConfiguration];

    //Step 2: Create the order with whatever params you want to add. But make sure that you include the merchant mandatory params
    NSMutableDictionary *orderDict = [NSMutableDictionary new];
    //Merchant configuration in the order object

    orderDict[@"MID"] = merchantId;
    orderDict[@"ORDER_ID"] = orderId;
    orderDict[@"CUST_ID"] = customerId;
    orderDict[@"INDUSTRY_TYPE_ID"] = industryTypeId;
    orderDict[@"CHANNEL_ID"] = channelId;
    orderDict[@"TXN_AMOUNT"] = amount;
    orderDict[@"WEBSITE"] = website;
    orderDict[@"CALLBACK_URL"] = callbackURl;
    orderDict[@"CHECKSUMHASH"] = checksumHash;
    orderDict[@"EMAIL"] = email;
    orderDict[@"MOBILE_NO"] = phone;

    PGOrder *order = [PGOrder orderWithParams:orderDict];

    //Step 3: Choose the PG server. In your production build dont call selectServerDialog. Just create a instance of the
    //PGTransactionViewController and set the serverType to eServerTypeProduction

    txnController = [[PGTransactionViewController alloc] initTransactionForOrder:order];
    if ([environment isEqualToString:@"staging"]) {
        txnController.serverType = eServerTypeStaging;
    } else {
        txnController.serverType = eServerTypeProduction;
    }

    txnController.merchant = merchant;
    txnController.delegate = self;
    txnController.loggingEnabled = YES;
    [self showController:txnController];
}

-(void)showController:(PGTransactionViewController *)controller
{
    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    //    [rootVC.navigationController pushViewController:txnController animated:true];
    [rootVC presentViewController:controller animated:YES completion:nil];
}

#pragma mark PGTransactionViewController delegate

-(void)didFinishedResponse:(PGTransactionViewController *)controller response:(NSString *)responseString {
    DEBUGLOG(@"ViewController::didFinishedResponse:response = %@", responseString);
    
    NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (json != nil) {
        if ([json[@"RESPCODE"] integerValue] == 1 || [json[@"RESPCODE"] isEqualToString:@"TXN_SUCCESS"]) {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:responseString];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        } else {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:responseString];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }
    
    [txnController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelTransaction:(PGTransactionViewController *)controller error:(NSError*)error response:(NSDictionary *)response
{
    DEBUGLOG(@"ViewController::didCancelTransaction error = %@ response= %@", error, response);
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:response options:0 error:&err];
    if (err != nil && jsonData != nil) {
        NSString * responseString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:responseString];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    } else {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:response];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
    [txnController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didFinishCASTransaction:(PGTransactionViewController *)controller response:(NSDictionary *)response
{
    DEBUGLOG(@"ViewController::didFinishCASTransaction:response = %@", response);
}

//Called when a user has been cancelled the transaction.

-(void)didCancelTrasaction:(PGTransactionViewController *)controller;{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User has been cancelled the transaction."];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    [txnController dismissViewControllerAnimated:YES completion:nil];
    
}

//Called when a required parameter is missing.

-(void)errorMisssingParameter:(PGTransactionViewController *)controller error:(NSError *) error; {
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.description];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    [txnController dismissViewControllerAnimated:YES completion:nil];
}


@end
