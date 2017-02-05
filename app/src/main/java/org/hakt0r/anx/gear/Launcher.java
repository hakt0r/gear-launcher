package org.hakt0r.anx.gear;

import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.webkit.WebSettings;
import android.webkit.WebView;

public class Launcher extends AppCompatActivity {
    private LauncherApi api;
    private GEARWebView view;

    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        GEARWebView mainWebView;
        WebSettings webSettings;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(true); }

        mainWebView = view = (GEARWebView) findViewById(R.id.mainWebView);
        assert mainWebView != null;

        mainWebView.setWebViewClient(new GEARWebViewClient());
        mainWebView.setWebChromeClient(new GEARWebChromeClient());

        webSettings = mainWebView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        webSettings.setBuiltInZoomControls(false);
        webSettings.setSupportZoom(false);
        webSettings.setDefaultZoom(WebSettings.ZoomDensity.FAR);

        api = new LauncherApi(this,mainWebView,this);
        mainWebView.addJavascriptInterface(api,"API");

        mainWebView.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);

        mainWebView.loadUrl("file:///android_asset/html/index.html");

        InputMethodManager inputManager = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        inputManager.toggleSoftInput (InputMethodManager.SHOW_FORCED, InputMethodManager.HIDE_IMPLICIT_ONLY);
    }

    @Override public boolean onKeyDown(int keyCode, KeyEvent event) {
        assert view != null;
        if ((keyCode == KeyEvent.KEYCODE_BACK)) {
            view.eval("$(window).trigger('backButton')"); return true; }
        else return super.onKeyDown(keyCode, event); }

    @Override public boolean onKeyUp(int keyCode, KeyEvent event) {
        assert view != null;
        if ((keyCode == KeyEvent.KEYCODE_BACK)) { return true; }
        else return super.onKeyUp(keyCode, event); }

    public Boolean showKeyboard() {
        assert view != null;
        view.requestFocus();
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
        InputMethodManager mgr = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        mgr.showSoftInput(view, InputMethodManager.SHOW_FORCED);
        return true; }

    public Boolean hideKeyboard() {
        assert view != null;
        // view.requestFocus();
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM,
                WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);
        InputMethodManager mgr = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        mgr.hideSoftInputFromWindow(view.getWindowToken(), 0);
        return true; }}