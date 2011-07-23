package com.projectcocoon.p2p.vo
{
	
	[Bindable]
	public class ClientVO
	{
		
		public var clientName:String;
		public var peerID:String;
		public var groupID:String;
		public var deviceType:String;
		public var clientUID:String;
		
		[Transient]
		public var isLocal:Boolean;
		
		public function ClientVO(_clientName:String = null, _peerID:String = null, _groupID:String = null, _clientUID:String = null, _deviceType:String = null)
		{
			clientName = _clientName;
			peerID = _peerID;
			groupID = _groupID;
			deviceType = _deviceType;
			clientUID = _clientUID;
		}
		
		
	}
}