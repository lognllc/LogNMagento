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

The simplest way to add the LogN Magento to your project is to directly drag Magento folder to your project.

1. Download the latest code version from the repository (you can simply use the Download Source button and get the zip or tar archive of the master branch).
2. Extract the archive.
3. Open your project in Xcode, than drag and drop `Magento` folder to your classes group (in the Groups & Files view). 
4. Make sure to select Copy items when asked. 

If you have a git tracked project, you can add LogN Magento as a submodule to your project. 

1. Move inside your git tracked project.
2. Add LogNMagento as a submodule using `git submodule add git://github.com/lognllc/LogNMagento.git` .
3. Open your project in Xcode, than drag and drop `Magento` folder to your classes group (in the Groups & Files view). 
4. Don't select Copy items and select a suitable Reference type (relative to project should work fine most of the time). 
               
Usage
=====

Before import Magento.h to your header, be sure to define these values:

```objective-c
#define MAGENTO_BASE_URL =
#define MAGENTO_USERNAME =
#define MAGENTO_API_KEY =
```

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
LogN Magento is available under the MIT license. See the LICENSE file for more info.
