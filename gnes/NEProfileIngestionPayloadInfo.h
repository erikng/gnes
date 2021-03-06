/*
* This header is generated by classdump-dyld 1.0
* on Friday, March 4, 2022 at 8:33:41 PM Central Standard Time
* Operating System: Version 11.6 (Build 20G165)
* Image Source: /System/Library/Frameworks/NetworkExtension.framework/Versions/A/NetworkExtension
* classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
*/

@class NSString, NSDate;

@interface NEProfileIngestionPayloadInfo : NSObject <NSCopying> {
	char _isSetAside;
	NSString* _payloadProtocolType;
	NSString* _payloadUUID;
	NSString* _payloadOrganization;
	NSString* _profileOrganization;
	NSString* _profileIdentifier;
	NSString* _profileUUID;
	NSDate* _profileIngestionDate;
	NSString* _systemVersion;
	long long _profileSource;
}

@property (copy) NSString * payloadProtocolType;              //@synthesize payloadProtocolType=_payloadProtocolType - In the implementation block
@property (copy) NSString * payloadUUID;                      //@synthesize payloadUUID=_payloadUUID - In the implementation block
@property (copy) NSString * payloadOrganization;              //@synthesize payloadOrganization=_payloadOrganization - In the implementation block
@property (copy) NSString * profileOrganization;              //@synthesize profileOrganization=_profileOrganization - In the implementation block
@property (copy) NSString * profileIdentifier;                //@synthesize profileIdentifier=_profileIdentifier - In the implementation block
@property (copy) NSString * profileUUID;                      //@synthesize profileUUID=_profileUUID - In the implementation block
@property (copy) NSDate * profileIngestionDate;               //@synthesize profileIngestionDate=_profileIngestionDate - In the implementation block
@property (copy) NSString * systemVersion;                    //@synthesize systemVersion=_systemVersion - In the implementation block
@property (assign) char isSetAside;                           //@synthesize isSetAside=_isSetAside - In the implementation block
@property (assign) long long profileSource;                   //@synthesize profileSource=_profileSource - In the implementation block
-(char)isSetAside;
-(NSString *)profileOrganization;
-(NSDate *)profileIngestionDate;
-(long long)profileSource;
-(id)init;
-(NSString *)systemVersion;
-(NSString *)profileUUID;
-(NSString *)profileIdentifier;
-(NSString *)payloadUUID;
-(NSString *)payloadProtocolType;
-(NSString *)payloadOrganization;
@end

