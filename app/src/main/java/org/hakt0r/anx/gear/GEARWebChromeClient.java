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
