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

// This class is use just for testing in flex builder. The compiled swf is not
// supposed to work.
//
// Steps to make this work:
//  1) Add src to your build path
//  2) Add lib to your build path
//  3) Add lib/swc/Fl_cpackage.swc to your build libary

package {
  import flash.display.Sprite;
  
  import mixwidget.mixtape.Mixtape;

  public class mixwidget extends Sprite
  {
    public function mixwidget()
    {
      var mixtape:Mixtape = new Mixtape();
//      var debug:Debug = new Debug();
    }
  }
}
