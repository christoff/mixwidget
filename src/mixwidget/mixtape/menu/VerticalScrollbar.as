﻿/* The contents of this file are subject to the Common Public Attribution * License Version 1.0. (the "License"); you may not use this file except in * compliance with the License. You may obtain a copy of the License at * http://mixwidget.org/license-full. The License is based on the Mozilla Public * License Version 1.1, but Sections 14 and 15 have been added to cover use of * software over a computer network and provide for limited attribution for the * Original Developer. In addition, Exhibit A has been modified to be consistent * with Exhibit B. *  * Software distributed under the License is distributed on an "AS IS" basis, * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for * the specific language governing rights and limitations under the License. *  * The Original Code is Mixwidget.org. *  * The Original Developers are Michael Christoff & Radley Marx.  The Initial  * Developers of the Original Code are Michael Christoff & Radley Marx. */package mixwidget.mixtape.menu{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;		public class VerticalScrollbar extends EventDispatcher   {		private var _track:SimpleButton;		private var _button:Sprite;		private var stage:Stage = null;				public function VerticalScrollbar(stage:Stage, track:SimpleButton, button:Sprite) 		{			this.stage = stage;			this._track = track;			this._button = button;						this._button.addEventListener(MouseEvent.MOUSE_DOWN, handleButtonDown);						this._track.addEventListener(MouseEvent.MOUSE_DOWN, handleButtonDown);					}		private var _minimum:Number = 0;		public function get minimum():Number		 {			return _minimum;		}				public function set minimum(newValue:Number):void {			_minimum = newValue;			positionButton();					}			private var _maximum:Number = 0;			public function get maximum():Number {			return _maximum;		}				public function set maximum(newValue:Number):void {			_maximum = newValue;			positionButton();		}						private var _value:Number = 0;		public function get value():Number{			return _value;		}				public function set value(newValue:Number):void {			_value = newValue;						positionButton();		}								private function positionButton():void {						_button.y =  _track.y + (value-minimum)/(maximum-minimum)*(_track.height-_button.height);		}				protected function doDrag(e:MouseEvent):void {			calculateValue(_track.mouseX, _track.mouseY);		}						protected function calculateValue(myX:Number, myY:Number):void		{			if ( myX < -15 || myX > (_track.width+10) ) {							stage.removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);				stage.removeEventListener(MouseEvent.MOUSE_UP, handleButtonUp);						return;			}							if (myY < 0 || myY > _track.height)				return;							var newValue:Number = (myY-_button.height/2)/(_track.height-_button.height)*(maximum-minimum);			doSetValue(newValue);		}				protected function doSetValue(newValue:Number):void {			var oldVal:Number = _value;						// new value			_value = Math.max(minimum, Math.min(maximum, Math.round( newValue )));			dispatchEvent(new GenericScrollbarEvent(GenericScrollbarEvent.CHANGE, value));									positionButton();					}				private function handleButtonDown(e:MouseEvent):void{			calculateValue(_track.mouseX, _track.mouseY);										stage.addEventListener(MouseEvent.MOUSE_MOVE, doDrag,false,0,true);			stage.addEventListener(MouseEvent.MOUSE_UP, handleButtonUp,false,0,true);		}				private function handleButtonUp(e:MouseEvent):void {			stage.removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);			stage.removeEventListener(MouseEvent.MOUSE_UP, handleButtonUp);									// fire change event			dispatchEvent(new GenericScrollbarEvent(GenericScrollbarEvent.CHANGE, value));		}	}}