package com.projectcocoon.p2p.events
{
	import com.projectcocoon.p2p.vo.MediaVO;
	
	import flash.events.Event;
	
	public class MediaBroadcastEvent extends Event
	{									 
		public static const MEDIA_BROADCAST:String = "mediaBroadcast";

		public var mediaInfo:MediaVO;
		
		public function MediaBroadcastEvent(type:String, mediaInfo:MediaVO)
		{
			super(type);
			this.mediaInfo = mediaInfo;
		}
		
		override public function clone():Event
		{
			return new MediaBroadcastEvent(MEDIA_BROADCAST, mediaInfo);	
		}
	}
}