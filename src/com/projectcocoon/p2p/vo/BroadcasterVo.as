package com.projectcocoon.p2p.vo
{
	import flash.media.Camera;
	import flash.media.Microphone;

	public class BroadcasterVo
	{
		public var camera			:	Camera;
		public var microphone		:	Microphone;
		public var broadcasterUID 	:	String;
		public var requesterUID		:	String;
		public var deviceType		:   String;
		public var broadcasterHasTwoCameras:Boolean;
		
		public function BroadcasterVo(microphone:Microphone, camera:Camera, broadcasterUID:String = null, toRequesterID:String = null, broadcasterHasTwoCameras:Boolean = false)
		{
			this.microphone  	 = microphone;
			this.camera		 	 = camera;
			this.broadcasterUID  = broadcasterUID;
			this.requesterUID	 = toRequesterID;
			this.broadcasterHasTwoCameras	= broadcasterHasTwoCameras;
		}
	}
}