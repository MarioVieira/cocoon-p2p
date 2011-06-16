package com.projectcocoon.p2p.events
{
	import flash.events.Event;
	import flash.net.NetGroup;
	
	public class NetworkEvent extends Event
	{
		public static const NETWORK_CHANGE:String = "networkChange";
		
		public var info:String;
		public var group:NetGroup;
		
		public function NetworkEvent(type:String, info:String)
		{
			super(type);
			this.info = info;
		}
		
		public override function clone():Event
		{
			return new NetworkEvent(type, info);
		}
		
		
	}
}