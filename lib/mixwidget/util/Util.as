/* The contents of this file are subject to the Common Public Attribution
 * License Version 1.0. (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://mixwidget.org/license-full. The License is based on the Mozilla Public
 * License Version 1.1, but Sections 14 and 15 have been added to cover use of
 * software over a computer network and provide for limited attribution for the
 * Original Developer. In addition, Exhibit A has been modified to be consistent
 * with Exhibit B.
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * 
 * The Original Code is Mixwidget.org.
 * 
 * The Original Developers are Michael Christoff & Radley Marx.  The Initial 
 * Developers of the Original Code are Michael Christoff & Radley Marx.
 */

package mixwidget.util
{
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	public class Util
	{
		public static var DEBUG:Boolean = true;
		public static var VERBOSE:Boolean = false;
		
		public static function ioError(event:IOErrorEvent):void
    {
      e('io error - ' + event.text);
    }
    
    public static function securityError(event:SecurityErrorEvent):void
    {
      e('security error - ' + event.text);
    }
    
    public static function d(s:String='', level:int = 0):void
    {
      var spacer:String = '';
      var caller:String;
      for(var i:int = 0; i<level; i++) { spacer += '  '; }
      try{
      	throw new Error();
      }catch(e:Error){
      	if(VERBOSE){
      		caller = e.getStackTrace().split(/\r?\n\r?\tat /)[2].replace(/\[[^[]*\]/, "");
      	}else{
      		caller = e.getStackTrace().split(/\r?\n\r?\tat .*::/)[2].replace(/\[[^[]*\]/, "");
      	}
      }
      if(DEBUG) {
      	if(level > 0){
      		trace(spacer + '- ' + s);
      	}else{
      		trace(caller + ': ' + s);
      	}
      }
    }
    
    public static function e(s:String):void
    {
      trace('ERROR: ' + s);
    }
	}
}