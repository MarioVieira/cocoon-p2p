package com.projectcocoon.p2p.vo
{
	public class ObjectMetadataVO
	{
		public var identifier:String;
		public var size:uint;
		public var chunks:uint;
		public var info:Object;
		
		[Transient]
		public var chunksReceived:int;
		
		[Transient]
		public var object:Object;
		
		public function ObjectMetadataVO()
		{
			chunksReceived = 0;
		}
		
		public function get progress():Number
		{
			if (chunks > 0)
				return chunksReceived / chunks;
			return 0;
		}
		
		public function get isComplete():Boolean
		{
			return progress == 1;
		}
	}
}