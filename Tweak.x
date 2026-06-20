#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wobjc-method-access"

#import <UIKit/UIKit.h>

// ============================================================
// PHẦN 1: BYPASS NSUSERDEFAULTS
// ============================================================
%hook NSUserDefaults

- (BOOL)boolForKey:(NSString *)key {
    NSArray *premiumKeys = @[
        @"premium", @"pro", @"unlock", @"vip", @"gold", @"plus",
        @"full", @"trial", @"expired", @"subscription", @"purchased",
        @"isPro", @"hasPro", @"isPremium", @"hasPremium",
        @"isUnlocked", @"hasUnlocked", @"isVip", @"hasVip"
    ];
    for (NSString *k in premiumKeys) {
        if ([key.lowercaseString containsString:k]) {
            return YES;
        }
    }
    return %orig;
}

- (id)objectForKey:(NSString *)key {
    if ([key containsString:@"subscription"] || 
        [key containsString:@"purchase"] || 
        [key containsString:@"receipt"]) {
        return @{
            @"status": @"active",
            @"expiry": @"2099-12-31",
            @"plan": @"premium",
            @"is_trial": @NO
        };
    }
    return %orig;
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
    if ([key containsString:@"premium"] || [key containsString:@"pro"]) {
        %orig(YES, key);
        return;
    }
    %orig;
}
%end

// ============================================================
// PHẦN 2: BYPASS IAP & JAILBREAK DETECTION
// ============================================================
%hook SKPaymentQueue
+ (BOOL)canMakePayments {
    return YES;
}
%end

%hook NSBundle
- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key containsString:@"Receipt"]) return @"valid";
    return %orig;
}
%end

%hook UIApplication
- (BOOL)canOpenURL:(NSURL *)url {
    if ([url.scheme containsString:@"cydia"] || [url.scheme containsString:@"sileo"]) {
        return NO;
    }
    return %orig;
}
%end

%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    NSArray *jailbreakPaths = @[@"/Applications/Cydia.app", @"/usr/bin/ssh"];
    for (NSString *jp in jailbreakPaths) {
        if ([path isEqualToString:jp]) return NO;
    }
    return %orig;
}
%end

// ============================================================
// PHẦN 3: HOOK CÁC CLASS PHỔ BIẾN
// ============================================================
%hook PremiumManager
- (BOOL)isPremium { return YES; }
- (BOOL)hasActiveSubscription { return YES; }
- (int)userLevel { return 999; }
- (int)getCoins { return 999999; }
- (id)getSubscriptionStatus {
    return @{@"status": @"active", @"plan": @"premium"};
}
%end

%hook ProManager
- (BOOL)isPro { return YES; }
- (BOOL)hasProAccess { return YES; }
- (int)getScore { return 999999; }
%end

%hook VipManager
- (BOOL)isVip { return YES; }
- (BOOL)hasVipAccess { return YES; }
%end

// ============================================================
// PHẦN 4: HOOK SPRINGBOARD - THÔNG BÁO
// ============================================================
%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        if (window && window.rootViewController) {
            UIAlertController *alert = [UIAlertController 
                alertControllerWithTitle:@"UniversalVIP" 
                message:@"✅ Premium Unlock Active!\n✅ IAP Bypass Active!" 
                preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}
%end

// ============================================================
// PHẦN 5: LOG KHỞI ĐỘNG (KHÔNG CÓ %end THỪA)
// ============================================================
%ctor {
    NSLog(@"=========================================");
    NSLog(@"🚀 UniversalVIP Premium Unlock Loaded!");
    NSLog(@"=========================================");
}
