#import <Flutter/Flutter.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface SocialSharePlugin : NSObject<FlutterPlugin>

@property (nonatomic, retain) UIDocumentInteractionController *documentController;

@end
