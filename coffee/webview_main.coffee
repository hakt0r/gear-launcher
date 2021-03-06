###
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
###

$ -> requestAnimationFrame ->
  do Menu.init
  do App.list
  do App.running
  do App.clock
  Sort.current = Sort.default = new Sort
  Mode.default = new Mode.launch menu:false
  Mode.default.toggle()
  new Mode.shell
  new Mode.rename
  new Mode.hide
  new Mode.kill
  new App.ViewMode
