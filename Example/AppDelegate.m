// AppDelegate.m
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AppDelegate.h"

#import "Magento.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
	UITableViewController *viewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end

#else

@implementation AppDelegate

@synthesize window = _window;
@synthesize tableView = _tableView;
@synthesize logsArrayController;

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    [self.window makeKeyAndOrderFront:self];
	Magento.service.storeID = @1;
	[Magento.service renewSession];
	[Magento call:@[@"catalog_product.list"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSArray *products = responseObject;
		NSArray *attributes = @[@"msrp", @"price", @"color", @"size"];
		NSMutableArray *calls = [NSMutableArray array];
		for (NSDictionary *product in products) {
			[calls addObject:@[@"catalog_product.info", product[@"product_id"], Magento.service.storeID, attributes]];
		}
		[Magento multiCall:calls success:^(AFHTTPRequestOperation *operation, NSArray *newProductParts) {
			[products enumerateObjectsUsingBlock:^(NSMutableDictionary *product, NSUInteger idx, BOOL *stop) {
				[product addEntriesFromDictionary:[newProductParts objectAtIndex:idx]];
			}];
			self.logsArrayController.content = products;
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			
		}];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)application
                    hasVisibleWindows:(BOOL)flag
{
    [self.window makeKeyAndOrderFront:self];
    
    return YES;
}

@end

#endif