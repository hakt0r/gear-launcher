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

import android.content.Context;
import android.os.Build;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.webkit.WebView;

public class GEARWebView extends WebView {
    public Boolean wasInvisible = false;
    public GEARWebView(Context context){ super(context); }
    public GEARWebView(Context context, AttributeSet attrs){ super(context,attrs); }
    public GEARWebView(Context context, AttributeSet attrs, int defStyle){ super(context,attrs,defStyle); }
    public void eval(String code){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) { evaluateJavascript(code,null); }
        else loadUrl("javascript:" + code); }
    @Override public boolean onKeyPreIme(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) { eval( "$(window).trigger(\"syskey\",\"back\");"); return true; }
        return false; }
    @Override public boolean onKeyUp(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) { eval( "$(window).trigger(\"syskey\",\"upback\");"); return true; }
        return false; }
    @Override public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) { eval( "$(window).trigger(\"syskey\",\"back\");"); return true; }
        if (keyCode == KeyEvent.KEYCODE_HOME) { eval( "$(window).trigger(\"syskey\",\"home\");"); return true; }
        if (keyCode == KeyEvent.KEYCODE_MENU) { eval( "$(window).trigger(\"syskey\",\"menu\");"); return true; }
        return false; }
    @Override public void onWindowVisibilityChanged (int visibility){
        if (visibility == WebView.VISIBLE){
            eval( "$(window).trigger(\"visible\");"); }
        else {
            wasInvisible = true;
            eval( "$(window).trigger(\"invisible\");"); }}
    public void newIntentRecieved (){
        if ( wasInvisible ) { wasInvisible = false; return; }
        eval( "$(window).trigger(\"syskey\",\"home\");"); }
    @Override public boolean onCheckIsTextEditor() { return true; }}
