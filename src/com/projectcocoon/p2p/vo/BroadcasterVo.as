package com.projectcocoon.p2p.vo
{
	import flash.media.Camera;
	import flash.media.Microphone;

	public class BroadcasterVo
	{
		public var camera		:	Camera;
		public var microphone	:	Microphone;
		
		public function BroadcasterVo(microphone:Microphone, camera:Camera)
		{
			this.microphone  = microphone;
			this.camera		 = camera;
		}
	}
}