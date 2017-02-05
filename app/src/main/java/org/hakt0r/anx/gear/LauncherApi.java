package org.hakt0r.anx.gear;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.Base64;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import android.widget.Toast;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.util.List;

import static android.content.Context.ACTIVITY_SERVICE;
import static android.content.Context.INPUT_METHOD_SERVICE;
import static android.content.Context.NOTIFICATION_SERVICE;
import static org.hakt0r.anx.gear.R.drawable.gear_logo;

public class LauncherApi {
    GEARWebView view;
    Context mContext;
    Launcher launcher;
    ActivityManager activity_manager;
    public LauncherApi(Context c, GEARWebView v, Launcher l) { mContext = c; view = v; launcher = l; setupDirs(); }

    public static Bitmap drawableToBitmap (Drawable drawable) {
        Bitmap bitmap = null;
        if (drawable instanceof BitmapDrawable) {
            BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
            if(bitmapDrawable.getBitmap() != null) {
                return bitmapDrawable.getBitmap(); }}
        if(drawable.getIntrinsicWidth() <= 0 || drawable.getIntrinsicHeight() <= 0) {
            bitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888); // Single color bitmap will be created of 1x1 pixel
        } else {
            bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888); }
        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bitmap; }

    private static String imgToBase64(Bitmap image) {
        Bitmap immagex=image;
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        immagex.compress(Bitmap.CompressFormat.PNG, 100, baos);
        byte[] b = baos.toByteArray();
        String imageEncoded = Base64.encodeToString(b, Base64.DEFAULT);
        return imageEncoded; }

    private Boolean exec(String script){
        try { Runtime.getRuntime().exec("su -c " + script); return true;
        } catch (IOException e) { return false; }}

    private Boolean setupDirs(){
        return exec("mkdir -p /data/local/gear/scripts /data/local/gear/run"); }

    @JavascriptInterface
    public String getTasks() {
        final ActivityManager activityManager = (ActivityManager) mContext
                .getSystemService(ACTIVITY_SERVICE);
        final List<ActivityManager.RunningTaskInfo> recentTasks =
                activityManager.getRunningTasks(Integer.MAX_VALUE);
        int len = recentTasks.size();
        StringBuilder sb = new StringBuilder();
        sb.append("[\""); sb.append(recentTasks.get(0).baseActivity.toShortString());
        for (int i = 1; i < len; i++) {
            sb.append("\",\""); sb.append(recentTasks.get(i).baseActivity.toShortString()); }
        sb.append("\"]");
        return sb.toString(); }

    @JavascriptInterface public Boolean showKeyboard() {
        view.post(new Runnable() { @Override public void run() { launcher.showKeyboard(); } });
        return true; }

    @JavascriptInterface public Boolean hideKeyboard() {
        view.post(new Runnable() { @Override public void run() { launcher.hideKeyboard(); } });
        return true; }

    @JavascriptInterface public Boolean toast( String text ) {
        int duration = Toast.LENGTH_SHORT;
        Toast toast = Toast.makeText(mContext, text, duration);
        toast.show();
        return true; }

    @JavascriptInterface public int notify( int mId, String title, String text ) {
        NotificationManager mNotificationManager = (NotificationManager) mContext.getSystemService(NOTIFICATION_SERVICE);
        Intent intent = new Intent(mContext.getApplicationContext(), Launcher.class);
        PendingIntent pi = PendingIntent.getActivity(mContext, 0, intent, 0);
        Notification n = new Notification.Builder(mContext)
                .setContentTitle(title)
                .setContentText(text)
                .setSmallIcon(gear_logo)
                .setContentIntent(pi)
                .build();
        mNotificationManager.notify(mId, n); return mId; }

    @JavascriptInterface public Boolean runScript( String script ) {
        int duration = Toast.LENGTH_SHORT; Toast toast = Toast.makeText(mContext, script, duration); toast.show();
        try {
            Runtime.getRuntime().exec("su -c /data/local/gear/scripts/" + script);
            return true;
        } catch (IOException e) { return false; }}

    @JavascriptInterface public Boolean runToggle( String script ) {
        File file  = new File("/data/local/gear/scripts/" + script);
        if ( !file.exists() ) return false;
        File state = new File("/data/local/gear/run/" + script );
        if ( !state.exists() ){
            exec("/data/local/gear/scripts/" + script + ".start");
            exec("touch /dat/local/gear/run/" + script);
        } else {
            exec("/data/local/gear/scripts/" + script + ".stop");
            exec("rm /dat/local/gear/run/" + script); }
        return true;}

    @JavascriptInterface public Boolean callbackTest() {
        view.post(new Runnable() { @Override public void run() {
            view.eval("console.log('ok');"); } });
        return true; }

    @JavascriptInterface public String getScripts() {
        File f = new File("/data/local/gear/scripts");
        if ( f == null ) return "[1]";
        File[] files = f.listFiles();
        if ( files == null ) return "[2]";
        int len = files.length; StringBuilder sb = new StringBuilder(); sb.append("[\"");
        sb.append(files[0].getName());
        for (int i = 1; i < len; i++){ File ff = files[i]; if (ff.isFile()) { sb.append("\",\""); sb.append(ff.getName()); }}
        sb.append("\"]"); return sb.toString(); }

    @JavascriptInterface public String getApps() {
        Intent mainIntent = new Intent(Intent.ACTION_MAIN, null);
        mainIntent.addCategory(Intent.CATEGORY_LAUNCHER);
        List<ResolveInfo> packages = mContext.getPackageManager().queryIntentActivities( mainIntent, 0);
        int len = packages.size();
        StringBuilder sb = new StringBuilder();
        sb.append("[\""); sb.append(packages.get(0).activityInfo.packageName);
        for (int i = 1; i < len; i++) {
            sb.append("\",\""); sb.append(packages.get(i).activityInfo.packageName); }
        sb.append("\"]"); return sb.toString(); }

    @JavascriptInterface public String getAppName(String packageName) {
        PackageManager packageManager = mContext.getPackageManager();
        ApplicationInfo applicationInfo = null;
        try { applicationInfo = packageManager.getApplicationInfo(packageName, 0); } catch (final PackageManager.NameNotFoundException e) {}
        return (String) (applicationInfo != null ? packageManager.getApplicationLabel(applicationInfo) : "Unknown"); }

    @JavascriptInterface public String getAppIcon(String packageName) {
        Drawable ico = null;
        PackageManager packageManager = mContext.getPackageManager();
        try { ico = packageManager.getApplicationIcon(packageName);
        } catch (PackageManager.NameNotFoundException e) { return ""; }
        return "data:image/png;base64," + imgToBase64(drawableToBitmap(ico)); }

    @JavascriptInterface public Boolean launch( String packageName ) {
        Intent launchIntent = mContext.getPackageManager().getLaunchIntentForPackage(packageName);
        if (launchIntent != null) { mContext.startActivity(launchIntent); return true; }
        return false; }

    @JavascriptInterface public Boolean kill( String packageName ) {
        ActivityManager am = (ActivityManager) mContext.getSystemService(ACTIVITY_SERVICE);
        am.killBackgroundProcesses(packageName);
        return true; }

}
