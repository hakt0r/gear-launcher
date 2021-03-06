/*
 * Copyright (C) 2017 Sebastian Glaser <anx@ulzq.de>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 3
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

package org.hakt0r.anx.gear;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.webkit.WebSettings;
import android.webkit.WebView;

import static org.hakt0r.anx.gear.R.id;
import static org.hakt0r.anx.gear.R.layout;

public class Launcher extends AppCompatActivity {
    private LauncherApi api;
    private GEARWebView view;

    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(layout.activity_main);

        GEARWebView mainWebView;
        WebSettings webSettings;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(true); }

        mainWebView = view = (GEARWebView) findViewById(id.mainWebView);
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

        mainWebView.loadUrl("file:///android_asset/html/index.html"); }

    @Override protected void onNewIntent(Intent intent) {
        if ( intent.getSelector() != null && intent.getSelector().hasCategory(Intent.CATEGORY_APP_CALCULATOR) ){
            view.post(new Runnable() { @Override public void run() { view.eval("$(window).trigger('hotkey_1')"); }});
        } else view.post(new Runnable() { @Override public void run() { view.newIntentRecieved(); }});}

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
        InputMethodManager mgr = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        mgr.showSoftInput(view, InputMethodManager.SHOW_FORCED);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);
        view.requestFocus();
        return true; }

    public Boolean hideKeyboard() {
        assert view != null;
        InputMethodManager mgr = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        mgr.hideSoftInputFromWindow(view.getWindowToken(), 0);
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM, WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);
        return true; }}