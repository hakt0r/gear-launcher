package org.hakt0r.anx.gear;

import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * Created by anx on 2/5/17.
 */
public class GEARWebViewClient extends WebViewClient {
    @Override public boolean shouldOverrideUrlLoading(WebView view, String url) {
        view.loadUrl(url);
        return true; }}
