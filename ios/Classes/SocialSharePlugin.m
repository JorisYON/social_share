//
//  Created by Shekar Mudaliyar on 12/12/19.
//  Copyright © 2019 Shekar Mudaliyar. All rights reserved.
//

#import "SocialSharePlugin.h"
#import <AVFoundation/AVFoundation.h>
#include <objc/runtime.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@implementation SocialSharePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"social_share" binaryMessenger:[registrar messenger]];
    SocialSharePlugin* instance = [[SocialSharePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}



- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"shareInstagramStory" isEqualToString:call.method]) {
        //Sharing story on instagram
        
        NSLog(@"Share insta");
        NSString *stickerImage = call.arguments[@"stickerImage"];
        NSString *backgroundTopColor = call.arguments[@"backgroundTopColor"];
        NSString *backgroundBottomColor = call.arguments[@"backgroundBottomColor"];
        NSString *backgroundImage = call.arguments[@"backgroundImage"];
        NSString *backgroundVideo = call.arguments[@"backgroundVideo"];
        //getting image from file
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isFileExist = [fileManager fileExistsAtPath: stickerImage];
        UIImage *imgShare;
        if (isFileExist) {
            //if image exists
            imgShare = [[UIImage alloc] initWithContentsOfFile:stickerImage];
        }
        //url Scheme for instagram story
        NSURL *urlScheme = [NSURL URLWithString:@"instagram-stories://share?source_application=com.appyesorno.yesorno"];
        
        //adding data to send to instagram story
        if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
            //if instagram is installed and the url can be opened
            if ( [ backgroundImage  length] == 0 && [ backgroundVideo  length] == 0 ) {
                //If you dont have a background image
                // Assign background image asset
                NSLog(@"Share sticker");
                NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.stickerImage" : imgShare,
                                               @"com.instagram.sharedSticker.backgroundTopColor" : backgroundTopColor,
                                               @"com.instagram.sharedSticker.backgroundBottomColor" : backgroundBottomColor,
                                               @"com.instagram.sharedSticker.contentURL" : @"https://play.google.com/store/apps/details?id=com.instagram.android&hl=en&gl=US"
                }];
                if (@available(iOS 10.0, *)) {
                    NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
                    // This call is iOS 10+, can use 'setItems' depending on what versions you support
                    [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
                    
                    [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                    //if success
                    result(@"sharing");
                } else {
                    result(@"this only supports iOS 10+");
                }
                
            } else if ( [ backgroundVideo  length] != 0 ) {
                if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                    NSURL *backgroundVideoURL = [[NSURL alloc] initFileURLWithPath:backgroundVideo];
                    NSData *const videoBackgroundShare = [NSData dataWithContentsOfURL:backgroundVideoURL];
                    
                    // Assign background and sticker image assets to pasteboard
                    NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.backgroundVideo" : videoBackgroundShare,
                                                   @"com.instagram.sharedSticker.stickerImage" : stickerImage}];
                    
                    NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
                    // This call is iOS 10+, can use 'setItems' depending on what versions you support
                    [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
                    
                    [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                } else {
                    // Handle older app versions or app not installed case
                }
            } else {
                if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                    
                    UIImage *imgBackgroundShare = [[UIImage alloc] initWithContentsOfFile:backgroundImage];
                    
                    // Assign background and sticker image assets to pasteboard
                    NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.backgroundImage" : imgBackgroundShare,
                                                   @"com.instagram.sharedSticker.stickerImage" : stickerImage}];
                    NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
                    // This call is iOS 10+, can use 'setItems' depending on what versions you support
                    [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
                    
                    [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                } else {
                    // Handle older app versions or app not installed case
                }
            }
        } else {
            result(@"not supported or no facebook installed");
        }
    } else if ([@"shareInstagramWall" isEqualToString:call.method]){
        NSString *backgroundImage = call.arguments[@"image"];
        NSString *backgroundVideo = call.arguments[@"video"];
        NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
        
        UIImage *imgShare = [[UIImage alloc] initWithContentsOfFile:backgroundImage];
        
        if([[UIApplication sharedApplication] canOpenURL:instagramURL]) //check for App is install or not
        {
            UIImage *imageToUse = imgShare;
            NSString *documentDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *saveImagePath=[documentDirectory stringByAppendingPathComponent:@"Image.igo"];
            NSData *imageData=UIImagePNGRepresentation(imageToUse);
            [imageData writeToFile:saveImagePath atomically:YES];
            NSLog(@"Copied file");
            NSURL *imageURL=[NSURL fileURLWithPath:saveImagePath];
            self.documentController = [self setupControllerWithURL:imageURL usingDelegate:self];
            self.documentController.annotation = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Testing"], @"InstagramCaption", nil];
            
            UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
            [self.documentController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:vc.view animated:YES];
        }
        else {
            NSLog(@"Cant share to insta");
        }
    }else if ([@"shareFacebookStory" isEqualToString:call.method]) {
        NSString *stickerImage = call.arguments[@"stickerImage"];
        NSString *backgroundTopColor = call.arguments[@"backgroundTopColor"];
        NSString *backgroundBottomColor = call.arguments[@"backgroundBottomColor"];
        NSString *backgroundVideo = call.arguments[@"backgroundVideo"];
        NSString *backgroundImage = call.arguments[@"backgroundImage"];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSString *appID = call.arguments[@"FacebookAppID"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isFileExist = [fileManager fileExistsAtPath: stickerImage];
        UIImage *imgShare;
        if (isFileExist) {
            imgShare = [[UIImage alloc] initWithContentsOfFile:stickerImage];
        }
        NSURL *urlScheme = [NSURL URLWithString:@"facebook-stories://share"];
        if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
            
            if ( [ backgroundImage  length] == 0 && [ backgroundVideo  length] == 0 ) {
                //If you dont have a background image
                // Assign background image asset
                NSLog(@"Share sticker");
                NSArray *pasteboardItems = @[@{@"com.facebook.sharedSticker.stickerImage" : stickerImage,
                                               @"com.facebook.sharedSticker.backgroundTopColor" : backgroundTopColor,
                                               @"com.facebook.sharedSticker.backgroundBottomColor" : backgroundBottomColor,
                                               @"com.facebook.sharedSticker.appID" : appID}];
                if (@available(iOS 10.0, *)) {
                    NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
                    // This call is iOS 10+, can use 'setItems' depending on what versions you support
                    [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
                    
                    [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                    //if success
                    result(@"sharing");
                } else {
                    result(@"this only supports iOS 10+");
                }
                
            }else if ( [ backgroundVideo  length] != 0 ) {
                
                NSLog(@"Share facebook video story");
                if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                    NSURL *backgroundVideoURL = [[NSURL alloc] initFileURLWithPath:backgroundVideo];
                    NSData *const videoBackgroundShare = [NSData dataWithContentsOfURL:backgroundVideoURL];
                    
                    // Assign background and sticker image assets to pasteboard
                    NSArray *pasteboardItems = @[@{@"com.facebook.sharedSticker.backgroundVideo" : videoBackgroundShare,
                                                   @"com.facebook.sharedSticker.appID" : appID}];
                    
                    NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
                    // This call is iOS 10+, can use 'setItems' depending on what versions you support
                    [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
                    
                    [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                } else {
                    // Handle older app versions or app not installed case
                }
            } else {
                if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                    
                    UIImage *imgBackgroundShare = [[UIImage alloc] initWithContentsOfFile:backgroundImage];
                    
                    // Assign background and sticker image assets to pasteboard
                    NSArray *pasteboardItems = @[@{@"com.facebook.sharedSticker.backgroundImage" : imgBackgroundShare,
                                                   @"com.facebook.sharedSticker.appID" : appID}];
                    NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
                    // This call is iOS 10+, can use 'setItems' depending on what versions you support
                    [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
                    
                    [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                } else {
                    // Handle older app versions or app not installed case
                }
            }
            
        } else {
            result(@"not supported or no facebook installed");
        }
    } else if([@"shareFacebookWall" isEqualToString:call.method]){
        
        NSString *image = call.arguments[@"image"];
        NSString *video = call.arguments[@"video"];
        NSString *link = call.arguments[@"link"];
        NSString *hashtag = call.arguments[@"hashtag"];
        
        if ([image length] != 0) {
            
            NSLog(@"Sharing image");
            UIImage *imgShare = [[UIImage alloc] initWithContentsOfFile:image];
            FBSDKSharePhoto *sharePhoto = [[FBSDKSharePhoto alloc] initWithImage:imgShare isUserGenerated:false];
            FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
            content.photos = @[sharePhoto];
            content.hashtag = [[FBSDKHashtag alloc] initWithString:hashtag];
            
            UIViewController *controller =[UIApplication sharedApplication].keyWindow.rootViewController;
            
            FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] initWithViewController:controller content: content delegate:nil];
            dialog.mode = FBSDKShareDialogModeShareSheet;
            
            NSLog(@"Sharing facebook wall");
            
            [dialog show];
        }else if([video length] != 0){
            
            NSURL *videoURL = [[NSURL alloc] initFileURLWithPath:video];
            
            NSData *const videoShare = [NSData dataWithContentsOfURL:videoURL];
            
            FBSDKShareVideo *shareVideo = [[FBSDKShareVideo alloc] initWithData:videoShare previewPhoto:nil];
            FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
            content.video = shareVideo;
            content.hashtag = [[FBSDKHashtag alloc] initWithString:hashtag];
            
            UIViewController *controller =[UIApplication sharedApplication].keyWindow.rootViewController;
            
            FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] initWithViewController:controller content: content delegate:nil];
            dialog.mode = FBSDKShareDialogModeShareSheet;
            
            NSLog(@"Sharing facebook wall video");
            
            [dialog show];
        }else if([link length] != 0){
            
            NSString *urlString = @"fbapi://";
                NSURL *url1 = [NSURL URLWithString:urlString];

                if ([[UIApplication sharedApplication] canOpenURL:url1]) {
                    NSLog(@"can open facebook app");
                }
                else {
                    NSLog(@"cannot open facebook app");
                }
            
            NSURL *linkURL = [[NSURL alloc] initWithString: link];
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            content.contentURL = linkURL;
            content.hashtag = [[FBSDKHashtag alloc] initWithString:hashtag];
            
            UIViewController *controller =[UIApplication sharedApplication].keyWindow.rootViewController;
            
            FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] initWithViewController:nil content: content delegate:nil];
            dialog.fromViewController = controller;
            
            dialog.mode = FBSDKShareDialogModeShareSheet;
            
            NSLog(@"Sharing facebook wall link");
            
            [dialog show];
        }
        
    } else if ([@"copyToClipboard" isEqualToString:call.method]) {
        NSString *content = call.arguments[@"content"];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        //assigning content to pasteboard
        pasteboard.string = content;
        result([NSNumber numberWithBool:YES]);
    } else if ([@"shareTwitter" isEqualToString:call.method]) {
        // NSString *assetImage = call.arguments[@"assetImage"];
        NSString *captionText = call.arguments[@"captionText"];
        NSString *urlstring = call.arguments[@"url"];
        NSString *trailingText = call.arguments[@"trailingText"];
        
        NSString* urlTextEscaped = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString: urlTextEscaped];
        NSURL *urlScheme = [NSURL URLWithString:@"twitter://"];
        if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
            //check if twitter app exists
            //check if it contains a link
            if ( [ [url absoluteString]  length] == 0 ) {
                NSString *urlSchemeTwitter = [NSString stringWithFormat:@"twitter://post?message=%@",captionText];
                NSURL *urlSchemeSend = [NSURL URLWithString:urlSchemeTwitter];
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:urlSchemeSend options:@{} completionHandler:nil];
                    result(@"sharing");
                } else {
                    result(@"this only supports iOS 10+");
                }
            } else {
                //check if trailing text equals null
                if ( [ trailingText   length] == 0 ) {
                    //if trailing text is null
                    NSString *urlSchemeSms = [NSString stringWithFormat:@"twitter://post?message=%@",captionText];
                    //appending url with normal text and url scheme
                    NSString *urlWithLink = [urlSchemeSms stringByAppendingString:[url absoluteString]];
                    
                    //final urlscheme
                    NSURL *urlSchemeMsg = [NSURL URLWithString:urlWithLink];
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:urlSchemeMsg options:@{} completionHandler:nil];
                        result(@"sharing");
                    } else {
                        result(@"this only supports iOS 10+");
                    }
                } else {
                    //if trailing text is not null
                    NSString *urlSchemeSms = [NSString stringWithFormat:@"twitter://post?message=%@",captionText];
                    //appending url with normal text and url scheme
                    NSString *urlWithLink = [urlSchemeSms stringByAppendingString:[url absoluteString]];
                    NSString *finalurl = [urlWithLink stringByAppendingString:trailingText];
                    //final urlscheme
                    NSURL *urlSchemeMsg = [NSURL URLWithString:finalurl];
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:urlSchemeMsg options:@{} completionHandler:nil];
                        result(@"sharing");
                    } else {
                        result(@"this only supports iOS 10+");
                    }
                }
            }
        } else {
            result(@"cannot find Twitter app");
        }
    } else if ([@"shareSms" isEqualToString:call.method]) {
        NSString *msg = call.arguments[@"message"];
        NSString *urlstring = call.arguments[@"urlLink"];
        NSString *trailingText = call.arguments[@"trailingText"];
        
        NSURL *urlScheme = [NSURL URLWithString:@"sms://"];
        
        NSString* urlTextEscaped = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString: urlTextEscaped];
        //check if it contains a link
        if ( [ [url absoluteString]  length] == 0 ) {
            //if it doesn't contains a link
            NSString *urlSchemeSms = [NSString stringWithFormat:@"sms:?&body=%@",msg];
            NSURL *urlScheme = [NSURL URLWithString:urlSchemeSms];
            if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
                    result(@"sharing");
                } else {
                    result(@"this only supports iOS 10+");
                }
            } else {
                result(@"cannot find Sms app");
            }
        } else {
            //if it does contains a link
            //check if trailing text equals null
            if ( [ trailingText   length] == 0 ) {
                //if trailing text is null
                //url scheme with normal text message
                NSString *urlSchemeSms = [NSString stringWithFormat:@"sms:?&body=%@",msg];
                //appending url with normal text and url scheme
                NSString *urlWithLink = [urlSchemeSms stringByAppendingString:[url absoluteString]];
                //final urlscheme
                NSURL *urlSchemeMsg = [NSURL URLWithString:urlWithLink];
                if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:urlSchemeMsg options:@{} completionHandler:nil];
                        result(@"sharing");
                    } else {
                        result(@"this only supports iOS 10+");
                    }
                } else {
                    result(@"cannot find Sms app");
                }
            } else {
                //if trailing text is not null
                NSString *urlSchemeSms = [NSString stringWithFormat:@"sms:?&body=%@",msg];
                //appending url with normal text and url scheme
                NSString *urlWithLink = [urlSchemeSms stringByAppendingString:[url absoluteString]];
                NSString *finalUrl = [urlWithLink stringByAppendingString:trailingText];
                
                //final urlscheme
                NSURL *urlSchemeMsg = [NSURL URLWithString:finalUrl];
                if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:urlSchemeMsg options:@{} completionHandler:nil];
                        result(@"sharing");
                    } else {
                        result(@"this only supports iOS 10+");
                    }
                } else {
                    result(@"cannot find Sms app");
                }
            }
            
        }
    } else if ([@"shareSlack" isEqualToString:call.method]) {
        //NSString *content = call.arguments[@"content"];
        result([NSNumber numberWithBool:YES]);
    } else if ([@"shareWhatsapp" isEqualToString:call.method]) {
        NSString *content = call.arguments[@"content"];
        NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",content];
        NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            [[UIApplication sharedApplication] openURL: whatsappURL];
            result(@"sharing");
        } else {
            result(@"cannot open whatsapp");
        }
        result([NSNumber numberWithBool:YES]);
    } else if ([@"shareTelegram" isEqualToString:call.method]) {
        NSString *content = call.arguments[@"content"];
        NSString * urlScheme = [NSString stringWithFormat:@"tg://msg?text=%@",content];
        NSURL * telegramURL = [NSURL URLWithString:[urlScheme stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([[UIApplication sharedApplication] canOpenURL: telegramURL]) {
            [[UIApplication sharedApplication] openURL: telegramURL];
            result(@"sharing");
        } else {
            result(@"cannot open Telegram");
        }
        result([NSNumber numberWithBool:YES]);
    } else if ([@"shareOptions" isEqualToString:call.method]) {
        NSString *content = call.arguments[@"content"];
        NSString *image = call.arguments[@"image"];
        //checking if it contains image file
        if ([image isEqual:[NSNull null]] || [ image  length] == 0 ) {
            //when image is not included
            NSArray *objectsToShare = @[content];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            UIViewController *controller =[UIApplication sharedApplication].keyWindow.rootViewController;
            [controller presentViewController:activityVC animated:YES completion:nil];
            result([NSNumber numberWithBool:YES]);
        } else {
            //when image file is included
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isFileExist = [fileManager fileExistsAtPath: image];
            UIImage *imgShare;
            if (isFileExist) {
                imgShare = [[UIImage alloc] initWithContentsOfFile:image];
            }
            NSArray *objectsToShare = @[content, imgShare];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            UIViewController *controller =[UIApplication sharedApplication].keyWindow.rootViewController;
            [controller presentViewController:activityVC animated:YES completion:nil];
            result([NSNumber numberWithBool:YES]);
        }
    } else if ([@"checkInstalledApps" isEqualToString:call.method]) {
        NSMutableDictionary *installedApps = [[NSMutableDictionary alloc] init];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram-stories://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"instagram"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"instagram"];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"facebook-stories://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"facebook"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"facebook"];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"twitter"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"twitter"];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"sms"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"sms"];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whatsapp://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"whatsapp"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"whatsapp"];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tiktok://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"tiktok"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"tiktok"];
        }
        
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tg://"]]) {
            [installedApps setObject:[NSNumber numberWithBool: YES] forKey:@"telegram"];
        } else {
            [installedApps setObject:[NSNumber numberWithBool: NO] forKey:@"telegram"];
        }
        result(installedApps);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.UTI = @"com.instagram.exclusivegram";
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"completed");
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"fail %@",error.description);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"cancel");
}

@end
