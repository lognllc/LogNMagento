LogN Magento
============

LogN Magento is an unofficial client library for Magento Service (SOAPv1). Supports Mac and iOS

Requirements
============   

LogN Magento works on iOS5+ and ARC. It depends on the following lib(s):

* [AFNetworking](https://github.com/AFNetworking/AFNetworking)

You will need LLVM 3.0 or later in order to build LogN Magento. 

Adding LogN Magento to your project
===================================

1. Move inside your git tracked project.
2. Add LogNMagento as a submodule: `git submodule add git://github.com/lognllc/LogNMagento.git`.
3. Open your project in Xcode, than drag and drop `Magento` folder to your classes group (in the Groups & Files view).
4. Don't select Copy items and select a suitable Reference type (relative to project should work fine most of the time). 
5. Add AFNetworking too: `git submodule add git://github.com/AFNetworking/AFNetworking.git`.
6. Add frameworks: `SystemConfigration`, `MobileCoreServices`
7. Add header search path `user/include/libxml2`
8. Define your server

```objective-c
#define MAGENTO_BASE_URL @"http://yourserver/index.php/api/"
#define MAGENTO_USERNAME = @"xxx"
#define MAGENTO_API_KEY = @"xxx"
```
               
Usage
=====

Best practice is to renew session when ｀-applicationDidBecomeActive:`:
  
```objective-c 
- (void)applicationDidBecomeActive:(UIApplication *)application
{
	Magento.service.storeID = @1;
	[Magento.service renewSession];
	...
}
```

An sample of create customer would be:
               
```objective-c
[Magento call:@[@"customer.create", @{
	 @"email": email,
	 @"password": password,
	 @"firstname": firstname,
	 @"lastname": lastname,
	 @"website_id": @1,
	 @"store_id": Magento.service.storeID
}] success:^(AFHTTPRequestOperation *operation, id responseObject) {
	Magento.service.customerID = responseObject;
	NSLog(@"signUp customerID = %@", Magento.service.customerID);
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	NSLog(@"error %@", error.localizedDescription);
}];
```
	
License
=======
LogN Magento is available under the MIT license.
