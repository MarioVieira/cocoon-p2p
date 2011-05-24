package com.projectcocoon.p2p.vo
{
	public class GroupInfoVO
	{
		public var peerIds:Vector.<String>;
		public var clients:Vector.<ClientVO>;
		public var groupSpec:String;
		
		public function GroupInfoVO(groupSpec:String)
		{
			this.groupSpec = groupSpec;
			peerIds = new Vector.<String>();
			clients = new Vector.<ClientVO>();
		}
	}
}