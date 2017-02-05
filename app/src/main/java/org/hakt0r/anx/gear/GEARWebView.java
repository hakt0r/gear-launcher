package org.hakt0r.anx.gear;

import android.content.Context;
import android.graphics.Rect;
import android.os.Build;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.inputmethod.InputMethodManager;
import android.webkit.WebView;

public class GEARWebView extends WebView {
    public GEARWebView(Context context){ super(context); }
    public GEARWebView(Context context, AttributeSet attrs){ super(context,attrs); }
    public GEARWebView(Context context, AttributeSet attrs, int defStyle){ super(context,attrs,defStyle); }
    public void eval(String code){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) { evaluateJavascript(code,null); }
        else loadUrl("javascript:" + code); }
    @Override public boolean onKeyPreIme(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) { return true; }
        return false; }
    @Override public void onWindowVisibilityChanged (int visibility){
        if (visibility == WebView.VISIBLE){
            eval( "window.$(window).trigger(\"visible\");"); }
        else { eval( "window.$(window).trigger(\"invisible\");"); }}
    @Override public boolean onCheckIsTextEditor() { return true; }}
