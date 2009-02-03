/* The contents of this file are subject to the Common Public Attribution
 * License Version 1.0. (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://mixwidget.com/license. The License is based on the Mozilla Public
 * License Version 1.1, but Sections 14 and 15 have been added to cover use of
 * software over a computer network and provide for limited attribution for the
 * Original Developer. In addition, Exhibit A has been modified to be consistent
 * with Exhibit B.
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * 
 * The Original Code is Mixwidget.
 * 
 * The Original Developers are Michael Christoff & Radley Marx.  The Initial 
 * Developers of the Original Code are Michael Christoff & Radley Marx.
 * 
 */

package mixwidget.mixtape 
{
	
	import com.pixelfumes.reflect.Reflect;
	
	import fl.transitions.Tween;
	import fl.transitions.easing.Regular;
	
	import flash.display.MovieClip;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mixwidget.media.AudioEvent;
	import mixwidget.media.FlashAudioPlayer;
	import mixwidget.mixtape.bumper.Bumper;
	import mixwidget.mixtape.controls.Controller;
	import mixwidget.mixtape.controls.FirstPlayBtn;
	import mixwidget.mixtape.events.MixtapeEvent;
	import mixwidget.mixtape.menu.Menu;
	import mixwidget.mixtape.template.Basic;
	import mixwidget.util.Util;
	import mixwidget.util.XmlLoader;
		public class Mixtape extends MovieClip	{ 
		//XSPF namespace stuff
    namespace xspf = "http://xspf.org/ns/0/";
    use namespace xspf;
		
		// instance vars
    private var bumper:Bumper;
    private var template:Basic;
    private var controller:Controller;
    private var reflection:Reflect;
    private var first_play_btn:FirstPlayBtn;
    private var widget_menu:Menu;
		
		// flashvars
	  private var widget_config_url:String;
	  private var playlist_url:String;
	  private var image_url:String;
	  private var skin_url:String;
	  private var autoplay:Boolean = false;
	  
	  // member vars
	  private var widget_xml:XML;
	  private var playlist_xml:XML;
	  private var widget_config_loaded:Boolean = false;
	  private var playlist_loaded:Boolean = false;
	  private var widget_menu_loaded:Boolean = false;
	  private var template_height:Number; // need these becuase reflection changes
    private var template_width:Number; // probably not neccssary 
	  
	  private var player:FlashAudioPlayer;
	  	
	  //**********************************
    // Constructor Methods
    //**********************************
	  
	  public function Mixtape()
	  {	  	
	  	// config
      Security.allowDomain("*");
      Util.DEBUG = false;
	  	
	  	// In accordance with the Mixwidget License the "license" and "activateContextMenu"
	  	// method below must not be modified, moved, removed, or in any way inhibited
	  	// from being executed. In the case of "license" this includes
	  	// globally disabling trace statements. If you wish to disable debugging statements
	  	// use Util.DEBUG = false.
	  	license();
	  	activateContextMenu();
	  	
	  	Util.d();
	    
	    // init
	    Global.stage = this.stage;
	    this.player = new FlashAudioPlayer();
	    this.addEventListener(Event.ENTER_FRAME, loadCompleteCheck);
      getFlashVars();
      loadXML();
	    this.addEventListener(Event.ENTER_FRAME, onStageLoad);
	  }
	  
	  private function onStageLoad(event:Event):void
    {
      if(this.loaderInfo.bytesLoaded == this.loaderInfo.bytesTotal)
      {
        this.removeEventListener(Event.ENTER_FRAME, onStageLoad);
        loadBumper();
        loadController();
      }
    }
    
    //**********************************
    // BUMPER
    //**********************************
    
    private function loadBumper():void
    {
      Util.d();
      bumper = new Bumper();
      bumper.init(this, root.loaderInfo.width, root.loaderInfo.height);
      this.addChild(bumper);
    }
    
    //**********************************
    // CONTROLLER
    //**********************************
    
    private function loadController():void
    {
      Util.d();
      controller = new Controller();
      
      this.addChild(controller);
      controller.alpha  = 0;
      controller.x      = 0;
      controller.y      = 220;

      controller.init(this, player, playlist_xml, root.loaderInfo.width, root.loaderInfo.height);
      
      controller.visible = false;
    }
		
		private function loadCompleteCheck(event:Event):void
    {
      if (this.widget_config_loaded && this.playlist_loaded) 
      {
        Util.d('loadComplete: widget config & playlist loaded');
        removeEventListener(Event.ENTER_FRAME, loadCompleteCheck);
        this.template.applyPlaylist(this.playlist_xml);
        this.dispatchEvent(new MixtapeEvent(MixtapeEvent.INIT_LOAD_COMPLETE));
      }
    }
		
		private function getFlashVars():void
		{
			this.widget_config_url = this.loaderInfo.parameters.config;
			this.playlist_url = this.loaderInfo.parameters.playlist;
			this.image_url = this.loaderInfo.parameters.image;
			this.skin_url = this.loaderInfo.parameters.skin;
			
			var fv_ap:String = this.loaderInfo.parameters.autoplay;
			this.autoplay = (!fv_ap || fv_ap == 'false' || fv_ap == '0') ? false : true;
			
			if(!widget_config_url || widget_config_url == ""){
				Util.d('using default config: config.xml');
				this.widget_config_url = 'config.xml';
			}
			
			if(!playlist_url || playlist_url == ""){
				Util.d('using default playlist: playlist.xspf');
				this.playlist_url = 'playlist.xspf';
			}
		}
		
		//++++++++++++++++++++++++++++++++++
    // XML Load Methods
    //++++++++++++++++++++++++++++++++++
		
		private function loadXML():void
		{
			var wl:XmlLoader = new XmlLoader(this.widget_config_url);
			var pl:XmlLoader = new XmlLoader(this.playlist_url);
			
			wl.addEventListener(Event.COMPLETE, widgetConfigLoaded);
			pl.addEventListener(Event.COMPLETE, playlistLoaded);
		}
		
		private function widgetConfigLoaded(event:Event):void
		{
			Util.d('widget config loaded');
			this.widget_xml = (event.target as XmlLoader).xml;
		  this.loadTemplate();	
		}
		
		private function loadTemplate():void
    {
      this.template = new Basic(this.image_url, this.skin_url);
      this.template.playable = true;
      this.template.initPlayer(player);
      // this.addChild(template); // why adding 2x?
      
      this.template.visible = false;
      
      this.addChild(template);
      this.setChildIndex(template, 0);
      
      this.template_width = this.template.width;
      this.template_height = this.template.height;
      
      var width:Number;
      if(this.stage.stageWidth  / this.stage.stageHeight > 345 / 265){ // width is greater, go by height
      	// temp_height = (265 - 211.1)
      	width = this.stage.stageHeight * 345 / 265;
      }else{
      	width = this.stage.stageWidth;
      }
      
      Util.d('stageWidth: ' + this.stage.stageWidth + ' ' + this.template.width + ' ' + this.template.scaleX, 1);
      Util.d('stageHeight: ' + this.stage.stageHeight + ' ' + this.template.height + ' ' + this.template.scaleY, 1);
      this.template.x = 5; //Math.round(this.stage.stageWidth - width * 332/345) / 2;
      // this.template.x = ( Math.round(this.stage.stageWidth - (this.template_width * this.template.scaleX)) / 2);
      this.template.y = 5;// Math.round(this.stage.stageHeight - this.stage.stageHeight * 211.6/265) / 2 - 21;//( Math.round(this.stage.stageHeight - (this.template_height * this.template.scaleY)) / 2) - 21;
      Util.d('template x: ' + this.template.x + ' ' + 'y: ' + this.template.y, 1);
      Util.d('template w: ' + this.template_width + ' ' + 'h: ' + this.template_height, 1);
      
      this.template.addEventListener(MixtapeEvent.TEMPLATE_LOAD_COMPLETE, onTemplateComplete);

      this.template.init();

      this.template.widget = this.widget_xml;
      this.template.config();
      
      this.reflection = new Reflect({mc:this.template, alpha:50, ratio:50, distance:1, 
        updateTime:-1, reflectionDropoff:1.2, 
        mcWidth:this.template_width, mcHeight:this.template_height});
        
      Util.d('after reflect template w: ' + this.template.width + ' ' + 'h: ' + this.template.height, 1);
    
    }
    
    private function onTemplateComplete(event:Event):void
    {
      Util.d();
      template.removeEventListener(MixtapeEvent.TEMPLATE_LOAD_COMPLETE, onTemplateComplete);
      bumper.addEventListener(MixtapeEvent.BUMPER_COMPLETE, onBumperComplete);
      this.widget_config_loaded = true;
    }
    
    private function onBumperComplete(event:Event):void
    {
      Util.d();
      bumper.removeEventListener(MixtapeEvent.BUMPER_COMPLETE, onBumperComplete);
      showTemplate();
      
      controller.menuBtn.addEventListener(MouseEvent.CLICK, onMenuSelect);

      if (this.autoplay){
        try{
          this.player.play();
        }
        catch(e:Error){
          Util.e("Problem playing track:" + e);
        }
        
        addStageRollOvers();
      }
      else{
        getFirstPlayButton();
      }
    }
		
		private function showTemplate():void
    {
      Util.d();
      this.template.visible = true;
      
      this.reflection.update(template);
      this.template.cacheAsBitmap = true;

      this.template.scaleY = template.scaleX;
    }
		
		private function playlistLoaded(event:Event):void
		{
			Util.d('playlist loaded');
			Util.d('template h: ' + this.template_height, 1);
			this.playlist_xml = (event.target as XmlLoader).xml;
			// Util.d(this.playlist_xml.trackList.track);
			this.player.loadTracks(this.playlist_xml.trackList.track);
			this.playlist_loaded = true;
		}
		
		private function getFirstPlayButton():void
    {
      Util.d();
      this.first_play_btn = new FirstPlayBtn();
      
      this.first_play_btn.x = Math.round( (this.template_width - this.first_play_btn.width) / 2) + this.template.x - 2;
      this.first_play_btn.y = Math.round( (this.template_height - this.first_play_btn.height) / 2) - this.template.y; // yeah this looks wrong, but it centers better
      Util.d('template w: ' + this.template.width + ' ' + 'h: ' + this.template.height + ' s: ' + this.template.scaleX, 1);
      Util.d('template w: ' + this.template_width + ' h: ' + this.template_height, 1);
      Util.d(this.template_height + ' ' + this.first_play_btn.height + ' ' + this.template.y, 1);
      Util.d('first_play_btn x: ' + this.first_play_btn.x + ' ' + 'y: ' + this.first_play_btn.y, 1);
      Util.d('first_play_btn w: ' + this.first_play_btn.width + ' ' + 'h: ' + this.first_play_btn.height, 1);
      
      this.addChild(this.first_play_btn);
      
      this.player.initFirstPlayButton(this.first_play_btn);
      this.first_play_btn.addEventListener(MouseEvent.CLICK, handleFirstPlay);
    }
    
    private function showWidgetAgain():void
    {
      Util.d();
      showTemplate();
      addStageRollOvers();
       
      controller.menuBtn.addEventListener(MouseEvent.CLICK, onMenuSelect);
      addEventListener(Event.ENTER_FRAME, determineShowController);
      dispatchEvent(new Event("shellLoadComplete"));
    }
    
    private function handleFirstPlay(event:MouseEvent = null):void
    {
      Util.d();
      this.first_play_btn.removeEventListener(MouseEvent.CLICK, handleFirstPlay);
      this.removeChild(this.first_play_btn);
      
      addStageRollOvers();
    }
    
    private function addStageRollOvers():void
    {
      Util.d();
      this.stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
      this.stage.addEventListener(MouseEvent.MOUSE_OVER, onStageMouseOver);
      
    }
    
    private function removeStageRollOvers():void
    {
      Util.d();
      this.stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
      this.stage.removeEventListener(MouseEvent.MOUSE_OVER, onStageMouseOver);     
    }
      
    private var controller_tween:Tween;  
    private function onStageMouseOver(event:Event):void
    {
      this.controller.enableVolumeRollover();
      this.controller.visible = true;
      this.controller_tween = new Tween(controller, "alpha", Regular.easeOut, controller.alpha, 1, 0.4, true);
      //controllerTween = new Tween(controller, "y", Regular.easeOut, controller.y, 220, 0.4, true);
    }

    private function onStageMouseLeave(event:Event):void
    {
      // Util.d();
      this.controller.disableVolumeRollover();
      this.controller.hideVolSlider();
      removeEventListener(Event.ENTER_FRAME, determineShowController);
      this.controller_tween = new Tween(controller, "alpha", Regular.easeIn, controller.alpha, 0, 0.4, true);
      //controllerTween = new Tween(controller, "y", Regular.easeOut, controller.y, 267, 0.4, true);
    }
    
    private function determineShowController(event:Event):void
    {
      removeEventListener(Event.ENTER_FRAME, determineShowController);
      if ( (mouseX < this.template.x) || (mouseX >= this.stage.width) ||
           (mouseY < this.template.y) || (mouseY >= this.stage.height))
      { 
        onStageMouseLeave(event);
      }
    }
    
    //**********************************
    //
    // WIDGET MENU
    //
    //**********************************
    
        
    private function onMenuSelect(event:MouseEvent):void
    {
      Util.d();
      Util.d("this.widget_menu_loaded = " + this.widget_menu_loaded);
      
      if (!this.widget_menu_loaded) { loadWidgetMenu(); }
      else
      {
        
        if(this.widget_menu.visible){
          Util.d("hide menu", 1);
          this.widget_menu.showWidgetMenu();
        }
        else{
          showWidgetMenu();
        }
      }

    }

    private function loadWidgetMenu():void
    {
      removeStageRollOvers();
      
      this.widget_menu_loaded  = true;
      template.visible = false;
      this.widget_menu = new Menu(this.player);
      this.widget_menu.addEventListener(AudioEvent.PLAY_TRACK, onPlaylistClick);
      this.addChildAt(this.widget_menu, this.numChildren - 1);

      //controller.menuBtn.addEventListener(MouseEvent.CLICK, onMenuSelect);
      this.widget_menu.addEventListener("onMenuClose", onWidgetMenuClosed);
    }
    
    private function onPlaylistClick(e:AudioEvent):void
    {
    	this.player.play(e.track_num);
    }
    
    private function showWidgetMenu():void
    {
      Util.d();
      template.visible = false;
      this.widget_menu.addEventListener("onMenuClose", onWidgetMenuClosed);
      this.widget_menu.showWidgetMenu();
      this.widget_menu.visible = true;
      removeStageRollOvers();
    }
    
    private function onWidgetMenuClosed(event:Event=null):void
    {
      Util.d();
      this.widget_menu.visible = false;
      showWidgetAgain();
    }
    
    // In accordance with the Mixwidget License (http://mixwidget.com/license),
    // the context menu should not be removed. Additions to the menu are permitted,
    // but the item entitled "Mixwidget v1.0 - an open source mixtape" should remain 
    // unmodified. Please contact licensing@mixwidget.com for inquiries.
    private function activateContextMenu():void
    {
    	Util.d();
    	var context_menu:ContextMenu = new ContextMenu();
      context_menu.hideBuiltInItems();
    	
    	var item:ContextMenuItem = new ContextMenuItem("Mixwidget v1.0 - an open source mixtape");
    	context_menu.customItems.push(item);
    	item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextSelect);
    	
    	this.contextMenu = context_menu;
    }
    
    // In accordance with the Mixwidget License (http://mixwidget.com/license),
    // this function should not be removed, modified or in any way inhibited from
    // executing.
    private function onContextSelect(event:ContextMenuEvent):void
    {
    	flash.net.navigateToURL(new URLRequest("http://mixwidget.com/")); 
    }
    
    // In accordance with the Mixwidget License (http://mixwidget.com/license),
    // this copyright notice should not be modified or removed. Please contact
    // licensing@mixwidget.com for inquiries.
    private function license():void{
    	trace();
      trace("######################################################################################");
      trace("# Mixwidget v1.0 - a free and open source flash mixtape widget                       #");
      trace("#                                                                                    #");
      trace("#                                  by Michael Christoff & Radley Marx                #");
      trace("######################################################################################");
      trace();
      trace("The contents of this file are subject to the Common Public Attribution");
      trace("License Version 1.0. (the \"License\"); you may not use this file except in");
      trace("compliance with the License. You may obtain a copy of the License at");
      trace("http://mixwidget.com/license. The License is based on the Mozilla Public");
      trace("License Version 1.1, but Sections 14 and 15 have been added to cover use of");
      trace("software over a computer network and provide for limited attribution for the");
      trace("Original Developer. In addition, Exhibit A has been modified to be consistent");
      trace("with Exhibit B.");
      trace();
      trace("Software distributed under the License is distributed on an \"AS IS\" basis,");
      trace("WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for");
      trace("the specific language governing rights and limitations under the License.");
      trace();
      trace("The Original Code is Mixwidget.");
      trace();
      trace("The Original Developers are Michael Christoff & Radley Marx.  The Initial"); 
      trace("Developers of the Original Code are Michael Christoff & Radley Marx");
      trace();
    }
 }   }