package com.shekarmudaliyar.social_share

import android.app.Activity
import android.content.*
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.share.Sharer
import com.facebook.share.model.ShareLinkContent
import com.facebook.share.model.SharePhoto
import com.facebook.share.model.SharePhotoContent
import com.facebook.share.model.ShareVideo
import com.facebook.share.model.ShareHashtag
import com.facebook.share.model.ShareVideoContent
import com.facebook.share.widget.ShareDialog

class SocialSharePlugin:FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var activeContext: Context? = null
    private var context: Context? = null

    val INSTAGRAM_REQUEST_CODE = 0xc0c3

    private val callbackManager: CallbackManager = CallbackManager.Factory.create()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "social_share")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        activeContext = if (activity != null) activity!!.applicationContext else context!!

        if(call.method == "shareFacebookWall"){
            val image: String? = call.argument("image")
            val video: String? = call.argument("video")
            val link: String? = call.argument("link")
            val hashtag: String? = call.argument("hashtag")

            if(video != null){
                facebookShareVideo(video, hashtag, result)
            }else if(image != null){
                facebookSharePhoto(image, hashtag, result)
            }else if(link != null){
                facebookShareLink(link, hashtag, result)
            }

        }else if (call.method == "shareInstagramWall") {
            //share on instagram wall
            val image: String? = call.argument("image")
            val video: String? = call.argument("video")

            instagramShare("image/*", image, result)

        }else if (call.method == "shareInstagramStory") {
            //share on instagram story
            val stickerImage: String? = call.argument("stickerImage")
            val backgroundImage: String? = call.argument("backgroundImage")
            val backgroundVideo: String? = call.argument("backgroundVideo")
            val backgroundTopColor: String? = call.argument("backgroundTopColor")
            val backgroundBottomColor: String? = call.argument("backgroundBottomColor")

            val intent = Intent("com.instagram.share.ADD_TO_STORY")

            val sourceApplication = "com.appyesorno.and"
            intent.putExtra("source_application", sourceApplication);

            if(stickerImage != null){
                val file =  File(activeContext!!.cacheDir,stickerImage)
                val stickerImageFile = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".provider", file)
                intent.putExtra("interactive_asset_uri", stickerImageFile);
                activity!!.grantUriPermission(
                    "com.instagram.android", stickerImageFile, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            if (backgroundImage!=null) {
                Log.d("debug", "we has image")
                val backfile =  File(activeContext!!.cacheDir,backgroundImage)
                val backgroundImageFile = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".provider", backfile)
                intent.setDataAndType(backgroundImageFile, "image/png")
            }else if(backgroundVideo!=null) {
                val backfile =  File(activeContext!!.cacheDir,backgroundVideo)
                val backgroundVideoFile = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".provider", backfile)
                intent.setDataAndType(backgroundVideoFile,"video/mp4")
            }
            Log.d("", activity!!.toString())
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            // Instantiate activity and verify it will resolve implicit intent
            if (activity!!.packageManager.resolveActivity(intent, 0) != null) {
                activeContext!!.startActivity(intent)
                result.success("success")
            } else {
                result.success("error")
            }
        } else if (call.method == "shareFacebookStory") {
            //share on facebook story
            val stickerImage: String? = call.argument("stickerImage")
            val backgroundImage: String? = call.argument("backgroundImage")
            val backgroundVideo: String? = call.argument("backgroundVideo")
            val backgroundTopColor: String? = call.argument("backgroundTopColor")
            val backgroundBottomColor: String? = call.argument("backgroundBottomColor")
            val appId: String? = call.argument("appId")

            val intent = Intent("com.facebook.stories.ADD_TO_STORY")

            val sourceApplication = "com.appyesorno.and"
            intent.putExtra("source_application", sourceApplication)
            intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appId)

            if(stickerImage != null){
                Log.d("debug", "we has sticker")
                val file =  File(activeContext!!.cacheDir,stickerImage)
                val stickerImageFile = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".provider", file)
                intent.putExtra("interactive_asset_uri", stickerImageFile);
                activity!!.grantUriPermission(
                    "com.facebook.katana", stickerImageFile, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }

            if (backgroundImage!=null) {
                Log.d("debug", "we has image")
                val backfile =  File(activeContext!!.cacheDir,backgroundImage)
                val backgroundImageFile = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".provider", backfile)
                intent.setDataAndType(backgroundImageFile, "image/png")

            }else if(backgroundVideo!=null) {
                //check if background image is also provided
                Log.d("debug", "we has video")
                val backfile =  File(activeContext!!.cacheDir,backgroundVideo)
                val backgroundVideoFile = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".provider", backfile)
                intent.setDataAndType(backgroundVideoFile,"video/mp4")
            }
            Log.d("", activity!!.toString())
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            // Instantiate activity and verify it will resolve implicit intent
            if (activity!!.packageManager.resolveActivity(intent, 0) != null) {
                Log.d("debug", "we has launch 1")
                activeContext!!.startActivity(intent)
                result.success("success")
            } else {
                Log.d("debug", "we has fail")
                result.success("error")
            }
        } else if (call.method == "shareOptions") {
            //native share options
            val content: String? = call.argument("content")
            val image: String? = call.argument("image")
            val intent = Intent()
            intent.action = Intent.ACTION_SEND

            if (image!=null) {
                //check if  image is also provided
                val imagefile =  File(activeContext!!.cacheDir,image)
                val imageFileUri = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".provider", imagefile)
                intent.type = "image/*"
                intent.putExtra(Intent.EXTRA_STREAM,imageFileUri)
            } else {
                intent.type = "text/plain";
            }

            intent.putExtra(Intent.EXTRA_TEXT, content)

            //create chooser intent to launch intent
            //source: "share" package by flutter (https://github.com/flutter/plugins/blob/master/packages/share/)
            val chooserIntent: Intent = Intent.createChooser(intent, null /* dialog title optional */)
            chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

            activeContext!!.startActivity(chooserIntent)
            result.success(true)

        } else if (call.method == "copyToClipboard") {
            //copies content onto the clipboard
            val content: String? = call.argument("content")
            val clipboard =context!!.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newPlainText("", content)
            clipboard.setPrimaryClip(clip)
            result.success(true)
        } else if (call.method == "shareWhatsapp") {
            //shares content on WhatsApp
            val content: String? = call.argument("content")
            val whatsappIntent = Intent(Intent.ACTION_SEND)
            whatsappIntent.type = "text/plain"
            whatsappIntent.setPackage("com.whatsapp")
            whatsappIntent.putExtra(Intent.EXTRA_TEXT, content)
            try {
                activity!!.startActivity(whatsappIntent)
                result.success("true")
            } catch (ex: ActivityNotFoundException) {
                result.success("false")
            }
        } else if (call.method == "shareSms") {
            //shares content on sms
            val content: String? = call.argument("message")
            val intent = Intent(Intent.ACTION_SENDTO)
            intent.addCategory(Intent.CATEGORY_DEFAULT)
            intent.type = "vnd.android-dir/mms-sms"
            intent.data = Uri.parse("sms:" )
            intent.putExtra("sms_body", content)
            try {
                activity!!.startActivity(intent)
                result.success("true")
            } catch (ex: ActivityNotFoundException) {
                result.success("false")
            }
        } else if (call.method == "shareTwitter") {
            //shares content on twitter
            val text: String? = call.argument("captionText")
            val url: String? = call.argument("url")
            val trailingText: String? = call.argument("trailingText")
            val urlScheme = "http://www.twitter.com/intent/tweet?text=$text$url$trailingText"
            Log.d("log",urlScheme)
            val intent = Intent(Intent.ACTION_VIEW)
            intent.data = Uri.parse(urlScheme)
            try {
                activity!!.startActivity(intent)
                result.success("true")
            } catch (ex: ActivityNotFoundException) {
                result.success("false")
            }
        }
        else if (call.method == "shareTelegram") {
            //shares content on Telegram
            val content: String? = call.argument("content")
            val telegramIntent = Intent(Intent.ACTION_SEND)
            telegramIntent.type = "text/plain"
            telegramIntent.setPackage("org.telegram.messenger")
            telegramIntent.putExtra(Intent.EXTRA_TEXT, content)
            try {
                activity!!.startActivity(telegramIntent)
                result.success("true")
            } catch (ex: ActivityNotFoundException) {
                result.success("false")
            }
        }
        else if (call.method == "checkInstalledApps") {
            //check if the apps exists
            //creating a mutable map of apps
            var apps:MutableMap<String, Boolean> = mutableMapOf()
            //assigning package manager
            val pm: PackageManager =context!!.packageManager
            //get a list of installed apps.
            val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
            //intent to check sms app exists
            val intent = Intent(Intent.ACTION_SENDTO).addCategory(Intent.CATEGORY_DEFAULT)
            intent.type = "vnd.android-dir/mms-sms"
            intent.data = Uri.parse("sms:" )
            val resolvedActivities: List<ResolveInfo>  = pm.queryIntentActivities(intent, 0)
            //if sms app exists
            apps["sms"] = resolvedActivities.isNotEmpty()
            //if other app exists
            apps["instagram"] = packages.any  { it.packageName.toString().contentEquals("com.instagram.android") }
            apps["facebook"] = packages.any  { it.packageName.toString().contentEquals("com.facebook.katana") }
            apps["twitter"] = packages.any  { it.packageName.toString().contentEquals("com.twitter.android") }
            apps["whatsapp"] = packages.any  { it.packageName.toString().contentEquals("com.whatsapp") }
            apps["telegram"] = packages.any  { it.packageName.toString().contentEquals("org.telegram.messenger") }
            apps["tiktok"] = packages.any  { it.packageName.toString().contentEquals("com.zhiliaoapp.musically") }

            result.success(apps)
        } else {
            result.notImplemented()
        }
    }

    private fun facebookSharePhoto(imagePath: String?, hashtag: String?, @NonNull result: Result){
        val backfile =  File(activeContext!!.cacheDir,imagePath)
        val uri = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".provider", backfile)
        val photo: SharePhoto = SharePhoto.Builder().setImageUrl(uri).build()
        val hashtagContent: ShareHashtag = ShareHashtag.Builder()
                .setHashtag(hashtag)
                .build()
        val content: SharePhotoContent = SharePhotoContent.Builder().addPhoto(photo)
                     .setShareHashtag(hashtagContent).build()

        val shareDialog = ShareDialog(activity)
        shareDialog.registerCallback(callbackManager, object : FacebookCallback<Sharer.Result?> {
            override fun onSuccess(resultShare: Sharer.Result?) {
                result.success("true")
                Log.d("SocialSharePlugin", "Sharing successfully done.")
            }

            override fun onCancel() {
                result.success("false")
                Log.d("SocialSharePlugin", "Sharing cancelled.")
            }

            override fun onError(error: FacebookException) {
                result.success("false")
                Log.d("SocialSharePlugin", "Sharing error occurred.")
            }
        })
        if (ShareDialog.canShow(SharePhotoContent::class.java)) {
            shareDialog.show(content)
        }
    }

    private fun facebookShareVideo(imagePath: String?, hashtag: String?, @NonNull result: Result){
        val backfile =  File(activeContext!!.cacheDir,imagePath)
        val uri = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".provider", backfile)
        val video: ShareVideo = ShareVideo.Builder()
                .setLocalUrl(uri)
                .build()
        val hashtagContent: ShareHashtag = ShareHashtag.Builder()
                .setHashtag(hashtag)
                .build()
        val content: ShareVideoContent = ShareVideoContent.Builder()
                .setVideo(video)
                .setShareHashtag(hashtagContent)
                .build()

        val shareDialog = ShareDialog(activity)
        shareDialog.registerCallback(callbackManager, object : FacebookCallback<Sharer.Result?> {
            override fun onSuccess(resultShare: Sharer.Result?) {
                result.success("true")
            }

            override fun onCancel() {
                result.success("false")
                Log.d("SocialSharePlugin", "Sharing cancelled.")
            }

            override fun onError(error: FacebookException) {
                result.success("false")
                Log.d("SocialSharePlugin", "Sharing error occurred.")
            }
        })
        if (ShareDialog.canShow(ShareVideoContent::class.java)) {
            shareDialog.show(content)
        }
    }

    private fun facebookShareLink(link: String?, hashtag: String?, @NonNull result: Result){
        val hashtagContent: ShareHashtag = ShareHashtag.Builder()
                .setHashtag(hashtag)
                .build()
        val content: ShareLinkContent = ShareLinkContent.Builder()
                .setContentUrl(Uri.parse(link))
                .setShareHashtag(hashtagContent)
                .build()

        val shareDialog = ShareDialog(activity)
        shareDialog.registerCallback(callbackManager, object : FacebookCallback<Sharer.Result?> {
            override fun onSuccess(resultShare: Sharer.Result?) {
                result.success("true")
                Log.d("SocialSharePlugin", "Sharing successfully done.")
            }

            override fun onCancel() {
                result.success("false")
                Log.d("SocialSharePlugin", "Sharing cancelled.")
            }

            override fun onError(error: FacebookException) {
                result.success("false")
                Log.d("SocialSharePlugin", "Sharing error occurred.")
            }
        })
        if (ShareDialog.canShow(ShareLinkContent::class.java)) {
            shareDialog.show(content)
        }
    }

    private fun instagramShare(type: String?, imagePath: String?, @NonNull result: Result) {
        val backfile =  File(activeContext!!.cacheDir,imagePath)
        val uri = FileProvider.getUriForFile(activeContext!!, activeContext!!.applicationContext.packageName + ".provider", backfile)
        val shareIntent = Intent()
        shareIntent.setAction(Intent.ACTION_SEND)
        shareIntent.setPackage("com.instagram.android")
        try {
            shareIntent.putExtra(Intent.EXTRA_STREAM,
                    Uri.parse("file://$uri"))
        } catch (e: Exception) {
            // TODO Auto-generated catch block
            e.printStackTrace()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.getActivity()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}