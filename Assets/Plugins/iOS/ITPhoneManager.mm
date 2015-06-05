#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "UICKeyChainStore.h"

@interface ITPhoneManager : NSObject
+ (ITPhoneManager *) instance;
@end

@implementation ITPhoneManager

CTTelephonyNetworkInfo *networkInfo;
UICKeyChainStore *keychain;

+ (ITPhoneManager *) instance {
    static dispatch_once_t once;
    static ITPhoneManager *_instance;
    dispatch_once(&once, ^ { _instance = [[ITPhoneManager alloc] init]; });
    return _instance;
}

-(instancetype) init {
    self = [super init];
    if (self) {
    	networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    	keychain = [UICKeyChainStore keyChainStoreWithService:@"com.example.app"];
    }
    return self;
}

-(NSString *) getNetworkOperator {
	CTCarrier *carrier = [networkInfo subscriberCellularProvider];

	NSString *mcc = [carrier mobileCountryCode];
	NSString *mnc = [carrier mobileNetworkCode];
	if (mcc != nil && mnc != nil)
	{
		return [mcc stringByAppendingString:mnc];
	}
	return @"";
}

-(NSString *) getMCC {
	CTCarrier *carrier = [networkInfo subscriberCellularProvider];

	NSString *mcc = [carrier mobileCountryCode];
	if (mcc != nil)
	{
		return mcc;
	}
	return @"";
}

-(NSString *) getMNC {
	CTCarrier *carrier = [networkInfo subscriberCellularProvider];

	NSString *mnc = [carrier mobileNetworkCode];
	if (mnc != nil)
	{
		return mnc;
	}
	return @"";
}

-(void) setKeyChainValue:(NSString *)key withValue:(NSString *) value {
	[keychain setString:value forKey:key];
}

-(NSString *) getKeychainValue:(NSString *)key {
	if ([keychain contains:key])
	{
		NSString *value = [keychain stringForKey:key];
		if (value != nil)
		{
			return value;
		}
	}
	return @"";
}
@end

// Helper method to create C string copy
NSString* ITMakeNSString (const char* string) {
    if (string) {
        return [NSString stringWithUTF8String: string];
    } else {
        return [NSString stringWithUTF8String: ""];
    }
}

char* ITMakeCString(NSString *str) {
    const char* string = [str UTF8String];
    if (string == NULL) {
        return NULL;
    }
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

extern "C" {
	const char * _getNetworkOperator();
	const char * _getMCC();
	const char * _getMNC();
	void _setKeyChainValue(const char *key, const char *value);
	const char * _getKeyChainValue(const char *key);
}

const char * _getNetworkOperator() {
    return ITMakeCString([[ITPhoneManager instance] getNetworkOperator]);
}

const char * _getMCC() {
    return ITMakeCString([[ITPhoneManager instance] getMCC]);
}

const char * _getMNC() {
    return ITMakeCString([[ITPhoneManager instance] getMNC]);
}

void _setKeyChainValue(const char *key, const char *value) {
	[[ITPhoneManager instance] setKeyChainValue:ITMakeNSString(key) withValue:ITMakeNSString(value)];
}

const char * _getKeyChainValue(const char *key) {
	return ITMakeCString([[ITPhoneManager instance] getKeychainValue:ITMakeNSString(key)]);
}
