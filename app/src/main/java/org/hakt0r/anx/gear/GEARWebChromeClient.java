package org.hakt0r.anx.gear;

import android.util.Log;
import android.webkit.ConsoleMessage;
import android.webkit.WebChromeClient;

/**
 * Created by anx on 2/5/17.
 */
public class GEARWebChromeClient extends WebChromeClient {

    public boolean onConsoleMessage(ConsoleMessage cm) {
        Log.d("CONSOLE_LOG", cm.message() + " -- From line " + cm.lineNumber() + " of " + cm.sourceId() );
        return true; }
    public void onConsoleMessage(String message, int lineNumber, String sourceID) {
        Log.d("CONSOLE_LOG", message + " -- From line " + lineNumber + " of " + sourceID ); }}
