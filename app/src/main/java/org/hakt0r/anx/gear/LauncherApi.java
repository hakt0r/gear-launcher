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
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.webkit.JavascriptInterface;
import android.widget.Toast;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import static android.content.Context.ACTIVITY_SERVICE;
import static android.content.Context.NOTIFICATION_SERVICE;
import static org.hakt0r.anx.gear.R.drawable.gear_logo;

public class LauncherApi {
    private GEARWebView view;
    private Context mContext;
    private Launcher launcher;
    private ActivityManager activity_manager;
    private HashMap<String, Boolean> toggle;

    public LauncherApi(Context c, GEARWebView v, Launcher l) {
        mContext = c; view = v; launcher = l;
        toggle = new HashMap<String, Boolean>();
        setupDirs();
        initScripts(); }

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
        exec("mkdir -p /data/local/gear/scripts /data/local/gear/run /data/local/gear/icons");
        exec("chmod -R 755 /data/local/gear");
        exec("chmod -R 777 /data/local/gear/icons");
        return true; }

    private void initScripts(){
        File f = new File("/data/local/gear/scripts");
        File[] files = f.listFiles(); if ( files == null ) return ;
        int len = files.length; String name;
        for (File ff : files) { if (ff.isFile()) {
            name = ff.getName();
            if (name.matches(".*\\.toggle"))
                toggle.put(name, exec("sh /data/local/gear/scripts/" + name + " status")); }}}

    @JavascriptInterface public Boolean runScript( String script ) {
        return exec("/data/local/gear/scripts/" + script); }

    @JavascriptInterface public Boolean runToggle( String script ) throws IOException {
        File file  = new File("/data/local/gear/scripts/" + script);
        if ( !file.exists() ) return false;
        if ( !toggle.containsKey(script) || !toggle.get(script)){
            exec("sh /data/local/gear/scripts/" + script + " start");
            toggle.put(script,true); }
        else {
            exec("sh /data/local/gear/scripts/" + script + " stop");
            toggle.put(script,false); }
        return true;}

    @JavascriptInterface public String getApps() {
        // get apps
        Intent mainIntent = new Intent(Intent.ACTION_MAIN, null);
        mainIntent.addCategory(Intent.CATEGORY_LAUNCHER);
        List<ResolveInfo> packages = mContext.getPackageManager().queryIntentActivities( mainIntent, 0);
        int len = packages.size();
        StringBuilder sb = new StringBuilder();
        sb.append("[\""); sb.append(packages.get(0).activityInfo.packageName);
        for (int i = 1; i < len; i++) {
            sb.append("\",\""); sb.append(packages.get(i).activityInfo.packageName); }
        // get scripts
        File f = new File("/data/local/gear/scripts");
        File[] files = f.listFiles(); if ( files != null ){ len = files.length;
        for (int i = 0; i < len; i++){ File ff = files[i]; if (ff.isFile()) {
            sb.append("\",\""); sb.append("script.").append(ff.getName()); }}}
        sb.append("\"]"); return sb.toString(); }

    @JavascriptInterface public String getTasks() {
        final ActivityManager activityManager = (ActivityManager) mContext
                .getSystemService(ACTIVITY_SERVICE);
        final List<ActivityManager.RunningTaskInfo> recentTasks =
                activityManager.getRunningTasks(Integer.MAX_VALUE);
        int len = recentTasks.size();
        StringBuilder sb = new StringBuilder();
        sb.append("[\""); sb.append(recentTasks.get(0).baseActivity.toShortString());
        for (int i = 1; i < len; i++) {
            sb.append("\",\""); sb.append(recentTasks.get(i).baseActivity.toShortString()); }
        Iterator it = toggle.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<String,Boolean> pair;
            pair = (Map.Entry)it.next();
            if ( pair.getValue() == true ){
                Object pkg = pair.getKey();
                if ( toggle.get(pkg) == true )
                    sb.append("\",\""); sb.append("{script."+pkg+"/true}"); }}
        sb.append("\"]");
        return sb.toString(); }

    @JavascriptInterface public String getAppName(String packageName) {
        PackageManager packageManager = mContext.getPackageManager();
        ApplicationInfo applicationInfo = null;
        try { applicationInfo = packageManager.getApplicationInfo(packageName, 0); } catch (final PackageManager.NameNotFoundException e) {}
        return (String) (applicationInfo != null ? packageManager.getApplicationLabel(applicationInfo) : "Unknown"); }

    @JavascriptInterface public String getAppIcon(String packageName) {
        String path = "/data/local/gear/icons/" + packageName + ".png";
        File   file = new File(path); if (file.exists()){ return "file://" + path; }
        Drawable ico = null;
        PackageManager packageManager = mContext.getPackageManager();
        try { ico = packageManager.getApplicationIcon(packageName);
        } catch (PackageManager.NameNotFoundException e) { return ""; }
        return "data:image/png;base64," + imgToBase64(drawableToBitmap(ico)); }

    @JavascriptInterface public Boolean launch( String packageName ) {
        Intent launchIntent = mContext.getPackageManager().getLaunchIntentForPackage(packageName);
        if (launchIntent != null) { mContext.startActivity(launchIntent); return true; }
        return false; }

    @JavascriptInterface public Boolean kill( final String packageName ) {
        exec("am force-stop " + packageName);
        return true; }

    @JavascriptInterface public Boolean showKeyboard() {
        view.post(new Runnable() { @Override public void run() {
            launcher.showKeyboard();
        } });
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
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN) {
            NotificationManager mNotificationManager = (NotificationManager) mContext.getSystemService(NOTIFICATION_SERVICE);
            Intent intent = new Intent(mContext.getApplicationContext(), Launcher.class);
            PendingIntent pi = PendingIntent.getActivity(mContext, 0, intent, 0);
            Notification n = null;
            n = new Notification.Builder(mContext)
                    .setContentTitle(title)
                    .setContentText(text)
                    .setSmallIcon(gear_logo)
                    .setContentIntent(pi)
                    .build();
            mNotificationManager.notify(mId, n); return mId; }
        else return -1; }}
